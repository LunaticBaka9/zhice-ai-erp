const routeInventory = [
    {
        path: "/inventory/query",
        name: "InventoryQuery",
        component: () => import("../components/inventory/Query.vue"),
    },

    {
        path: "/inventory/settings",
        name: "InventorySetting",
        component: () => import("../components/inventory/Settings.vue")
    }
]

export default routeInventory;