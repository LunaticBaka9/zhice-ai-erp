package com.lunabaka.service;

import com.lunabaka.entity.Notice;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

@Service
public class NoticeWebSocketService {

    private final SimpMessagingTemplate messagingTemplate;

    public NoticeWebSocketService(SimpMessagingTemplate messagingTemplate) {
        this.messagingTemplate = messagingTemplate;
    }

    public void notifyNewNotice(Notice notice) {
        Map<String, Object> payload = new HashMap<>();
        payload.put("action", "new");
        payload.put("nid", notice.getNid());
        payload.put("title", notice.getTitle());
        payload.put("type", notice.getType());
        payload.put("summary", notice.getSummary());
        payload.put("author", notice.getAuthor());
        payload.put("publishDate", notice.getPublishDate());
        messagingTemplate.convertAndSend("/topic/notices", (Object) payload);
    }

    public void notifyUpdateNotice(Notice notice) {
        Map<String, Object> payload = new HashMap<>();
        payload.put("action", "update");
        payload.put("nid", notice.getNid());
        payload.put("title", notice.getTitle());
        messagingTemplate.convertAndSend("/topic/notices", (Object) payload);
    }

    public void notifyDeleteNotice(Long nid) {
        Map<String, Object> payload = new HashMap<>();
        payload.put("action", "delete");
        payload.put("nid", nid);
        messagingTemplate.convertAndSend("/topic/notices", (Object) payload);
    }
}
