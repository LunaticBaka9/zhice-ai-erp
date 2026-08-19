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

    @PostMapping("/chat")
    public Result chat(@RequestBody Map<String, Object> request,
                       @RequestAttribute(required = false) String userId) {
        String message = (String) request.get("message");
        String conversationId = (String) request.get("conversationId");

        if (message == null || message.trim().isEmpty()) {
            return Result.error("消息内容不能为空");
        }

        if (conversationId == null || conversationId.isEmpty()) {
            String title = message.length() > 30 ? message.substring(0, 30) + "..." : message;
            AiConversation conversation = aiService.createConversation(title, userId);
            conversationId = conversation.getConversationId();
        }

        String reply = aiService.chat(conversationId, message.trim());

        Map<String, Object> data = new HashMap<>();
        data.put("content", reply);
        data.put("conversationId", conversationId);

        return Result.success(data);
    }

    @GetMapping("/conversations")
    public Result getConversations(@RequestAttribute(required = false) String userId) {
        List<AiConversation> conversations = aiService.getConversations(userId);
        return Result.success(conversations);
    }

    @GetMapping("/conversation/{conversationId}")
    public Result getConversationMessages(@PathVariable String conversationId) {
        List<AiMessage> messages = aiService.getMessages(conversationId);
        return Result.success(messages);
    }

    @PostMapping("/conversation/create")
    public Result createConversation(@RequestBody Map<String, String> request,
                                     @RequestAttribute(required = false) String userId) {
        String title = request.getOrDefault("title", "新对话");
        AiConversation conversation = aiService.createConversation(title, userId);
        return Result.success(conversation);
    }

    @PostMapping("/conversation/delete")
    public Result deleteConversation(@RequestBody Map<String, String> request) {
        String conversationId = request.get("conversationId");
        if (conversationId == null || conversationId.isEmpty()) {
            return Result.error("会话ID不能为空");
        }
        aiService.deleteConversation(conversationId);
        return Result.success();
    }

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
