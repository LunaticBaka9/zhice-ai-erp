package com.lunabaka.common;

import java.lang.reflect.Method;
import java.util.Date;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import com.lunabaka.config.RabbitConfig;
import com.lunabaka.entity.OperationLog;
import com.lunabaka.entity.User;
import com.lunabaka.service.UserService;

import cn.hutool.json.JSONUtil;
import jakarta.annotation.Resource;
import jakarta.servlet.http.HttpServletRequest;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Aspect
@Component
public class OperationLogAspect {
    @Resource
    private UserService userService;

    @Resource
    private RabbitTemplate rabbitTemplate;

    // 使用Hutool的JSON工具

    // 定义切点：所有带有@OperationLogAnnotation注解的方法
    @Pointcut("@annotation(com.lunabaka.common.OperationLogAnnotation)")
    public void logPointcut() {}

    @Around("logPointcut()")
    public Object around(ProceedingJoinPoint point) throws Throwable {
        long beginTime = System.currentTimeMillis();
        
        // 执行方法
        Object result = point.proceed();
        
        // 计算执行时间
        long time = System.currentTimeMillis() - beginTime;
        
        // 保存日志
        saveLog(point, time);
        
        return result;
    }

    private void saveLog(ProceedingJoinPoint joinPoint, long time) {
        MethodSignature signature = (MethodSignature) joinPoint.getSignature();
        Method method = signature.getMethod();
        
        OperationLog operationLog = new OperationLog();
        operationLog.setTime(time);
        operationLog.setCreateTime(new Date());
        
        // 获取注解信息
        OperationLogAnnotation annotation = method.getAnnotation(OperationLogAnnotation.class);
        if (annotation != null) {
            operationLog.setModule(annotation.module());
            operationLog.setType(annotation.type());
            operationLog.setOperation(annotation.value());
        }
        
        // 获取方法名
        String className = joinPoint.getTarget().getClass().getName();
        String methodName = signature.getName();
        operationLog.setMethod(className + "." + methodName + "()");
        
        // 获取参数
        try {
            Object[] args = joinPoint.getArgs();
            String params = JSONUtil.toJsonStr(args);
            // 限制参数长度
            if (params.length() > 2000) {
                params = params.substring(0, 2000);
            }
            operationLog.setParams(params);
        } catch (Exception e) {
            operationLog.setParams("参数序列化失败");
        }
        
        // 获取操作用户和IP地址
        try {
            ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
            if (attributes != null) {
                HttpServletRequest request = attributes.getRequest();
                String username = "系统";

                String userId = (String) request.getAttribute("userId");
                if (userId != null) {
                    User loginUser = userService.getById(Long.parseLong(userId));
                    if (loginUser != null) {
                        username = loginUser.getName();
                    }
                }
                operationLog.setUsername(username);

                String ip = getClientIp(request);
                operationLog.setIp(ip);
            } else {
                operationLog.setUsername("系统");
            }
        } catch (Exception e) {
            operationLog.setUsername("系统");
        }

        try {
            rabbitTemplate.convertAndSend(RabbitConfig.EXCHANGE, RabbitConfig.ROUTING_KEY_LOG, operationLog);
            log.info("日志已发送到RabbitMQ队列");
        } catch (Exception e) {
            log.error("发送日志到RabbitMQ失败", e);
        }
    }

    private String getClientIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (isInvalidIp(ip)) {
            ip = request.getHeader("X-Real-IP");
        }
        if (isInvalidIp(ip)) {
            ip = request.getHeader("Proxy-Client-IP");
        }
        if (isInvalidIp(ip)) {
            ip = request.getHeader("WL-Proxy-Client-IP");
        }
        if (isInvalidIp(ip)) {
            ip = request.getHeader("HTTP_CLIENT_IP");
        }
        if (isInvalidIp(ip)) {
            ip = request.getHeader("HTTP_X_FORWARDED_FOR");
        }
        if (isInvalidIp(ip)) {
            ip = request.getHeader("CF-Connecting-IP");
        }
        if (isInvalidIp(ip)) {
            ip = request.getRemoteAddr();
        }
        if (ip != null && ip.contains(",")) {
            ip = ip.split(",")[0].trim();
        }
        if ("0:0:0:0:0:0:0:1".equals(ip)) {
            ip = "127.0.0.1";
        }
        return ip;
    }

    private boolean isInvalidIp(String ip) {
        return ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip);
    }
}
