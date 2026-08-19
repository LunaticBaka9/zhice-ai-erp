import { get, post } from '@/utils/request'
export const getLogList = (params) => get('/operationLog/list', params)
export const deleteAllLogs = () => post('/operationLog/deleteAll')
