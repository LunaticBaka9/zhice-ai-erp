<template>
	<view class="dashboard">
		<view class="welcome-banner">
			<text class="welcome-title">欢迎回来，{{ userName }}</text>
			<text class="welcome-desc">{{ greetingMessage }}</text>
		</view>

		<view class="stats-grid">
			<view class="stat-card" v-for="stat in statsCards" :key="stat.title">
				<view class="stat-icon" :style="{ background: stat.color }">
					<text class="stat-icon-text">{{ stat.icon }}</text>
				</view>
				<view class="stat-info">
					<text class="stat-value">{{ stat.value }}</text>
					<text class="stat-title">{{ stat.title }}</text>
				</view>
			</view>
		</view>

		<view class="section-card">
			<view class="section-header">
				<text class="section-title">快捷入口</text>
			</view>
			<view class="quick-grid">
				<view class="quick-item" v-for="item in quickAccessItems" :key="item.name" @click="handleQuickAccess(item)">
					<view class="quick-icon" :style="{ background: item.color }">
						<text class="quick-icon-text">{{ item.icon }}</text>
					</view>
					<text class="quick-name">{{ item.name }}</text>
				</view>
			</view>
		</view>

		<view class="section-card">
			<view class="section-header">
				<text class="section-title">库存预警 Top 5</text>
				<text class="section-more" @click="navigateTo('/pages/inventory/warning')">查看更多</text>
			</view>
			<view class="notice-list">
				<view class="notice-item" v-for="item in inventoryWarnings" :key="item.skuCode" @click="navigateTo('/pages/inventory/warning')">
					<view class="notice-tag" :class="item.warningType === '缺货' ? 'tag-danger' : 'tag-warning'">
						<text class="notice-tag-text">{{ item.warningType }}</text>
					</view>
					<text class="notice-title">{{ item.skuName }} ({{ item.skuCode }})</text>
				</view>
				<view v-if="inventoryWarnings.length === 0" class="notice-empty">
					<text>暂无库存预警</text>
				</view>
			</view>
		</view>

		<view class="section-card">
			<view class="section-header">
				<text class="section-title">近7天销售趋势</text>
				<text class="section-more" @click="navigateTo('/pages/report/sales')">详细报表</text>
			</view>
			<view class="chart-bars">
				<view class="chart-bar-item" v-for="(day, idx) in weekSales" :key="idx">
					<text class="chart-label">{{ day.label }}</text>
					<view class="chart-bar-wrapper">
						<view class="chart-bar" :style="{ height: day.height + 'px' }"></view>
					</view>
					<text class="chart-value">¥{{ day.amount }}</text>
				</view>
			</view>
		</view>

		<view class="section-card">
			<view class="section-header">
				<text class="section-title">最新公告</text>
				<text class="section-more" @click="navigateTo('/pages/notice/index')">查看更多</text>
			</view>
			<view class="notice-list">
				<view class="notice-item" v-for="notice in recentNotices" :key="notice.nid" @click="viewNotice(notice)">
					<view class="notice-tag tag-primary">
						<text class="notice-tag-text">{{ notice.type }}</text>
					</view>
					<text class="notice-title text-ellipsis">{{ notice.title }}</text>
					<text class="notice-date">{{ formatDateTime(notice.publishDate) }}</text>
				</view>
				<view v-if="recentNotices.length === 0" class="notice-empty">
					<text>暂无公告</text>
				</view>
			</view>
		</view>
	</view>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { getAlertList, getAlertStatistics, getNoticeList } from '@/api'
import { formatDateTime, parseDate } from '@/utils/date'
import { getLocalUser } from '@/utils/storage'

const userName = computed(() => {
	const user = getLocalUser()
	return user?.name || user?.username || '用户'
})

const greetingMessage = computed(() => {
	const hour = new Date().getHours()
	if (hour < 6) return '夜深了，注意休息'
	if (hour < 9) return '早上好，新的一天开始了'
	if (hour < 12) return '上午好，工作顺利'
	if (hour < 14) return '中午好，记得午休'
	if (hour < 18) return '下午好，继续加油'
	if (hour < 22) return '晚上好，辛苦了'
	return '夜深了，早点休息'
})

const statsCards = ref([
	{ title: '今日销售额', value: '¥12,800', icon: '📈', color: '#409EFF' },
	{ title: '今日订单数', value: '42', icon: '🛒', color: '#67C23A' },
	{ title: '待采购入库', value: '8', icon: '📦', color: '#E6A23C' },
	{ title: '库存预警', value: '5', icon: '🔔', color: '#F56C6C' },
])

const quickAccessItems = [
	{ name: '销售开单', icon: '🛒', color: '#409EFF', route: '/pages/sale/order' },
	{ name: '采购入库', icon: '📦', color: '#67C23A', route: '/pages/purchase/inbound' },
	{ name: '库存查询', icon: '🔍', color: '#E6A23C', route: '/pages/inventory/query' },
	{ name: '新增客户', icon: '➕', color: '#909399', route: '/pages/base/customer' },
	{ name: '个人中心', icon: '👤', color: '#F56C6C', route: '/pages/userinfo/index' },
	{ name: 'AI 助手', icon: '🤖', color: '#9B59B6', route: '/pages/ai/index' },
]

