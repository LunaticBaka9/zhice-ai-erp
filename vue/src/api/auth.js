import request from "@/utils/request";

export function login(data) {
    return request.post("/login", data);
}

export function emailLogin(data) {
    return request.post("/emailLogin", data);
}

export function sendEmailCode(data) {
    return request.post("/sendEmailCode", data);
}

export function register(data) {
    return request.post("/register", data);
}

export function emailRegister(data) {
    return request.post("/emailRegister", data);
}

export function sendEmailRegCode(data) {
    return request.post("/sendEmailRegCode", data);
}
