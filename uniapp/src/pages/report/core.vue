<template>
	<view class="page">
		<view class="toolbar">
			<view class="toolbar-btn" @tap="loadData"><text class="toolbar-btn-text">刷新数据</text></view>
		</view>
		<scroll-view scroll-y class="scroll-area">
			<view class="stat-cards">
				<view class="stat-card">
					<view class="stat-icon" style="background: #409EFF;">
						<text class="stat-icon-text">客</text>
					</view>
					<view class="stat-info">
						<text class="stat-label">客户数量</text>
						<text class="stat-value">{{ data.customerCount || 0 }}</text>
					</view>
				</view>
				<view class="stat-card">
					<view class="stat-icon" style="background: #67C23A;">
						<text class="stat-icon-text">仓</text>
					</view>
					<view class="stat-info">
						<text class="stat-label">仓库数量</text>
						<text class="stat-value">{{ data.warehouseCount || 0 }}</text>
					</view>
				</view>
				<view class="stat-card">
					<view class="stat-icon" style="background: #E6A23C;">
						<text class="stat-icon-text">供</text>
					</view>
					<view class="stat-info">
						<text class="stat-label">供应商数量</text>
						<text class="stat-value">{{ data.supplierCount || 0 }}</text>
					</view>
				</view>
			</view>
			<view class="section">
				<view class="section-title"><text>销售订单统计</text></view>
				<view v-if="data.sale" class="data-list">
					<view class="data-card">
						<view class="card-row">
							<text class="card-label">订单总数</text>
							<text class="card-value">{{ data.sale.totalCount || 0 }}</text>
						</view>
					</view>
					<view class="data-card">
						<view class="card-row">
							<text class="card-label">草稿</text>
							<text class="card-value">{{ data.sale.draftCount || 0 }}</text>
						</view>
					</view>
					<view class="data-card">
						<view class="card-row">
							<text class="card-label">待出库</text>
							<text class="card-value">{{ data.sale.pendingCount || 0 }}</text>
						</view>
					</view>
					<view class="data-card">
						<view class="card-row">
							<text class="card-label">已完成</text>
							<text class="card-value completed">{{ data.sale.completedCount || 0 }}</text>
						</view>
					</view>
					<view class="data-card">
						<view class="card-row">
							<text class="card-label">已作废</text>
							<text class="card-value cancelled">{{ data.sale.cancelledCount || 0 }}</text>
						</view>
					</view>
				</view>
				<view v-else class="empty"><text>暂无数据</text></view>
			</view>
			<view class="section">
				<view class="section-title"><text>销售出库统计</text></view>
				<view v-if="data.outbound" class="data-list">
					<view class="data-card">
						<view class="card-row">
							<text class="card-label">出库单总数</text>
							<text class="card-value">{{ data.outbound.total || 0 }}</text>
						</view>
					</view>
					<view class="data-card">
						<view class="card-row">
							<text class="card-label">草稿</text>
							<text class="card-value">{{ data.outbound.draft || 0 }}</text>
						</view>
					</view>
					<view class="data-card">
						<view class="card-row">
							<text class="card-label">已确认</text>
							<text class="card-value completed">{{ data.outbound.confirmed || 0 }}</text>
						</view>
					</view>
				</view>
				<view v-else class="empty"><text>暂无数据</text></view>
			</view>
			<view class="section">
				<view class="section-title"><text>销售订单状态分布</text></view>
				<view v-if="data.sale" class="data-list">
					<view class="pie-item">
						<view class="pie-dot" style="background: #909399;"></view>
						<text class="pie-label">草稿</text>
						<text class="pie-value">{{ data.sale.draftCount || 0 }}</text>
					</view>
					<view class="pie-item">
						<view class="pie-dot" style="background: #E6A23C;"></view>
						<text class="pie-label">待出库</text>
						<text class="pie-value">{{ data.sale.pendingCount || 0 }}</text>
					</view>
					<view class="pie-item">
						<view class="pie-dot" style="background: #67C23A;"></view>
						<text class="pie-label">已完成</text>
						<text class="pie-value">{{ data.sale.completedCount || 0 }}</text>
					</view>
					<view class="pie-item">
						<view class="pie-dot" style="background: #F56C6C;"></view>
						<text class="pie-label">已作废</text>
						<text class="pie-value">{{ data.sale.cancelledCount || 0 }}</text>
					</view>
				</view>
				<view v-else class="empty"><text>暂无数据</text></view>
			</view>
			<view class="section">
				<view class="section-title"><text>出库单状态分布</text></view>
				<view v-if="data.outbound" class="data-list">
					<view class="pie-item">
						<view class="pie-dot" style="background: #909399;"></view>
						<text class="pie-label">草稿</text>
						<text class="pie-value">{{ data.outbound.draft || 0 }}</text>
					</view>
					<view class="pie-item">
						<view class="pie-dot" style="background: #67C23A;"></view>
						<text class="pie-label">已确认</text>
						<text class="pie-value">{{ data.outbound.confirmed || 0 }}</text>
					</view>
				</view>
				<view v-else class="empty"><text>暂无数据</text></view>
			</view>
		</scroll-view>
	</view>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { getCoreReport } from '@/api/report'

