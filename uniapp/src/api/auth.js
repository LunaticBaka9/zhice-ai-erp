import { post } from '@/utils/request'
export const login = (data) => post('/login', data)
export const emailLogin = (data) => post('/emailLogin', data)
export const sendEmailCode = (data) => post('/sendEmailCode', data)
export const register = (data) => post('/register', data)
export const emailRegister = (data) => post('/emailRegister', data)
export const sendEmailRegCode = (data) => post('/sendEmailRegCode', data)
