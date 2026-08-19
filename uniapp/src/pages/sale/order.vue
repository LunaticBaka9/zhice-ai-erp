<template>
	<view class="page">
		<view class="stats-bar">
			<view class="stat-item">
				<text class="stat-value">{{ statistics.total || 0 }}</text>
				<text class="stat-label">全部订单</text>
			</view>
			<view class="stat-item">
				<text class="stat-value warning">{{ statistics.pending || 0 }}</text>
				<text class="stat-label">待出库</text>
			</view>
			<view class="stat-item">
				<text class="stat-value success">{{ statistics.completed || 0 }}</text>
				<text class="stat-label">已完成</text>
			</view>
			<view class="stat-item">
				<text class="stat-value danger">{{ statistics.cancelled || 0 }}</text>
				<text class="stat-label">已作废</text>
			</view>
		</view>
		<view class="search-bar">
			<view class="search-input-wrapper">
				<text class="search-icon">🔍</text>
				<input class="search-input" v-model="keyword" placeholder="搜索订单号/客户名" @confirm="handleSearch" />
			</view>
			<view class="search-btn" @click="handleSearch"><text class="search-btn-text">搜索</text></view>
		</view>
		<view class="toolbar">
			<view class="toolbar-btn primary" @click="handleAdd"><text class="btn-text">+ 新建销售单</text></view>
			<view class="toolbar-btn" @click="loadList"><text class="btn-text">刷新</text></view>
		</view>
		<view class="list">
			<view class="list-item" v-for="item in list" :key="item.id">
				<view class="item-header">
					<text class="item-order-no">{{ item.orderNo }}</text>
					<view class="status-tag" :class="'status-' + item.status">
						<text class="status-text">{{ statusMap[item.status] || '未知' }}</text>
					</view>
				</view>
				<view class="item-main">
					<text class="item-meta">客户：{{ item.customerName || '-' }}</text>
					<text class="item-meta">金额：¥{{ item.finalAmount || 0 }}</text>
					<text class="item-meta">日期：{{ item.orderDate || '-' }}</text>
				</view>
				<view class="item-actions">
					<view v-if="item.status === 0" class="action-btn" @click="handleEdit(item)"><text class="action-text edit">编辑</text></view>
					<view v-if="item.status === 0" class="action-btn" @click="handleConfirm(item)"><text class="action-text edit">确认</text></view>
					<view v-if="item.status === 0" class="action-btn" @click="handleCancel(item)"><text class="action-text delete">作废</text></view>
				</view>
			</view>
			<view v-if="list.length === 0 && !loading" class="empty"><text>暂无销售订单</text></view>
		</view>
		<Pagination :currentPage="pageNum" :pageSize="pageSize" :total="total" @update:currentPage="pageNum = $event" @change="loadList" />

		<view v-if="showModal" class="modal-mask" @click="showModal = false">
			<view class="modal-box" @click.stop>
				<text class="modal-title">{{ form.id ? '编辑销售单' : '新建销售单' }}</text>
				<scroll-view scroll-y class="modal-scroll">
					<view class="modal-field">
						<text class="field-label">客户 <text class="required">*</text></text>
						<picker :range="customerOptions" range-key="name" @change="handleCustomerChange">
							<view class="field-input picker-field">
								<text>{{ selectedCustomerName || '请选择客户' }}</text>
							</view>
						</picker>
					</view>
					<view class="modal-field">
						<text class="field-label">出库仓库 <text class="required">*</text></text>
						<picker :range="warehouseOptions" range-key="name" @change="handleWarehouseChange">
							<view class="field-input picker-field">
								<text>{{ selectedWarehouseName || '请选择仓库' }}</text>
							</view>
						</picker>
					</view>
					<view class="modal-field">
						<text class="field-label">订单日期 <text class="required">*</text></text>
						<picker mode="date" :value="form.orderDate" @change="form.orderDate = $event.detail.value">
							<view class="field-input picker-field">
								<text>{{ form.orderDate || '请选择日期' }}</text>
							</view>
						</picker>
					</view>
					<view class="modal-field">
						<text class="field-label">订单明细</text>
						<view class="items-table">
							<view class="table-header">
								<text class="th" style="flex:2">商品</text>
								<text class="th" style="flex:1">数量</text>
								<text class="th" style="flex:1">单价</text>
							</view>
							<view v-for="(item, idx) in form.items" :key="idx" class="table-row">
								<picker :range="goodsOptions" range-key="name" @change="handleGoodsChange(idx, $event)" style="flex:2">
									<view class="td picker-td"><text>{{ getGoodsName(item.goodsId) || '选择商品' }}</text></view>
								</picker>
								<input class="td" type="number" v-model="item.quantity" placeholder="0" />
								<input class="td" type="digit" v-model="item.unitPrice" placeholder="0.00" />
								<text class="td-remove" @click="removeItem(idx)">✕</text>
							</view>
							<view class="add-item-btn" @click="addItem"><text>+ 添加明细</text></view>
						</view>
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
import { getSaleList, getSaleStatistics, addSale, updateSale, confirmSale, cancelSale } from '@/api/sale'
import { useCustomerStore } from '@/store/customer'
import { useGoodsStore } from '@/store/goods'
import { useWarehouseStore } from '@/store/warehouse'
import Pagination from '@/components/Pagination.vue'

