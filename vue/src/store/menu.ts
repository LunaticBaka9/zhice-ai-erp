import { defineStore } from "pinia";
import { computed, ref } from "vue";
import { getCurrentMenus, getCurrentPermissions } from "@/api/role";

/** 不在侧边栏登记的页面（详情等）一律放行 */
const SIDEBAR_PATHS = new Set([
    "/",
    "/notice/index",
    "/notice/post",
    "/notice/manager",
    "/base/goodsInfo",
    "/base/supplier",
    "/base/customer",
    "/base/warehouse",
    "/sale/order",
    "/sale/delivery",
    "/purchase/order",
    "/purchase/inbound",
    "/purchase/query",
    "/inventory/query",
    "/inventory/operation",
    "/inventory/warning",
    "/meeting/create",
    "/meeting/index",
    "/report/core",
    "/report/sales",
    "/report/inventory",
    "/dept/list",
    "/system/user",
    "/system/post",
    "/system/role",
    "/system/menu",
    "/monitor/operationLog",
    "/message",
    "/ai/partner",
    "/userInfo",
]);

/** 无菜单角色也要能进的入口 */
const ALWAYS_VISIBLE = new Set(["/", "/userInfo"]);

export const useMenuStore = defineStore("menu", () => {
    const isCollapse = ref(false);
    const loaded = ref(false);
    const superAdmin = ref(false);
    const allowedPaths = ref<string[]>([]);
    const permissionCodes = ref<string[]>([]);

    function handleToggle() {
        isCollapse.value = !isCollapse.value;
    }

    const pathSet = computed(() => new Set(allowedPaths.value));
    const codeSet = computed(() => new Set(permissionCodes.value));

    /** 侧边栏某一项是否显示 */
    function canShow(path: string) {
        if (superAdmin.value) return true;
        if (ALWAYS_VISIBLE.has(path)) return true;
        return pathSet.value.has(path);
    }

    /** 路由是否允许进入：非侧边栏路径放行 */
    function canAccess(path: string) {
        if (superAdmin.value) return true;
        if (ALWAYS_VISIBLE.has(path)) return true;
        if (!SIDEBAR_PATHS.has(path)) return true;
        return pathSet.value.has(path);
    }

    /** 按钮权限，超管或尚未加载时不拦截以免误藏 */
    function hasPermission(code: string) {
        if (superAdmin.value) return true;
        if (!loaded.value) return true;
        if (permissionCodes.value.length === 0) return true;
        return codeSet.value.has(code);
    }

    async function fetchAuth() {
        const token = localStorage.getItem("token");
        if (!token) {
            loaded.value = true;
            superAdmin.value = false;
            allowedPaths.value = [];
            permissionCodes.value = [];
            return;
        }
        try {
            const [menuRes, permRes] = await Promise.all([
                getCurrentMenus(),
                getCurrentPermissions(),
            ]);
            if (menuRes.code === "200") {
                superAdmin.value = !!menuRes.data?.superAdmin;
                allowedPaths.value = Array.isArray(menuRes.data?.paths)
                    ? menuRes.data.paths
                    : [];
            }
            if (permRes.code === "200") {
                if (permRes.data?.superAdmin) {
                    superAdmin.value = true;
                }
                permissionCodes.value = Array.isArray(permRes.data?.codes)
                    ? permRes.data.codes
                    : [];
            }
        } catch (e) {
            console.error("加载当前用户权限失败", e);
        } finally {
            loaded.value = true;
        }
    }

    function clearAuth() {
        loaded.value = false;
        superAdmin.value = false;
        allowedPaths.value = [];
        permissionCodes.value = [];
    }

    return {
        isCollapse,
        loaded,
        superAdmin,
        allowedPaths,
        permissionCodes,
        handleToggle,
        canShow,
        canAccess,
        hasPermission,
        fetchAuth,
        clearAuth,
    };
});
