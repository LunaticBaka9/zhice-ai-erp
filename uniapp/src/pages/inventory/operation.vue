<template>
	<view class="page">
		<view class="stats-grid">
			<view class="stat-card"><text class="stat-value">{{ statistics.pending }}</text><text class="stat-label">待处理</text></view>
			<view class="stat-card processing"><text class="stat-value">{{ statistics.processing }}</text><text class="stat-label">进行中</text></view>
			<view class="stat-card success"><text class="stat-value">{{ statistics.completed }}</text><text class="stat-label">已完成</text></view>
			<view class="stat-card danger"><text class="stat-value">{{ statistics.cancelled }}</text><text class="stat-label">已取消</text></view>
		</view>
		<view class="search-bar">
			<view class="search-input-wrapper">
				<text class="search-icon">🔍</text>
				<input class="search-input" v-model="keyword" placeholder="搜索单号/商品名称" @confirm="handleSearch" />
			</view>
			<view class="search-btn" @click="handleSearch"><text class="search-btn-text">搜索</text></view>
		</view>
		<view class="toolbar">
			<view class="toolbar-btn primary" @click="handleCreate"><text class="btn-text">+ 新建盘点</text></view>
		</view>
		<view class="list">
			<view class="list-item" v-for="item in operationList" :key="item.id">
				<view class="item-header">
					<text class="item-sku">{{ item.operationNo }}</text>
					<view class="stock-tag" :class="getStatusClass(item.status)"><text class="stock-tag-text">{{ getStatusText(item.status) }}</text></view>
				</view>
				<text class="item-name">{{ item.operationType === 'inbound' ? '入库盘点' : item.operationType === 'outbound' ? '出库盘点' : '调拨盘点' }}</text>
				<view class="item-row">
					<text class="item-meta">商品：{{ item.goodsName || '-' }}</text>
					<text class="item-meta">数量：{{ item.quantity || 0 }}</text>
				</view>
				<view class="item-row">
					<text class="item-meta">仓库：{{ item.warehouseName || '-' }}</text>
					<text class="item-meta">{{ item.createTime || '' }}</text>
				</view>
				<view class="item-actions">
					<view class="action-btn" v-if="item.status === 'pending'" @click="handleComplete(item)"><text class="action-text edit">完成</text></view>
					<view class="action-btn" v-if="item.status === 'pending'" @click="handleCancel(item)"><text class="action-text delete">取消</text></view>
				</view>
			</view>
			<view v-if="operationList.length === 0 && !loading" class="empty"><text>暂无盘点记录</text></view>
		</view>
		<Pagination :currentPage="pageNum" :pageSize="pageSize" :total="total" @update:currentPage="pageNum = $event" @change="loadList" />

		<view v-if="showModal" class="modal-mask" @click="showModal = false">
			<view class="modal-box" @click.stop>
				<text class="modal-title">新建盘点</text>
				<scroll-view scroll-y class="modal-scroll">
					<view class="modal-field">
						<text class="field-label">盘点类型 <text class="required">*</text></text>
						<view class="picker-wrapper" @click="showTypePicker = true">
							<text class="picker-text">{{ form.operationType ? (form.operationType === 'inbound' ? '入库盘点' : form.operationType === 'outbound' ? '出库盘点' : '调拨盘点') : '请选择盘点类型' }}</text>
							<text class="picker-arrow">▼</text>
						</view>
					</view>
					<view class="modal-field">
						<text class="field-label">选择商品 <text class="required">*</text></text>
						<view class="picker-wrapper" @click="showGoodsPicker = true">
							<text class="picker-text">{{ form.goodsName || '请选择商品' }}</text>
							<text class="picker-arrow">▼</text>
						</view>
					</view>
					<view class="modal-field">
						<text class="field-label">选择仓库 <text class="required">*</text></text>
						<view class="picker-wrapper" @click="showWarehousePicker = true">
							<text class="picker-text">{{ form.warehouseName || '请选择仓库' }}</text>
							<text class="picker-arrow">▼</text>
						</view>
					</view>
					<view class="modal-field">
						<text class="field-label">数量 <text class="required">*</text></text>
						<input class="field-input" v-model="form.quantity" type="number" placeholder="请输入数量" />
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

		<view v-if="showTypePicker" class="picker-mask" @click="showTypePicker = false">
			<view class="picker-content" @click.stop>
				<text class="picker-title">选择盘点类型</text>
				<view class="picker-option" v-for="opt in typeOptions" :key="opt.value" @click="selectType(opt)"><text class="picker-option-text">{{ opt.label }}</text></view>
			</view>
		</view>
		<view v-if="showGoodsPicker" class="picker-mask" @click="showGoodsPicker = false">
			<view class="picker-content" @click.stop>
				<text class="picker-title">选择商品</text>
				<scroll-view scroll-y class="picker-list">
					<view class="picker-option" v-for="g in goodsOptions" :key="g.id" @click="selectGoods(g)"><text class="picker-option-text">{{ g.name }}（{{ g.skuCode }}）</text></view>
				</scroll-view>
			</view>
		</view>
		<view v-if="showWarehousePicker" class="picker-mask" @click="showWarehousePicker = false">
			<view class="picker-content" @click.stop>
				<text class="picker-title">选择仓库</text>
				<scroll-view scroll-y class="picker-list">
					<view class="picker-option" v-for="w in warehouseOptions" :key="w.id" @click="selectWarehouse(w)"><text class="picker-option-text">{{ w.name }}</text></view>
				</scroll-view>
			</view>
		</view>
	</view>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { getInventoryList, addInventory, completeInventory, cancelInventory } from '@/api/inventory'
