<template>
	<view class="page">
		<view v-if="detail" class="detail-content">
			<view class="detail-card">
				<view class="detail-header">
					<text class="detail-title">{{ detail.title }}</text>
					<view class="status-tag" :class="'status-' + detail.status">
						<text class="status-text">{{ statusMap[detail.status] || '未知' }}</text>
					</view>
				</view>
				<view class="detail-row">
					<text class="row-label">开始时间</text>
					<text class="row-value">{{ detail.startTime || '-' }}</text>
				</view>
				<view class="detail-row">
					<text class="row-label">结束时间</text>
					<text class="row-value">{{ detail.endTime || '-' }}</text>
				</view>
				<view class="detail-row">
					<text class="row-label">会议地点</text>
					<text class="row-value">{{ detail.location || '-' }}</text>
				</view>
				<view class="detail-row" v-if="detail.description">
					<text class="row-label">会议描述</text>
					<text class="row-value">{{ detail.description }}</text>
				</view>
			</view>

			<view class="detail-card">
				<text class="card-title">参与人</text>
				<view class="participants-grid">
					<view class="participant-chip" v-for="(p, idx) in participantList" :key="idx">
						<text class="participant-avatar">{{ (p.name || p.username || '?')[0] }}</text>
						<text class="participant-name">{{ p.name || p.username || '-' }}</text>
					</view>
					<view v-if="participantList.length === 0" class="empty"><text>暂无参与人信息</text></view>
				</view>
			</view>

			<view class="action-area" v-if="detail.status === 0 || detail.status === 1">
				<view class="checkin-btn" :class="{ 'checkin-disabled': checkedIn }" @click="handleCheckin">
					<text class="checkin-text">{{ checkedIn ? '已签到' : '签到' }}</text>
				</view>
			</view>
		</view>
		<view v-else-if="loading" class="loading-state">
			<text>加载中...</text>
		</view>
		<view v-else class="empty-state">
			<text>会议不存在或加载失败</text>
		</view>
	</view>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { getMeetingById, checkinMeeting } from '@/api/meeting'

const detail = ref(null)
const loading = ref(true)
const checkedIn = ref(false)
const meetingId = ref('')

const statusMap = { 0: '未开始', 1: '进行中', 2: '已结束', 3: '已取消' }

const participantList = computed(() => {
	if (!detail.value || !detail.value.participants) return []
	if (Array.isArray(detail.value.participants)) return detail.value.participants
	return []
})

async function loadDetail() {
	loading.value = true
	try {
		const res = await getMeetingById(meetingId.value)
		if (res.code === '200') {
			detail.value = res.data
		} else {
			uni.showToast({ title: res.msg || '加载失败', icon: 'none' })
		}
	} catch (e) { console.error(e) }
	finally { loading.value = false }
}

async function handleCheckin() {
	if (checkedIn.value) return
	uni.showModal({
		title: '提示', content: '确认签到？',
		success: async (res) => {
			if (res.confirm) {
				try {
					const r = await checkinMeeting(meetingId.value)
					if (r.code === '200') {
						checkedIn.value = true
						uni.showToast({ title: '签到成功', icon: 'success' })
					} else uni.showToast({ title: r.msg || '签到失败', icon: 'none' })
				} catch (e) { uni.showToast({ title: '签到失败', icon: 'none' }) }
			}
		}
	})
}

onMounted(() => {
	const pages = getCurrentPages()
	const currentPage = pages[pages.length - 1]
	meetingId.value = currentPage.options?.id || ''
	if (meetingId.value) {
		loadDetail()
	} else {
		loading.value = false
	}
})
</script>

<style scoped>
.page { background: #F5F7FA; min-height: 100vh; padding: 12px; }
.detail-card { background: #FFFFFF; border-radius: 10px; padding: 16px; margin-bottom: 12px; }
.detail-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
.detail-title { font-size: 18px; font-weight: 600; color: #303133; flex: 1; margin-right: 8px; }
.status-tag { padding: 2px 10px; border-radius: 4px; flex-shrink: 0; }
.status-text { font-size: 12px; }
.status-0 { background: #ECF5FF; } .status-0 .status-text { color: #409EFF; }
.status-1 { background: #F0F9EB; } .status-1 .status-text { color: #67C23A; }
.status-2 { background: #F0F2F5; } .status-2 .status-text { color: #909399; }
.status-3 { background: #FEF0F0; } .status-3 .status-text { color: #F56C6C; }
.detail-row { display: flex; padding: 10px 0; border-bottom: 1px solid #F2F6FC; }
.detail-row:last-child { border-bottom: none; }
.row-label { font-size: 14px; color: #909399; width: 80px; flex-shrink: 0; }
.row-value { font-size: 14px; color: #303133; flex: 1; }
.card-title { font-size: 15px; font-weight: 500; color: #303133; margin-bottom: 12px; display: block; }
.participants-grid { display: flex; flex-wrap: wrap; gap: 10px; }
.participant-chip { display: flex; align-items: center; gap: 6px; background: #F5F7FA; border-radius: 20px; padding: 6px 12px; }
.participant-avatar { width: 24px; height: 24px; border-radius: 50%; background: #409EFF; color: #FFFFFF; font-size: 12px; display: flex; align-items: center; justify-content: center; }
.participant-name { font-size: 13px; color: #303133; }
.action-area { margin-top: 12px; }
.checkin-btn { background: #409EFF; border-radius: 10px; height: 48px; display: flex; align-items: center; justify-content: center; }
.checkin-btn.checkin-disabled { background: #DCDFE6; }
.checkin-text { font-size: 16px; color: #FFFFFF; font-weight: 500; }
.loading-state { padding: 60px 0; text-align: center; color: #909399; font-size: 14px; }
.empty-state { padding: 60px 0; text-align: center; color: #909399; font-size: 14px; }
.empty { padding: 20px 0; text-align: center; color: #909399; font-size: 13px; }
</style>
