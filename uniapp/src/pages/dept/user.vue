<template>
	<view class="page">
		<view class="search-bar">
			<view class="search-input-wrapper">
				<input class="search-input" v-model="searchForm.username" placeholder="用户名" @confirm="handleSearch" />
			</view>
			<view class="search-input-wrapper">
				<input class="search-input" v-model="searchForm.name" placeholder="姓名" @confirm="handleSearch" />
			</view>
			<view class="search-btn" @click="handleSearch"><text class="btn-text">搜索</text></view>
			<view class="search-btn outline" @click="resetSearch"><text class="btn-text outline-text">重置</text></view>
		</view>
		<view class="toolbar">
			<view class="toolbar-btn primary" @click="handleAdd"><text class="btn-text white">+ 新增用户</text></view>
			<view class="toolbar-btn" @click="loadList"><text class="btn-text">刷新</text></view>
		</view>

		<view class="list">
			<view class="list-item" v-for="item in list" :key="item.uid">
				<view class="user-row">
					<image class="avatar" :src="item.avatar || defaultAvatar" mode="aspectFill" />
					<view class="user-info">
						<text class="user-name">{{ item.name }}</text>
						<text class="user-meta">{{ item.username }} · {{ item.deptName || '-' }}</text>
						<view class="user-tags">
							<view class="tag role"><text class="tag-text">{{ item.roleName || '-' }}</text></view>
							<view class="tag post"><text class="tag-text">{{ item.postName || '-' }}</text></view>
							<view class="tag" :class="'employed-' + (item.employed || '0')"><text class="tag-text">{{ employedMap[item.employed] || '未知' }}</text></view>
						</view>
					</view>
				</view>
				<view class="user-contact">
					<text class="contact-item" v-if="item.phone">手机: {{ item.phone }}</text>
					<text class="contact-item" v-if="item.email">邮箱: {{ item.email }}</text>
					<text class="contact-item" v-if="item.joinDate">入职: {{ item.joinDate }}</text>
				</view>
				<view class="item-footer">
					<text class="action-btn" @click="handleViewDetail(item)">查看</text>
					<text class="action-btn edit" @click="handleEdit(item)">编辑</text>
					<text class="action-btn delete" @click="handleDelete(item)">删除</text>
					<text class="action-btn" @click="handleResetPassword(item)">改密</text>
				</view>
			</view>
			<view v-if="list.length === 0 && !loading" class="empty"><text>暂无用户数据</text></view>
		</view>

		<Pagination :currentPage="pageNum" :pageSize="pageSize" :total="total" @update:currentPage="pageNum = $event" @change="loadList" />

		<!-- 新增/编辑弹窗 -->
		<view v-if="showModal" class="modal-mask" @click="showModal = false">
			<view class="modal-box" @click.stop>
				<text class="modal-title">{{ form.uid ? '编辑用户' : '新增用户' }}</text>
				<scroll-view scroll-y class="modal-scroll">
					<view class="modal-field">
						<text class="field-label">用户名 <text class="required">*</text></text>
						<input class="field-input" v-model="form.username" placeholder="请输入用户名" />
					</view>
					<view class="modal-field">
						<text class="field-label">姓名 <text class="required">*</text></text>
						<input class="field-input" v-model="form.name" placeholder="请输入姓名" />
					</view>
					<view class="modal-field" v-if="!form.uid">
						<text class="field-label">密码 <text class="required">*</text></text>
						<input class="field-input" v-model="form.password" type="password" placeholder="请输入密码" />
					</view>
					<view class="modal-field">
						<text class="field-label">角色 <text class="required">*</text></text>
						<picker :range="roleOptions" range-key="name" @change="handleRoleChange">
							<view class="field-input picker-field">
								<text>{{ form.roleName || '请选择角色' }}</text>
							</view>
						</picker>
					</view>
					<view class="modal-field">
						<text class="field-label">部门 <text class="required">*</text></text>
						<picker :range="deptOptions" range-key="name" @change="handleDeptChange">
							<view class="field-input picker-field">
								<text>{{ form.deptName || '请选择部门' }}</text>
							</view>
						</picker>
					</view>
					<view class="modal-field">
						<text class="field-label">手机号</text>
						<input class="field-input" v-model="form.phone" type="number" placeholder="请输入手机号" />
					</view>
					<view class="modal-field">
						<text class="field-label">邮箱</text>
						<input class="field-input" v-model="form.email" placeholder="请输入邮箱" />
					</view>
					<view class="modal-field">
						<text class="field-label">入职时间</text>
						<mode-picker mode="date" :value="form.joinDate" @change="handleJoinDateChange">
							<view class="field-input picker-field">
								<text>{{ form.joinDate || '请选择入职时间' }}</text>
							</view>
						</mode-picker>
					</view>
					<view class="modal-field">
						<text class="field-label">状态</text>
						<picker :range="statusOptions" range-key="label" @change="handleStatusChange">
							<view class="field-input picker-field">
								<text>{{ form.status || '启用' }}</text>
							</view>
						</picker>
					</view>
					<view class="modal-field">
						<text class="field-label">个人简介</text>
						<textarea class="field-textarea" v-model="form.bio" placeholder="请输入个人简介" :maxlength="200" />
					</view>
				</scroll-view>
				<view class="modal-btns">
					<view class="modal-btn cancel" @click="showModal = false"><text>取消</text></view>
					<view class="modal-btn confirm" @click="submitForm"><text>确认</text></view>
				</view>
			</view>
		</view>

		<!-- 详情弹窗 -->
		<view v-if="showDetail" class="modal-mask" @click="showDetail = false">
			<view class="modal-box" @click.stop>
				<text class="modal-title">用户详情</text>
				<scroll-view scroll-y class="modal-scroll">
					<view class="detail-list">
						<view class="detail-row"><text class="detail-label">用户名</text><text class="detail-value">{{ detailData.username }}</text></view>
						<view class="detail-row"><text class="detail-label">姓名</text><text class="detail-value">{{ detailData.name }}</text></view>
						<view class="detail-row"><text class="detail-label">部门</text><text class="detail-value">{{ detailData.deptName }}</text></view>
						<view class="detail-row"><text class="detail-label">职位</text><text class="detail-value">{{ detailData.postName }}</text></view>
						<view class="detail-row"><text class="detail-label">角色</text><text class="detail-value">{{ detailData.roleName }}</text></view>
						<view class="detail-row"><text class="detail-label">手机</text><text class="detail-value">{{ detailData.phone }}</text></view>
						<view class="detail-row"><text class="detail-label">邮箱</text><text class="detail-value">{{ detailData.email }}</text></view>
						<view class="detail-row"><text class="detail-label">入职时间</text><text class="detail-value">{{ detailData.joinDate }}</text></view>
						<view class="detail-row"><text class="detail-label">简介</text><text class="detail-value">{{ detailData.bio || '暂无' }}</text></view>
						<view class="detail-row"><text class="detail-label">在职状态</text><text class="detail-value">{{ employedMap[detailData.employed] || '未知' }}</text></view>
						<view class="detail-row"><text class="detail-label">账号状态</text><text class="detail-value">{{ detailData.status }}</text></view>
						<view class="detail-row"><text class="detail-label">创建时间</text><text class="detail-value">{{ detailData.createTime }}</text></view>
						<view class="detail-row"><text class="detail-label">更新时间</text><text class="detail-value">{{ detailData.updateTime }}</text></view>
					</view>
				</scroll-view>
				<view class="modal-btns">
					<view class="modal-btn confirm" @click="showDetail = false"><text>关闭</text></view>
				</view>
			</view>
		</view>

		<!-- 改密弹窗 -->
		<view v-if="showPwdModal" class="modal-mask" @click="showPwdModal = false">
			<view class="modal-box" @click.stop>
				<text class="modal-title">修改密码</text>
				<scroll-view scroll-y class="modal-scroll">
					<view class="modal-field">
						<text class="field-label">新密码 <text class="required">*</text></text>
						<input class="field-input" v-model="pwdForm.newPassword" type="password" placeholder="请输入新密码" />
					</view>
					<view class="modal-field">
						<text class="field-label">确认密码 <text class="required">*</text></text>
						<input class="field-input" v-model="pwdForm.confirmPassword" type="password" placeholder="请确认新密码" />
					</view>
				</scroll-view>
				<view class="modal-btns">
					<view class="modal-btn cancel" @click="showPwdModal = false"><text>取消</text></view>
					<view class="modal-btn confirm" @click="submitResetPassword"><text>确认重置</text></view>
				</view>
			</view>
		</view>
	</view>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { getUserList, addUser, updateUser, deleteUser, updatePassword, getAllRoles, getAllPosts } from '@/api/user'
