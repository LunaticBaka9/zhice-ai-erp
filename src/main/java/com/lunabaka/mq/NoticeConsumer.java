package com.lunabaka.mq;

import com.lunabaka.config.RabbitConfig;
import com.lunabaka.entity.Notice;
import jakarta.annotation.Resource;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Map;

@Slf4j
@Component
public class NoticeConsumer {

    @Resource
    private SimpMessagingTemplate messagingTemplate;

    @RabbitListener(queues = RabbitConfig.QUEUE_NOTICE)
    public void handleNotice(Notice notice) {
        log.info("收到通知消息: {}", notice.getTitle());

        Map<String, Object> payload = new HashMap<>();
        payload.put("action", "new");
        payload.put("nid", notice.getNid());
        payload.put("title", notice.getTitle());
        payload.put("type", notice.getType());
        payload.put("summary", notice.getSummary());
        payload.put("author", notice.getAuthor());
        payload.put("publishDate", notice.getPublishDate());

        messagingTemplate.convertAndSend("/topic/notices", (Object) payload);
        log.info("WebSocket通知推送成功");
    }
}
