<template>
	<view class="page">
		<view class="search-bar">
			<view class="search-input-wrapper">
				<text class="search-icon">🔍</text>
				<input class="search-input" v-model="keyword" placeholder="搜索公告标题" @confirm="handleSearch" />
			</view>
			<view class="search-btn" @click="handleSearch"><text class="search-btn-text">搜索</text></view>
		</view>
		<view class="toolbar">
			<view class="toolbar-btn primary" @click="handleAdd"><text class="btn-text">+ 发布公告</text></view>
			<view class="toolbar-btn" @click="loadList"><text class="btn-text">刷新</text></view>
		</view>
		<view class="list">
			<view class="list-item" v-for="item in list" :key="item.nid || item.id">
				<view class="item-header">
					<text class="item-title">{{ item.title }}</text>
					<view class="type-tag" :class="'type-' + (item.type || 0)">
						<text class="type-text">{{ typeMap[item.type] || '其他' }}</text>
					</view>
				</view>
				<text class="item-summary">{{ item.content || '暂无内容' }}</text>
				<view class="item-footer">
					<text class="item-time">{{ item.createTime || '-' }}</text>
					<view class="item-actions">
						<view class="action-btn" @click="handleEdit(item)"><text class="action-text edit">编辑</text></view>
						<view class="action-btn" @click="handleDelete(item)"><text class="action-text delete">删除</text></view>
					</view>
				</view>
			</view>
			<view v-if="list.length === 0 && !loading" class="empty"><text>暂无公告</text></view>
		</view>
		<Pagination :currentPage="pageNum" :pageSize="pageSize" :total="total" @update:currentPage="pageNum = $event" @change="loadList" />

		<view v-if="showModal" class="modal-mask" @click="showModal = false">
			<view class="modal-box" @click.stop>
				<text class="modal-title">{{ form.nid ? '编辑公告' : '发布公告' }}</text>
				<scroll-view scroll-y class="modal-scroll">
					<view class="modal-field">
						<text class="field-label">标题 <text class="required">*</text></text>
						<input class="field-input" v-model="form.title" placeholder="请输入公告标题" />
					</view>
					<view class="modal-field">
						<text class="field-label">类型 <text class="required">*</text></text>
						<picker :range="typeOptions" range-key="label" @change="handleTypeChange">
							<view class="field-input picker-field">
								<text>{{ selectedTypeLabel || '请选择类型' }}</text>
							</view>
						</picker>
					</view>
					<view class="modal-field">
						<text class="field-label">内容 <text class="required">*</text></text>
						<textarea class="field-textarea" v-model="form.content" placeholder="请输入公告内容" :maxlength="2000" />
					</view>
				</scroll-view>
				<view class="modal-btns">
					<view class="modal-btn cancel" @click="showModal = false"><text>取消</text></view>
					<view class="modal-btn confirm" @click="submitForm"><text>保存</text></view>
				</view>
			</view>
		</view>
	</view>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { getNoticeList, postNotice, deleteNotice } from '@/api/notice'
import Pagination from '@/components/Pagination.vue'

const keyword = ref('')
const list = ref([])
const loading = ref(false)
const pageNum = ref(1)
const pageSize = ref(10)
const total = ref(0)
const showModal = ref(false)

const typeMap = { 0: '系统更新', 1: '维护通知', 2: '功能上线', 3: '其他' }
const typeOptions = [
	{ value: 0, label: '系统更新' },
	{ value: 1, label: '维护通知' },
	{ value: 2, label: '功能上线' },
	{ value: 3, label: '其他' },
]

const form = reactive({ nid: null, title: '', type: 0, content: '' })

const selectedTypeLabel = computed(() => {
	const opt = typeOptions.find(o => o.value === form.type)
	return opt ? opt.label : ''
})

function handleTypeChange(e) {
	const idx = e.detail.value
	form.type = typeOptions[idx]?.value ?? 0
}

async function loadList() {
	loading.value = true
	try {
		const res = await getNoticeList({ pageNum: pageNum.value, pageSize: pageSize.value, keyword: keyword.value })
		if (res.code === '200') {
			list.value = res.data.records || res.data.list || []
			total.value = res.data.total || list.value.length
		}
	} catch (e) { console.error(e) }
	finally { loading.value = false }
}