import { getDeptList } from '@/api/dept'
import Pagination from '@/components/Pagination.vue'

const defaultAvatar = 'https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png'
const employedMap = { '0': '实习', '1': '试用', '2': '转正', '3': '离职' }

const searchForm = reactive({ username: '', name: '', roleName: '', postName: '', deptName: '' })
const list = ref([])
const loading = ref(false)
const pageNum = ref(1)
const pageSize = ref(10)
const total = ref(0)
const showModal = ref(false)
const showDetail = ref(false)
const showPwdModal = ref(false)
const detailData = ref({})
const pwdUserId = ref(null)

const roleOptions = ref([])
const postOptions = ref([])
const deptOptions = ref([])

const statusOptions = [{ value: '启用', label: '启用' }, { value: '禁用', label: '禁用' }]

const form = reactive({
	uid: null, username: '', name: '', password: '', roleName: '', deptName: '',
	phone: '', email: '', joinDate: '', status: '启用', bio: ''
})
const pwdForm = reactive({ newPassword: '', confirmPassword: '' })

async function loadRoles() {
	try {
		const res = await getAllRoles()
		if (res.code === '200') roleOptions.value = Array.isArray(res.data) ? res.data : []
	} catch (e) { console.error(e) }
}
async function loadPosts() {
	try {
		const res = await getAllPosts()
		if (res.code === '200') postOptions.value = Array.isArray(res.data) ? res.data : []
	} catch (e) { console.error(e) }
}
async function loadDepts() {
	try {
		const res = await getDeptList()
		if (res.code === '200') {
			const data = Array.isArray(res.data) ? res.data : (res.data.records || [])
			const flat = []
			const flatten = (list) => { for (const d of list) { flat.push(d); if (d.children && d.children.length) flatten(d.children) } }
			flatten(data)
			deptOptions.value = flat
		}
	} catch (e) { console.error(e) }
}

