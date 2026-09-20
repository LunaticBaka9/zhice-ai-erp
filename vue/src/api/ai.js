import request from "@/utils/request";

/**
 * 发送聊天消息（后端非流式返回）
 * @param {Object} data - { conversationId, message }
 *                       - conversationId: 会话ID，为空时后端会自动新建会话并在返回值中带回
 *                       - message: 用户输入的消息内容
 * @returns 后端返回结果，成功时 data 形如 { content, conversationId }
 */
export function sendChatMessage(data) {
    return request.post("/ai/chat", data);
}

/**
 * 获取历史会话列表（按最后更新时间倒序）
 */
export function getConversationList() {
    return request.get("/ai/conversations");
}

/**
 * 获取某个会话的所有消息（按时间升序）
 * @param {String|Number} conversationId 会话ID
 */
export function getConversationMessages(conversationId) {
    return request.get(`/ai/conversation/${conversationId}`);
}

/**
 * 手动创建新会话
 * @param {Object} data - { title } 会话标题
 */
export function createConversation(data) {
    return request.post("/ai/conversation/create", data);
}

/**
 * 删除会话（级联删除其全部消息）
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
 * 保存当前登录用户的 DeepSeek API Key
 * <p>
 * 中台将 api-key 按用户维度存入 Redis（key 前缀 ai:apikey:），不会写入任何配置文件，
 * 也不会在项目启动时进行校验。key 以密码框输入，仅保存在该用户账号下。
 * @param {Object} data - { apiKey } 用户在设置弹窗中输入的真实 api-key（sk- 开头）
 */
export function setAiApiKey(data) {
    return request.post("/ai/api-key", data);
}

/**
 * 查询当前登录用户是否已配置过 API Key
 * @returns 成功时 data 形如 { configured: boolean }
 *         前端据此点亮/置灰顶部“API Key 设置”图标的已配置状态
 */
export function getAiApiKeyStatus() {
    return request.get("/ai/api-key/status");
}

/**
 * 删除当前登录用户已配置的 API Key
 * 删除后再次发送消息，后端会提示“请先配置 DeepSeek API Key”
 */
export function removeAiApiKey() {
    return request.delete("/ai/api-key");
}
