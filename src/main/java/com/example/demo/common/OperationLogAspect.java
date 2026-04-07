package com.example.demo.common;

import cn.hutool.json.JSONUtil;
import com.example.demo.entity.OperationLog;
import com.example.demo.service.OperationLogService;
import jakarta.annotation.Resource;
import jakarta.servlet.http.HttpServletRequest;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.lang.reflect.Method;
import java.util.Date;

@Aspect
@Component
public class OperationLogAspect {
    @Resource
    private OperationLogService operationLogService;

    // 使用Hutool的JSON工具

    // 定义切点：所有带有@OperationLogAnnotation注解的方法
    @Pointcut("@annotation(com.example.demo.common.OperationLogAnnotation)")
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
        
        // 获取操作用户
        try {
            // 从localStorage获取用户信息
            ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
            if (attributes != null) {
                HttpServletRequest request = attributes.getRequest();
                String token = request.getHeader("token");
                // 这里可以根据token获取用户信息
                log.setUsername("系统");
                
                // 获取IP地址
                String ip = request.getRemoteAddr();
                log.setIp(ip);
            }
        } catch (Exception e) {
            log.setUsername("系统");
        }
        
        operationLogService.insertLog(log);
    }
}
