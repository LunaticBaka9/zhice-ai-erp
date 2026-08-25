import axios from "axios";
import { ElMessage } from "element-plus";

const request = axios.create({
    baseURL: "/api",
    timeout: 30000,
});

request.interceptors.request.use(
    (config) => {
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

        return config;
    },
    (error) => {
        return Promise.reject(error);
    },
);

request.interceptors.response.use(
    (response) => {
        let res = response.data;
        if (typeof res === "string") {
            res = res ? JSON.parse(res) : res;
        }
        return res;
    },
    (error) => {
        const status = error.response?.status;
        const data = error.response?.data;
        const msg = typeof data === "object" && data?.msg ? data.msg : null;
        if (status === 401) {
            ElMessage.error(msg || "登录已失效，请重新登录");
        } else if (status === 404) {
            ElMessage.error("未找到请求接口");
        } else if (status === 500) {
            ElMessage.error("系统异常，请查看后端控制台");
        } else if (!error.response) {
            ElMessage.error("网络异常，请检查服务是否启动");
        } else {
            ElMessage.error(msg || error.message || "请求失败");
        }
        return Promise.reject(error);
    },
);

export default request;
