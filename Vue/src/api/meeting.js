import request from "@/utils/request";

export function getMeetingList(params) {
    return request.get("/meeting/list", { params });
}

export function createMeeting(data) {
    return request.post("/meeting/create", data);
}

export function getMeetingById(id) {
    return request.get(`/meeting/detail/${id}`);
}

export function deleteMeeting(data) {
    return request.post("/meeting/delete", data);
}

export function checkinMeeting(id) {
    return request.post(`/meeting/checkin/${id}`);
}
