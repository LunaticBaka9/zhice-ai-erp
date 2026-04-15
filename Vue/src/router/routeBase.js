const routeBase = [
    {
        path: "/base/goodsInfo",
        name: "GoodsInfo",
        component: () => import("../components/base/goodsInfo.vue"),
    },
    {
        path: "/base/warehouse",
        name: "WarehouseSetting",
        component: () => import("../components/base/warehouse.vue"),
    },
    {
        path: "/base/supplier",
        name: "SupplierInfo",
        component: () => import("../components/base/supplier.vue"),
    },
    {
        path: "/base/customer",
        name: "Customer",
        component: () => import("../components/base/customer.vue"),
    },
];

export default routeBase;
