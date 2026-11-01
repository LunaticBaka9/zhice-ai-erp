package com.lunabaka;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.ai.model.deepseek.autoconfigure.DeepSeekChatAutoConfiguration;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.EnableAspectJAutoProxy;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.serializer.GenericJacksonJsonRedisSerializer;
import org.springframework.data.redis.serializer.StringRedisSerializer;
import org.springframework.scheduling.annotation.EnableScheduling;
import tools.jackson.databind.ObjectMapper;

import java.util.TimeZone;

@SpringBootApplication(exclude = DeepSeekChatAutoConfiguration.class)
// 排除 DeepSeek 的自动配置：DeepSeekChatAutoConfiguration 会在项目启动时读取
// spring.ai.deepseek.api-key 配置并创建 ChatModel Bean。一旦 api-key 缺失或格式错误，
// 启动阶段就会直接失败。为了支持“由用户在前端自行导入 api-key、启动时不检测”，
// 这里显式排除该自动配置，改为在运行时由 AiService 动态构建 DeepSeek 模型。
@EnableScheduling
@EnableAspectJAutoProxy
@MapperScan("com.lunabaka.mapper")
public class ProjectApplication {
    public static void main(String[] args) {
        TimeZone.setDefault(TimeZone.getTimeZone("Asia/Shanghai"));
        SpringApplication.run(ProjectApplication.class, args);
    }

    /**
     * 全局 RedisTemplate Bean
     * <p>
     * 项目中 Redis 的 key 统一使用 StringRedisSerializer（字符串），value 使用
     * GenericJacksonJsonRedisSerializer（基于 Jackson 的 JSON 序列化，会自动携带类型信息）。
     * AiService 中“每个用户保存自己的 DeepSeek API Key”就是通过该模板写入 Redis 的。
     *
     * @param redisConnectionFactory Redis 连接工厂，由 Spring Boot 自动注入
     * @param objectMapper           Jackson 的 ObjectMapper，由 Spring Boot 自动注入
     * @return 配置好序列化策略的 RedisTemplate
     */
    @Bean
    public RedisTemplate<String, Object> redisTemplate(RedisConnectionFactory redisConnectionFactory, ObjectMapper objectMapper) {
        // 使用 GenericJacksonJsonRedisSerializer 作为值的序列化器，可序列化任意对象
        GenericJacksonJsonRedisSerializer serializer = new GenericJacksonJsonRedisSerializer(objectMapper);
        RedisTemplate<String, Object> template = new RedisTemplate<>();
        // 设置连接工厂
        template.setConnectionFactory(redisConnectionFactory);
        // key / hashKey 一律以字符串形式存取
        template.setKeySerializer(new StringRedisSerializer());
        // value / hashValue 使用 JSON 序列化
        template.setValueSerializer(serializer);
        template.setHashKeySerializer(new StringRedisSerializer());
        template.setHashValueSerializer(serializer);
        // 根据上述设置初始化模板内部的序列化/反序列化组件
        template.afterPropertiesSet();
        return template;
    }
}
