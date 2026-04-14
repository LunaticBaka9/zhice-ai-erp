const routeBase = [
    {
        path: "/base/goodsInfo",
        name: "GoodsInfo",
        component: () => import("../components/base/goodsInfo.vue"),
    },
    {
        path: "/base/warehouse",
        name: "WarehouseSetting",
        component: () => import("../components/base/Warehouse.vue"),
    },
];

export default routeBase;
