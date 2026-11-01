package com.lunabaka.service;

import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.lunabaka.entity.AiConversation;
import com.lunabaka.entity.AiMessage;
import com.lunabaka.exception.CustomerException;
import com.lunabaka.mapper.AiConversationMapper;
import com.lunabaka.mapper.AiMessageMapper;
import jakarta.annotation.Resource;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.deepseek.DeepSeekChatModel;
import org.springframework.ai.deepseek.api.DeepSeekApi;
import org.springframework.ai.deepseek.api.common.DeepSeekConstants;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Slf4j
@Service
public class AiService {

    /* ==================== 常量与依赖 ==================== */

    /**
     * Redis 中存储“每个用户 DeepSeek API Key”的 key 前缀。
     * <p>
     * 完整 key 形如：ai:apikey:{userId}，value 为真实的 api-key 字符串。
     * 这样做的好处：
     * 1. api-key 不再写死在 yml 配置文件中（避免泄漏、避免启动时校验失败）；
     * 2. 每个登录用户可以有自己独立的 key；3. 保存在 Redis 中，服务重启后不丢失。
     */
    private static final String API_KEY_REDIS_PREFIX = "ai:apikey:";

    /**
     * 系统提示词（System Prompt）：用来限定 AI 助手的角色与回答风格。
     * <p>
     * 每一份动态构建的 ChatClient 都会带上该提示词，保证不同用户的回答风格一致。
     */
    private static final String DEFAULT_SYSTEM_PROMPT = "你是一个进销存ERP系统的AI助手，名叫「智策AI」。" +
            "你可以帮助用户分析库存、销售、采购等业务数据，提供经营建议，" +
            "解答系统使用问题。请用中文回答，语言简洁专业。";

    @Resource
    private AiConversationMapper conversationMapper;

    @Resource
    private AiMessageMapper aiMessageMapper;

    @Resource
    private RedisTemplate<String, Object> redisTemplate;

    /**
     * 内存缓存：userId -> ChatClient。
     * <p>
     * 每次请求都重新构建 DeepSeekChatModel / ChatClient 会带来不必要的开销
     * （内部会创建 RestClient、WebClient 等重量级组件），因此按用户做缓存。
     * 当用户更新或删除 api-key 时，会主动移除对应缓存项，下次调用时按新 key 重建。
     */
    private final Map<String, ChatClient> chatClientCache = new ConcurrentHashMap<>();

    /* ==================== API Key 管理 ==================== */

    /**
     * 保存（覆盖）当前用户的 DeepSeek API Key。
     * <p>
     * 供前端“API Key 设置”弹窗调用：写入 Redis 并清除该用户的 ChatClient 缓存，
     * 确保下一次聊天使用最新的 key。
     *
     * @param userId  当前登录用户（来自 JWT 拦截器放入的 request attribute）
     * @param apiKey  用户输入的 api-key，会去除首尾空格后存储
     */
    public void saveApiKey(String userId, String apiKey) {
        if (userId == null || userId.isEmpty()) {
            throw new CustomerException("用户未登录");
        }
        if (apiKey == null || apiKey.trim().isEmpty()) {
            throw new CustomerException("API Key不能为空");
        }
        // 写入 Redis：ai:apikey:{userId} -> api-key
        redisTemplate.opsForValue().set(API_KEY_REDIS_PREFIX + userId, apiKey.trim());
        // 失效缓存，下次会话会基于新 key 重建 ChatClient
        chatClientCache.remove(userId);
    }

    /**
     * 查询当前用户是否已经配置过 API Key。
     * <p>
     * 供前端在初始化时调用来点亮“API Key 设置”图标的配置状态。
     *
     * @param userId 当前登录用户
     * @return true 表示已配置有效的 api-key（非空）
     */
    public boolean hasApiKey(String userId) {
        if (userId == null || userId.isEmpty()) {
            return false;
        }
        Object value = redisTemplate.opsForValue().get(API_KEY_REDIS_PREFIX + userId);
        return value != null && !value.toString().isEmpty();
    }

