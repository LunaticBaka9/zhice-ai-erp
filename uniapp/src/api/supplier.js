import { get, post, del } from '@/utils/request'
export const getSupplierList = (params) => get('/supplier/list', params)
export const getAllSuppliers = () => get('/supplier/selectAllCustomer')
export const addSupplier = (data) => post('/supplier/add', data)
export const updateSupplier = (data) => post('/supplier/update', data)
export const deleteSupplier = (id) => del(`/supplier/delete/${id}`)
