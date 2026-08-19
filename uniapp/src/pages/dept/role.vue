<template>
	<view class="page">
		<view class="search-bar">
			<view class="search-input-wrapper">
				<input class="search-input" v-model="keyword" placeholder="搜索角色名称" @confirm="handleSearch" />
			</view>
			<view class="search-btn" @click="handleSearch"><text class="btn-text">搜索</text></view>
			<view class="search-btn outline" @click="resetSearch"><text class="btn-text outline-text">重置</text></view>
		</view>
		<view class="toolbar">
			<view class="toolbar-btn primary" @click="handleAdd"><text class="btn-text white">+ 新增角色</text></view>
			<view class="toolbar-btn" @click="loadList"><text class="btn-text">刷新</text></view>
		</view>

		<view class="list">
			<view class="list-item" v-for="item in list" :key="item.id">
				<view class="item-header">
					<text class="item-id">ID: {{ item.id }}</text>
					<view class="status-tag" :class="item.status === 1 ? 'active' : 'inactive'">
						<text class="status-text">{{ item.status === 1 ? '启用' : '禁用' }}</text>
					</view>
				</view>
				<text class="item-name">{{ item.name }}</text>
				<text class="item-desc" v-if="item.bio">{{ item.bio }}</text>
				<view class="item-footer">
					<text class="action-btn edit" @click="handleEdit(item)">编辑</text>
					<text class="action-btn delete" @click="handleDelete(item)">删除</text>
				</view>
			</view>
			<view v-if="list.length === 0 && !loading" class="empty"><text>暂无角色数据</text></view>
		</view>

		<Pagination :currentPage="pageNum" :pageSize="pageSize" :total="total" @update:currentPage="pageNum = $event" @change="loadList" />

		<view v-if="showModal" class="modal-mask" @click="showModal = false">
			<view class="modal-box" @click.stop>
				<text class="modal-title">{{ form.id ? '编辑角色' : '新增角色' }}</text>
				<scroll-view scroll-y class="modal-scroll">
					<view class="modal-field">
						<text class="field-label">角色名称 <text class="required">*</text></text>
						<input class="field-input" v-model="form.name" placeholder="请输入角色名称" />
					</view>
					<view class="modal-field">
						<text class="field-label">状态</text>
						<picker :range="statusOptions" range-key="label" @change="handleStatusChange">
							<view class="field-input picker-field">
								<text>{{ form.status === 1 ? '启用' : '禁用' }}</text>
							</view>
						</picker>
					</view>
					<view class="modal-field">
						<text class="field-label">角色简介</text>
						<textarea class="field-textarea" v-model="form.bio" placeholder="请输入角色简介" :maxlength="200" />
					</view>
				</scroll-view>
				<view class="modal-btns">
					<view class="modal-btn cancel" @click="showModal = false"><text>取消</text></view>
					<view class="modal-btn confirm" @click="submitForm"><text>确认</text></view>
				</view>
			</view>
		</view>
	</view>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { getRoleList, addRole, updateRole, deleteRole } from '@/api/role'
import Pagination from '@/components/Pagination.vue'

const keyword = ref('')
const list = ref([])
const loading = ref(false)
const pageNum = ref(1)
const pageSize = ref(10)
const total = ref(0)
const showModal = ref(false)

const form = reactive({ id: null, name: '', bio: '', status: 1 })
const statusOptions = [{ value: 1, label: '启用' }, { value: 0, label: '禁用' }]

async function loadList() {
	loading.value = true
	try {
		const params = { pageNum: pageNum.value, pageSize: pageSize.value }
		if (keyword.value) params.name = keyword.value
		const res = await getRoleList(params)
		if (res.code === '200') {
			list.value = res.data.records || []
			total.value = res.data.total || 0
		}
	} catch (e) { console.error(e) }
	finally { loading.value = false }
}

function handleSearch() { pageNum.value = 1; loadList() }
function resetSearch() { keyword.value = ''; pageNum.value = 1; loadList() }

function handleAdd() {
	Object.assign(form, { id: null, name: '', bio: '', status: 1 })
	showModal.value = true
}