    /**
     * 删除当前用户已配置的 API Key。
     * <p>
     * 从 Redis 中移除并清理内存缓存，删除后再次聊天会提示“请先配置 DeepSeek API Key”。
     *
     * @param userId 当前登录用户
     */
    public void removeApiKey(String userId) {
        if (userId != null && !userId.isEmpty()) {
            redisTemplate.delete(API_KEY_REDIS_PREFIX + userId);
            chatClientCache.remove(userId);
        }
    }

    /**
     * 根据当前用户的 api-key 获取（或构建）一个可复用的 ChatClient。
     * <p>
     * 核心逻辑：从 Redis 读取该用户的 api-key → 动态构建 DeepSeekApi →
     * 构建 DeepSeekChatModel → 包装成带系统提示词的 ChatClient，并放入缓存。
     * 由于项目启动时已排除 DeepSeek 自动配置（ProjectApplication 中的 exclude），
     * 所以这里完全不依赖配置文件中的任何 api-key，启动阶段也不会做 key 校验。
     *
     * @param userId 当前登录用户
     * @return 带默认系统提示词的 ChatClient
     * @throws CustomerException 用户未配置 api-key 时抛出，由全局异常处理器转为友好提示
     */
    private ChatClient getChatClient(String userId) {
        // 命中缓存直接返回，避免重复构建重量级客户端
        ChatClient client = chatClientCache.get(userId);
        if (client != null) {
            return client;
        }

        // 从 Redis 读取该用户的 api-key，未配置则提示用户先在前端设置
        Object apiKeyObj = redisTemplate.opsForValue().get(API_KEY_REDIS_PREFIX + userId);
        if (apiKeyObj == null || apiKeyObj.toString().isEmpty()) {
            throw new CustomerException("请先配置 DeepSeek API Key");
        }

        // 1. 构建 DeepSeek 客户端：指定官方接口地址（DeepSeekConstants.DEFAULT_BASE_URL 即
        //    https://api.deepseek.com，其接口兼容 OpenAI 协议）并携带用户自己的 api-key
        DeepSeekApi deepSeekApi = DeepSeekApi.builder()
                .baseUrl(DeepSeekConstants.DEFAULT_BASE_URL)
                .apiKey(apiKeyObj.toString())
                .build();

        // 2. 基于 DeepSeekApi 构建聊天模型（模型名等选项取框架默认值）
        DeepSeekChatModel chatModel = DeepSeekChatModel.builder()
                .deepSeekApi(deepSeekApi)
                .build();

        // 3. 包装为 Spring AI 的 ChatClient，并固定注入系统提示词
        client = ChatClient.builder(chatModel)
                .defaultSystem(DEFAULT_SYSTEM_PROMPT)
                .build();

        // 4. 放入内存缓存，供后续对话直接复用
        chatClientCache.put(userId, client);
        return client;
    }

    /* ==================== 会话/对话管理 ==================== */

    /**
     * 创建新对话。
     *
     * @param title  对话标题
     * @param userId 当前登录用户
     * @return 已落库的新对话实体（含 conversationId）
     */
    public AiConversation createConversation(String title, String userId) {
        AiConversation conversation = new AiConversation();
        // 生成 32 位无横线的 UUID 作为对外使用的会话 ID
        conversation.setConversationId(UUID.randomUUID().toString().replace("-", ""));
        conversation.setTitle(title);
        conversation.setUserId(userId);
        conversation.setCreateTime(new Date());
        conversation.setUpdateTime(new Date());
        conversationMapper.insert(conversation);
        return conversation;
    }

