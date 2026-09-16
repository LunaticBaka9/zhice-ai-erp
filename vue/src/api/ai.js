import request from "@/utils/request";

/**
 * 发送聊天消息（流式/非流式）
 * @param {Object} data - { conversationId, message }
 */
export function sendChatMessage(data) {
    return request.post("/ai/chat", data);
}

/**
 * 获取历史会话列表
 */
export function getConversationList() {
    return request.get("/ai/conversations");
}

/**
 * 获取某个会话的所有消息
 * @param {String|Number} conversationId
 */
export function getConversationMessages(conversationId) {
    return request.get(`/ai/conversation/${conversationId}`);
}

/**
 * 创建新会话
 * @param {Object} data - { title }
 */
export function createConversation(data) {
    return request.post("/ai/conversation/create", data);
}

/**
 * 删除会话
 * @param {Object} data - { conversationId }
 */
export function deleteConversation(data) {
    return request.post("/ai/conversation/delete", data);
}

/**
 * 重命名会话
 * @param {Object} data - { conversationId, title }
 */
export function renameConversation(data) {
    return request.post("/ai/conversation/rename", data);
}

/**
 * 保存当前用户的 DeepSeek API Key
 * @param {Object} data - { apiKey }
 */
export function setAiApiKey(data) {
    return request.post("/ai/api-key", data);
}

/**
 * 查询当前用户是否已配置 API Key
 */
export function getAiApiKeyStatus() {
    return request.get("/ai/api-key/status");
}

/**
 * 删除当前用户已配置的 API Key
 */
export function removeAiApiKey() {
    return request.delete("/ai/api-key");
}
