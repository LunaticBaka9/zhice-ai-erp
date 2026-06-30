import request from "@/utils/request";

export function getSalesReport(params) {
    return request.get("/report/stat/sales", { params });
}

export function getInventoryReport(params) {
    return request.get("/report/stat/inventory", { params });
}

export function getCoreReport(params) {
    return request.get("/report/stat/core", { params });
}
