<template>
	<view class="page">
		<view class="search-bar">
			<view class="search-input-wrapper">
				<text class="search-icon">🔍</text>
				<input class="search-input" v-model="keyword" placeholder="搜索仓库名称" @confirm="handleSearch" />
			</view>
			<view class="search-btn" @click="handleSearch"><text class="search-btn-text">搜索</text></view>
		</view>
		<view class="toolbar">
			<view class="toolbar-btn primary" @click="handleAdd"><text class="btn-text">+ 新增仓库</text></view>
		</view>
		<view class="list">
			<view class="list-item" v-for="item in list" :key="item.id">
				<view class="item-main">
					<text class="item-name">{{ item.name }}</text>
					<text class="item-meta">地址：{{ item.address || '-' }}</text>
					<text class="item-meta">电话：{{ item.phone || '-' }}</text>
					<text class="item-meta">负责人：{{ item.manager || '-' }}</text>
				</view>
				<view class="item-actions">
					<view class="action-btn" @click="handleEdit(item)"><text class="action-text edit">编辑</text></view>
					<view class="action-btn" @click="handleDelete(item)"><text class="action-text delete">删除</text></view>
				</view>
			</view>
			<view v-if="list.length === 0 && !loading" class="empty"><text>暂无仓库数据</text></view>
		</view>
		<Pagination :currentPage="pageNum" :pageSize="pageSize" :total="total" @update:currentPage="pageNum = $event" @change="loadList" />

		<view v-if="showModal" class="modal-mask" @click="showModal = false">
			<view class="modal-box" @click.stop>
				<text class="modal-title">{{ form.id ? '编辑仓库' : '新增仓库' }}</text>
				<scroll-view scroll-y class="modal-scroll">
					<view class="modal-field">
						<text class="field-label">仓库名称 <text class="required">*</text></text>
						<input class="field-input" v-model="form.name" placeholder="请输入仓库名称" />
					</view>
					<view class="modal-field">
						<text class="field-label">地址</text>
						<input class="field-input" v-model="form.address" placeholder="请输入仓库地址" />
					</view>
					<view class="modal-field">
						<text class="field-label">电话</text>
						<input class="field-input" v-model="form.phone" placeholder="请输入联系电话" />
					</view>
					<view class="modal-field">
						<text class="field-label">负责人</text>
						<input class="field-input" v-model="form.manager" placeholder="请输入负责人" />
					</view>
					<view class="modal-field">
						<text class="field-label">状态</text>
						<picker :range="statusOptions" :range-key="'label'" @change="handleStatusChange($event.detail.value)">
							<view class="field-input picker-field"><text>{{ currentStatusLabel }}</text></view>
						</picker>
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
import { getWarehouseList, addWarehouse, updateWarehouse, deleteWarehouse } from '@/api/warehouse'
import Pagination from '@/components/Pagination.vue'

const keyword = ref('')
const list = ref([])
const loading = ref(false)
const pageNum = ref(1)
const pageSize = ref(10)
const total = ref(0)
const showModal = ref(false)
const statusOptions = [{ label: '启用', value: 1 }, { label: '停用', value: 0 }]
const form = reactive({ id: null, name: '', address: '', phone: '', manager: '', status: 1 })

const currentStatusLabel = computed(() => {
	const found = statusOptions.find(s => s.value === form.status)
	return found ? found.label : '启用'
})

function handleStatusChange(index) {
	form.status = statusOptions[index].value
}

async function loadList() {
	loading.value = true
	try {
		const res = await getWarehouseList({ pageNum: pageNum.value, pageSize: pageSize.value, keyword: keyword.value })
		if (res.code === '200') {
			list.value = res.data.records || res.data.list || []
			total.value = res.data.total || list.value.length
		}
	} catch (e) { console.error(e) }
	finally { loading.value = false }
}

function handleSearch() { pageNum.value = 1; loadList() }
function handleAdd() {
	Object.assign(form, { id: null, name: '', address: '', phone: '', manager: '', status: 1 })
	showModal.value = true
}
function handleEdit(item) {
	Object.assign(form, { ...item })
	showModal.value = true
}
function handleDelete(item) {
	uni.showModal({
		title: '提示', content: `确认删除仓库【${item.name}】？`,
		success: async (res) => {
			if (res.confirm) {
				try {
					const r = await deleteWarehouse(item.id)
					if (r.code === '200') { uni.showToast({ title: '删除成功', icon: 'success' }); loadList() }
					else uni.showToast({ title: r.msg || '删除失败', icon: 'none' })
				} catch (e) { uni.showToast({ title: '删除失败', icon: 'none' }) }
			}
		}
	})
}
async function submitForm() {
	if (!form.name) { uni.showToast({ title: '请输入仓库名称', icon: 'none' }); return }
	try {
		const res = form.id ? await updateWarehouse(form) : await addWarehouse(form)
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
.toolbar { margin-bottom: 12px; }
.toolbar-btn { display: inline-flex; background: #409EFF; border-radius: 8px; padding: 0 16px; height: 36px; align-items: center; }
.btn-text { font-size: 14px; color: #FFFFFF; }
.list { display: flex; flex-direction: column; gap: 8px; }
.list-item { background: #FFFFFF; border-radius: 10px; padding: 14px; }
.item-main { }
.item-name { font-size: 16px; font-weight: 500; color: #303133; display: block; margin-bottom: 4px; }
.item-meta { font-size: 13px; color: #909399; display: block; margin-bottom: 2px; }
.item-actions { display: flex; gap: 16px; margin-top: 10px; padding-top: 10px; border-top: 1px solid #F2F6FC; }
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
.modal-btns { display: flex; border-top: 1px solid #F2F6FC; }
.modal-btn { flex: 1; height: 48px; display: flex; align-items: center; justify-content: center; font-size: 15px; }
.cancel { color: #606266; border-right: 1px solid #F2F6FC; }
.confirm { color: #409EFF; font-weight: 500; }
</style>
