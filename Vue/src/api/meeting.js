import request from "@/utils/request";

export function getMeetingList(params) {
    return request.get("/meeting/list", { params });
}

export function createMeeting(data) {
    return request.post("/meeting/create", data);
}

export function deleteMeeting(data) {
    return request.post("/meeting/delete", data);
}
