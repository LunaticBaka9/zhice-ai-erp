<template>
	<view class="login-page">
		<view class="login-bg">
			<view class="login-brand">
				<text class="brand-title">进销存管理系统</text>
				<text class="brand-subtitle">高效 · 智能 · 安全</text>
				<view class="feature-list">
					<text class="feature-item">✓ 实时库存监控</text>
					<text class="feature-item">✓ 智能预警系统</text>
					<text class="feature-item">✓ 多维度数据分析</text>
				</view>
			</view>
		</view>
		<view class="login-card">
			<text class="login-title">欢迎回来</text>
			<text class="login-desc">请登录您的账户</text>
			<view class="login-tabs">
				<view class="tab-item" :class="{ 'tab-active': loginType === 'account' }" @tap="switchTab('account')">
					<text class="tab-text">账号登录</text>
				</view>
				<view class="tab-item" :class="{ 'tab-active': loginType === 'email' }" @tap="switchTab('email')">
					<text class="tab-text">邮箱登录</text>
				</view>
			</view>

			<view v-if="loginType === 'account'" class="login-form">
				<view class="form-field">
					<text class="field-icon">👤</text>
					<input class="field-input" v-model="accountForm.username" placeholder="请输入账号" />
				</view>
				<view class="form-field">
					<text class="field-icon">🔒</text>
					<input class="field-input" v-model="accountForm.password" type="password" placeholder="请输入密码" />
				</view>
			</view>

			<view v-if="loginType === 'email'" class="login-form">
				<view class="form-field">
					<text class="field-icon">📧</text>
					<input class="field-input" v-model="emailForm.email" placeholder="请输入邮箱" />
				</view>
				<view class="form-field code-field">
					<text class="field-icon">🔑</text>
					<input class="field-input" v-model="emailForm.code" placeholder="请输入验证码" maxlength="6" />
					<view class="code-btn" :class="{ 'code-disabled': codeDisabled }" @tap="sendCode">
						<text class="code-btn-text">{{ codeDisabled ? codeCountdown + 's' : '获取验证码' }}</text>
					</view>
				</view>
			</view>

			<view class="login-btn" :class="{ 'btn-disabled': loading }" @tap="handleLogin">
				<text class="login-btn-text">{{ loading ? '登录中...' : '登 录' }}</text>
			</view>
			<view class="login-footer">
				<text class="footer-text">没有账号？</text>
				<text class="footer-link" @tap="goRegister">立即注册</text>
			</view>
		</view>
	</view>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { login as apiLogin, emailLogin as apiEmailLogin, sendEmailCode } from '@/api/auth'
import { setToken, setLocalUser } from '@/utils/storage'

const loginType = ref('account')
const loading = ref(false)
const codeDisabled = ref(false)
const codeCountdown = ref(0)

const accountForm = reactive({ username: '', password: '' })
const emailForm = reactive({ email: '', code: '' })

function switchTab(type) {
	if (loginType.value === type) return
	loginType.value = type
}

function handleLogin() {
	if (loading.value) return

	if (loginType.value === 'account') {
		if (!accountForm.username) {
			uni.showToast({ title: '请输入账号', icon: 'none' }); return
		}
		if (!accountForm.password) {
			uni.showToast({ title: '请输入密码', icon: 'none' }); return
		}
		doAccountLogin()
	} else {
		if (!emailForm.email) {
			uni.showToast({ title: '请输入邮箱', icon: 'none' }); return
		}
		if (!emailForm.code) {
			uni.showToast({ title: '请输入验证码', icon: 'none' }); return
		}
		doEmailLogin()
	}
}

function doAccountLogin() {
	loading.value = true
	apiLogin({ username: accountForm.username, password: accountForm.password }).then(res => {
		if (res.code === '200') {
			const userData = res.data?.user || res.data || {}
			const token = res.data?.token || ''
			setLocalUser(userData)
			if (token) setToken(token)
			uni.showToast({ title: '登录成功', icon: 'success' })
			setTimeout(() => { uni.switchTab({ url: '/pages/index/index' }) }, 1000)
		} else {
			uni.showToast({ title: res.msg || '登录失败', icon: 'none' })
		}
	}).catch(() => {
		uni.showToast({ title: '网络异常', icon: 'none' })
	}).finally(() => { loading.value = false })
}

