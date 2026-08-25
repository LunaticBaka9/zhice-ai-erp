const routeInventory = [
    {
        path: "/inventory/query",
        name: "InventoryQuery",
        component: () => import("../components/inventory/Query.vue"),
    },
    {
        path: "/inventory/operation",
        name: "InventoryOperation",
        component: () => import("../components/inventory/Operation.vue"),
    },
    {
        path: "/inventory/warning",
        name: "InventoryWarning",
        component: () => import("../components/inventory/Warning.vue"),
    },
];

export default routeInventory;
