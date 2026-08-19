import { get, post } from '@/utils/request'
export const getAlertList = (params) => get('/inventoryAlert/list', params)
export const getAlertStatistics = () => get('/inventoryAlert/statistics')
export const replenishAlert = (data) => post('/inventoryAlert/replenish', data)
export const generateAlert = (data) => post('/inventoryAlert/generate', data)
export const acknowledgeAlert = (id) => post(`/inventoryAlert/acknowledge/${id}`)
