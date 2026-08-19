import { get } from '@/utils/request'
export const getSalesReport = (params) => get('/report/stat/sales', params)
export const getInventoryReport = (params) => get('/report/stat/inventory', params)
export const getCoreReport = (params) => get('/report/stat/core', params)
