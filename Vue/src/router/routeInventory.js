const routeInventory = [
    {
        path: "/inventory/query",
        name: "InventoryQuery",
        component: () => import("../components/inventory/InventoryQuery.vue"),
    },
]

export default routeInventory;