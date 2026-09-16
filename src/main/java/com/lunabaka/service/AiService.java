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

    private static final String API_KEY_REDIS_PREFIX = "ai:apikey:";
    private static final String DEFAULT_SYSTEM_PROMPT = "你是一个进销存ERP系统的AI助手，名叫「智策AI」。" +
            "你可以帮助用户分析库存、销售、采购等业务数据，提供经营建议，" +
            "解答系统使用问题。请用中文回答，语言简洁专业。";

    @Resource
    private AiConversationMapper conversationMapper;

    @Resource
    private AiMessageMapper aiMessageMapper;

    @Resource
    private RedisTemplate<String, Object> redisTemplate;

    private final Map<String, ChatClient> chatClientCache = new ConcurrentHashMap<>();

    public void saveApiKey(String userId, String apiKey) {
        if (userId == null || userId.isEmpty()) {
            throw new CustomerException("用户未登录");
        }
        if (apiKey == null || apiKey.trim().isEmpty()) {
            throw new CustomerException("API Key不能为空");
        }
        redisTemplate.opsForValue().set(API_KEY_REDIS_PREFIX + userId, apiKey.trim());
        chatClientCache.remove(userId);
    }

    public boolean hasApiKey(String userId) {
        if (userId == null || userId.isEmpty()) {
            return false;
        }
        Object value = redisTemplate.opsForValue().get(API_KEY_REDIS_PREFIX + userId);
        return value != null && !value.toString().isEmpty();
    }

    public void removeApiKey(String userId) {
        if (userId != null && !userId.isEmpty()) {
            redisTemplate.delete(API_KEY_REDIS_PREFIX + userId);
            chatClientCache.remove(userId);
        }
    }

    private ChatClient getChatClient(String userId) {
        ChatClient client = chatClientCache.get(userId);
        if (client != null) {
            return client;
        }

        Object apiKeyObj = redisTemplate.opsForValue().get(API_KEY_REDIS_PREFIX + userId);
        if (apiKeyObj == null || apiKeyObj.toString().isEmpty()) {
            throw new CustomerException("请先配置 DeepSeek API Key");
        }

        DeepSeekApi deepSeekApi = DeepSeekApi.builder()
                .baseUrl(DeepSeekConstants.DEFAULT_BASE_URL)
                .apiKey(apiKeyObj.toString())
                .build();
        DeepSeekChatModel chatModel = DeepSeekChatModel.builder()
                .deepSeekApi(deepSeekApi)
                .build();
        client = ChatClient.builder(chatModel)
                .defaultSystem(DEFAULT_SYSTEM_PROMPT)
                .build();
        chatClientCache.put(userId, client);
        return client;
    }

    public AiConversation createConversation(String title, String userId) {
        AiConversation conversation = new AiConversation();
        conversation.setConversationId(UUID.randomUUID().toString().replace("-", ""));
        conversation.setTitle(title);
        conversation.setUserId(userId);
        conversation.setCreateTime(new Date());
        conversation.setUpdateTime(new Date());
        conversationMapper.insert(conversation);
        return conversation;
    }

    public String chat(String userId, String conversationId, String message) {
        ChatClient client = getChatClient(userId);

        List<AiMessage> historyMessages = aiMessageMapper.selectList(
                Wrappers.<AiMessage>lambdaQuery()
                        .eq(AiMessage::getConversationId, conversationId)
                        .orderByAsc(AiMessage::getCreateTime)
        );

        StringBuilder history = new StringBuilder();
        for (AiMessage msg : historyMessages) {
            if ("user".equals(msg.getRole())) {
                history.append("用户: ").append(msg.getContent()).append("\n");
            } else {
                history.append("AI: ").append(msg.getContent()).append("\n");
            }
        }

        String fullPrompt;
        if (!history.isEmpty()) {
            fullPrompt = "之前的对话上下文:\n" + history + "\n\n用户新消息: " + message;
        } else {
            fullPrompt = message;
        }

        AiMessage userMsg = new AiMessage();
        userMsg.setConversationId(conversationId);
        userMsg.setRole("user");
        userMsg.setContent(message);
        userMsg.setCreateTime(new Date());
        aiMessageMapper.insert(userMsg);

        String reply;
        try {
            reply = client.prompt()
                    .user(fullPrompt)
                    .call()
                    .content();
        } catch (CustomerException e) {
            throw e;
        } catch (Exception e) {
            log.error("DeepSeek 调用失败", e);
            throw new CustomerException("AI 调用失败，请检查 API Key 是否有效后重试");
        }

        AiMessage aiMsg = new AiMessage();
        aiMsg.setConversationId(conversationId);
        aiMsg.setRole("assistant");
        aiMsg.setContent(reply);
        aiMsg.setCreateTime(new Date());
        aiMessageMapper.insert(aiMsg);

        conversationMapper.update(null,
                Wrappers.<AiConversation>lambdaUpdate()
                        .eq(AiConversation::getConversationId, conversationId)
                        .set(AiConversation::getUpdateTime, new Date())
        );

        return reply;
    }

    public List<AiConversation> getConversations(String userId) {
        return conversationMapper.selectList(
                Wrappers.<AiConversation>lambdaQuery()
                        .eq(userId != null, AiConversation::getUserId, userId)
                        .orderByDesc(AiConversation::getUpdateTime)
        );
    }

    public List<AiMessage> getMessages(String conversationId) {
        return aiMessageMapper.selectList(
                Wrappers.<AiMessage>lambdaQuery()
                        .eq(AiMessage::getConversationId, conversationId)
                        .orderByAsc(AiMessage::getCreateTime)
        );
    }

    public void deleteConversation(String conversationId) {
        aiMessageMapper.delete(
                Wrappers.<AiMessage>lambdaQuery()
                        .eq(AiMessage::getConversationId, conversationId)
        );
        conversationMapper.delete(
                Wrappers.<AiConversation>lambdaQuery()
                        .eq(AiConversation::getConversationId, conversationId)
        );
    }

    public void renameConversation(String conversationId, String title) {
        conversationMapper.update(null,
                Wrappers.<AiConversation>lambdaUpdate()
                        .eq(AiConversation::getConversationId, conversationId)
                        .set(AiConversation::getTitle, title)
                        .set(AiConversation::getUpdateTime, new Date())
        );
    }
}