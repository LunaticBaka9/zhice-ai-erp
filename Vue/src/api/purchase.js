import request from "@/utils/request";

export function getPurchaseOrderList(params) {
    return request.get("/purchase/order/list", { params });
}

export function getPurchaseOrderDetail(id) {
    return request.get(`/purchase/order/detail/${id}`);
}

export function savePurchaseOrder(data) {
    return request.post("/purchase/order/save", data);
}

export function confirmPurchaseOrder(id) {
    return request.post(`/purchase/order/confirm/${id}`);
}

export function cancelPurchaseOrder(id) {
    return request.post(`/purchase/order/cancel/${id}`);
}

export function getEligibleInbound(params) {
    return request.get("/purchase/order/eligibleInbound", { params });
}

export function getInboundList(params) {
    return request.get("/purchase/inbound/list", { params });
}

export function createInbound(data) {
    return request.post("/purchase/inbound/create", data);
}

export function getInboundDetail(id) {
    return request.get(`/purchase/inbound/detail/${id}`);
}

export function confirmInbound(id) {
    return request.post(`/purchase/inbound/confirm/${id}`);
}

export function deleteDraftInbound(id) {
    return request.post(`/purchase/inbound/deleteDraft/${id}`);
}
