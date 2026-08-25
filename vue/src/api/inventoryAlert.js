import request from "@/utils/request";

export function getAlertList(params) {
    return request.get("/inventoryAlert/list", { params });
}

export function getAlertStatistics() {
    return request.get("/inventoryAlert/statistics");
}

export function replenishAlert(data) {
    return request.post("/inventoryAlert/replenish", data);
}

export function generateAlert(data) {
    return request.post("/inventoryAlert/generate", data);
}

export function acknowledgeAlert(id) {
    return request.post(`/inventoryAlert/acknowledge/${id}`);
}
