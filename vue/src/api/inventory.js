import request from "@/utils/request";

export function getInventoryList(params) {
    return request.get("/inventoryOperation/list", { params });
}

export function addInventory(data) {
    return request.post("/inventoryOperation/add", data);
}

export function updateInventory(data) {
    return request.post("/inventoryOperation/update", data);
}

export function completeInventory(id) {
    return request.post(`/inventoryOperation/updateStatus/${id}/completed`);
}

export function cancelInventory(id) {
    return request.post(`/inventoryOperation/updateStatus/${id}/cancelled`);
}
