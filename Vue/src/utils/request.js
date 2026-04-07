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
        if (error.response.status === 404) {
            ElMessage.error("未找到请求接口");
        } else if (error.response.status === 500) {
            ElMessage.error("系统异常，请查看后端控制台");
        } else {
            console.error(error.message);
        }
        return Promise.reject(error);
    },
);

export default request;
