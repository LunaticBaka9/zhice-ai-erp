package com.example.demo.config;

import org.springframework.cache.CacheManager;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.cache.concurrent.ConcurrentMapCacheManager;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@EnableCaching
public class CacheConfig {

    /**
     * 内存缓存管理器（适用于单机部署）
     * 使用 ConcurrentMapCacheManager 提供线程安全的缓存实现
     */
    @Bean
    public CacheManager cacheManager() {
        ConcurrentMapCacheManager cacheManager = new ConcurrentMapCacheManager();
        
        // 配置所有模块的缓存名称
        cacheManager.setCacheNames(java.util.Arrays.asList(
            "goods", "goodsList", "goodsDetail",
            "category", "categoryTree",
            "warehouse", "warehouseList",
            "customer", "customerList",
            "supplier", "supplierList",
            "inventory", "inventoryOperation",
            "user", "userList",
            "operationLog", "notice"
        ));
        
        // 启用动态创建缓存（如果缓存名称不存在）
        cacheManager.setAllowNullValues(false); // 不缓存null值
        
        return cacheManager;
    }

    /**
     * 缓存键生成器 - 包含方法参数
     * 生成格式：ClassName.methodName:param1_param2
     */
    @Bean
    public org.springframework.cache.interceptor.KeyGenerator customKeyGenerator() {
        return (target, method, params) -> {
            StringBuilder key = new StringBuilder();
            key.append(target.getClass().getSimpleName());
            key.append(".");
            key.append(method.getName());
            key.append(":");
            
            // 将参数转换为字符串
            if (params.length > 0) {
                for (Object param : params) {
                    if (param != null) {
                        key.append(param.toString());
                    } else {
                        key.append("null");
                    }
                    key.append("_");
                }
                // 移除最后一个下划线
                key.deleteCharAt(key.length() - 1);
            }
            
            return key.toString();
        };
    }
}