const routeReport = [
    {
        path: "/report/core",
        name: "ReportCoreAnalysis",
        component: () => import("../components/report/CoreAnalysis.vue"),
    },
    {
        path: "/report/sales",
        name: "ReportSalesAnalysis",
        component: () => import("../components/report/SalesAnalysis.vue"),
    },
    {
        path: "/report/inventory",
        name: "ReportInventoryAnalysis",
        component: () => import("../components/report/InventoryAnalysis.vue"),
    },
];

export default routeReport;
