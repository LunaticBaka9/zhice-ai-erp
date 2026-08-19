<template>
	<view class="page">
		<view class="stats-grid">
			<view class="stat-card warning"><text class="stat-value">{{ statistics.pending }}</text><text class="stat-label">待入库</text></view>
			<view class="stat-card success"><text class="stat-value">{{ statistics.confirmed }}</text><text class="stat-label">已入库</text></view>
			<view class="stat-card danger"><text class="stat-value">{{ statistics.draft }}</text><text class="stat-label">草稿</text></view>
			<view class="stat-card"><text class="stat-value">{{ statistics.total }}</text><text class="stat-label">总记录</text></view>
		</view>
		<view class="search-bar">
			<view class="search-input-wrapper">
				<text class="search-icon">🔍</text>
				<input class="search-input" v-model="keyword" placeholder="搜索入库单号/供应商" @confirm="handleSearch" />
			</view>
			<view class="search-btn" @click="handleSearch"><text class="search-btn-text">搜索</text></view>
		</view>
		<view class="toolbar">
			<view class="toolbar-btn primary" @click="handleCreate"><text class="btn-text">+ 新建入库</text></view>
		</view>
		<view class="list">
			<view class="list-item" v-for="item in inboundList" :key="item.id">
				<view class="item-header">
					<text class="item-sku">{{ item.inboundNo }}</text>
					<view class="stock-tag" :class="getStatusClass(item.status)"><text class="stock-tag-text">{{ getStatusText(item.status) }}</text></view>
				</view>
				<text class="item-name">{{ item.supplierName || '-' }}</text>
				<view class="item-row">
					<text class="item-meta">仓库：{{ item.warehouseName || '-' }}</text>
					<text class="item-meta">金额：¥{{ item.totalAmount || 0 }}</text>
				</view>
				<view class="item-row">
					<text class="item-meta">商品数：{{ item.itemCount || 0 }}</text>
					<text class="item-meta">{{ item.createTime || '' }}</text>
				</view>
				<view class="item-actions">
					<view class="action-btn" v-if="item.status === 'pending' || item.status === 'draft'" @click="handleConfirm(item)"><text class="action-text edit">确认入库</text></view>
					<view class="action-btn" v-if="item.status === 'draft'" @click="handleDelete(item)"><text class="action-text delete">删除</text></view>
				</view>
			</view>
			<view v-if="inboundList.length === 0 && !loading" class="empty"><text>暂无入库记录</text></view>
		</view>
		<Pagination :currentPage="pageNum" :pageSize="pageSize" :total="total" @update:currentPage="pageNum = $event" @change="loadList" />

		<view v-if="showModal" class="modal-mask" @click="showModal = false">
			<view class="modal-box" @click.stop>
				<text class="modal-title">新建入库</text>
				<scroll-view scroll-y class="modal-scroll">
					<view class="modal-field">
						<text class="field-label">选择采购单 <text class="required">*</text></text>
						<view class="picker-wrapper" @click="loadEligibleOrders">
							<text class="picker-text">{{ form.purchaseOrderNo || '请选择采购单' }}</text>
							<text class="picker-arrow">▼</text>
						</view>
					</view>
					<view class="modal-field">
						<text class="field-label">仓库 <text class="required">*</text></text>
						<view class="picker-wrapper" @click="showWarehousePicker = true">
							<text class="picker-text">{{ form.warehouseName || '请选择仓库' }}</text>
							<text class="picker-arrow">▼</text>
						</view>
					</view>
					<view class="modal-field">
						<text class="field-label">备注</text>
						<textarea class="field-textarea" v-model="form.remark" placeholder="请输入备注" />
					</view>
				</scroll-view>
				<view class="modal-btns">
					<view class="modal-btn cancel" @click="showModal = false"><text>取消</text></view>
					<view class="modal-btn confirm" @click="submitForm"><text>保存</text></view>
				</view>
			</view>
		</view>

		<view v-if="showWarehousePicker" class="picker-mask" @click="showWarehousePicker = false">
			<view class="picker-content" @click.stop>
				<text class="picker-title">选择仓库</text>
				<scroll-view scroll-y class="picker-list">
					<view class="picker-option" v-for="w in warehouseOptions" :key="w.id" @click="selectWarehouse(w)">
						<text class="picker-option-text">{{ w.name }}</text>
					</view>
				</scroll-view>
			</view>
		</view>
		<view v-if="showOrderPicker" class="picker-mask" @click="showOrderPicker = false">
			<view class="picker-content" @click.stop>
				<text class="picker-title">选择采购单</text>
				<scroll-view scroll-y class="picker-list">
					<view class="picker-option" v-for="o in eligibleOrders" :key="o.id" @click="selectOrder(o)">
						<text class="picker-option-text">{{ o.orderNo }} - ¥{{ o.totalAmount || 0 }}</text>
					</view>
					<view v-if="eligibleOrders.length === 0" class="picker-option"><text class="picker-option-text">无可选采购单</text></view>
				</scroll-view>
			</view>
		</view>
	</view>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { getInboundList, createInbound, confirmInbound, deleteDraftInbound, getEligibleInbound } from '@/api/purchase'
