import { get, post } from '@/utils/request'
export const getInventoryList = (params) => get('/inventoryOperation/list', params)
export const addInventory = (data) => post('/inventoryOperation/add', data)
export const updateInventory = (data) => post('/inventoryOperation/update', data)
export const completeInventory = (id) => post(`/inventoryOperation/updateStatus/${id}/completed`)
export const cancelInventory = (id) => post(`/inventoryOperation/updateStatus/${id}/cancelled`)
