import request from "@/utils/request";

export function getOutboundStatistics() {
    return request.get("/sale/outbound/statistics");
}

export function getEligibleOutbound(params) {
    return request.get("/sale/eligibleOutbound", { params });
}

export function getOutboundList(params) {
    return request.get("/sale/outbound/list", { params });
}

export function createOutbound(data) {
    return request.post("/sale/outbound/create", data);
}

export function getOutboundDetail(id) {
    return request.get(`/sale/outbound/detail/${id}`);
}

export function confirmOutbound(id) {
    return request.post(`/sale/outbound/confirm/${id}`);
}

export function deleteDraftOutbound(id) {
    return request.post(`/sale/outbound/deleteDraft/${id}`);
}
