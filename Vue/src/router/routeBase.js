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
    {
        path: "/base/supplier",
        name: "SupplierInfo",
        component: () => import("../components/base/Supplier.vue"),
    },
    {
        path: "/base/customer",
        name: "Customer",
        component: () => import("../components/base/Customer.vue"),
    },
];

export default routeBase;