import Pagination from '@/components/Pagination.vue'

const keyword = ref('')
const operationList = ref([])
const loading = ref(false)
const pageNum = ref(1)
const pageSize = ref(10)
const total = ref(0)
const showModal = ref(false)
const showTypePicker = ref(false)
const showGoodsPicker = ref(false)
const showWarehousePicker = ref(false)

const goodsOptions = ref([])
const warehouseOptions = ref([])
const typeOptions = [
	{ value: 'inbound', label: '入库盘点' },
	{ value: 'outbound', label: '出库盘点' },
	{ value: 'transfer', label: '调拨盘点' }
]
const form = reactive({ id: null, operationType: '', goodsId: '', goodsName: '', warehouseId: '', warehouseName: '', quantity: '', remark: '' })

const statistics = computed(() => {
	let pending = 0, processing = 0, completed = 0, cancelled = 0
	operationList.value.forEach(item => {
		if (item.status === 'pending') pending++
		else if (item.status === 'processing') processing++
		else if (item.status === 'completed') completed++
		else if (item.status === 'cancelled') cancelled++
	})
	return { pending, processing, completed, cancelled }
})

function getStatusText(status) {
	const map = { pending: '待处理', processing: '进行中', completed: '已完成', cancelled: '已取消' }
	return map[status] || status
}
function getStatusClass(status) {
	const map = { pending: 'status-warning', processing: 'status-info', completed: 'status-success', cancelled: 'status-danger' }
	return map[status] || ''
}

async function loadList() {
	loading.value = true
	try {
		const res = await getInventoryList({ pageNum: pageNum.value, pageSize: pageSize.value, keyword: keyword.value })
		if (res.code === '200') {
			operationList.value = res.data.records || res.data.list || []
			total.value = res.data.total || operationList.value.length
		}
	} catch (e) { console.error(e) }
	finally { loading.value = false }
}

function handleSearch() { pageNum.value = 1; loadList() }
function handleCreate() {
	Object.assign(form, { id: null, operationType: '', goodsId: '', goodsName: '', warehouseId: '', warehouseName: '', quantity: '', remark: '' })
	showModal.value = true
}

function selectType(opt) { form.operationType = opt.value; showTypePicker.value = false }
function selectGoods(g) { form.goodsId = g.id; form.goodsName = g.name; showGoodsPicker.value = false }
function selectWarehouse(w) { form.warehouseId = w.id; form.warehouseName = w.name; showWarehousePicker.value = false }

function handleComplete(item) {
	uni.showModal({ title: '提示', content: '确定完成该盘点吗？',
		success: async (res) => {
			if (res.confirm) {
				const r = await completeInventory(item)
				if (r.code === '200') { uni.showToast({ title: '操作成功', icon: 'success' }); loadList() }
				else uni.showToast({ title: r.msg || '操作失败', icon: 'none' })
			}
		}
	})
}
function handleCancel(item) {
	uni.showModal({ title: '提示', content: '确定取消该盘点吗？',
		success: async (res) => {
			if (res.confirm) {
				const r = await cancelInventory(item)
				if (r.code === '200') { uni.showToast({ title: '已取消', icon: 'success' }); loadList() }
				else uni.showToast({ title: r.msg || '操作失败', icon: 'none' })
			}
		}
	})
}

async function submitForm() {
	if (!form.operationType || !form.goodsId || !form.warehouseId || !form.quantity) {
		uni.showToast({ title: '请填写完整信息', icon: 'none' }); return
	}
	const res = await addInventory(form)
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
.stat-card.processing .stat-value { color: #409EFF; }
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
.field-input { border: 1px solid #DCDFE6; border-radius: 8px; padding: 0 12px; height: 40px; font-size: 14px; width: 100%; }
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
