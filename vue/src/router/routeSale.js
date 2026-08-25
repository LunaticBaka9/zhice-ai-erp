const routeSale = [
    {
        path: "/sale/order",
        name: "SaleOrder",
        component: () => import("../components/sale/order.vue"),
    },
    {
        path: "/sale/delivery",
        name: "SaleDelivery",
        component: () => import("../components/sale/Delivery.vue"),
    },
];

export default routeSale;
