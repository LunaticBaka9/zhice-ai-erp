import request from "@/utils/request";

/**
 * 分页查询当前用户消息列表
 * @param {{pageNum?:number,pageSize?:number,type?:string,priority?:string,keyword?:string,isRead?:number,needAction?:number,startDate?:string,endDate?:string}} params
 */
export function getMessageList(params) {
    return request.get("/message/list", { params });
}

/** 查询单条消息详情 */
export function getMessageDetail(msgId) {
    return request.get(`/message/selectByMsgId/${msgId}`);
}

/** 当前用户未读消息数 */
export function getMessageUnreadCount() {
    return request.get("/message/unreadCount");
}

/** 当前用户待处理消息数 */
export function getMessagePendingCount() {
    return request.get("/message/pendingCount");
}

/** 标记单条消息已读 */
export function markMessageRead(msgId) {
    return request.post("/message/markRead", { msgId });
}

/** 当前用户全部标记已读 */
export function markAllMessageRead() {
    return request.post("/message/markAllRead");
}

/** 批量标记已读 */
export function markBatchMessageRead(msgIds) {
    return request.post("/message/markBatchRead", { msgIds });
}

/** 删除单条消息 */
export function removeMessage(msgId) {
    return request.post("/message/delete", { msgId });
}

/** 批量删除消息 */
export function removeBatchMessage(msgIds) {
    return request.post("/message/batchDelete", { msgIds });
}

/** 清空当前用户全部消息 */
export function clearAllMessage() {
    return request.post("/message/clearAll");
}

/** 发送消息 */
export function sendMessage(data) {
    return request.post("/message/send", data);
}
