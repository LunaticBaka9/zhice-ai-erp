import { get, post } from '@/utils/request'
export const getGoodsList = (params) => get('/goods/list', params)
export const getAllGoods = () => get('/goods/selectAllGoods')
export const addGoods = (data) => post('/goods/add', data)
export const updateGoods = (data) => post('/goods/update', data)
export const deleteGoods = (data) => post('/goods/delete', data)
