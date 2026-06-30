import request from "@/utils/request";

export function getNoticeList(params) {
    return request.get("/notice/list", { params });
}

export function getAllNotices() {
    return request.get("/notice/selectAllNotice");
}

export function getNoticeById(nid) {
    return request.get(`/notice/selectByNid/${nid}`);
}

export function updateNotice(data) {
    return request.post("/notice/update", data);
}

export function postNotice(data) {
    return request.post("/notice/postNotice", data);
}

export function saveDraft(data) {
    return request.post("/notice/saveDraft", data);
}

export function deleteNotice(data) {
    return request.post("/notice/delete", data);
}

export function getUnreadCount() {
    return request.get("/notice/unreadCount");
}

export function updateViews(data) {
    return request.post("/notice/updateViews", data);
}

export function markAsRead(data) {
    return request.post("/notice/markAsRead", data);
}

export function exportNotices() {
    return request.get("/notice/exportData");
}