async function loadList() {
	loading.value = true
	try {
		const params = { pageNum: pageNum.value, pageSize: pageSize.value }
		Object.entries(searchForm).forEach(([k, v]) => { if (v) params[k] = v })
		const res = await getUserList(params)
		if (res.code === '200') {
			list.value = res.data.records || res.data.list || []
			total.value = res.data.total || 0
		}
	} catch (e) { console.error(e) }
	finally { loading.value = false }
}

function handleSearch() { pageNum.value = 1; loadList() }
function resetSearch() { Object.keys(searchForm).forEach(k => searchForm[k] = ''); pageNum.value = 1; loadList() }
function handleRoleChange(e) { form.roleName = roleOptions.value[e.detail.value]?.name || '' }
function handleDeptChange(e) { form.deptName = deptOptions.value[e.detail.value]?.name || '' }
function handleJoinDateChange(e) { form.joinDate = e.detail.value }
function handleStatusChange(e) { form.status = statusOptions[e.detail.value]?.value || '启用' }

function handleAdd() {
	Object.assign(form, { uid: null, username: '', name: '', password: '', roleName: '', deptName: '', phone: '', email: '', joinDate: '', status: '启用', bio: '' })
	showModal.value = true
}
function handleEdit(item) {
	Object.assign(form, {
		uid: item.uid, username: item.username || '', name: item.name || '', password: '',
		roleName: item.roleName || '', deptName: item.deptName || '', phone: item.phone || '',
		email: item.email || '', joinDate: item.joinDate || '', status: item.status || '启用', bio: item.bio || ''
	})
	showModal.value = true
}
function handleViewDetail(item) { detailData.value = { ...item }; showDetail.value = true }
function handleResetPassword(item) { pwdUserId.value = item.uid; pwdForm.newPassword = ''; pwdForm.confirmPassword = ''; showPwdModal.value = true }

