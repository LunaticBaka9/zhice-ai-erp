import request from "@/utils/request";

export function getMenuList(params) {
    return request.get("/menu/list", { params });
}

export function addMenu(data) {
    return request.post("/menu/add", data);
}

export function updateMenu(data) {
    return request.post("/menu/updateInfo", data);
}

export function deleteMenu(data) {
    return request.post("/menu/delete", data);
}
