package com.lunabaka.service.websocket;

import com.lunabaka.entity.Notice;
import jakarta.annotation.Resource;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

@Slf4j
@Service
public class NoticeWebSocketService {

    @Resource
    private SimpMessagingTemplate messagingTemplate;

    public void notifyNewNotice(Notice notice) {
        sendNotice("new", notice);
    }

    public void notifyUpdateNotice(Notice notice) {
        sendNotice("update", notice);
    }

    public void notifyDeleteNotice(Long nid) {
        Map<String, Object> payload = new HashMap<>();
        payload.put("action", "delete");
        payload.put("nid", nid);
        messagingTemplate.convertAndSend("/topic/notices", (Object) payload);
        log.info("WebSocket通知推送成功: nid={}", nid);
    }

    private void sendNotice(String action, Notice notice) {
        Map<String, Object> payload = new HashMap<>();
        payload.put("action", action);
        payload.put("nid", notice.getNid());
        payload.put("title", notice.getTitle());
        payload.put("type", notice.getType());
        payload.put("summary", notice.getSummary());
        payload.put("author", notice.getAuthor());
        payload.put("publishDate", notice.getPublishDate());
        messagingTemplate.convertAndSend("/topic/notices", (Object) payload);
        log.info("WebSocket通知推送成功: {}", notice.getTitle());
    }
}
