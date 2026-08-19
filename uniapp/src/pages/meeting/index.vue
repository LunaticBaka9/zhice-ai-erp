<template>
	<view class="page">
		<view class="search-bar">
			<view class="search-input-wrapper">
				<text class="search-icon">🔍</text>
				<input class="search-input" v-model="keyword" placeholder="搜索会议" @confirm="handleSearch" />
			</view>
			<view class="search-btn" @click="handleSearch"><text class="search-btn-text">搜索</text></view>
		</view>
		<view class="toolbar">
			<view class="toolbar-btn primary" @click="goCreate"><text class="btn-text">+ 创建会议</text></view>
			<view class="toolbar-btn" @click="loadList"><text class="btn-text">刷新</text></view>
		</view>
		<view class="list">
			<view class="list-item" v-for="item in list" :key="item.id" @click="goDetail(item)">
				<view class="item-header">
					<text class="item-title">{{ item.title }}</text>
					<view class="status-tag" :class="'status-' + item.status">
						<text class="status-text">{{ statusMap[item.status] || '未知' }}</text>
					</view>
				</view>
				<view class="item-main">
					<text class="item-meta">时间：{{ item.startTime || '-' }} ~ {{ item.endTime || '-' }}</text>
					<text class="item-meta">地点：{{ item.location || '-' }}</text>
					<text class="item-meta">参与人：{{ formatParticipants(item.participants) }}</text>
				</view>
				<view class="item-actions">
					<view class="action-btn" @click.stop="handleDelete(item)"><text class="action-text delete">删除</text></view>
				</view>
			</view>
			<view v-if="list.length === 0 && !loading" class="empty"><text>暂无会议</text></view>
		</view>
		<Pagination :currentPage="pageNum" :pageSize="pageSize" :total="total" @update:currentPage="pageNum = $event" @change="loadList" />
	</view>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getMeetingList, deleteMeeting, checkinMeeting } from '@/api/meeting'
import Pagination from '@/components/Pagination.vue'

const keyword = ref('')
const list = ref([])
const loading = ref(false)
const pageNum = ref(1)
const pageSize = ref(10)
const total = ref(0)

const statusMap = { 0: '未开始', 1: '进行中', 2: '已结束', 3: '已取消' }

function formatParticipants(participants) {
	if (!participants) return '-'
	if (Array.isArray(participants)) return participants.map(p => p.name || p).join('、')
	return String(participants)
}

async function loadList() {
	loading.value = true
	try {
		const res = await getMeetingList({ pageNum: pageNum.value, pageSize: pageSize.value, keyword: keyword.value })
		if (res.code === '200') {
			list.value = res.data.records || res.data.list || []
			total.value = res.data.total || list.value.length
		}
	} catch (e) { console.error(e) }
	finally { loading.value = false }
}

function handleSearch() { pageNum.value = 1; loadList() }
function goCreate() { uni.navigateTo({ url: '/pages/meeting/create' }) }
function goDetail(item) { uni.navigateTo({ url: `/pages/meeting/detail?id=${item.id}` }) }
function handleDelete(item) {
	uni.showModal({
		title: '提示', content: `确认删除会议【${item.title}】？`,
		success: async (res) => {
			if (res.confirm) {
				try {
					const r = await deleteMeeting({ id: item.id })
					if (r.code === '200') { uni.showToast({ title: '删除成功', icon: 'success' }); loadList() }
					else uni.showToast({ title: r.msg || '删除失败', icon: 'none' })
				} catch (e) { uni.showToast({ title: '删除失败', icon: 'none' }) }
			}
		}
	})
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
.toolbar { display: flex; gap: 10px; margin-bottom: 12px; }
.toolbar-btn { background: #FFFFFF; border: 1px solid #DCDFE6; border-radius: 8px; padding: 0 16px; height: 36px; display: flex; align-items: center; }
.toolbar-btn.primary { background: #409EFF; border-color: #409EFF; }
.btn-text { font-size: 14px; color: #303133; }
.toolbar-btn.primary .btn-text { color: #FFFFFF; }
.list { display: flex; flex-direction: column; gap: 8px; }
.list-item { background: #FFFFFF; border-radius: 10px; padding: 14px; }
.item-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; }
.item-title { font-size: 16px; font-weight: 500; color: #303133; flex: 1; margin-right: 8px; }
.status-tag { padding: 2px 8px; border-radius: 4px; flex-shrink: 0; }
.status-text { font-size: 12px; }
.status-0 { background: #ECF5FF; } .status-0 .status-text { color: #409EFF; }
.status-1 { background: #F0F9EB; } .status-1 .status-text { color: #67C23A; }
.status-2 { background: #F0F2F5; } .status-2 .status-text { color: #909399; }
.status-3 { background: #FEF0F0; } .status-3 .status-text { color: #F56C6C; }
.item-meta { font-size: 13px; color: #909399; display: block; margin-bottom: 2px; }
.item-actions { display: flex; gap: 16px; margin-top: 10px; padding-top: 10px; border-top: 1px solid #F2F6FC; }
.action-text { font-size: 14px; }
.action-text.delete { color: #F56C6C; }
.empty { padding: 60px 0; text-align: center; color: #909399; font-size: 14px; }
</style>
