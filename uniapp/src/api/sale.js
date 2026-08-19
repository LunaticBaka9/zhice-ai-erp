import { get, post } from '@/utils/request'
export const getSaleList = (params) => get('/sale/list', params)
export const getSaleStatistics = () => get('/sale/statistics')
export const getSaleById = (id) => get(`/sale/selectById/${id}`)
export const addSale = (data) => post('/sale/add', data)
export const updateSale = (data) => post('/sale/update', data)
export const confirmSale = (id) => post(`/sale/confirm/${id}`)
export const cancelSale = (id) => post(`/sale/cancel/${id}`)
