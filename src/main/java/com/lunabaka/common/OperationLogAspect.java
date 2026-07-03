package com.lunabaka.common;

import java.lang.reflect.Method;
import java.util.Date;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import com.lunabaka.entity.OperationLog;
import com.lunabaka.entity.User;
import com.lunabaka.service.OperationLogService;
import com.lunabaka.service.UserService;

import cn.hutool.json.JSONUtil;
import jakarta.annotation.Resource;
import jakarta.servlet.http.HttpServletRequest;

@Aspect
@Component
public class OperationLogAspect {
    @Resource
    private OperationLogService operationLogService;

    @Resource
    private UserService userService;

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
        
        OperationLog log = new OperationLog();
        log.setTime(time);
        log.setCreateTime(new Date());
        
        // 获取注解信息
        OperationLogAnnotation annotation = method.getAnnotation(OperationLogAnnotation.class);
        if (annotation != null) {
            log.setModule(annotation.module());
            log.setType(annotation.type());
            log.setOperation(annotation.value());
        }
        
        // 获取方法名
        String className = joinPoint.getTarget().getClass().getName();
        String methodName = signature.getName();
        log.setMethod(className + "." + methodName + "()");
        
        // 获取参数
        try {
            Object[] args = joinPoint.getArgs();
            String params = JSONUtil.toJsonStr(args);
            // 限制参数长度
            if (params.length() > 2000) {
                params = params.substring(0, 2000);
            }
            log.setParams(params);
        } catch (Exception e) {
            log.setParams("参数序列化失败");
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
                log.setUsername(username);

                String ip = getClientIp(request);
                log.setIp(ip);
            } else {
                log.setUsername("系统");
            }
        } catch (Exception e) {
            log.setUsername("系统");
        }

        operationLogService.insertLog(log);
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