async function submitForm() {
	if (!form.username) { uni.showToast({ title: '请输入用户名', icon: 'none' }); return }
	if (!form.name) { uni.showToast({ title: '请输入姓名', icon: 'none' }); return }
	if (!form.uid && !form.password) { uni.showToast({ title: '请输入密码', icon: 'none' }); return }
	if (!form.roleName) { uni.showToast({ title: '请选择角色', icon: 'none' }); return }
	if (!form.deptName) { uni.showToast({ title: '请选择部门', icon: 'none' }); return }
	try {
		const fn = form.uid ? updateUser : addUser
		const data = { ...form }
		if (form.uid) delete data.password
		const res = await fn(data)
		if (res.code === '200') {
			uni.showToast({ title: '保存成功', icon: 'success' })
			showModal.value = false; loadList()
		} else uni.showToast({ title: res.msg || '操作失败', icon: 'none' })
	} catch (e) { uni.showToast({ title: '提交失败', icon: 'none' }) }
}

function handleDelete(item) {
	uni.showModal({
		title: '提示', content: `确认删除用户「${item.name}」？`,
		success: async (res) => {
			if (res.confirm) {
				try {
					const r = await deleteUser({ uid: item.uid })
					if (r.code === '200') { uni.showToast({ title: '删除成功', icon: 'success' }); loadList() }
					else uni.showToast({ title: r.msg || '删除失败', icon: 'none' })
				} catch (e) { uni.showToast({ title: '删除失败', icon: 'none' }) }
			}
		}
	})
}

async function submitResetPassword() {
	if (!pwdForm.newPassword) { uni.showToast({ title: '请输入新密码', icon: 'none' }); return }
	if (pwdForm.newPassword !== pwdForm.confirmPassword) { uni.showToast({ title: '两次密码不一致', icon: 'none' }); return }
	if (pwdForm.newPassword.length < 6) { uni.showToast({ title: '密码至少6位', icon: 'none' }); return }
	try {
		const res = await updatePassword({ uid: pwdUserId.value, password: pwdForm.newPassword })
		if (res.code === '200') {
			uni.showToast({ title: '密码修改成功', icon: 'success' })
			showPwdModal.value = false
		} else uni.showToast({ title: res.msg || '修改失败', icon: 'none' })
	} catch (e) { uni.showToast({ title: '修改失败', icon: 'none' }) }
}

onMounted(() => { loadList(); loadRoles(); loadPosts(); loadDepts() })
</script>