    /**
     * 发送一条消息并获取 AI 回复（非流式）。
     * <p>
     * 流程：取该用户的 ChatClient → 读取历史消息拼装上下文 → 保存用户消息 →
     * 调用 DeepSeek 获取回复 → 保存 AI 回复 → 更新会话时间。
     *
     * @param userId         当前登录用户，用于获取其专属 api-key 动态构建 ChatClient
     * @param conversationId 会话 ID
     * @param message        用户输入的消息
     * @return AI 的回复内容
     */
    public String chat(String userId, String conversationId, String message) {
        // 先解析该用户的 ChatClient：若未配置 api-key，会抛出异常并提示前端弹出设置框
        ChatClient client = getChatClient(userId);

        // 查询该会话的历史消息（按时间升序），用于维持多轮对话的上下文
        List<AiMessage> historyMessages = aiMessageMapper.selectList(
                Wrappers.<AiMessage>lambdaQuery()
                        .eq(AiMessage::getConversationId, conversationId)
                        .orderByAsc(AiMessage::getCreateTime)
        );

        // 把历史消息拼装成纯文本上下文
        StringBuilder history = new StringBuilder();
        for (AiMessage msg : historyMessages) {
            if ("user".equals(msg.getRole())) {
                history.append("用户: ").append(msg.getContent()).append("\n");
            } else {
                history.append("AI: ").append(msg.getContent()).append("\n");
            }
        }

        // 有历史则带上历史上下文，否则直接使用新消息
        String fullPrompt;
        if (!history.isEmpty()) {
            fullPrompt = "之前的对话上下文:\n" + history + "\n\n用户新消息: " + message;
        } else {
            fullPrompt = message;
        }

        // 先把用户消息落库
        AiMessage userMsg = new AiMessage();
        userMsg.setConversationId(conversationId);
        userMsg.setRole("user");
        userMsg.setContent(message);
        userMsg.setCreateTime(new Date());
        aiMessageMapper.insert(userMsg);

        // 调用 DeepSeek 模型获取回复
        String reply;
        try {
            reply = client.prompt()
                    .user(fullPrompt)
                    .call()
                    .content();
        } catch (CustomerException e) {
            // 自定义异常直接向上抛出（例如未配置 key），交给全局异常处理器转为友好提示
            throw e;
        } catch (Exception e) {
            // 模型调用失败（如 key 无效、余额不足、网络异常等），统一包装为友好错误
            log.error("DeepSeek 调用失败", e);
            throw new CustomerException("AI 调用失败，请检查 API Key 是否有效后重试");
        }

        // 保存 AI 回复
        AiMessage aiMsg = new AiMessage();
        aiMsg.setConversationId(conversationId);
        aiMsg.setRole("assistant");
        aiMsg.setContent(reply);
        aiMsg.setCreateTime(new Date());
        aiMessageMapper.insert(aiMsg);

        // 更新会话的最后更新时间
        conversationMapper.update(null,
                Wrappers.<AiConversation>lambdaUpdate()
                        .eq(AiConversation::getConversationId, conversationId)
                        .set(AiConversation::getUpdateTime, new Date())
        );

        return reply;
    }

    /**
     * 获取某用户的历史会话列表（按最后更新时间倒序）。
     *
     * @param userId 当前登录用户
     * @return 会话列表
     */
    public List<AiConversation> getConversations(String userId) {
        return conversationMapper.selectList(
                Wrappers.<AiConversation>lambdaQuery()
                        .eq(userId != null, AiConversation::getUserId, userId)
                        .orderByDesc(AiConversation::getUpdateTime)
        );
    }

    /**
     * 获取指定会话下的全部消息（按时间升序）。
     *
     * @param conversationId 会话 ID
     * @return 消息列表
     */
    public List<AiMessage> getMessages(String conversationId) {
        return aiMessageMapper.selectList(
                Wrappers.<AiMessage>lambdaQuery()
                        .eq(AiMessage::getConversationId, conversationId)
                        .orderByAsc(AiMessage::getCreateTime)
        );
    }

    /**
     * 删除指定会话（级联删除其下所有消息）。
     *
     * @param conversationId 会话 ID
     */
    public void deleteConversation(String conversationId) {
        // 先删除该会话的全部历史消息，再删除会话本身
        aiMessageMapper.delete(
                Wrappers.<AiMessage>lambdaQuery()
                        .eq(AiMessage::getConversationId, conversationId)
        );
        conversationMapper.delete(
                Wrappers.<AiConversation>lambdaQuery()
                        .eq(AiConversation::getConversationId, conversationId)
        );
    }

    /**
     * 重命名会话标题。
     *
     * @param conversationId 会话 ID
     * @param title          新标题
     */
    public void renameConversation(String conversationId, String title) {
        conversationMapper.update(null,
                Wrappers.<AiConversation>lambdaUpdate()
                        .eq(AiConversation::getConversationId, conversationId)
                        .set(AiConversation::getTitle, title)
                        .set(AiConversation::getUpdateTime, new Date())
        );
    }
}