import Pagination from '@/components/Pagination.vue'

const keyword = ref('')
const inboundList = ref([])
const loading = ref(false)
const pageNum = ref(1)
const pageSize = ref(10)
const total = ref(0)
const showModal = ref(false)
const showWarehousePicker = ref(false)
const showOrderPicker = ref(false)

const warehouseOptions = ref([])
const eligibleOrders = ref([])
const form = reactive({ purchaseOrderId: '', purchaseOrderNo: '', warehouseId: '', warehouseName: '', remark: '' })

const statistics = computed(() => {
	let pending = 0, confirmed = 0, draft = 0
	inboundList.value.forEach(item => {
		if (item.status === 'pending') pending++
		else if (item.status === 'confirmed') confirmed++
		else if (item.status === 'draft') draft++
	})
	return { pending, confirmed, draft, total: inboundList.value.length }
})

function getStatusText(status) {
	const map = { draft: '草稿', pending: '待入库', confirmed: '已入库' }
	return map[status] || status
}
function getStatusClass(status) {
	const map = { draft: 'status-warning', pending: 'status-info', confirmed: 'status-success' }
	return map[status] || ''
}

async function loadList() {
	loading.value = true
	try {
		const res = await getInboundList({ pageNum: pageNum.value, pageSize: pageSize.value, keyword: keyword.value })
		if (res.code === '200') {
			inboundList.value = res.data.records || res.data.list || []
			total.value = res.data.total || inboundList.value.length
		}
	} catch (e) { console.error(e) }
	finally { loading.value = false }
}

function handleSearch() { pageNum.value = 1; loadList() }
function handleCreate() {
	Object.assign(form, { purchaseOrderId: '', purchaseOrderNo: '', warehouseId: '', warehouseName: '', remark: '' })
	showModal.value = true
}

async function loadEligibleOrders() {
	try {
		const res = await getEligibleInbound()
		if (res.code === '200') { eligibleOrders.value = res.data || [] }
	} catch (e) { console.error(e) }
	showOrderPicker.value = true
}
function selectOrder(o) { form.purchaseOrderId = o.id; form.purchaseOrderNo = o.orderNo; showOrderPicker.value = false }
function selectWarehouse(w) { form.warehouseId = w.id; form.warehouseName = w.name; showWarehousePicker.value = false }