<style scoped>
.page { background: #F5F7FA; min-height: 100vh; padding: 12px; }
.search-bar { display: flex; gap: 8px; margin-bottom: 12px; flex-wrap: wrap; }
.search-input-wrapper { flex: 1; min-width: 120px; display: flex; align-items: center; background: #FFFFFF; border: 1px solid #DCDFE6; border-radius: 8px; padding: 0 10px; height: 38px; }
.search-input { flex: 1; font-size: 14px; }
.search-btn { background: #409EFF; border-radius: 8px; padding: 0 16px; display: flex; align-items: center; height: 38px; }
.search-btn.outline { background: #FFFFFF; border: 1px solid #DCDFE6; }
.btn-text { font-size: 14px; color: #FFFFFF; }
.outline-text { color: #606266; }
.toolbar { display: flex; gap: 10px; margin-bottom: 12px; }
.toolbar-btn { background: #FFFFFF; border: 1px solid #DCDFE6; border-radius: 8px; padding: 0 16px; height: 36px; display: flex; align-items: center; }
.toolbar-btn.primary { background: #409EFF; border-color: #409EFF; }
.white { color: #FFFFFF; }
.list { display: flex; flex-direction: column; gap: 8px; }
.list-item { background: #FFFFFF; border-radius: 10px; padding: 14px; }
.user-row { display: flex; gap: 10px; margin-bottom: 8px; }
.avatar { width: 44px; height: 44px; border-radius: 50%; background: #F5F7FA; }
.user-info { flex: 1; }
.user-name { font-size: 16px; font-weight: 500; color: #303133; display: block; }
.user-meta { font-size: 12px; color: #909399; display: block; margin: 2px 0 6px; }
.user-tags { display: flex; gap: 6px; flex-wrap: wrap; }
.tag { padding: 2px 8px; border-radius: 4px; }
.tag.role { background: #ECF5FF; } .tag.role .tag-text { color: #409EFF; }
.tag.post { background: #FDF6EC; } .tag.post .tag-text { color: #E6A23C; }
.tag.employed-0 { background: #F4F4F5; } .tag.employed-0 .tag-text { color: #909399; }
.tag.employed-1 { background: #FDF6EC; } .tag.employed-1 .tag-text { color: #E6A23C; }
.tag.employed-2 { background: #F0F9EB; } .tag.employed-2 .tag-text { color: #67C23A; }
.tag.employed-3 { background: #FEF0F0; } .tag.employed-3 .tag-text { color: #F56C6C; }
.tag-text { font-size: 12px; }
.user-contact { display: flex; flex-wrap: wrap; gap: 12px; margin-bottom: 8px; }
.contact-item { font-size: 12px; color: #909399; }
.item-footer { display: flex; gap: 16px; border-top: 1px solid #F2F6FC; padding-top: 8px; }
.action-btn { font-size: 13px; color: #409EFF; }
.action-btn.delete { color: #F56C6C; }
.empty { padding: 60px 0; text-align: center; color: #909399; font-size: 14px; }
.modal-mask { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); z-index: 1000; display: flex; align-items: center; justify-content: center; }
.modal-box { background: #FFFFFF; border-radius: 12px; width: 92%; max-height: 85vh; display: flex; flex-direction: column; }
.modal-title { font-size: 17px; font-weight: 500; text-align: center; padding: 16px; border-bottom: 1px solid #F2F6FC; }
.modal-scroll { flex: 1; max-height: 60vh; padding: 16px; }
.modal-field { margin-bottom: 14px; }
.field-label { font-size: 14px; color: #606266; margin-bottom: 6px; display: block; }
.required { color: #F56C6C; }
.field-input { border: 1px solid #DCDFE6; border-radius: 8px; padding: 0 12px; height: 40px; font-size: 14px; width: 100%; }
.picker-field { display: flex; align-items: center; }
.field-textarea { border: 1px solid #DCDFE6; border-radius: 8px; padding: 10px 12px; font-size: 14px; width: 100%; height: 80px; }
.modal-btns { display: flex; border-top: 1px solid #F2F6FC; }
.modal-btn { flex: 1; height: 48px; display: flex; align-items: center; justify-content: center; font-size: 15px; }
.cancel { color: #606266; border-right: 1px solid #F2F6FC; }
.confirm { color: #409EFF; font-weight: 500; }
.detail-list { display: flex; flex-direction: column; }
.detail-row { display: flex; padding: 10px 0; border-bottom: 1px solid #F2F6FC; }
.detail-label { width: 80px; font-size: 14px; color: #909399; flex-shrink: 0; }
.detail-value { flex: 1; font-size: 14px; color: #303133; }
</style>
