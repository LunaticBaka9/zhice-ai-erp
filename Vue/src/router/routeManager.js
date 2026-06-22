const routeManager = [
    {
        path: "/system/user",
        name: "userManager",
        component: () => import("../components/system/UserManager.vue"),
    },
    {
        path: "/system/menu",
        name: "menuManager",
        component: () => import("../components/system/MenuManager.vue")
    },
    {
        path: "/system/role",
        name: "roleManager",
        component: ()=> import("../components/system/RoleManager.vue")
    },
    {
        path: "/monitor/operationLog",
        name: "operationLogManager",
        component: () => import("../components/system/OperationLogManager.vue"),
    },
];

export default routeManager;
