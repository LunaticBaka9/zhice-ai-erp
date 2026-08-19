<template>
	<view class="userinfo-page">
		<view class="profile-card">
			<image class="avatar" :src="userInfo.avatar || defaultAvatar" mode="aspectFill"></image>
			<text class="user-name">{{ userInfo.name || '用户' }}</text>
			<text class="user-role">{{ userInfo.roleName || '' }}</text>
			<text class="user-dept">{{ userInfo.deptName || '' }}</text>
		</view>

		<view class="info-card">
			<view class="card-header">
				<text class="card-title">个人信息</text>
				<text class="card-action" @click="showEditModal = true">编辑</text>
			</view>
			<view class="info-row">
				<text class="info-label">姓名</text>
				<text class="info-value">{{ userInfo.name || '-' }}</text>
			</view>
			<view class="info-row">
				<text class="info-label">角色</text>
				<text class="info-value">{{ userInfo.roleName || '-' }}</text>
			</view>
			<view class="info-row">
				<text class="info-label">部门</text>
				<text class="info-value">{{ userInfo.deptName || '-' }}</text>
			</view>
			<view class="info-row">
				<text class="info-label">邮箱</text>
				<text class="info-value">{{ userInfo.email || '-' }}</text>
			</view>
			<view class="info-row">
				<text class="info-label">手机</text>
				<text class="info-value">{{ userInfo.phone || '-' }}</text>
			</view>
			<view class="info-row">
				<text class="info-label">入职时间</text>
				<text class="info-value">{{ userInfo.joinDate || '-' }}</text>
			</view>
		</view>

		<view class="security-card">
			<view class="card-header">
				<text class="card-title">安全设置</text>
			</view>
			<view class="security-item" @click="showPasswordModal = true">
				<view class="security-left">
					<text class="security-name">账户密码</text>
					<text class="security-desc">当前密码强度：强</text>
				</view>
				<text class="security-action">修改 ></text>
			</view>
			<view class="security-item" @click="showPhoneModal = true">
				<view class="security-left">
					<text class="security-name">绑定手机</text>
					<text class="security-desc">{{ userInfo.phone ? '已绑定：' + userInfo.phone : '未绑定' }}</text>
				</view>
				<text class="security-action">修改 ></text>
			</view>
			<view class="security-item" @click="showEmailModal = true">
				<view class="security-left">
					<text class="security-name">绑定邮箱</text>
					<text class="security-desc">{{ userInfo.email ? '已绑定：' + userInfo.email : '未绑定' }}</text>
				</view>
				<text class="security-action">修改 ></text>
			</view>
		</view>

		<view class="logout-btn" @click="handleLogout">
			<text class="logout-text">退出登录</text>
		</view>

		<view v-if="showPasswordModal" class="modal-mask" @click="showPasswordModal = false">
			<view class="modal-box" @click.stop>
				<text class="modal-title">修改密码</text>
				<view class="modal-field">
					<text class="field-label">当前密码</text>
					<input class="field-input" v-model="passwordForm.oldPassword" type="password" placeholder="请输入当前密码" />
				</view>
				<view class="modal-field">
					<text class="field-label">新密码</text>
					<input class="field-input" v-model="passwordForm.newPassword" type="password" placeholder="请输入新密码" />
				</view>
				<view class="modal-field">
					<text class="field-label">确认密码</text>
					<input class="field-input" v-model="passwordForm.confirmPassword" type="password" placeholder="请再次输入新密码" />
				</view>
				<view class="modal-btns">
					<view class="modal-btn cancel" @click="showPasswordModal = false"><text>取消</text></view>
					<view class="modal-btn confirm" @click="submitPassword"><text>确认修改</text></view>
				</view>
			</view>
		</view>
	</view>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { getUserById, updateUser, updatePassword } from '@/api/user'
import { getLocalUser, setLocalUser, clearAuth } from '@/utils/storage'

const defaultAvatar = 'https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png'
const userInfo = ref({})
const showPasswordModal = ref(false)
const showPhoneModal = ref(false)
const showEmailModal = ref(false)
const showEditModal = ref(false)
const passwordForm = reactive({ oldPassword: '', newPassword: '', confirmPassword: '' })

