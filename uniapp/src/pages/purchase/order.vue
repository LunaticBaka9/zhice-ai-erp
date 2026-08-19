<template>
	<view class="page">
		<view class="stats-grid">
			<view class="stat-card"><text class="stat-value">{{ statistics.draft }}</text><text class="stat-label">草稿</text></view>
			<view class="stat-card info"><text class="stat-value">{{ statistics.confirmed }}</text><text class="stat-label">已确认</text></view>
			<view class="stat-card success"><text class="stat-value">{{ statistics.inbound }}</text><text class="stat-label">已入库</text></view>
			<view class="stat-card danger"><text class="stat-value">{{ statistics.voided }}</text><text class="stat-label">已作废</text></view>
		</view>
		<view class="search-bar">
			<view class="search-input-wrapper">
				<text class="search-icon">🔍</text>
				<input class="search-input" v-model="keyword" placeholder="搜索订单号/供应商" @confirm="handleSearch" />
			</view>
			<view class="search-btn" @click="handleSearch"><text class="search-btn-text">搜索</text></view>
		</view>
		<view class="toolbar">
			<view class="toolbar-btn primary" @click="handleCreate"><text class="btn-text">+ 新建采购单</text></view>
		</view>
		<view class="list">
			<view class="list-item" v-for="item in orderList" :key="item.id">
				<view class="item-header">
					<text class="item-sku">{{ item.orderNo }}</text>
					<view class="stock-tag" :class="getStatusClass(item.status)"><text class="stock-tag-text">{{ getStatusText(item.status) }}</text></view>
				</view>
				<text class="item-name">{{ item.supplierName }}</text>
				<view class="item-row">
					<text class="item-meta">仓库：{{ item.warehouseName || '-' }}</text>
					<text class="item-meta">总金额：¥{{ item.totalAmount || 0 }}</text>
				</view>
				<view class="item-row">
					<text class="item-meta">商品数：{{ item.itemCount || 0 }}</text>
					<text class="item-meta">{{ item.createTime || '' }}</text>
				</view>
				<view class="item-actions">
					<view class="action-btn" v-if="item.status === 'draft'" @click="handleEdit(item)"><text class="action-text edit">编辑</text></view>
					<view class="action-btn" v-if="item.status === 'draft'" @click="handleConfirm(item)"><text class="action-text edit">确认</text></view>
					<view class="action-btn" v-if="item.status === 'draft'" @click="handleVoid(item)"><text class="action-text delete">作废</text></view>
				</view>
			</view>
			<view v-if="orderList.length === 0 && !loading" class="empty"><text>暂无采购订单</text></view>
		</view>
		<Pagination :currentPage="pageNum" :pageSize="pageSize" :total="total" @update:currentPage="pageNum = $event" @change="loadList" />

		<view v-if="showModal" class="modal-mask" @click="showModal = false">
			<view class="modal-box" @click.stop>
				<text class="modal-title">{{ form.id ? '编辑采购单' : '新建采购单' }}</text>
				<scroll-view scroll-y class="modal-scroll">
					<view class="modal-field">
						<text class="field-label">供应商 <text class="required">*</text></text>
						<view class="picker-wrapper" @click="showSupplierPicker = true">
							<text class="picker-text">{{ form.supplierName || '请选择供应商' }}</text>
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
						<text class="field-label">商品明细 <text class="required">*</text></text>
						<view class="items-table">
							<view class="table-header">
								<text class="th" style="flex:2">商品</text>
								<text class="th">单价</text>
								<text class="th">数量</text>
								<text class="th">小计</text>
								<text class="th action-th"></text>
							</view>
							<view class="table-row" v-for="(row, idx) in form.items" :key="idx">
								<view class="td" style="flex:2" @click="pickOrderGoods(idx)">
									<text class="td-text">{{ row.goodsName || '选择' }}</text>
								</view>
								<view class="td">
									<input class="td-input" v-model="row.price" type="digit" placeholder="0" />
								</view>
								<view class="td">
									<input class="td-input" v-model="row.quantity" type="number" placeholder="0" />
								</view>
								<text class="td">{{ (row.price * row.quantity || 0).toFixed(2) }}</text>
								<view class="td action-td" @click="removeItem(idx)"><text class="del-text">✕</text></view>
							</view>
						</view>
						<view class="add-item-btn" @click="addItem"><text class="add-item-text">+ 添加商品</text></view>
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

		<view v-if="showSupplierPicker" class="picker-mask" @click="showSupplierPicker = false">
			<view class="picker-content" @click.stop>
				<text class="picker-title">选择供应商</text>
				<scroll-view scroll-y class="picker-list">
					<view class="picker-option" v-for="s in supplierOptions" :key="s.id" @click="selectSupplier(s)">
						<text class="picker-option-text">{{ s.name }}</text>
					</view>
				</scroll-view>
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
		<view v-if="showGoodsPicker" class="picker-mask" @click="showGoodsPicker = false">
			<view class="picker-content" @click.stop>
				<text class="picker-title">选择商品</text>
				<scroll-view scroll-y class="picker-list">
					<view class="picker-option" v-for="g in goodsOptions" :key="g.id" @click="selectOrderGoods(g)">
						<text class="picker-option-text">{{ g.name }}（{{ g.skuCode }}）</text>
					</view>
				</scroll-view>
			</view>
		</view>
	</view>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { getPurchaseOrderList, savePurchaseOrder, confirmPurchaseOrder, cancelPurchaseOrder } from '@/api/purchase'
