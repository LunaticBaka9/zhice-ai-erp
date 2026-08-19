import { get, post } from '@/utils/request'
export const getMeetingList = (params) => get('/meeting/list', params)
export const createMeeting = (data) => post('/meeting/create', data)
export const getMeetingById = (id) => get(`/meeting/detail/${id}`)
export const deleteMeeting = (data) => post('/meeting/delete', data)
export const checkinMeeting = (id) => post(`/meeting/checkin/${id}`)
