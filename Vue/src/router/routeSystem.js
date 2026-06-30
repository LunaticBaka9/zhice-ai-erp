const routeSystem = [
    {
        path: "/system/menu",
        name: "menuManager",
        component: () => import("../components/system/MenuManager.vue")
    },
    {
        path: "/monitor/operationLog",
        name: "operationLogManager",
        component: () => import("../components/system/OperationLogManager.vue"),
    },
];

export default routeSystem;
