import request from "@/utils/request";

export function getGoodsList(params) {
    return request.get("/goods/list", { params });
}

export function getAllGoods() {
    return request.get("/goods/selectAllGoods");
}

export function addGoods(data) {
    return request.post("/goods/add", data);
}

export function updateGoods(data) {
    return request.post("/goods/update", data);
}

export function deleteGoods(data) {
    return request.post("/goods/delete", data);
}
