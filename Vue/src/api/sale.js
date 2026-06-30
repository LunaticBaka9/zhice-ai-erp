import request from "@/utils/request";

export function getSaleList(params) {
    return request.get("/sale/list", { params });
}

export function getSaleStatistics() {
    return request.get("/sale/statistics");
}

export function getSaleById(id) {
    return request.get(`/sale/selectById/${id}`);
}

export function addSale(data) {
    return request.post("/sale/add", data);
}

export function updateSale(data) {
    return request.post("/sale/update", data);
}

export function confirmSale(id) {
    return request.post(`/sale/confirm/${id}`);
}

export function cancelSale(id) {
    return request.post(`/sale/cancel/${id}`);
}
