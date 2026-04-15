const routeInventory = [
    {
        path: "/inventory/query",
        name: "InventoryQuery",
        component: () => import("../components/inventory/query.vue"),
    },
    {
        path: "/inventory/operation",
        name: "InventoryOperation",
        component: () => import("../components/inventory/operation.vue"),
    },
    {
        path: "/inventory/warning",
        name: "InventoryWarning",
        component: () => import("../components/inventory/warning.vue"),
    },
];

export default routeInventory;
