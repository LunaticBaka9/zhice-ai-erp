export function getStorage(key) {
	try {
		return uni.getStorageSync(key)
	} catch (e) {
		return null
	}
}

export function setStorage(key, value) {
	try {
		uni.setStorageSync(key, value)
	} catch (e) {
		console.error('setStorage error', e)
	}
}

export function removeStorage(key) {
	try {
		uni.removeStorageSync(key)
	} catch (e) {
		console.error('removeStorage error', e)
	}
}

export function getLocalUser() {
	try {
		const s = uni.getStorageSync('local_user')
		return s ? (typeof s === 'string' ? JSON.parse(s) : s) : null
	} catch (e) {
		return null
	}
}

export function setLocalUser(user) {
	uni.setStorageSync('local_user', JSON.stringify(user))
}

export function getToken() {
	return uni.getStorageSync('token') || ''
}

export function setToken(token) {
	uni.setStorageSync('token', token)
}

export function clearAuth() {
	uni.removeStorageSync('token')
	uni.removeStorageSync('local_user')
}
