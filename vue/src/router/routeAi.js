const routeAi = [
    {
        path: "/ai/partner",
        name: "aiPartner",
        component: () => import("../components/ai/AiPartner.vue"),
        meta: { breadcrumb: "AI助手" },
    },
];

export default routeAi;
