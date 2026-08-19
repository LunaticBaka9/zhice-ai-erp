import { get, post } from '@/utils/request'
export const getDeptList = (params) => get('/dept/list', params)
export const getDeptDetail = (id) => get(`/dept/detail/${id}`)
export const getDeptMembers = (id, params) => get(`/dept/members/${id}`, params)
export const addDept = (data) => post('/dept/add', data)
export const updateDept = (data) => post('/dept/updateInfo', data)
export const updateDeptStatus = (data) => post('/dept/updateStatus', data)
export const deleteDept = (data) => post('/dept/delete', data)
