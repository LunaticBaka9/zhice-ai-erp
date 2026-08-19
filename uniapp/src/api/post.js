import { get, post } from '@/utils/request'
export const getAllPosts = () => get('/post/all')
export const getPostsList = () => get('/post/list')
export const addPost = (data) => post('/post/add', data)
export const updatePost = (data) => post('/post/updateInfo', data)
export const deletePost = (data) => post('/post/delete', data)
export const updatePostStatus = (data) => post('/post/updateStatus', data)
export const exportPosts = () => get('/post/exportData')