const inventoryWarnings = ref([])
const recentNotices = ref([])

const weekSales = ref([
	{ label: '周一', amount: 3200, height: 40 },
	{ label: '周二', amount: 4500, height: 56 },
	{ label: '周三', amount: 3800, height: 48 },
	{ label: '周四', amount: 5100, height: 64 },
	{ label: '周五', amount: 6200, height: 78 },
	{ label: '周六', amount: 7800, height: 98 },
	{ label: '周日', amount: 5300, height: 66 },
])

function navigateTo(url) { uni.navigateTo({ url }) }

function handleQuickAccess(item) {
	if (item.route) {
		uni.navigateTo({ url: item.route })
	}
}

function viewNotice(notice) {
	uni.navigateTo({ url: '/pages/notice/index' })
}

async function fetchInventoryWarnings() {
	try {
		const res = await getAlertList({ pageNum: 1, pageSize: 5 })
		if (res && (res.code === '200' || res.code === 200)) {
			const list = res.data?.list || res.data?.records || []
			inventoryWarnings.value = list.map(item => {
				const stock = item.stockQuantity || 0
				const low = item.stockLow || 0
				const high = item.stockHigh || 0
				let warningType = '正常'
				if (stock <= 0) warningType = '缺货'
				else if (stock < low) warningType = '库存不足'
				else if (stock > high) warningType = '积压'
				return { skuCode: item.skuCode, skuName: item.goodsName, currentStock: stock, threshold: stock <= 0 ? low : high, warningType }
			})
		}
	} catch (e) { console.error(e) }
}

async function fetchRecentNotices() {
	try {
		const res = await getNoticeList({ pageNum: 1, pageSize: 5 })
		if (res && (res.code === '200' || res.code === 200)) {
			recentNotices.value = res.data?.records || []
		}
	} catch (e) { console.error(e) }
}

onMounted(() => {
	fetchRecentNotices()
	fetchInventoryWarnings()
})
</script>

<style scoped>
.dashboard { padding: 20rpx; background: #F5F7FA; min-height: 100vh; }
.welcome-banner { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 12px; padding: 30rpx; margin-bottom: 20rpx; }
.welcome-title { font-size: 22px; font-weight: 600; color: #FFFFFF; }
.welcome-desc { font-size: 14px; color: rgba(255,255,255,0.8); margin-top: 4px; }
.stats-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 16px; }
.stat-card { background: #FFFFFF; border-radius: 10px; padding: 16px; display: flex; align-items: center; gap: 12px; }
.stat-icon { width: 44px; height: 44px; border-radius: 10px; display: flex; align-items: center; justify-content: center; }
.stat-icon-text { font-size: 20px; }
.stat-info { flex: 1; }
.stat-value { font-size: 20px; font-weight: 600; color: #303133; }
.stat-title { font-size: 12px; color: #909399; margin-top: 2px; }
.section-card { background: #FFFFFF; border-radius: 10px; padding: 16px; margin-bottom: 16px; }
.section-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 12px; }
.section-title { font-size: 16px; font-weight: 500; color: #303133; }
.section-more { font-size: 13px; color: #409EFF; }
.quick-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; }
.quick-item { display: flex; flex-direction: column; align-items: center; gap: 8px; }
.quick-icon { width: 44px; height: 44px; border-radius: 10px; display: flex; align-items: center; justify-content: center; }
.quick-icon-text { font-size: 18px; }
.quick-name { font-size: 13px; color: #606266; }
.notice-list { display: flex; flex-direction: column; gap: 12px; }
.notice-item { display: flex; align-items: center; gap: 8px; padding: 8px 0; }
.notice-tag { padding: 2px 8px; border-radius: 4px; }
.notice-tag-text { font-size: 11px; }
.tag-primary { background: #ECF5FF; }
.tag-primary .notice-tag-text { color: #409EFF; }
.tag-danger { background: #FEF0F0; }
.tag-danger .notice-tag-text { color: #F56C6C; }
.tag-warning { background: #FDF6EC; }
.tag-warning .notice-tag-text { color: #E6A23C; }
.notice-title { flex: 1; font-size: 14px; color: #303133; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.notice-date { font-size: 12px; color: #909399; flex-shrink: 0; }
.notice-empty { padding: 30px 0; text-align: center; color: #909399; font-size: 14px; }
.chart-bars { display: flex; justify-content: space-around; align-items: flex-end; height: 160px; padding: 10px 0; }
.chart-bar-item { display: flex; flex-direction: column; align-items: center; width: 12%; }
.chart-label { font-size: 11px; color: #909399; margin-bottom: 5px; }
.chart-bar-wrapper { height: 100px; width: 100%; display: flex; align-items: flex-end; justify-content: center; }
.chart-bar { width: 24px; background: linear-gradient(180deg, #409eff 0%, #66b1ff 100%); border-radius: 4px 4px 0 0; min-height: 4px; }
.chart-value { font-size: 11px; color: #303133; margin-top: 5px; font-weight: 500; }
</style>
