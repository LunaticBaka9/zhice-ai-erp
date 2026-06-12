package com.lunabaka.config;

import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {
    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry){
        // 客户端建立 WebSocket 连接的端点
        registry.addEndpoint("/zhice-erp").setAllowedOriginPatterns("*").withSockJS();
    }

    @Override
    public void configureMessageBroker(MessageBrokerRegistry registry){
        // 启用简单的内存消息代理，前端订阅以 /topic 开头的消息
        registry.enableSimpleBroker("/topic");
        // 后端接收前端消息的前缀
        registry.setApplicationDestinationPrefixes("/app");
    }
}
