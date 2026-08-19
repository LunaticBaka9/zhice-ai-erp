<template>
	<view class="page">
		<view class="toolbar">
			<view class="toolbar-btn" @tap="loadData"><text class="toolbar-btn-text">刷新数据</text></view>
		</view>
		<scroll-view scroll-y class="scroll-area">
			<view class="section">
				<view class="section-title"><text>采购订单 — 按商品汇总（数量 / 金额）</text></view>
				<view v-if="purchaseOrders.length > 0" class="data-list">
					<view class="data-card" v-for="item in purchaseOrders" :key="item.goodsId">
						<view class="card-header">
							<text class="card-name">{{ item.goodsName }}</text>
						</view>
						<view class="card-row">
							<text class="card-label">数量</text>
							<text class="card-value">{{ item.qty }}</text>
						</view>
						<view class="card-row">
							<text class="card-label">金额</text>
							<text class="card-value amount">¥{{ item.amount }}</text>
						</view>
					</view>
				</view>
				<view v-else class="empty"><text>暂无数据</text></view>
			</view>
			<view class="section">
				<view class="section-title"><text>采购入库 — 按商品汇总（已入账数量）</text></view>
				<view v-if="purchaseInbounds.length > 0" class="data-list">
					<view class="data-card" v-for="item in purchaseInbounds" :key="item.goodsId">
						<view class="card-header">
							<text class="card-name">{{ item.goodsName }}</text>
						</view>
						<view class="card-row">
							<text class="card-label">已入账数量</text>
							<text class="card-value">{{ item.qty }}</text>
						</view>
					</view>
				</view>
				<view v-else class="empty"><text>暂无数据</text></view>
			</view>
			<view class="section">
				<view class="section-title"><text>销售出库 — 按商品汇总（已确认出库数量）</text></view>
				<view v-if="saleOutbounds.length > 0" class="data-list">
					<view class="data-card" v-for="item in saleOutbounds" :key="item.goodsId">
						<view class="card-header">
							<text class="card-name">{{ item.goodsName }}</text>
						</view>
						<view class="card-row">
							<text class="card-label">出库数量</text>
							<text class="card-value">{{ item.qty }}</text>
						</view>
					</view>
				</view>
				<view v-else class="empty"><text>暂无数据</text></view>
			</view>
			<view class="section">
				<view class="section-title"><text>当前库存 — 按商品汇总（在手数量）</text></view>
				<view v-if="stocks.length > 0" class="data-list">
					<view class="data-card" v-for="item in stocks" :key="item.goodsId">
						<view class="card-header">
							<text class="card-name">{{ item.goodsName }}</text>
						</view>
						<view class="card-row">
							<text class="card-label">在手数量</text>
							<text class="card-value">{{ item.qty }}</text>
						</view>
					</view>
				</view>
				<view v-else class="empty"><text>暂无数据</text></view>
			</view>
		</scroll-view>
	</view>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getInventoryReport } from '@/api/report'

const loading = ref(false)
const purchaseOrders = ref([])
const purchaseInbounds = ref([])
const saleOutbounds = ref([])
const stocks = ref([])

function isApiOk(res) {
	return res && (res.code === '200' || res.code === 200)
}

async function loadData() {
	loading.value = true
	try {
		const res = await getInventoryReport()
		if (!isApiOk(res) || !res.data) {
			uni.showToast({ title: res?.msg || '加载失败', icon: 'none' })
			return
		}
		purchaseOrders.value = res.data.purchaseOrders || []
		purchaseInbounds.value = res.data.purchaseInbounds || []
		saleOutbounds.value = res.data.saleOutbounds || []
		stocks.value = res.data.stocks || []
	} catch (e) {
		console.error(e)
		uni.showToast({ title: '加载失败', icon: 'none' })
	} finally {
		loading.value = false
	}
}

onMounted(() => {
	loadData()
})
</script>

<style scoped>
.page { background: #F5F7FA; min-height: 100vh; padding: 12px; }
.toolbar { margin-bottom: 12px; }
.toolbar-btn { background: #409EFF; border-radius: 8px; padding: 10px 20px; display: flex; align-items: center; justify-content: center; }
.toolbar-btn-text { color: #FFFFFF; font-size: 14px; }
.scroll-area { height: calc(100vh - 100px); }
.section { margin-bottom: 16px; }
.section-title { font-size: 15px; font-weight: 600; color: #303133; background: #FFFFFF; border-radius: 10px 10px 0 0; padding: 12px 14px; }
.data-list { display: flex; flex-direction: column; gap: 8px; background: #FFFFFF; border-radius: 0 0 10px 10px; padding: 0 14px 14px 14px; }
.data-card { border-bottom: 1px solid #F2F3F5; padding: 12px 0; }
.data-card:last-child { border-bottom: none; }
.card-header { margin-bottom: 8px; }
.card-name { font-size: 15px; font-weight: 500; color: #303133; }
.card-row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px; }
.card-label { font-size: 13px; color: #909399; }
.card-value { font-size: 14px; color: #606266; font-weight: 500; }
.card-value.amount { color: #E6A23C; font-size: 16px; }
.empty { padding: 60px 0; text-align: center; color: #909399; font-size: 14px; background: #FFFFFF; border-radius: 0 0 10px 10px; }
</style>
