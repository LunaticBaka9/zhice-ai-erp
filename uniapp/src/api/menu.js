import { get, post } from '@/utils/request'
export const getMenuList = (params) => get('/menu/list', params)
export const addMenu = (data) => post('/menu/add', data)
export const updateMenu = (data) => post('/menu/updateInfo', data)
export const deleteMenu = (data) => post('/menu/delete', data)