async function loadUserInfo() {
	const user = getLocalUser()
	if (!user?.uid) { uni.redirectTo({ url: '/pages/login/index' }); return }
	try {
		const res = await getUserById(user.uid)
		if (res.code === '200') userInfo.value = res.data
	} catch (e) { console.error(e) }
}

async function submitPassword() {
	if (!passwordForm.oldPassword || !passwordForm.newPassword) {
		uni.showToast({ title: '请填写完整', icon: 'none' }); return
	}
	if (passwordForm.newPassword !== passwordForm.confirmPassword) {
		uni.showToast({ title: '两次密码不一致', icon: 'none' }); return
	}
	try {
		const user = getLocalUser()
		const res = await updatePassword({ uid: user.uid, password: passwordForm.newPassword })
		if (res.code === '200') {
			uni.showToast({ title: '修改成功', icon: 'success' })
			showPasswordModal.value = false
		} else {
			uni.showToast({ title: res.msg || '修改失败', icon: 'none' })
		}
	} catch (e) { uni.showToast({ title: '修改失败', icon: 'none' }) }
}

function handleLogout() {
	uni.showModal({
		title: '提示', content: '确定要退出登录吗？',
		success: (res) => {
			if (res.confirm) {
				clearAuth()
				uni.redirectTo({ url: '/pages/login/index' })
			}
		}
	})
}

onMounted(() => { loadUserInfo() })
</script>

<style scoped>
.userinfo-page { background: #F5F7FA; min-height: 100vh; padding-bottom: 40px; }
.profile-card { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 40px 20px 30px; display: flex; flex-direction: column; align-items: center; }
.avatar { width: 80px; height: 80px; border-radius: 50%; border: 3px solid rgba(255,255,255,0.3); }
.user-name { font-size: 22px; font-weight: 600; color: #FFFFFF; margin-top: 12px; }
.user-role { font-size: 14px; color: rgba(255,255,255,0.8); margin-top: 4px; }
.user-dept { font-size: 13px; color: rgba(255,255,255,0.6); margin-top: 2px; }
.info-card, .security-card { background: #FFFFFF; margin: 12px 16px; border-radius: 10px; overflow: hidden; }
.card-header { display: flex; justify-content: space-between; align-items: center; padding: 14px 16px; border-bottom: 1px solid #F2F6FC; }
.card-title { font-size: 16px; font-weight: 500; color: #303133; }
.card-action { font-size: 14px; color: #409EFF; }
.info-row { display: flex; justify-content: space-between; padding: 12px 16px; border-bottom: 1px solid #F2F6FC; }
.info-row:last-child { border-bottom: none; }
.info-label { font-size: 14px; color: #909399; }
.info-value { font-size: 14px; color: #303133; }
.security-item { display: flex; justify-content: space-between; align-items: center; padding: 14px 16px; border-bottom: 1px solid #F2F6FC; }
.security-item:last-child { border-bottom: none; }
.security-name { font-size: 15px; color: #303133; }
.security-desc { font-size: 13px; color: #909399; margin-top: 2px; }
.security-action { font-size: 13px; color: #C0C4CC; }
.logout-btn { margin: 24px 16px; background: #FFFFFF; border-radius: 10px; padding: 14px; text-align: center; }
.logout-text { color: #F56C6C; font-size: 16px; }
.modal-mask { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); z-index: 1000; display: flex; align-items: center; justify-content: center; }
.modal-box { background: #FFFFFF; border-radius: 12px; width: 85%; padding: 24px; }
.modal-title { font-size: 17px; font-weight: 500; text-align: center; margin-bottom: 20px; }
.modal-field { margin-bottom: 16px; }
.field-label { font-size: 14px; color: #606266; margin-bottom: 6px; display: block; }
.field-input { border: 1px solid #DCDFE6; border-radius: 8px; padding: 0 12px; height: 40px; font-size: 14px; width: 100%; }
.modal-btns { display: flex; gap: 12px; margin-top: 20px; }
.modal-btn { flex: 1; height: 40px; display: flex; align-items: center; justify-content: center; border-radius: 8px; font-size: 14px; }
.cancel { background: #F5F7FA; color: #606266; }
.confirm { background: #409EFF; color: #FFFFFF; }
</style>
