import { get, post } from '@/utils/request'
export const getAllRoles = () => get('/role/all')
export const getRoleList = (params) => get('/role/list', params)
export const addRole = (data) => post('/role/add', data)
export const updateRole = (data) => post('/role/updateInfo', data)
export const deleteRole = (data) => post('/role/delete', data)
export const updateRoleStatus = (data) => post('/role/updateStatus', data)
export const exportRoles = () => get('/role/exportData')
