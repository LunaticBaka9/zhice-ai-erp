<template>
	<view class="page">
		<view class="search-bar">
			<view class="search-input-wrapper">
				<text class="search-icon">🔍</text>
				<input class="search-input" v-model="keyword" placeholder="搜索单号/供应商/仓库" @confirm="handleSearch" />
			</view>
			<view class="search-btn" @click="handleSearch"><text class="search-btn-text">搜索</text></view>
		</view>
		<view class="filter-tabs">
			<view class="filter-tab" :class="{ active: activeTab === 'all' }" @click="switchTab('all')"><text class="tab-text">全部</text></view>
			<view class="filter-tab" :class="{ active: activeTab === 'order' }" @click="switchTab('order')"><text class="tab-text">采购单</text></view>
			<view class="filter-tab" :class="{ active: activeTab === 'inbound' }" @click="switchTab('inbound')"><text class="tab-text">入库单</text></view>
		</view>
		<view class="status-filter">
			<view class="status-chip" :class="{ active: statusFilter === '' }" @click="filterByStatus('')"><text class="chip-text">全部状态</text></view>
			<view class="status-chip" :class="{ active: statusFilter === 'draft' }" @click="filterByStatus('draft')"><text class="chip-text">草稿</text></view>
			<view class="status-chip" :class="{ active: statusFilter === 'confirmed' }" @click="filterByStatus('confirmed')"><text class="chip-text">已确认</text></view>
			<view class="status-chip" :class="{ active: statusFilter === 'inbound' }" @click="filterByStatus('inbound')"><text class="chip-text">已入库</text></view>
			<view class="status-chip" :class="{ active: statusFilter === 'voided' }" @click="filterByStatus('voided')"><text class="chip-text">已作废</text></view>
		</view>
		<view class="list">
			<view class="list-item" v-for="item in combinedList" :key="item._type + item.id">
				<view class="item-header">
					<text class="item-sku">{{ item._type === 'order' ? item.orderNo : item.inboundNo }}</text>
					<view class="item-tags">
						<view class="type-tag" :class="item._type === 'order' ? 'type-order' : 'type-inbound'">
							<text class="type-tag-text">{{ item._type === 'order' ? '采购单' : '入库单' }}</text>
						</view>
						<view class="stock-tag" :class="getStatusClass(item.status)"><text class="stock-tag-text">{{ getStatusText(item.status) }}</text></view>
					</view>
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
			</view>
			<view v-if="combinedList.length === 0 && !loading" class="empty"><text>暂无数据</text></view>
		</view>
		<Pagination :currentPage="pageNum" :pageSize="pageSize" :total="total" @update:currentPage="pageNum = $event" @change="loadList" />
	</view>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getPurchaseOrderList, getInboundList } from '@/api/purchase'
import Pagination from '@/components/Pagination.vue'

const keyword = ref('')
const combinedList = ref([])
const loading = ref(false)
const pageNum = ref(1)
const pageSize = ref(10)
const total = ref(0)
const activeTab = ref('all')
const statusFilter = ref('')

function getStatusText(status) {
	const map = { draft: '草稿', confirmed: '已确认', inbound: '已入库', voided: '已作废', pending: '待入库' }
	return map[status] || status
}
function getStatusClass(status) {
	const map = { draft: 'status-warning', confirmed: 'status-info', inbound: 'status-success', voided: 'status-danger', pending: 'status-info' }
	return map[status] || ''
}

function switchTab(tab) { activeTab.value = tab; pageNum.value = 1; loadList() }
function filterByStatus(status) { statusFilter.value = status; pageNum.value = 1; loadList() }
function handleSearch() { pageNum.value = 1; loadList() }

async function loadList() {
	loading.value = true
	try {
		const allData = []
		const params = { pageNum: pageNum.value, pageSize: pageSize.value, keyword: keyword.value }
		if (statusFilter.value) params.status = statusFilter.value

		if (activeTab.value === 'all' || activeTab.value === 'order') {
			try {
				const orderRes = await getPurchaseOrderList(params)
				if (orderRes.code === '200') {
					const records = orderRes.data.records || orderRes.data.list || []
					records.forEach(r => allData.push({ ...r, _type: 'order' }))
				}
			} catch (e) { console.error(e) }
		}

		if (activeTab.value === 'all' || activeTab.value === 'inbound') {
			try {
				const inboundRes = await getInboundList(params)
				if (inboundRes.code === '200') {
					const records = inboundRes.data.records || inboundRes.data.list || []
					records.forEach(r => allData.push({ ...r, _type: 'inbound' }))
				}
			} catch (e) { console.error(e) }
		}

		allData.sort((a, b) => {
			const ta = a.createTime || '', tb = b.createTime || ''
			return tb.localeCompare(ta)
		})

		combinedList.value = allData
		total.value = allData.length
	} catch (e) { console.error(e) }
	finally { loading.value = false }
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
.filter-tabs { display: flex; gap: 8px; margin-bottom: 10px; }
.filter-tab { padding: 6px 16px; border-radius: 20px; background: #FFFFFF; border: 1px solid #DCDFE6; }
.filter-tab.active { background: #409EFF; border-color: #409EFF; }
.tab-text { font-size: 13px; color: #606266; }
.filter-tab.active .tab-text { color: #FFFFFF; }
.status-filter { display: flex; gap: 6px; margin-bottom: 12px; flex-wrap: wrap; }
.status-chip { padding: 4px 12px; border-radius: 16px; background: #F5F7FA; border: 1px solid #E4E7ED; }
.status-chip.active { background: #ECF5FF; border-color: #409EFF; }
.chip-text { font-size: 12px; color: #606266; }
.status-chip.active .chip-text { color: #409EFF; }
.list { display: flex; flex-direction: column; gap: 8px; }
.list-item { background: #FFFFFF; border-radius: 10px; padding: 14px; }
.item-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px; }
.item-sku { font-size: 13px; color: #909399; }
.item-tags { display: flex; gap: 6px; align-items: center; }
.type-tag { padding: 2px 8px; border-radius: 4px; }
.type-tag-text { font-size: 11px; }
.type-order { background: #ECF5FF; } .type-order .type-tag-text { color: #409EFF; }
.type-inbound { background: #F0F9EB; } .type-inbound .type-tag-text { color: #67C23A; }
.stock-tag { padding: 2px 8px; border-radius: 4px; }
.stock-tag-text { font-size: 11px; }
.status-danger { color: #F56C6C; } .status-danger .stock-tag-text { color: #F56C6C; background: #FEF0F0; }
.status-warning { color: #E6A23C; } .status-warning .stock-tag-text { color: #E6A23C; background: #FDF6EC; }
.status-success { color: #67C23A; } .status-success .stock-tag-text { color: #67C23A; background: #F0F9EB; }
.status-info { color: #409EFF; } .status-info .stock-tag-text { color: #409EFF; background: #ECF5FF; }
.item-name { font-size: 16px; font-weight: 500; color: #303133; display: block; margin-bottom: 6px; }
.item-row { display: flex; justify-content: space-between; margin-bottom: 2px; }
.item-meta { font-size: 13px; color: #909399; }
.empty { padding: 60px 0; text-align: center; color: #909399; font-size: 14px; }
</style>
