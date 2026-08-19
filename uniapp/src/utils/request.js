const BASE_URL = '/api'

const request = (options) => {
	return new Promise((resolve, reject) => {
		const token = uni.getStorageSync('token')
		const header = {
			'Content-Type': 'application/json;charset=utf-8',
			...options.header,
		}
		if (token) {
			header['token'] = token
		}
		if (options.isUpload) {
			delete header['Content-Type']
		}
		uni.request({
			url: BASE_URL + options.url,
			method: options.method || 'GET',
			data: options.data,
			header,
			timeout: 30000,
			success: (res) => {
				let data = res.data
				if (typeof data === 'string') {
					data = data ? JSON.parse(data) : data
				}
				if (res.statusCode === 401) {
					uni.showToast({ title: '登录已失效，请重新登录', icon: 'none' })
					uni.removeStorageSync('token')
					uni.removeStorageSync('local_user')
					setTimeout(() => {
						uni.redirectTo({ url: '/pages/login/index' })
					}, 1500)
					reject(data)
				} else if (res.statusCode === 404) {
					uni.showToast({ title: '未找到请求接口', icon: 'none' })
					reject(data)
				} else if (res.statusCode === 500) {
					uni.showToast({ title: '系统异常', icon: 'none' })
					reject(data)
				} else {
					resolve(data)
				}
			},
			fail: (err) => {
				uni.showToast({ title: '网络异常，请检查服务是否启动', icon: 'none' })
				reject(err)
			},
		})
	})
}

const get = (url, data) => request({ url, method: 'GET', data })
const post = (url, data) => request({ url, method: 'POST', data })
const del = (url, data) => request({ url, method: 'DELETE', data })

export default request
export { get, post, del }