function handleEdit(item) {
	Object.assign(form, { id: item.id, name: item.name || '', bio: item.bio || '', status: item.status ?? 1 })
	showModal.value = true
}

function handleStatusChange(e) {
	const idx = e.detail.value
	form.status = statusOptions[idx]?.value ?? 1
}

async function submitForm() {
	if (!form.name) { uni.showToast({ title: '请输入角色名称', icon: 'none' }); return }
	try {
		const fn = form.id ? updateRole : addRole
		const res = await fn({ ...form })
		if (res.code === '200') {
			uni.showToast({ title: '保存成功', icon: 'success' })
			showModal.value = false; loadList()
		} else uni.showToast({ title: res.msg || '操作失败', icon: 'none' })
	} catch (e) { uni.showToast({ title: '提交失败', icon: 'none' }) }
}

function handleDelete(item) {
	uni.showModal({
		title: '提示', content: `确认删除角色「${item.name}」？`,
		success: async (res) => {
			if (res.confirm) {
				try {
					const r = await deleteRole({ id: item.id })
					if (r.code === '200') { uni.showToast({ title: '删除成功', icon: 'success' }); loadList() }
					else uni.showToast({ title: r.msg || '删除失败', icon: 'none' })
				} catch (e) { uni.showToast({ title: '删除失败', icon: 'none' }) }
			}
		}
	})
}

onMounted(() => { loadList() })
</script>

<style scoped>
.page { background: #F5F7FA; min-height: 100vh; padding: 12px; }
.search-bar { display: flex; gap: 8px; margin-bottom: 12px; }
.search-input-wrapper { flex: 1; display: flex; align-items: center; background: #FFFFFF; border: 1px solid #DCDFE6; border-radius: 8px; padding: 0 10px; height: 38px; }
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
.item-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px; }
.item-id { font-size: 12px; color: #C0C4CC; }
.status-tag { padding: 2px 8px; border-radius: 4px; }
.status-tag.active { background: #F0F9EB; }
.status-tag.active .status-text { color: #67C23A; }
.status-tag.inactive { background: #FEF0F0; }
.status-tag.inactive .status-text { color: #F56C6C; }
.status-text { font-size: 12px; }
.item-name { font-size: 16px; font-weight: 500; color: #303133; display: block; margin-bottom: 4px; }
.item-desc { font-size: 13px; color: #909399; display: block; margin-bottom: 8px; }
.item-footer { display: flex; gap: 20px; }
.action-btn { font-size: 14px; }
.action-btn.edit { color: #409EFF; }
.action-btn.delete { color: #F56C6C; }
.empty { padding: 60px 0; text-align: center; color: #909399; font-size: 14px; }
.modal-mask { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); z-index: 1000; display: flex; align-items: center; justify-content: center; }
.modal-box { background: #FFFFFF; border-radius: 12px; width: 90%; max-height: 80vh; display: flex; flex-direction: column; }
.modal-title { font-size: 17px; font-weight: 500; text-align: center; padding: 16px; border-bottom: 1px solid #F2F6FC; }
.modal-scroll { flex: 1; max-height: 55vh; padding: 16px; }
.modal-field { margin-bottom: 14px; }
.field-label { font-size: 14px; color: #606266; margin-bottom: 6px; display: block; }
.required { color: #F56C6C; }
.field-input { border: 1px solid #DCDFE6; border-radius: 8px; padding: 0 12px; height: 40px; font-size: 14px; width: 100%; }
.picker-field { display: flex; align-items: center; }
.field-textarea { border: 1px solid #DCDFE6; border-radius: 8px; padding: 10px 12px; font-size: 14px; width: 100%; height: 100px; }
.modal-btns { display: flex; border-top: 1px solid #F2F6FC; }
.modal-btn { flex: 1; height: 48px; display: flex; align-items: center; justify-content: center; font-size: 15px; }
.cancel { color: #606266; border-right: 1px solid #F2F6FC; }
.confirm { color: #409EFF; font-weight: 500; }
</style>