function handleConfirm(item) {
	uni.showModal({ title: '提示', content: '确认该入库单吗？入库后库存将更新。',
		success: async (res) => {
			if (res.confirm) {
				const r = await confirmInbound(item)
				if (r.code === '200') { uni.showToast({ title: '已入库', icon: 'success' }); loadList() }
				else uni.showToast({ title: r.msg || '操作失败', icon: 'none' })
			}
		}
	})
}
function handleDelete(item) {
	uni.showModal({ title: '提示', content: '确定删除该草稿入库单吗？',
		success: async (res) => {
			if (res.confirm) {
				const r = await deleteDraftInbound(item)
				if (r.code === '200') { uni.showToast({ title: '已删除', icon: 'success' }); loadList() }
				else uni.showToast({ title: r.msg || '删除失败', icon: 'none' })
			}
		}
	})
}

async function submitForm() {
	if (!form.purchaseOrderId || !form.warehouseId) { uni.showToast({ title: '请填写完整信息', icon: 'none' }); return }
	const res = await createInbound(form)
	if (res.code === '200') { uni.showToast({ title: '保存成功', icon: 'success' }); showModal.value = false; loadList() }
	else uni.showToast({ title: res.msg || '操作失败', icon: 'none' })
}

onMounted(() => { loadList() })
</script>

<style scoped>
.page { background: #F5F7FA; min-height: 100vh; padding: 12px; }
.stats-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-bottom: 12px; }
.stat-card { background: #FFFFFF; border-radius: 10px; padding: 14px; text-align: center; }
.stat-value { font-size: 22px; font-weight: 600; color: #303133; display: block; }
.stat-card.danger .stat-value { color: #F56C6C; }
.stat-card.warning .stat-value { color: #E6A23C; }
.stat-card.success .stat-value { color: #67C23A; }
.stat-card.info .stat-value { color: #409EFF; }
.stat-label { font-size: 12px; color: #909399; display: block; margin-top: 4px; }
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
.item-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px; }
.item-sku { font-size: 13px; color: #909399; }
.stock-tag { padding: 2px 8px; border-radius: 4px; }
.stock-tag-text { font-size: 11px; }
.status-danger { color: #F56C6C; } .status-danger .stock-tag-text { color: #F56C6C; background: #FEF0F0; }
.status-warning { color: #E6A23C; } .status-warning .stock-tag-text { color: #E6A23C; background: #FDF6EC; }
.status-success { color: #67C23A; } .status-success .stock-tag-text { color: #67C23A; background: #F0F9EB; }
.status-info { color: #409EFF; } .status-info .stock-tag-text { color: #409EFF; background: #ECF5FF; }
.item-name { font-size: 16px; font-weight: 500; color: #303133; display: block; margin-bottom: 6px; }
.item-row { display: flex; justify-content: space-between; margin-bottom: 2px; }
.item-meta { font-size: 13px; color: #909399; }
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
.field-textarea { border: 1px solid #DCDFE6; border-radius: 8px; padding: 10px 12px; height: 80px; font-size: 14px; width: 100%; }
.modal-btns { display: flex; border-top: 1px solid #F2F6FC; }
.modal-btn { flex: 1; height: 48px; display: flex; align-items: center; justify-content: center; font-size: 15px; }
.cancel { color: #606266; border-right: 1px solid #F2F6FC; }
.confirm { color: #409EFF; font-weight: 500; }
.picker-wrapper { border: 1px solid #DCDFE6; border-radius: 8px; padding: 0 12px; height: 40px; display: flex; align-items: center; justify-content: space-between; }
.picker-text { font-size: 14px; color: #606266; }
.picker-arrow { font-size: 10px; color: #C0C4CC; }
.picker-mask { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); z-index: 1001; display: flex; align-items: flex-end; justify-content: center; }
.picker-content { background: #FFFFFF; border-radius: 12px 12px 0 0; width: 100%; max-height: 60vh; padding: 16px; }
.picker-title { font-size: 16px; font-weight: 500; text-align: center; margin-bottom: 12px; display: block; }
.picker-list { max-height: 40vh; }
.picker-option { padding: 14px 0; border-bottom: 1px solid #F2F6FC; }
.picker-option-text { font-size: 15px; color: #303133; }
</style>
