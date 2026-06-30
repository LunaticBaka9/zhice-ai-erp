import request from "@/utils/request";

export function getDeptList(params) {
    return request.get("/dept/list", { params });
}

export function getDeptDetail(id) {
    return request.get(`/dept/detail/${id}`);
}

export function getDeptMembers(id, params) {
    return request.get(`/dept/members/${id}`, { params });
}

export function addDept(data) {
    return request.post("/dept/add", data);
}

export function updateDept(data) {
    return request.post("/dept/updateInfo", data);
}

export function updateDeptStatus(data) {
    return request.post("/dept/updateStatus", data);
}

export function deleteDept(data) {
    return request.post("/dept/delete", data);
}
