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
import routeAi from "./routeAi.js";
import { useMenuStore } from "../store/menu.ts";

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
        ...routeAi,
    ],
});

// 路由守卫：登录后按角色菜单拦截侧边栏对应路径
router.beforeEach(async (to) => {
    const whiteList = ["/login", "/register"];
    const isAuthenticated = checkAuth();
    const isWhiteListed = whiteList.includes(to.path);

    if (isWhiteListed) {
        if (isAuthenticated) {
            return { path: "/" };
        }
        return true;
    }
    if (!isAuthenticated) {
        return { path: "/login", query: { redirect: to.fullPath } };
    }
    const menuStore = useMenuStore();
    if (!menuStore.loaded) {
        await menuStore.fetchAuth();
    }
    if (!menuStore.canAccess(to.path)) {
        return { path: "/" };
    }
    return true;
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
