import request from "@/utils/request";

export function getWarehouseList(params) {
    return request.get("/warehouse/list", { params });
}

export function getAllWarehouses() {
    return request.get("/warehouse/selectAll");
}

export function addWarehouse(data) {
    return request.post("/warehouse/add", data);
}

export function updateWarehouse(data) {
    return request.post("/warehouse/update", data);
}

export function deleteWarehouse(data) {
    return request.post("/warehouse/delete", data);
}
