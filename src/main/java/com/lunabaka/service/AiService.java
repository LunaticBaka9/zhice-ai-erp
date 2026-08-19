package com.lunabaka.service;

import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.lunabaka.entity.AiConversation;
import com.lunabaka.entity.AiMessage;
import com.lunabaka.mapper.AiConversationMapper;
import com.lunabaka.mapper.AiMessageMapper;
import jakarta.annotation.Resource;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;
import java.util.UUID;

@Slf4j
@Service
public class AiService {

    private final ChatClient chatClient;

    @Resource
    private AiConversationMapper conversationMapper;

    @Resource
    private AiMessageMapper aiMessageMapper;

    public AiService(ChatModel chatModel) {
        this.chatClient = ChatClient.builder(chatModel)
                .defaultSystem("你是一个进销存ERP系统的AI助手，名叫「智策AI」。" +
                        "你可以帮助用户分析库存、销售、采购等业务数据，提供经营建议，" +
                        "解答系统使用问题。请用中文回答，语言简洁专业。")
                .build();
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

    public String chat(String conversationId, String message) {
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

        String reply = chatClient.prompt()
                .user(fullPrompt)
                .call()
                .content();

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
