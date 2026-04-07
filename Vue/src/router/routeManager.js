const routeManager = [
    {
        path: "/system/user",
        name: "userManager",
        component: () => import("../components/system/UserManager.vue"),
    },
    {
        path: "/system/sign",
        name: "signManager",
        component: () => import("../components/system/SignManager.vue"),
    },
    {
        path: "/monitor/operationLog",
        name: "operationLogManager",
        component: () => import("../components/system/OperationLogManager.vue"),
    },
];

export default routeManager;
