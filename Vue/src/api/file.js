import request from "@/utils/request";

export function uploadFile(formData) {
    return request.post("/file/upload", formData, {
        headers: { "Content-Type": "multipart/form-data" },
    });
}

export function uploadAvatar(formData) {
    return request.post("/api/file/uploadAvatar", formData, {
        headers: { "Content-Type": "multipart/form-data" },
    });
}