const loading = ref(false)
const data = reactive({
	customerCount: 0,
	warehouseCount: 0,
	supplierCount: 0,
	sale: null,
	outbound: null
})

function isApiOk(res) {
	return res && (res.code === '200' || res.code === 200)
}

async function loadData() {
	loading.value = true
	try {
		const res = await getCoreReport()
		if (!isApiOk(res) || !res.data) {
			uni.showToast({ title: res?.msg || '加载失败', icon: 'none' })
			return
		}
		data.customerCount = res.data.customerCount || 0
		data.warehouseCount = res.data.warehouseCount || 0
		data.supplierCount = res.data.supplierCount || 0
		data.sale = res.data.sale || null
		data.outbound = res.data.outbound || null
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
.stat-cards { display: flex; gap: 8px; margin-bottom: 16px; }
.stat-card { flex: 1; background: #FFFFFF; border-radius: 10px; padding: 14px 10px; display: flex; flex-direction: column; align-items: center; gap: 8px; }
.stat-icon { width: 48px; height: 48px; border-radius: 8px; display: flex; align-items: center; justify-content: center; }
.stat-icon-text { color: #FFFFFF; font-size: 18px; font-weight: 600; }
.stat-info { display: flex; flex-direction: column; align-items: center; gap: 4px; }
.stat-label { font-size: 12px; color: #909399; }
.stat-value { font-size: 22px; font-weight: 700; color: #303133; }
.section { margin-bottom: 16px; }
.section-title { font-size: 15px; font-weight: 600; color: #303133; background: #FFFFFF; border-radius: 10px 10px 0 0; padding: 12px 14px; }
.data-list { background: #FFFFFF; border-radius: 0 0 10px 10px; padding: 0 14px 14px 14px; }
.data-card { border-bottom: 1px solid #F2F3F5; padding: 12px 0; }
.data-card:last-child { border-bottom: none; }
.card-row { display: flex; justify-content: space-between; align-items: center; }
.card-label { font-size: 13px; color: #909399; }
.card-value { font-size: 14px; color: #606266; font-weight: 500; }
.card-value.completed { color: #67C23A; }
.card-value.cancelled { color: #F56C6C; }
.pie-item { display: flex; align-items: center; padding: 10px 0; border-bottom: 1px solid #F2F3F5; }
.pie-item:last-child { border-bottom: none; }
.pie-dot { width: 12px; height: 12px; border-radius: 50%; margin-right: 10px; }
.pie-label { font-size: 14px; color: #606266; flex: 1; }
.pie-value { font-size: 14px; font-weight: 600; color: #303133; }
.empty { padding: 60px 0; text-align: center; color: #909399; font-size: 14px; background: #FFFFFF; border-radius: 0 0 10px 10px; }
</style>
