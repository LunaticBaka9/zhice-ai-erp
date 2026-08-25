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
];

export default routeIndex;
