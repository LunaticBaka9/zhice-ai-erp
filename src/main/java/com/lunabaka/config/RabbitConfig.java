package com.lunabaka.config;

import org.springframework.amqp.core.*;
import org.springframework.amqp.support.converter.Jackson2JsonMessageConverter;
import org.springframework.amqp.support.converter.MessageConverter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class RabbitConfig {

    // 队列名称
    public static final String QUEUE_LOG = "erp.log.queue";
    public static final String QUEUE_NOTICE = "erp.notice.queue";

    // 交换机名称
    public static final String EXCHANGE = "erp.exchange";

    // 路由键
    public static final String ROUTING_KEY_LOG = "log.routing-key";
    public static final String ROUTING_KEY_NOTICE = "notice.routing-key";

    // 队列
    @Bean
    public Queue logQueue() {
        return QueueBuilder.durable(QUEUE_LOG).build();
    }

    @Bean
    public Queue noticeQueue() {
        return QueueBuilder.durable(QUEUE_NOTICE).build();
    }

    // 交换机
    @Bean
    public DirectExchange erpExchange() {
        return new DirectExchange(EXCHANGE);
    }

    // 绑定
    @Bean
    public Binding logBinding(Queue logQueue, DirectExchange erpExchange) {
        return BindingBuilder.bind(logQueue).to(erpExchange).with(ROUTING_KEY_LOG);
    }

    @Bean
    public Binding noticeBinding(Queue noticeQueue, DirectExchange erpExchange) {
        return BindingBuilder.bind(noticeQueue).to(erpExchange).with(ROUTING_KEY_NOTICE);
    }

    // JSON消息转换器
    @Bean
    public MessageConverter jsonMessageConverter() {
        return new Jackson2JsonMessageConverter();
    }
}