import Pagination from '@/components/Pagination.vue'

const keyword = ref('')
const orderList = ref([])
const loading = ref(false)
const pageNum = ref(1)
const pageSize = ref(10)
const total = ref(0)
const showModal = ref(false)
const showSupplierPicker = ref(false)
const showWarehousePicker = ref(false)
const showGoodsPicker = ref(false)
const currentGoodsIdx = ref(0)

const supplierOptions = ref([])
const warehouseOptions = ref([])
const goodsOptions = ref([])

const form = reactive({ id: null, supplierId: '', supplierName: '', warehouseId: '', warehouseName: '', remark: '', items: [] })

const statistics = computed(() => {
	let draft = 0, confirmed = 0, inbound = 0, voided = 0
	orderList.value.forEach(item => {
		if (item.status === 'draft') draft++
		else if (item.status === 'confirmed') confirmed++
		else if (item.status === 'inbound') inbound++
		else if (item.status === 'voided') voided++
	})
	return { draft, confirmed, inbound, voided }
})

function getStatusText(status) {
	const map = { draft: '草稿', confirmed: '已确认', inbound: '已入库', voided: '已作废' }
	return map[status] || status
}
function getStatusClass(status) {
	const map = { draft: 'status-warning', confirmed: 'status-info', inbound: 'status-success', voided: 'status-danger' }
	return map[status] || ''
}

async function loadList() {
	loading.value = true
	try {
		const res = await getPurchaseOrderList({ pageNum: pageNum.value, pageSize: pageSize.value, keyword: keyword.value })
		if (res.code === '200') {
			orderList.value = res.data.records || res.data.list || []
			total.value = res.data.total || orderList.value.length
		}
	} catch (e) { console.error(e) }
	finally { loading.value = false }
}

function handleSearch() { pageNum.value = 1; loadList() }
function handleCreate() {
	Object.assign(form, { id: null, supplierId: '', supplierName: '', warehouseId: '', warehouseName: '', remark: '', items: [emptyItem()] })
	showModal.value = true
}
function handleEdit(item) {
	Object.assign(form, { ...item, items: item.items && item.items.length ? [...item.items.map(i => ({ ...i }))] : [emptyItem()] })
	showModal.value = true
}
function emptyItem() { return { goodsId: '', goodsName: '', price: '', quantity: '' } }
function addItem() { form.items.push(emptyItem()) }
function removeItem(idx) { form.items.splice(idx, 1) }
function pickOrderGoods(idx) { currentGoodsIdx.value = idx; showGoodsPicker.value = true }
function selectOrderGoods(g) {
	form.items[currentGoodsIdx.value].goodsId = g.id
	form.items[currentGoodsIdx.value].goodsName = g.name
	showGoodsPicker.value = false
}
function selectSupplier(s) { form.supplierId = s.id; form.supplierName = s.name; showSupplierPicker.value = false }
function selectWarehouse(w) { form.warehouseId = w.id; form.warehouseName = w.name; showWarehousePicker.value = false }

