import { get, post } from '@/utils/request'
export const getWarehouseList = (params) => get('/warehouse/list', params)
export const getAllWarehouses = () => get('/warehouse/selectAll')
export const addWarehouse = (data) => post('/warehouse/add', data)
export const updateWarehouse = (data) => post('/warehouse/update', data)
export const deleteWarehouse = (data) => post('/warehouse/delete', data)