function doEmailLogin() {
	loading.value = true
	apiEmailLogin({ email: emailForm.email, code: emailForm.code }).then(res => {
		if (res.code === '200') {
			const userData = res.data?.user || res.data || {}
			const token = res.data?.token || ''
			setLocalUser(userData)
			if (token) setToken(token)
			uni.showToast({ title: '登录成功', icon: 'success' })
			setTimeout(() => { uni.switchTab({ url: '/pages/index/index' }) }, 1000)
		} else {
			uni.showToast({ title: res.msg || '登录失败', icon: 'none' })
		}
	}).catch(() => {
		uni.showToast({ title: '网络异常', icon: 'none' })
	}).finally(() => { loading.value = false })
}

function sendCode() {
	if (codeDisabled.value) return
	if (!emailForm.email) {
		uni.showToast({ title: '请先输入邮箱', icon: 'none' }); return
	}
	sendEmailCode({ email: emailForm.email }).then(res => {
		if (res.code === '200') {
			uni.showToast({ title: '验证码已发送', icon: 'success' })
			startCountdown()
		} else {
			uni.showToast({ title: res.msg || '发送失败', icon: 'none' })
		}
	})
}

function startCountdown() {
	codeDisabled.value = true
	codeCountdown.value = 60
	const timer = setInterval(() => {
		codeCountdown.value--
		if (codeCountdown.value <= 0) {
			clearInterval(timer)
			codeDisabled.value = false
		}
	}, 1000)
}

function goRegister() {
	uni.showToast({ title: '注册功能开发中', icon: 'none' })
}
</script>

<style scoped>
.login-page { min-height: 100vh; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); display: flex; flex-direction: column; }
.login-bg { padding: 80px 30px 40px; }
.brand-title { font-size: 28px; font-weight: bold; color: #FFFFFF; }
.brand-subtitle { font-size: 14px; color: rgba(255,255,255,0.8); margin-top: 8px; }
.feature-list { margin-top: 24px; display: flex; flex-direction: column; gap: 12px; }
.feature-item { font-size: 14px; color: rgba(255,255,255,0.9); }
.login-card { flex: 1; background: #FFFFFF; border-radius: 20px 20px 0 0; padding: 30px 24px; }
.login-title { font-size: 22px; font-weight: 600; color: #303133; }
.login-desc { font-size: 14px; color: #909399; margin-top: 4px; margin-bottom: 24px; }
.login-tabs { display: flex; border-bottom: 1px solid #EBEEF5; margin-bottom: 20px; }
.tab-item { flex: 1; text-align: center; padding: 10px 0; }
.tab-text { font-size: 15px; color: #909399; }
.tab-active .tab-text { color: #409EFF; font-weight: 500; }
.tab-active { border-bottom: 2px solid #409EFF; }
.login-form { display: flex; flex-direction: column; gap: 16px; }
.form-field { display: flex; align-items: center; border: 1px solid #DCDFE6; border-radius: 8px; padding: 0 12px; height: 44px; }
.field-icon { margin-right: 8px; font-size: 16px; }
.field-input { flex: 1; font-size: 14px; }
.code-field { padding-right: 8px; }
.code-btn { background: #409EFF; border-radius: 6px; padding: 6px 12px; flex-shrink: 0; }
.code-btn-text { color: #FFFFFF; font-size: 12px; white-space: nowrap; }
.code-disabled { background: #C0C4CC; }
.login-btn { background: #409EFF; border-radius: 10px; height: 48px; display: flex; align-items: center; justify-content: center; margin-top: 24px; }
.login-btn-text { color: #FFFFFF; font-size: 16px; font-weight: 500; }
.btn-disabled { opacity: 0.6; }
.login-footer { display: flex; align-items: center; justify-content: center; margin-top: 20px; }
.footer-text { font-size: 14px; color: #909399; }
.footer-link { font-size: 14px; color: #409EFF; margin-left: 4px; }
</style>
