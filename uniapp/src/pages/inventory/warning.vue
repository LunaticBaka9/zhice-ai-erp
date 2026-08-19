<template>
	<view class="page">
		<view class="stats-grid">
			<view class="stat-card danger"><text class="stat-value">{{ alertStats.outOfStock }}</text><text class="stat-label">缺货预警</text></view>
			<view class="stat-card warning"><text class="stat-value">{{ alertStats.lowStock }}</text><text class="stat-label">库存不足</text></view>
			<view class="stat-card info"><text class="stat-value">{{ alertStats.overstock }}</text><text class="stat-label">库存积压</text></view>
			<view class="stat-card"><text class="stat-value">{{ alertStats.total }}</text><text class="stat-label">总预警数</text></view>
		</view>
		<view class="search-bar">
			<view class="search-input-wrapper">
				<text class="search-icon">🔍</text>
				<input class="search-input" v-model="keyword" placeholder="搜索商品名称/SKU" @confirm="handleSearch" />
			</view>
			<view class="filter-tabs">
				<view class="filter-tab" :class="{ active: activeType === '' }" @click="filterByType('')"><text class="tab-text">全部</text></view>
				<view class="filter-tab" :class="{ active: activeType === 'out_of_stock' }" @click="filterByType('out_of_stock')"><text class="tab-text">缺货</text></view>
				<view class="filter-tab" :class="{ active: activeType === 'low_stock' }" @click="filterByType('low_stock')"><text class="tab-text">不足</text></view>
				<view class="filter-tab" :class="{ active: activeType === 'overstock' }" @click="filterByType('overstock')"><text class="tab-text">积压</text></view>
			</view>
		</view>
		<view class="list">
			<view class="list-item" v-for="item in alertList" :key="item.id">
				<view class="item-header">
					<text class="item-sku">{{ item.skuCode }}</text>
					<view class="stock-tag" :class="getAlertClass(item.alertType)"><text class="stock-tag-text">{{ getAlertText(item.alertType) }}</text></view>
				</view>
				<text class="item-name">{{ item.goodsName }}</text>
				<view class="item-row">
					<text class="item-meta">当前库存：<text :class="getAlertClass(item.alertType)">{{ item.currentStock }}</text></text>
					<text class="item-meta">预警值：{{ item.threshold }}</text>
				</view>
				<view class="item-actions">
					<view class="action-btn" @click="handleAcknowledge(item)"><text class="action-text edit">确认处理</text></view>
				</view>
			</view>
			<view v-if="alertList.length === 0 && !loading" class="empty"><text>暂无预警数据</text></view>
		</view>
		<Pagination :currentPage="pageNum" :pageSize="pageSize" :total="total" @update:currentPage="pageNum = $event" @change="loadList" />
	</view>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { getAlertList, getAlertStatistics, acknowledgeAlert } from '@/api/inventoryAlert'
import Pagination from '@/components/Pagination.vue'

const keyword = ref('')
const alertList = ref([])
const loading = ref(false)
const pageNum = ref(1)
const pageSize = ref(10)
const total = ref(0)
const activeType = ref('')

const alertStats = reactive({ outOfStock: 0, lowStock: 0, overstock: 0, total: 0 })

function getAlertText(type) {
	const map = { out_of_stock: '缺货', low_stock: '库存不足', overstock: '库存积压' }
	return map[type] || type
}
function getAlertClass(type) {
	const map = { out_of_stock: 'status-danger', low_stock: 'status-warning', overstock: 'status-info' }
	return map[type] || ''
}

function filterByType(type) { activeType.value = type; pageNum.value = 1; loadList() }
function handleSearch() { pageNum.value = 1; loadList() }

async function loadStats() {
	try {
		const res = await getAlertStatistics()
		if (res.code === '200') {
			Object.assign(alertStats, {
				outOfStock: res.data.outOfStock || 0,
				lowStock: res.data.lowStock || 0,
				overstock: res.data.overstock || 0,
				total: res.data.total || 0
			})
		}
	} catch (e) { console.error(e) }
}

async function loadList() {
	loading.value = true
	try {
		const params = { pageNum: pageNum.value, pageSize: pageSize.value, keyword: keyword.value }
		if (activeType.value) params.alertType = activeType.value
		const res = await getAlertList(params)
		if (res.code === '200') {
			alertList.value = res.data.records || res.data.list || []
			total.value = res.data.total || alertList.value.length
		}
	} catch (e) { console.error(e) }
	finally { loading.value = false }
}

function handleAcknowledge(item) {
	uni.showModal({ title: '提示', content: `确认处理"${item.goodsName}"的预警吗？`,
		success: async (res) => {
			if (res.confirm) {
				const r = await acknowledgeAlert(item)
				if (r.code === '200') { uni.showToast({ title: '已确认', icon: 'success' }); loadList(); loadStats() }
				else uni.showToast({ title: r.msg || '操作失败', icon: 'none' })
			}
		}
	})
}

onMounted(() => { loadStats(); loadList() })
</script>

<style scoped>
.page { background: #F5F7FA; min-height: 100vh; padding: 12px; }
.stats-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-bottom: 12px; }
.stat-card { background: #FFFFFF; border-radius: 10px; padding: 14px; text-align: center; }
.stat-value { font-size: 22px; font-weight: 600; color: #303133; display: block; }
.stat-card.danger .stat-value { color: #F56C6C; }
.stat-card.warning .stat-value { color: #E6A23C; }
.stat-card.info .stat-value { color: #409EFF; }
.stat-label { font-size: 12px; color: #909399; display: block; margin-top: 4px; }
.search-bar { margin-bottom: 12px; }
.search-input-wrapper { display: flex; align-items: center; background: #FFFFFF; border: 1px solid #DCDFE6; border-radius: 8px; padding: 0 10px; height: 38px; margin-bottom: 10px; }
.search-icon { margin-right: 6px; font-size: 14px; }
.search-input { flex: 1; font-size: 14px; }
.filter-tabs { display: flex; gap: 8px; }
.filter-tab { padding: 6px 14px; border-radius: 20px; background: #FFFFFF; border: 1px solid #DCDFE6; }
.filter-tab.active { background: #409EFF; border-color: #409EFF; }
.tab-text { font-size: 13px; color: #606266; }
.filter-tab.active .tab-text { color: #FFFFFF; }
.list { display: flex; flex-direction: column; gap: 8px; }
.list-item { background: #FFFFFF; border-radius: 10px; padding: 14px; }
.item-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px; }
.item-sku { font-size: 13px; color: #909399; }
.stock-tag { padding: 2px 8px; border-radius: 4px; }
.stock-tag-text { font-size: 11px; }
.status-danger { color: #F56C6C; } .status-danger .stock-tag-text { color: #F56C6C; background: #FEF0F0; }
.status-warning { color: #E6A23C; } .status-warning .stock-tag-text { color: #E6A23C; background: #FDF6EC; }
.status-info { color: #409EFF; } .status-info .stock-tag-text { color: #409EFF; background: #ECF5FF; }
.item-name { font-size: 16px; font-weight: 500; color: #303133; display: block; margin-bottom: 6px; }
.item-row { display: flex; justify-content: space-between; margin-bottom: 2px; }
.item-meta { font-size: 13px; color: #909399; }
.item-actions { display: flex; gap: 16px; margin-top: 10px; padding-top: 10px; border-top: 1px solid #F2F6FC; }
.action-text { font-size: 14px; }
.action-text.edit { color: #409EFF; }
.empty { padding: 60px 0; text-align: center; color: #909399; font-size: 14px; }
</style>
