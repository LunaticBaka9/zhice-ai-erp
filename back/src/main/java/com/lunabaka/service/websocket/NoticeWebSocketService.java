package com.lunabaka.service.websocket;

import com.lunabaka.config.RabbitConfig;
import com.lunabaka.entity.Notice;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.stereotype.Service;

import jakarta.annotation.Resource;

@Slf4j
@Service
public class NoticeWebSocketService {

    @Resource
    private RabbitTemplate rabbitTemplate;

    public void notifyNewNotice(Notice notice) {
        rabbitTemplate.convertAndSend(RabbitConfig.EXCHANGE, RabbitConfig.ROUTING_KEY_NOTICE, notice);
        log.info("通知已发送到RabbitMQ队列: {}", notice.getTitle());
    }

    public void notifyUpdateNotice(Notice notice) {
        rabbitTemplate.convertAndSend(RabbitConfig.EXCHANGE, RabbitConfig.ROUTING_KEY_NOTICE, notice);
        log.info("通知更新已发送到RabbitMQ队列: {}", notice.getTitle());
    }

    public void notifyDeleteNotice(Long nid) {
        Notice notice = new Notice();
        notice.setNid(nid);
        rabbitTemplate.convertAndSend(RabbitConfig.EXCHANGE, RabbitConfig.ROUTING_KEY_NOTICE, notice);
        log.info("通知删除已发送到RabbitMQ队列: nid={}", nid);
    }
}
