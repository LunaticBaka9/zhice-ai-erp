import { get, post } from '@/utils/request'
export const sendChatMessage = (data) => post('/ai/chat', data)
export const getConversationList = () => get('/ai/conversations')
export const getConversationMessages = (conversationId) => get(`/ai/conversation/${conversationId}`)
export const createConversation = (data) => post('/ai/conversation/create', data)
export const deleteConversation = (data) => post('/ai/conversation/delete', data)
export const renameConversation = (data) => post('/ai/conversation/rename', data)
