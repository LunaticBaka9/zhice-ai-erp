import { get, post } from '@/utils/request'
export const getOutboundStatistics = () => get('/sale/outbound/statistics')
export const getEligibleOutbound = (params) => get('/sale/eligibleOutbound', params)
export const getOutboundList = (params) => get('/sale/outbound/list', params)
export const createOutbound = (data) => post('/sale/outbound/create', data)
export const getOutboundDetail = (id) => get(`/sale/outbound/detail/${id}`)
export const confirmOutbound = (id) => post(`/sale/outbound/confirm/${id}`)
export const deleteDraftOutbound = (id) => post(`/sale/outbound/deleteDraft/${id}`)
