import request from "@/utils/request";

export function getAllPosts() {
    return request.get("/post/all");
}

export function getPostsList(){
    return request.get("/post/list");
}

export function addPost(data) {
    return request.post("/post/add", data);
}

export function updatePost(data) {
    return request.post("/post/updateInfo", data);
}

export function deletePost(data) {
    return request.post("/post/delete", data);
}

export function updatePostStatus(data) {
    return request.post("/post/updateStatus", data);
}

export function exportPosts() {
    return request.get("/post/exportData");
}
