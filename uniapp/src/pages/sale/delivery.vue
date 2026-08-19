<template>
	<view class="page">
		<view class="stats-bar">
			<view class="stat-item">
				<text class="stat-value">{{ statistics.total || 0 }}</text>
				<text class="stat-label">全部出库</text>
			</view>
			<view class="stat-item">
				<text class="stat-value warning">{{ statistics.pending || 0 }}</text>
				<text class="stat-label">待确认</text>
			</view>
			<view class="stat-item">
				<text class="stat-value success">{{ statistics.completed || 0 }}</text>
				<text class="stat-label">已确认</text>
			</view>
		</view>
		<view class="search-bar">
			<view class="search-input-wrapper">
				<text class="search-icon">🔍</text>
				<input class="search-input" v-model="keyword" placeholder="搜索出库单号" @confirm="handleSearch" />
			</view>
			<view class="search-btn" @click="handleSearch"><text class="search-btn-text">搜索</text></view>
		</view>
		<view class="toolbar">
			<view class="toolbar-btn primary" @click="handleCreate"><text class="btn-text">+ 新建出库单</text></view>
			<view class="toolbar-btn" @click="loadList"><text class="btn-text">刷新</text></view>
		</view>
		<view class="list">
			<view class="list-item" v-for="item in list" :key="item.id">
				<view class="item-header">
					<text class="item-order-no">{{ item.outboundNo || item.orderNo || '-' }}</text>
					<view class="status-tag" :class="'status-' + item.status">
						<text class="status-text">{{ statusMap[item.status] || '未知' }}</text>
					</view>
				</view>
				<view class="item-main">
					<text class="item-meta">关联销售单：{{ item.saleOrderNo || '-' }}</text>
					<text class="item-meta">客户：{{ item.customerName || '-' }}</text>
					<text class="item-meta">仓库：{{ item.warehouseName || '-' }}</text>
					<text class="item-meta">金额：¥{{ item.totalAmount || 0 }}</text>
				</view>
				<view class="item-actions">
					<view v-if="item.status === 0" class="action-btn" @click="handleConfirm(item)"><text class="action-text edit">确认出库</text></view>
					<view v-if="item.status === 0" class="action-btn" @click="handleDelete(item)"><text class="action-text delete">删除</text></view>
				</view>
			</view>
			<view v-if="list.length === 0 && !loading" class="empty"><text>暂无出库单</text></view>
		</view>
		<Pagination :currentPage="pageNum" :pageSize="pageSize" :total="total" @update:currentPage="pageNum = $event" @change="loadList" />

		<view v-if="showCreateModal" class="modal-mask" @click="showCreateModal = false">
			<view class="modal-box" @click.stop>
				<text class="modal-title">选择待出库销售单</text>
				<scroll-view scroll-y class="modal-scroll">
					<view v-if="eligibleList.length === 0" class="empty"><text>暂无可出库的销售单</text></view>
					<view class="eligible-list">
						<view class="eligible-item" v-for="item in eligibleList" :key="item.id" @click="handleSelectEligible(item)">
							<view class="eligible-info">
								<text class="eligible-no">{{ item.orderNo }}</text>
								<text class="eligible-meta">客户：{{ item.customerName || '-' }}</text>
								<text class="eligible-meta">金额：¥{{ item.finalAmount || 0 }}</text>
							</view>
							<text class="eligible-arrow">▶</text>
						</view>
					</view>
				</scroll-view>
				<view class="modal-btns">
					<view class="modal-btn cancel" @click="showCreateModal = false"><text>取消</text></view>
				</view>
			</view>
		</view>
	</view>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { getOutboundList, createOutbound, confirmOutbound, deleteDraftOutbound, getEligibleOutbound, getOutboundStatistics } from '@/api/saleOutbound'
import Pagination from '@/components/Pagination.vue'

const keyword = ref('')
const list = ref([])
const loading = ref(false)
const pageNum = ref(1)
const pageSize = ref(10)
const total = ref(0)
const showCreateModal = ref(false)
const eligibleList = ref([])
const statistics = reactive({ total: 0, pending: 0, completed: 0 })

const statusMap = { 0: '草稿待确认', 1: '已确认出库' }

async function loadStatistics() {
	try {
		const res = await getOutboundStatistics()
		if (res.code === '200') {
			Object.assign(statistics, res.data || {})
		}
	} catch (e) { console.error(e) }
}

async function loadList() {
	loading.value = true
	try {
		const res = await getOutboundList({ pageNum: pageNum.value, pageSize: pageSize.value, keyword: keyword.value })
		if (res.code === '200') {
			list.value = res.data.records || res.data.list || []
			total.value = res.data.total || list.value.length
		}
	} catch (e) { console.error(e) }
	finally { loading.value = false }
}

