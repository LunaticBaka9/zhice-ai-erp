import request from "@/utils/request";

export function getLogList(params) {
    return request.get("/operationLog/list", { params });
}

export function deleteAllLogs() {
    return request.post("/operationLog/deleteAll");
}
