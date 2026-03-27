import { createRouter, createWebHistory } from "vue-router";
import routeIndex from "./routeIndex.js"; // 普通文件路由
import routeManager from "./routeManager.js";
import routeUser from "./routeUser.js";


const router = createRouter({
    history: createWebHistory(),
    routes: [...routeIndex, ...routeManager, ...routeUser],
});

export default router;