function handleSearch() { pageNum.value = 1; loadList() }
function handleAdd() {
	Object.assign(form, { nid: null, title: '', type: 0, content: '' })
	showModal.value = true
}
function handleEdit(item) {
	Object.assign(form, { nid: item.nid || item.id, title: item.title || '', type: item.type || 0, content: item.content || '' })
	showModal.value = true
}
function handleDelete(item) {
	uni.showModal({
		title: '提示', content: `确认删除公告【${item.title}】？`,
		success: async (res) => {
			if (res.confirm) {
				try {
					const r = await deleteNotice({ id: item.nid || item.id })
					if (r.code === '200') { uni.showToast({ title: '删除成功', icon: 'success' }); loadList() }
					else uni.showToast({ title: r.msg || '删除失败', icon: 'none' })
				} catch (e) { uni.showToast({ title: '删除失败', icon: 'none' }) }
			}
		}
	})
}
async function submitForm() {
	if (!form.title) { uni.showToast({ title: '请输入标题', icon: 'none' }); return }
	if (!form.content) { uni.showToast({ title: '请输入内容', icon: 'none' }); return }
	try {
		const res = await postNotice(form)
		if (res.code === '200') {
			uni.showToast({ title: '保存成功', icon: 'success' })
			showModal.value = false; loadList()
		} else uni.showToast({ title: res.msg || '操作失败', icon: 'none' })
	} catch (e) { uni.showToast({ title: '提交失败', icon: 'none' }) }
}

onMounted(() => { loadList() })
</script>

<style scoped>
.page { background: #F5F7FA; min-height: 100vh; padding: 12px; }
.search-bar { display: flex; gap: 8px; margin-bottom: 12px; }
.search-input-wrapper { flex: 1; display: flex; align-items: center; background: #FFFFFF; border: 1px solid #DCDFE6; border-radius: 8px; padding: 0 10px; height: 38px; }
.search-icon { margin-right: 6px; font-size: 14px; }
.search-input { flex: 1; font-size: 14px; }
.search-btn { background: #409EFF; border-radius: 8px; padding: 0 16px; display: flex; align-items: center; }
.search-btn-text { color: #FFFFFF; font-size: 14px; }
.toolbar { display: flex; gap: 10px; margin-bottom: 12px; }
.toolbar-btn { background: #FFFFFF; border: 1px solid #DCDFE6; border-radius: 8px; padding: 0 16px; height: 36px; display: flex; align-items: center; }
.toolbar-btn.primary { background: #409EFF; border-color: #409EFF; }
.btn-text { font-size: 14px; color: #303133; }
.toolbar-btn.primary .btn-text { color: #FFFFFF; }
.list { display: flex; flex-direction: column; gap: 8px; }
.list-item { background: #FFFFFF; border-radius: 10px; padding: 14px; }
.item-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 6px; }
.item-title { font-size: 16px; font-weight: 500; color: #303133; flex: 1; margin-right: 8px; }
.type-tag { padding: 2px 8px; border-radius: 4px; flex-shrink: 0; }
.type-text { font-size: 12px; }
.type-0 { background: #ECF5FF; } .type-0 .type-text { color: #409EFF; }
.type-1 { background: #FDF6EC; } .type-1 .type-text { color: #E6A23C; }
.type-2 { background: #F0F9EB; } .type-2 .type-text { color: #67C23A; }
.type-3 { background: #F0F2F5; } .type-3 .type-text { color: #909399; }
.item-summary { font-size: 13px; color: #909399; display: block; margin-bottom: 8px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.item-footer { display: flex; justify-content: space-between; align-items: center; }
.item-time { font-size: 12px; color: #C0C4CC; }
.item-actions { display: flex; gap: 16px; }
.action-text { font-size: 14px; }
.action-text.edit { color: #409EFF; }
.action-text.delete { color: #F56C6C; }
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
.field-textarea { border: 1px solid #DCDFE6; border-radius: 8px; padding: 10px 12px; font-size: 14px; width: 100%; height: 120px; }
.modal-btns { display: flex; border-top: 1px solid #F2F6FC; }
.modal-btn { flex: 1; height: 48px; display: flex; align-items: center; justify-content: center; font-size: 15px; }
.cancel { color: #606266; border-right: 1px solid #F2F6FC; }
.confirm { color: #409EFF; font-weight: 500; }
</style>