function handleSearch() { pageNum.value = 1; loadList() }

async function handleCreate() {
	try {
		const res = await getEligibleOutbound()
		if (res.code === '200') {
			eligibleList.value = Array.isArray(res.data) ? res.data : []
		}
	} catch (e) { console.error(e) }
	showCreateModal.value = true
}

function handleSelectEligible(item) {
	uni.showModal({
		title: '提示', content: `确认为销售单【${item.orderNo}】创建出库单？`,
		success: async (res) => {
			if (res.confirm) {
				try {
					const r = await createOutbound({ saleOrderId: item.id })
					if (r.code === '200') {
						uni.showToast({ title: '创建成功', icon: 'success' })
						showCreateModal.value = false; loadList(); loadStatistics()
					} else uni.showToast({ title: r.msg || '创建失败', icon: 'none' })
				} catch (e) { uni.showToast({ title: '操作失败', icon: 'none' }) }
			}
		}
	})
}

function handleConfirm(item) {
	uni.showModal({
		title: '提示', content: `确认出库单【${item.outboundNo || item.orderNo}】？`,
		success: async (res) => {
			if (res.confirm) {
				try {
					const r = await confirmOutbound(item.id)
					if (r.code === '200') { uni.showToast({ title: '确认成功', icon: 'success' }); loadList(); loadStatistics() }
					else uni.showToast({ title: r.msg || '确认失败', icon: 'none' })
				} catch (e) { uni.showToast({ title: '操作失败', icon: 'none' }) }
			}
		}
	})
}

function handleDelete(item) {
	uni.showModal({
		title: '提示', content: `确认删除出库单【${item.outboundNo || item.orderNo}】？`,
		success: async (res) => {
			if (res.confirm) {
				try {
					const r = await deleteDraftOutbound(item.id)
					if (r.code === '200') { uni.showToast({ title: '删除成功', icon: 'success' }); loadList(); loadStatistics() }
					else uni.showToast({ title: r.msg || '删除失败', icon: 'none' })
				} catch (e) { uni.showToast({ title: '操作失败', icon: 'none' }) }
			}
		}
	})
}

onMounted(() => { loadStatistics(); loadList() })
</script>

<style scoped>
.page { background: #F5F7FA; min-height: 100vh; padding: 12px; }
.stats-bar { display: flex; background: #FFFFFF; border-radius: 10px; padding: 14px 8px; margin-bottom: 12px; gap: 4px; }
.stat-item { flex: 1; text-align: center; }
.stat-value { font-size: 20px; font-weight: 600; color: #303133; display: block; }
.stat-value.warning { color: #E6A23C; }
.stat-value.success { color: #67C23A; }
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
.status-0 { background: #FDF6EC; } .status-0 .status-text { color: #E6A23C; }
.status-1 { background: #F0F9EB; } .status-1 .status-text { color: #67C23A; }
.item-meta { font-size: 13px; color: #909399; display: block; margin-bottom: 2px; }
.item-actions { display: flex; gap: 16px; margin-top: 10px; padding-top: 10px; border-top: 1px solid #F2F6FC; }
.action-text { font-size: 14px; }
.action-text.edit { color: #409EFF; }
.action-text.delete { color: #F56C6C; }
.empty { padding: 60px 0; text-align: center; color: #909399; font-size: 14px; }
.modal-mask { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); z-index: 1000; display: flex; align-items: center; justify-content: center; }
.modal-box { background: #FFFFFF; border-radius: 12px; width: 90%; max-height: 80vh; display: flex; flex-direction: column; }
.modal-title { font-size: 17px; font-weight: 500; text-align: center; padding: 16px; border-bottom: 1px solid #F2F6FC; }
.modal-scroll { flex: 1; max-height: 55vh; padding: 16px; }
.eligible-list { display: flex; flex-direction: column; gap: 8px; }
.eligible-item { display: flex; align-items: center; background: #F5F7FA; border-radius: 8px; padding: 12px; }
.eligible-info { flex: 1; }
.eligible-no { font-size: 15px; font-weight: 500; color: #303133; display: block; margin-bottom: 4px; }
.eligible-meta { font-size: 13px; color: #909399; display: block; margin-bottom: 2px; }
.eligible-arrow { color: #C0C4CC; font-size: 14px; padding-left: 10px; }
.modal-btns { display: flex; border-top: 1px solid #F2F6FC; }
.modal-btn { flex: 1; height: 48px; display: flex; align-items: center; justify-content: center; font-size: 15px; }
.cancel { color: #606266; }
.confirm { color: #409EFF; font-weight: 500; }
</style>
