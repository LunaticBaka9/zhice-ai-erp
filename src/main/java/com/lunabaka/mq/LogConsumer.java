package com.lunabaka.mq;

import com.lunabaka.config.RabbitConfig;
import com.lunabaka.entity.OperationLog;
import com.lunabaka.service.OperationLogService;
import jakarta.annotation.Resource;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

@Slf4j
@Component
public class LogConsumer {

    @Resource
    private OperationLogService operationLogService;

    @RabbitListener(queues = RabbitConfig.QUEUE_LOG)
    public void handleLog(OperationLog operationLog) {
        log.info("收到日志消息: {}", operationLog);
        operationLogService.insertLog(operationLog);
        log.info("日志写入数据库成功");
    }
}