const customerStore = useCustomerStore()
const goodsStore = useGoodsStore()
const warehouseStore = useWarehouseStore()

const keyword = ref('')
const list = ref([])
const loading = ref(false)
const pageNum = ref(1)
const pageSize = ref(10)
const total = ref(0)
const showModal = ref(false)
const statistics = reactive({ total: 0, pending: 0, completed: 0, cancelled: 0 })

const statusMap = { 0: '草稿', 1: '已确认待出库', 2: '已出库完成', 3: '已作废' }

const form = reactive({
	id: null, customerId: '', warehouseId: '', orderDate: '', items: []
})

const customerOptions = computed(() => customerStore.allCustomers)
const warehouseOptions = computed(() => warehouseStore.allWarehouses)
const goodsOptions = computed(() => goodsStore.allGoods)

const selectedCustomerName = computed(() => {
	const c = customerOptions.value.find(c => c.id === form.customerId)
	return c ? c.name : ''
})
const selectedWarehouseName = computed(() => {
	const w = warehouseOptions.value.find(w => w.id === form.warehouseId)
	return w ? w.name : ''
})

function getGoodsName(goodsId) {
	const g = goodsOptions.value.find(g => g.id === goodsId)
	return g ? g.name : ''
}
function handleCustomerChange(e) {
	const idx = e.detail.value
	form.customerId = customerOptions.value[idx]?.id || ''
}
function handleWarehouseChange(e) {
	const idx = e.detail.value
	form.warehouseId = warehouseOptions.value[idx]?.id || ''
}
function handleGoodsChange(idx, e) {
	const gIdx = e.detail.value
	form.items[idx].goodsId = goodsOptions.value[gIdx]?.id || ''
}
function addItem() {
	form.items.push({ goodsId: '', quantity: 1, unitPrice: 0 })
}
function removeItem(idx) {
	form.items.splice(idx, 1)
}

async function loadStatistics() {
	try {
		const res = await getSaleStatistics()
		if (res.code === '200') {
			Object.assign(statistics, res.data || {})
		}
	} catch (e) { console.error(e) }
}

async function loadList() {
	loading.value = true
	try {
		const res = await getSaleList({ pageNum: pageNum.value, pageSize: pageSize.value, keyword: keyword.value })
		if (res.code === '200') {
			list.value = res.data.records || res.data.list || []
			total.value = res.data.total || list.value.length
		}
	} catch (e) { console.error(e) }
	finally { loading.value = false }
}

