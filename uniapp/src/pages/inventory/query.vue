<template>
	<view class="page">
		<view class="stats-grid">
			<view class="stat-card"><text class="stat-value">{{ statistics.totalGoods }}</text><text class="stat-label">总商品数</text></view>
			<view class="stat-card"><text class="stat-value">{{ statistics.totalStock }}</text><text class="stat-label">总库存量</text></view>
			<view class="stat-card danger"><text class="stat-value">{{ statistics.outOfStock }}</text><text class="stat-label">缺货商品</text></view>
			<view class="stat-card warning"><text class="stat-value">{{ statistics.lowStock }}</text><text class="stat-label">库存不足</text></view>
		</view>
		<view class="search-bar">
			<view class="search-input-wrapper">
				<text class="search-icon">🔍</text>
				<input class="search-input" v-model="keyword" placeholder="搜索SKU/商品名称" @confirm="handleSearch" />
			</view>
			<view class="search-btn" @click="handleSearch"><text class="search-btn-text">搜索</text></view>
		</view>
		<view class="toolbar">
			<view class="toolbar-btn primary" @click="handleAdd"><text class="btn-text">+ 新增商品</text></view>
		</view>
		<view class="list">
			<view class="list-item" v-for="item in goodsList" :key="item.id">
				<view class="item-header">
					<text class="item-sku">{{ item.skuCode }}</text>
					<view class="stock-tag" :class="getStockStatusClass(item)"><text class="stock-tag-text">{{ getStockStatusText(item) }}</text></view>
				</view>
				<text class="item-name">{{ item.name }}</text>
				<view class="item-row">
					<text class="item-meta">库存：<text :class="getStockStatusClass(item)">{{ item.stockQuantity || 0 }}</text></text>
					<text class="item-meta">售价：¥{{ item.salePrice || 0 }}</text>
				</view>
				<view class="item-actions">
					<view class="action-btn" @click="handleEdit(item)"><text class="action-text edit">编辑</text></view>
					<view class="action-btn" @click="handleDelete(item)"><text class="action-text delete">删除</text></view>
				</view>
			</view>
			<view v-if="goodsList.length === 0 && !loading" class="empty"><text>暂无库存数据</text></view>
		</view>
		<Pagination :currentPage="pageNum" :pageSize="pageSize" :total="total" @update:currentPage="pageNum = $event" @change="loadList" />

		<view v-if="showModal" class="modal-mask" @click="showModal = false">
			<view class="modal-box" @click.stop>
				<text class="modal-title">{{ form.id ? '编辑商品' : '新增商品' }}</text>
				<scroll-view scroll-y class="modal-scroll">
					<view class="modal-field">
						<text class="field-label">SKU编码 <text class="required">*</text></text>
						<input class="field-input" v-model="form.skuCode" placeholder="请输入SKU编码" />
					</view>
					<view class="modal-field">
						<text class="field-label">商品名称 <text class="required">*</text></text>
						<input class="field-input" v-model="form.name" placeholder="请输入商品名称" />
					</view>
					<view class="modal-field">
						<text class="field-label">品牌</text>
						<input class="field-input" v-model="form.brand" placeholder="请输入品牌" />
					</view>
					<view class="modal-field">
						<text class="field-label">规格型号</text>
						<input class="field-input" v-model="form.spec" placeholder="请输入规格型号" />
					</view>
					<view class="modal-field">
						<text class="field-label">单位</text>
						<input class="field-input" v-model="form.unit" placeholder="请输入单位" />
					</view>
					<view class="modal-field">
						<text class="field-label">采购价</text>
						<input class="field-input" v-model="form.purchasePrice" type="digit" placeholder="¥0.00" />
					</view>
					<view class="modal-field">
						<text class="field-label">售价</text>
						<input class="field-input" v-model="form.salePrice" type="digit" placeholder="¥0.00" />
					</view>
					<view class="modal-field">
						<text class="field-label">成本价</text>
						<input class="field-input" v-model="form.costPrice" type="digit" placeholder="¥0.00" />
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
import { getGoodsList, addGoods, updateGoods, deleteGoods } from '@/api/goods'
import Pagination from '@/components/Pagination.vue'

const keyword = ref('')
const goodsList = ref([])
const loading = ref(false)
const pageNum = ref(1)
const pageSize = ref(10)
const total = ref(0)
const showModal = ref(false)
const form = reactive({ id: null, skuCode: '', name: '', brand: '', spec: '', unit: '箱', purchasePrice: '', salePrice: '', costPrice: '', stockLow: '', stockHigh: '' })

const statistics = computed(() => {
	let totalGoods = goodsList.value.length, totalStock = 0, outOfStock = 0, lowStock = 0
	goodsList.value.forEach(item => {
		const stock = item.stockQuantity || 0, low = item.stockLow || 0
		totalStock += stock
		if (stock <= 0) outOfStock++
		else if (stock < low) lowStock++
	})
	return { totalGoods, totalStock, outOfStock, lowStock }
})

function getStockStatusText(row) {
	const stock = row.stockQuantity || 0, low = row.stockLow || 0, high = row.stockHigh || 999999
	if (stock <= 0) return '缺货'
	if (stock < low) return '库存不足'
	if (stock > high) return '库存过剩'
	return '库存正常'
}
function getStockStatusClass(row) {
	const stock = row.stockQuantity || 0, low = row.stockLow || 0, high = row.stockHigh || 999999
	if (stock <= 0) return 'status-danger'
	if (stock < low) return 'status-warning'
	if (stock > high) return 'status-info'
	return 'status-success'
}

async function loadList() {
	loading.value = true
	try {
		const res = await getGoodsList({ pageNum: pageNum.value, pageSize: pageSize.value, keyword: keyword.value })
		if (res.code === '200') {
			goodsList.value = res.data.records || res.data.list || []
			total.value = res.data.total || goodsList.value.length
		}
	} catch (e) { console.error(e) }
	finally { loading.value = false }
}

function handleSearch() { pageNum.value = 1; loadList() }
function handleAdd() {
	Object.assign(form, { id: null, skuCode: '', name: '', brand: '', spec: '', unit: '箱', purchasePrice: '', salePrice: '', costPrice: '', stockLow: '', stockHigh: '' })
	showModal.value = true
}
function handleEdit(item) { Object.assign(form, { ...item }); showModal.value = true }
function handleDelete(item) {
	uni.showModal({ title: '提示', content: `确定删除"${item.name}"吗？`,
		success: async (res) => {
			if (res.confirm) {
				const r = await deleteGoods(item)
				if (r.code === '200') { uni.showToast({ title: '删除成功', icon: 'success' }); loadList() }
				else uni.showToast({ title: r.msg || '删除失败', icon: 'none' })
			}
		}
	})
}
async function submitForm() {
	if (!form.skuCode || !form.name) { uni.showToast({ title: '请填写必要信息', icon: 'none' }); return }
	const res = form.id ? await updateGoods(form) : await addGoods(form)
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
.item-row { display: flex; justify-content: space-between; }
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
.modal-btns { display: flex; border-top: 1px solid #F2F6FC; }
.modal-btn { flex: 1; height: 48px; display: flex; align-items: center; justify-content: center; font-size: 15px; }
.cancel { color: #606266; border-right: 1px solid #F2F6FC; }
.confirm { color: #409EFF; font-weight: 500; }
</style>
