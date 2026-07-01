import request from "@/utils/request";

export function getUserList(params) {
    return request.get("/user/list", { params });
}

export function getUserById(uid) {
    return request.get(`/user/selectById/${uid}`);
}

export function getAllUsers() {
    return request.get("/user/selectAllUsers");
}

export function addUser(data) {
    return request.post("/user/add", data);
}

export function transferUser(data) {
    return request.post("/user/deptTransfer", data)
}

export function updateUser(data) {
    return request.post("/user/updateInfo", data);
}

export function deleteUser(data) {
    return request.post("/user/delete", data);
}

export function updateUserStatus(data) {
    return request.post("/user/updateStatus", data);
}

export function updatePassword(data) {
    return request.post("/user/updatePassword", data);
}

export function exportUsers(params) {
    return request.get("/user/exportData", { params });
}

export function sendUserEmailCode(data) {
    return request.post("/user/send-email-code", data);
}

export function changeEmail(data) {
    return request.post("/user/changeEmail", data);
}

export function sendPhoneCode(data) {
    return request.post("/api/send-phone-code", data);
}

export function changePhone(data) {
    return request.post("/api/change-phone", data);
}
