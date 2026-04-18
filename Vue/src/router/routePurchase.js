const routePurchase = [
    {
        path: "/purchase/order",
        name: "PurchaseOrder",
        component: () => import("../components/purchase/Order.vue"),
    },
    {
        path: "/purchase/inbound",
        name: "PurchaseInbound",
        component: () => import("../components/purchase/Inbound.vue"),
    },
    {
        path: "/purchase/query",
        name: "PurchaseQuery",
        component: () => import("../components/purchase/Query.vue"),
    },
];

export default routePurchase;
