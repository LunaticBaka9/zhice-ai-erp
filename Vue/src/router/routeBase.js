const routeBase = [
    {
        path: "/base/goodsInfo",
        name: "GoodsInfo",
        component: () => import("../components/base/GoodsInfo.vue"),
    },
    {
        path: "/base/warehouse",
        name: "WarehouseSetting",
        component: () => import("../components/base/Warehouse.vue"),
    },
    {
        path: "/base/customer",
        name: "Customer",
        component: () => import("../components/base/Customer.vue"),
    },
];

export default routeBase;