function handleConfirm(item) {
	uni.showModal({ title: '提示', content: '确定确认该采购单吗？',
		success: async (res) => {
			if (res.confirm) {
				const r = await confirmPurchaseOrder(item)
				if (r.code === '200') { uni.showToast({ title: '已确认', icon: 'success' }); loadList() }
				else uni.showToast({ title: r.msg || '操作失败', icon: 'none' })
			}
		}
	})
}
function handleVoid(item) {
	uni.showModal({ title: '提示', content: '确定作废该采购单吗？',
		success: async (res) => {
			if (res.confirm) {
				const r = await cancelPurchaseOrder(item)
				if (r.code === '200') { uni.showToast({ title: '已作废', icon: 'success' }); loadList() }
				else uni.showToast({ title: r.msg || '操作失败', icon: 'none' })
			}
		}
	})
}

async function submitForm() {
	if (!form.supplierId || !form.warehouseId) { uni.showToast({ title: '请填写必要信息', icon: 'none' }); return }
	const validItems = form.items.filter(i => i.goodsId && i.price && i.quantity)
	if (!validItems.length) { uni.showToast({ title: '请至少添加一项商品', icon: 'none' }); return }
	const res = await savePurchaseOrder({ ...form, items: validItems })
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
.modal-box { background: #FFFFFF; border-radius: 12px; width: 92%; max-height: 85vh; display: flex; flex-direction: column; }
.modal-title { font-size: 17px; font-weight: 500; text-align: center; padding: 16px; border-bottom: 1px solid #F2F6FC; }
.modal-scroll { flex: 1; max-height: 60vh; padding: 16px; }
.modal-field { margin-bottom: 14px; }
.field-label { font-size: 14px; color: #606266; margin-bottom: 6px; display: block; }
.required { color: #F56C6C; }
.field-textarea { border: 1px solid #DCDFE6; border-radius: 8px; padding: 10px 12px; height: 60px; font-size: 14px; width: 100%; }
.modal-btns { display: flex; border-top: 1px solid #F2F6FC; }
.modal-btn { flex: 1; height: 48px; display: flex; align-items: center; justify-content: center; font-size: 15px; }
.cancel { color: #606266; border-right: 1px solid #F2F6FC; }
.confirm { color: #409EFF; font-weight: 500; }
.picker-wrapper { border: 1px solid #DCDFE6; border-radius: 8px; padding: 0 12px; height: 40px; display: flex; align-items: center; justify-content: space-between; }
.picker-text { font-size: 14px; color: #606266; }
.picker-arrow { font-size: 10px; color: #C0C4CC; }
.items-table { background: #FAFAFA; border-radius: 8px; overflow: hidden; }
.table-header { display: flex; padding: 8px 10px; background: #F5F7FA; }
.th { flex: 1; font-size: 12px; color: #909399; text-align: center; }
.action-th { width: 30px; flex: none; }
.table-row { display: flex; align-items: center; padding: 6px 10px; border-bottom: 1px solid #F2F6FC; }
.td { flex: 1; text-align: center; font-size: 13px; color: #303133; }
.action-td { width: 30px; flex: none; }
.del-text { color: #F56C6C; font-size: 14px; }
.td-input { border: 1px solid #DCDFE6; border-radius: 4px; height: 28px; font-size: 12px; text-align: center; width: 100%; }
.td-text { font-size: 12px; color: #606266; }
.add-item-btn { padding: 10px; text-align: center; }
.add-item-text { font-size: 14px; color: #409EFF; }
.picker-mask { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); z-index: 1001; display: flex; align-items: flex-end; justify-content: center; }
.picker-content { background: #FFFFFF; border-radius: 12px 12px 0 0; width: 100%; max-height: 60vh; padding: 16px; }
.picker-title { font-size: 16px; font-weight: 500; text-align: center; margin-bottom: 12px; display: block; }
.picker-list { max-height: 40vh; }
.picker-option { padding: 14px 0; border-bottom: 1px solid #F2F6FC; }
.picker-option-text { font-size: 15px; color: #303133; }
</style>
