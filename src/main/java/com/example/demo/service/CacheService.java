package com.example.demo.service;

import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.stereotype.Service;

import jakarta.annotation.Resource;
import java.util.concurrent.Callable;

@Service
public class CacheService {

    @Resource
    private CacheManager cacheManager;

    /**
     * 手动获取缓存
     */
    public <T> T getFromCache(String cacheName, Object key, Class<T> type) {
        Cache cache = cacheManager.getCache(cacheName);
        if (cache != null) {
            Cache.ValueWrapper wrapper = cache.get(key);
            if (wrapper != null) {
                return type.cast(wrapper.get());
            }
        }
        return null;
    }

    /**
     * 手动放入缓存
     */
    public void putToCache(String cacheName, Object key, Object value) {
        Cache cache = cacheManager.getCache(cacheName);
        if (cache != null) {
            cache.put(key, value);
        }
    }

    /**
     * 手动清除缓存
     */
    public void evictFromCache(String cacheName, Object key) {
        Cache cache = cacheManager.getCache(cacheName);
        if (cache != null) {
            cache.evict(key);
        }
    }

    /**
     * 清除整个缓存
     */
    public void clearCache(String cacheName) {
        Cache cache = cacheManager.getCache(cacheName);
        if (cache != null) {
            cache.clear();
        }
    }

    /**
     * 获取或计算缓存值
     */
    public <T> T getOrCompute(String cacheName, Object key, Callable<T> valueLoader, Class<T> type) {
        T cachedValue = getFromCache(cacheName, key, type);
        if (cachedValue != null) {
            return cachedValue;
        }
        
        try {
            T computedValue = valueLoader.call();
            if (computedValue != null) {
                putToCache(cacheName, key, computedValue);
            }
            return computedValue;
        } catch (Exception e) {
            throw new RuntimeException("Failed to compute cache value", e);
        }
    }

    /**
     * 缓存工具方法 - 清除所有商品相关缓存
     */
    public void clearGoodsCache() {
        clearCache("goods");
        clearCache("goodsList");
        clearCache("goodsDetail");
    }

    /**
     * 缓存工具方法 - 清除所有分类相关缓存
     */
    public void clearCategoryCache() {
        clearCache("category");
        clearCache("categoryTree");
    }

    /**
     * 缓存工具方法 - 清除所有仓库相关缓存
     */
    public void clearWarehouseCache() {
        clearCache("warehouse");
        clearCache("warehouseList");
    }

    /**
     * 缓存工具方法 - 清除所有客户相关缓存
     */
    public void clearCustomerCache() {
        clearCache("customer");
        clearCache("customerList");
    }

    /**
     * 缓存工具方法 - 清除所有缓存
     */
    public void clearAllCache() {
        cacheManager.getCacheNames().forEach(this::clearCache);
    }

    /**
     * 获取缓存统计信息
     */
    public String getCacheStats() {
        StringBuilder stats = new StringBuilder();
        stats.append("Cache Statistics:\n");
        
        for (String cacheName : cacheManager.getCacheNames()) {
            Cache cache = cacheManager.getCache(cacheName);
            if (cache != null) {
                Object nativeCache = cache.getNativeCache();
                stats.append(String.format("  %s: [Type: %s]\n", 
                    cacheName, 
                    nativeCache.getClass().getSimpleName()));
            }
        }
        
        return stats.toString();
    }
}