function handleSearch() { pageNum.value = 1; loadList() }
function handleAdd() {
	Object.assign(form, { id: null, customerId: '', warehouseId: '', orderDate: '', items: [{ goodsId: '', quantity: 1, unitPrice: 0 }] })
	showModal.value = true
}
function handleEdit(item) {
	Object.assign(form, {
		id: item.id, customerId: item.customerId || '', warehouseId: item.warehouseId || '',
		orderDate: item.orderDate || '', items: (item.items || []).map(i => ({ ...i }))
	})
	if (form.items.length === 0) addItem()
	showModal.value = true
}
function handleConfirm(item) {
	uni.showModal({
		title: '提示', content: `确认订单【${item.orderNo}】？`,
		success: async (res) => {
			if (res.confirm) {
				try {
					const r = await confirmSale(item.id)
					if (r.code === '200') { uni.showToast({ title: '确认成功', icon: 'success' }); loadList(); loadStatistics() }
					else uni.showToast({ title: r.msg || '确认失败', icon: 'none' })
				} catch (e) { uni.showToast({ title: '操作失败', icon: 'none' }) }
			}
		}
	})
}
function handleCancel(item) {
	uni.showModal({
		title: '提示', content: `确认作废订单【${item.orderNo}】？`,
		success: async (res) => {
			if (res.confirm) {
				try {
					const r = await cancelSale(item.id)
					if (r.code === '200') { uni.showToast({ title: '已作废', icon: 'success' }); loadList(); loadStatistics() }
					else uni.showToast({ title: r.msg || '操作失败', icon: 'none' })
				} catch (e) { uni.showToast({ title: '操作失败', icon: 'none' }) }
			}
		}
	})
}
async function submitForm() {
	if (!form.customerId) { uni.showToast({ title: '请选择客户', icon: 'none' }); return }
	if (!form.warehouseId) { uni.showToast({ title: '请选择仓库', icon: 'none' }); return }
	if (!form.orderDate) { uni.showToast({ title: '请选择订单日期', icon: 'none' }); return }
	if (!form.items.length) { uni.showToast({ title: '请添加订单明细', icon: 'none' }); return }
	try {
		const res = form.id ? await updateSale(form) : await addSale(form)
		if (res.code === '200') {
			uni.showToast({ title: '保存成功', icon: 'success' })
			showModal.value = false; loadList(); loadStatistics()
		} else uni.showToast({ title: res.msg || '操作失败', icon: 'none' })
	} catch (e) { uni.showToast({ title: '提交失败', icon: 'none' }) }
}

onMounted(() => {
	customerStore.fetchAllCustomers()
	goodsStore.fetchAllGoods()
	warehouseStore.fetchAllWarehouses()
	loadStatistics()
	loadList()
})
</script>

<style scoped>
.page { background: #F5F7FA; min-height: 100vh; padding: 12px; }
.stats-bar { display: flex; background: #FFFFFF; border-radius: 10px; padding: 14px 8px; margin-bottom: 12px; gap: 4px; }
.stat-item { flex: 1; text-align: center; }
.stat-value { font-size: 20px; font-weight: 600; color: #303133; display: block; }
.stat-value.warning { color: #E6A23C; }
.stat-value.success { color: #67C23A; }
.stat-value.danger { color: #F56C6C; }
.stat-label { font-size: 12px; color: #909399; display: block; margin-top: 4px; }
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
.item-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; }
.item-order-no { font-size: 15px; font-weight: 500; color: #303133; }
.status-tag { padding: 2px 8px; border-radius: 4px; }
.status-text { font-size: 12px; }
.status-0 { background: #F0F2F5; } .status-0 .status-text { color: #909399; }
.status-1 { background: #FDF6EC; } .status-1 .status-text { color: #E6A23C; }
.status-2 { background: #F0F9EB; } .status-2 .status-text { color: #67C23A; }
.status-3 { background: #FEF0F0; } .status-3 .status-text { color: #F56C6C; }
.item-meta { font-size: 13px; color: #909399; display: block; margin-bottom: 2px; }
.item-actions { display: flex; gap: 16px; margin-top: 10px; padding-top: 10px; border-top: 1px solid #F2F6FC; }
.action-text { font-size: 14px; }
.action-text.edit { color: #409EFF; }
.action-text.delete { color: #F56C6C; }
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
.items-table { border: 1px solid #EBEEF5; border-radius: 8px; overflow: hidden; }
.table-header { display: flex; background: #F5F7FA; padding: 8px 0; }
.th { flex: 1; font-size: 13px; color: #909399; text-align: center; }
.table-row { display: flex; align-items: center; border-top: 1px solid #EBEEF5; padding: 4px 0; }
.td { flex: 1; font-size: 13px; text-align: center; height: 36px; border: none; }
.picker-td { display: flex; align-items: center; justify-content: center; height: 36px; }
.td-remove { color: #F56C6C; font-size: 14px; padding: 0 8px; }
.add-item-btn { padding: 10px; text-align: center; color: #409EFF; font-size: 14px; border-top: 1px solid #EBEEF5; }
.modal-btns { display: flex; border-top: 1px solid #F2F6FC; }
.modal-btn { flex: 1; height: 48px; display: flex; align-items: center; justify-content: center; font-size: 15px; }
.cancel { color: #606266; border-right: 1px solid #F2F6FC; }
.confirm { color: #409EFF; font-weight: 500; }
</style>
