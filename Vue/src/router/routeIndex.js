const routeIndex = [
    {
        path: "/",
        name: "",
        component: () => import("../components/index.vue"),
    },
    {
        path: "/message",
        name: "message",
        component: () => import("../components/Message.vue"),
    },
    {
        path: "/login",
        name: "login",
        component: () => import("../components/Login.vue"),
    },
    {
        path: "/register",
        name: "register",
        component: () => import("../components/Register.vue"),
    },
];

export default routeIndex;
