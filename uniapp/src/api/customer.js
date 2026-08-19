import { get, post, del } from '@/utils/request'
export const getCustomerList = (params) => get('/customer/list', params)
export const getAllCustomers = () => get('/customer/selectAllCustomer')
export const addCustomer = (data) => post('/customer/add', data)
export const updateCustomer = (data) => post('/customer/update', data)
export const deleteCustomer = (id) => del(`/customer/${id}`)
