import { createRouter, createWebHistory } from "vue-router";
import routeIndex from "./routeIndex.js"; // 普通文件路由
import routeSystem from "./routeSystem.js";
import routeUser from "./routeUser.js";
import routeNotice from "./routeNotice.js";
import routeInventory from "./routeInventory.js";
import routeBase from "./routeBase.js";
import routePurchase from "./routePurchase.js";
import routeSale from "./routeSale.js";
import routeReport from "./routeReport.js";
import routeMeeting from "./routeMeeting.js";
import routeDept from "./routeDept.js";

const router = createRouter({
    history: createWebHistory(),
    routes: [
        {
            path: "/login",
            name: "login",
            component: () => import("../components/Login.vue"),
            meta: { requiresAuth: false },
        },
        {
            path: "/register",
            name: "register",
            component: () => import("../components/Register.vue"),
            meta: { requiresAuth: false },
        },
        ...routeIndex,
        ...routeSystem,
        ...routeUser,
        ...routeDept,
        ...routeNotice,
        ...routeInventory,
        ...routeBase,
        ...routePurchase,
        ...routeSale,
        ...routeReport,
        ...routeMeeting,
    ],
});

// 路由守卫
router.beforeEach((to, from) => {
    // 白名单路径（不需要登录）
    const whiteList = ["/login", "/register"];

    // 检查用户是否已登录
    const isAuthenticated = checkAuth();

    // 检查当前路径是否在白名单中
    const isWhiteListed = whiteList.includes(to.path);

    if (isWhiteListed) {
        if (isAuthenticated) {
            return { path: "/" };
        }
        return true;
    } else {
        if (isAuthenticated) {
            return true;
        }
        return { path: "/login", query: { redirect: to.fullPath } };
    }
});

// 检查用户是否已登录
function checkAuth() {
    try {
        const user = localStorage.getItem("local_user");
        const token = localStorage.getItem("token");
        return !!(user && token);
    } catch (e) {
        return false;
    }
}

export default router;
