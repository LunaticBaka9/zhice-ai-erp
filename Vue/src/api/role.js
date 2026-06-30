import request from "@/utils/request";

export function getAllRoles() {
    return request.get("/role/all");
}

export function getRoleList(params) {
    return request.get("/role/list", { params });
}

export function addRole(data) {
    return request.post("/role/add", data);
}

export function updateRole(data) {
    return request.post("/role/updateInfo", data);
}

export function deleteRole(data) {
    return request.post("/role/delete", data);
}

export function updateRoleStatus(data) {
    return request.post("/role/updateStatus", data);
}

export function exportRoles() {
    return request.get("/role/exportData");
}
