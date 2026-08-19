import { post } from '@/utils/request'
export const uploadFile = (formData) => post('/file/upload', formData, { isUpload: true })
export const uploadAvatar = (formData) => post('/file/uploadAvatar', formData, { isUpload: true })
