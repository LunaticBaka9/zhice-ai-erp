import axios from "axios";
import { ElMessage } from "element-plus";

// 创建 axios 实例
const request = axios.create({
    baseURL: "/api",
    timeout: 10000, // 减少超时时间到10秒（原30秒）
    withCredentials: true, // 跨域请求时发送cookie
});

// 请求缓存 Map（简单实现）
const cache = new Map();
const CACHE_DURATION = 5 * 60 * 1000; // 5分钟缓存

// 请求取消控制器 Map
const cancelTokenMap = new Map();

// 请求拦截器
request.interceptors.request.use(
    (config) => {
        // 生成请求唯一标识
        const requestKey = `${config.method}-${config.url}-${JSON.stringify(config.params || config.data || "")}`;

        // 检查是否有相同的请求正在进行，如果有则取消前一个
        if (cancelTokenMap.has(requestKey)) {
            cancelTokenMap.get(requestKey).cancel("取消重复请求");
        }

        // 创建新的取消令牌
        const cancelToken = axios.CancelToken.source();
        cancelTokenMap.set(requestKey, cancelToken);
        config.cancelToken = cancelToken.token;

        // 检查缓存（仅对 GET 请求）
        if (config.method?.toLowerCase() === "get" && config.cache !== false) {
            const cacheKey = requestKey;
            const cached = cache.get(cacheKey);
            if (cached && Date.now() - cached.timestamp < CACHE_DURATION) {
                // 使用缓存，取消实际请求
                cancelToken.cancel("使用缓存");
                return Promise.reject({ __fromCache: true, data: cached.data });
            }
        }

        // 文件上传请求不设置 Content-Type，让浏览器自动设置 multipart/form-data
        const isUpload = config.url && config.url.includes("/file/upload");
        if (!isUpload) {
            config.headers["Content-Type"] = "application/json;charset=utf-8";
        }

        // 添加JWT token到请求头
        const token = localStorage.getItem("token");
        if (token) {
            config.headers["token"] = token;
        }

        // 添加请求时间戳防止浏览器缓存
        if (config.method?.toLowerCase() === "get" && config.params) {
            config.params._t = Date.now();
        }

        return config;
    },
    (error) => {
        return Promise.reject(error);
    },
);

// 响应拦截器
request.interceptors.response.use(
    (response) => {
        const requestKey = `${response.config.method}-${response.config.url}-${JSON.stringify(response.config.params || response.config.data || "")}`;

        // 请求完成后移除取消令牌
        cancelTokenMap.delete(requestKey);

        // 缓存 GET 请求的响应
        if (response.config.method?.toLowerCase() === "get" && response.config.cache !== false) {
            const cacheKey = requestKey;
            cache.set(cacheKey, {
                data: response.data,
                timestamp: Date.now(),
            });
        }

        let res = response.data;
        if (typeof res === "string") {
            res = res ? JSON.parse(res) : res;
        }
        return res;
    },
    (error) => {
        // 如果是缓存命中，直接返回缓存数据
        if (error.__fromCache) {
            return Promise.resolve(error.data);
        }

        // 如果是请求被取消，不显示错误消息
        if (axios.isCancel(error)) {
            return Promise.reject(error);
        }

        // 处理网络错误
        if (!error.response) {
            ElMessage.error("网络连接失败，请检查网络设置");
            return Promise.reject(error);
        }

        const status = error.response.status;
        switch (status) {
            case 400:
                ElMessage.error("请求参数错误");
                break;
            case 401:
                ElMessage.error("未授权，请重新登录");
                // 跳转到登录页
                localStorage.removeItem("token");
                window.location.href = "/login";
                break;
            case 403:
                ElMessage.error("拒绝访问");
                break;
            case 404:
                ElMessage.error("请求资源不存在");
                break;
            case 408:
                ElMessage.error("请求超时");
                break;
            case 500:
                ElMessage.error("服务器内部错误");
                break;
            case 502:
                ElMessage.error("网关错误");
                break;
            case 503:
                ElMessage.error("服务不可用");
                break;
            case 504:
                ElMessage.error("网关超时");
                break;
            default:
                ElMessage.error(`请求失败: ${error.message}`);
        }

        return Promise.reject(error);
    },
);

// 添加重试机制
const retryRequest = async (config, retries = 2, delay = 1000) => {
    for (let i = 0; i <= retries; i++) {
        try {
            return await request(config);
        } catch (error) {
            if (i === retries || error.response?.status < 500) {
                throw error;
            }
            // 等待一段时间后重试
            await new Promise((resolve) => setTimeout(resolve, delay * Math.pow(2, i)));
        }
    }
};

// 导出优化的请求方法
export default {
    ...request,
    // 添加带重试的请求方法
    retry: retryRequest,
    // 清除缓存的方法
    clearCache: () => cache.clear(),
    // 取消所有 pending 请求
    cancelAll: () => {
        cancelTokenMap.forEach((cancelToken) => {
            cancelToken.cancel("取消所有请求");
        });
        cancelTokenMap.clear();
    },
};
