package com.lunabaka.controller;

import com.lunabaka.common.Result;
import com.lunabaka.entity.AiConversation;
import com.lunabaka.entity.AiMessage;
import com.lunabaka.service.AiService;
import jakarta.annotation.Resource;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/ai")
public class AiController {

    @Resource
    private AiService aiService;

    /**
     * 聊天接口：发送消息并返回 AI 回复（非流式）。
     * <p>
     * 若请求未携带 conversationId，则自动以消息内容的前 30 个字符作为标题创建新会话。
     * userId 由 JwtInterceptor 在请求前置处理时放入 request attribute，未登录时为 null。
     *
     * @param request  请求体：{ message, conversationId }
     * @param userId   当前登录用户（拦截器注入）
     * @return 形如 { content, conversationId } 的返回数据
     */
    @PostMapping("/chat")
    public Result chat(@RequestBody Map<String, Object> request,
                       @RequestAttribute(required = false) String userId) {
        String message = (String) request.get("message");
        String conversationId = (String) request.get("conversationId");

        if (message == null || message.trim().isEmpty()) {
            return Result.error("消息内容不能为空");
        }

        // 没有会话 ID 时自动创建新会话
        if (conversationId == null || conversationId.isEmpty()) {
            String title = message.length() > 30 ? message.substring(0, 30) + "..." : message;
            AiConversation conversation = aiService.createConversation(title, userId);
            conversationId = conversation.getConversationId();
        }

        String reply = aiService.chat(userId, conversationId, message.trim());

        Map<String, Object> data = new HashMap<>();
        data.put("content", reply);
        data.put("conversationId", conversationId);

        return Result.success(data);
    }

    /**
     * 保存当前用户的 DeepSeek API Key。
     * <p>
     * 用户在前端“API Key 设置”弹窗中输入 key 后调用，key 会按用户维度存入 Redis，
     * 不再写入任何配置文件。
     *
     * @param request 请求体：{ apiKey }
     * @param userId  当前登录用户（拦截器注入）
     */
    @PostMapping("/api-key")
    public Result saveApiKey(@RequestBody Map<String, String> request,
                             @RequestAttribute(required = false) String userId) {
        aiService.saveApiKey(userId, request.get("apiKey"));
        return Result.success();
    }

    /**
     * 查询当前用户是否已配置 API Key。
     * <p>
     * 前端页面初始化时调用，用于点亮/置灰“API Key 设置”图标的已配置状态。
     *
     * @param userId 当前登录用户（拦截器注入）
     * @return 形如 { configured: true|false } 的返回数据
     */
    @GetMapping("/api-key/status")
    public Result apiKeyStatus(@RequestAttribute(required = false) String userId) {
        Map<String, Object> data = new HashMap<>();
        data.put("configured", aiService.hasApiKey(userId));
        return Result.success(data);
    }

    /**
     * 删除当前用户已配置的 API Key。
     *
     * @param userId 当前登录用户（拦截器注入）
     */
    @DeleteMapping("/api-key")
    public Result removeApiKey(@RequestAttribute(required = false) String userId) {
        aiService.removeApiKey(userId);
        return Result.success();
    }

    /**
     * 获取当前用户的历史会话列表（按最后更新时间倒序）。
     *
     * @param userId 当前登录用户
     * @return 会话列表
     */
    @GetMapping("/conversations")
    public Result getConversations(@RequestAttribute(required = false) String userId) {
        List<AiConversation> conversations = aiService.getConversations(userId);
        return Result.success(conversations);
    }

    /**
     * 获取指定会话下的全部消息（按时间升序）。
     *
     * @param conversationId 会话 ID
     * @return 消息列表
     */
    @GetMapping("/conversation/{conversationId}")
    public Result getConversationMessages(@PathVariable String conversationId) {
        List<AiMessage> messages = aiService.getMessages(conversationId);
        return Result.success(messages);
    }

    /**
     * 手动创建新会话（与聊天接口自动建会话互补）。
     *
     * @param request 请求体：{ title }
     * @param userId  当前登录用户
     * @return 新建的会话实体
     */
    @PostMapping("/conversation/create")
    public Result createConversation(@RequestBody Map<String, String> request,
                                     @RequestAttribute(required = false) String userId) {
        String title = request.getOrDefault("title", "新对话");
        AiConversation conversation = aiService.createConversation(title, userId);
        return Result.success(conversation);
    }

    /**
     * 删除指定会话（级联删除其全部消息）。
     *
     * @param request 请求体：{ conversationId }
     */
    @PostMapping("/conversation/delete")
    public Result deleteConversation(@RequestBody Map<String, String> request) {
        String conversationId = request.get("conversationId");
        if (conversationId == null || conversationId.isEmpty()) {
            return Result.error("会话ID不能为空");
        }
        aiService.deleteConversation(conversationId);
        return Result.success();
    }

    /**
     * 重命名会话标题。
     *
     * @param request 请求体：{ conversationId, title }
     */
    @PostMapping("/conversation/rename")
    public Result renameConversation(@RequestBody Map<String, String> request) {
        String conversationId = request.get("conversationId");
        String title = request.get("title");
        if (conversationId == null || title == null) {
            return Result.error("参数不完整");
        }
        aiService.renameConversation(conversationId, title);
        return Result.success();
    }
}
