import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";

export default defineConfig({
    plugins: [vue()],
    optimizeDeps: {
        include: ["element-plus"],
    },
    resolve: {
        alias: {
            "@": "/src",
        },
    },
    server: {
        proxy: {
            "/api": {
                target: "http://localhost:8080/",
                changeOrigin: true,
                rewrite: (path) => path.replace(/^\/api/, ""),
            },
            '/static': {
                target: 'http://192.140.163.56:8080', // 后端地址
                changeOrigin: true,
                // 注意：这里不需要 rewrite，因为路径是匹配的
            }
        },
    },
});