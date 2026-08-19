<template>
	<view class="message-page">
		<view class="stats-bar">
			<view class="stat-item">
				<text class="stat-value danger">{{ unreadCount }}</text>
				<text class="stat-label">未读</text>
			</view>
			<view class="stat-item">
				<text class="stat-value warning">{{ pendingCount }}</text>
				<text class="stat-label">待审批</text>
			</view>
			<view class="stat-item">
				<text class="stat-value">{{ messageList.length }}</text>
				<text class="stat-label">总消息</text>
			</view>
		</view>

		<view class="filter-bar">
			<view class="filter-input-wrapper">
				<text class="filter-icon">🔍</text>
				<input class="filter-input" v-model="searchKeyword" placeholder="搜索消息" />
			</view>
			<scroll-view scroll-x class="filter-tags">
				<view class="filter-tag" :class="{ 'filter-tag-active': filterType === '' }" @click="filterType = ''">
					<text>全部</text>
				</view>
				<view class="filter-tag" :class="{ 'filter-tag-active': filterType === 'system' }" @click="filterType = 'system'">
					<text>系统</text>
				</view>
				<view class="filter-tag" :class="{ 'filter-tag-active': filterType === 'approval' }" @click="filterType = 'approval'">
					<text>审批</text>
				</view>
				<view class="filter-tag" :class="{ 'filter-tag-active': filterType === 'todo' }" @click="filterType = 'todo'">
					<text>待办</text>
				</view>
				<view class="filter-tag" :class="{ 'filter-tag-active': filterType === 'finance' }" @click="filterType = 'finance'">
					<text>财务</text>
				</view>
				<view class="filter-tag" :class="{ 'filter-tag-active': filterType === 'hr' }" @click="filterType = 'hr'">
					<text>人事</text>
				</view>
			</scroll-view>
		</view>

		<view class="message-list">
			<view v-for="msg in filteredMessages" :key="msg.id" class="message-item"
				:class="{ 'message-unread': !msg.isRead }" @click="handleMessageClick(msg)">
				<view class="message-icon" :class="'icon-' + msg.type">
					<text class="icon-text">{{ getTypeIcon(msg.type) }}</text>
				</view>
				<view class="message-content">
					<view class="message-title-row">
						<text class="message-title">{{ msg.title }}</text>
						<view v-if="!msg.isRead" class="unread-dot"></view>
					</view>
					<text class="message-summary">{{ msg.summary }}</text>
					<view class="message-meta">
						<view class="message-tag" :class="'tag-' + msg.type">
							<text class="tag-text">{{ getTypeLabel(msg.type) }}</text>
						</view>
						<text class="message-time">{{ formatRelativeTime(msg.time) }}</text>
					</view>
				</view>
			</view>
			<view v-if="filteredMessages.length === 0" class="empty-state">
				<text class="empty-icon">📭</text>
				<text class="empty-text">暂无消息</text>
			</view>
		</view>

		<view v-if="showDetail && selectedMessage" class="detail-overlay" @click="showDetail = false">
			<view class="detail-panel" @click.stop>
				<view class="detail-header">
					<text class="detail-title">消息详情</text>
					<text class="detail-close" @click="showDetail = false">✕</text>
				</view>
				<view class="detail-body">
					<view class="detail-tags">
						<view class="detail-tag" :class="'tag-' + selectedMessage.type">
							<text class="tag-text">{{ getTypeLabel(selectedMessage.type) }}</text>
						</view>
						<view v-if="selectedMessage.priority === 'high'" class="detail-tag tag-danger">
							<text class="tag-text">高优先级</text>
						</view>
					</view>
					<text class="detail-msg-title">{{ selectedMessage.title }}</text>
					<view class="detail-info">
						<text class="detail-label">发送方：</text>
						<text class="detail-value">{{ selectedMessage.sender || '系统管理员' }}</text>
					</view>
					<view class="detail-info">
						<text class="detail-label">时间：</text>
						<text class="detail-value">{{ formatDateTime(selectedMessage.time) }}</text>
					</view>
					<text class="detail-content">{{ selectedMessage.content || selectedMessage.summary }}</text>
				</view>
			</view>
		</view>
	</view>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { formatDateTime } from '@/utils/date'

const messageList = ref([])
const searchKeyword = ref('')
const filterType = ref('')
const showDetail = ref(false)
const selectedMessage = ref(null)

const unreadCount = computed(() => messageList.value.filter(m => !m.isRead).length)
const pendingCount = computed(() => messageList.value.filter(m => m.type === 'approval' && !m.isProcessed).length)

const filteredMessages = computed(() => {
	let result = [...messageList.value]
	if (searchKeyword.value) {
		const kw = searchKeyword.value.toLowerCase()
		result = result.filter(m => m.title.toLowerCase().includes(kw) || m.summary.toLowerCase().includes(kw))
	}
	if (filterType.value) {
		result = result.filter(m => m.type === filterType.value)
	}
	return result
})

function getTypeIcon(type) {
	const icons = { system: '⚙️', approval: '📋', todo: '📝', finance: '💰', hr: '👤' }
	return icons[type] || '🔔'
}
function getTypeLabel(type) {
	const labels = { system: '系统', approval: '审批', todo: '待办', finance: '财务', hr: '人事' }
	return labels[type] || '消息'
}
function formatRelativeTime(time) {
	const diff = Date.now() - new Date(time).getTime()
	if (diff < 60000) return '刚刚'
	if (diff < 3600000) return Math.floor(diff / 60000) + '分钟前'
	if (diff < 86400000) return Math.floor(diff / 3600000) + '小时前'
	if (diff < 604800000) return Math.floor(diff / 86400000) + '天前'
	const d = new Date(time)
	return `${d.getMonth() + 1}月${d.getDate()}日`
}

function handleMessageClick(msg) {
	selectedMessage.value = msg
	showDetail.value = true
	if (!msg.isRead) msg.isRead = true
}

function generateMockMessages() {
	const types = ['system', 'approval', 'todo', 'finance', 'hr']
	const templates = {
		system: { titles: ['系统维护通知', '安全策略更新', '新模块上线'], summaries: ['ERP系统将于本周末进行升级维护', '系统安全策略已更新', '采购管理模块已上线'] },
		approval: { titles: ['采购申请待审批', '费用报销申请', '合同审批提醒'], summaries: ['采购申请单号PO-2024001，金额¥12,800', '费用报销单，金额¥3,200', '销售合同SALE-2024005待您审批'] },
		todo: { titles: ['待处理工单提醒', '库存盘点任务', '月度报表待提交'], summaries: ['您有3个工单待处理', '仓库A区库存盘点任务已分配给您', '10月份销售报表请于今日下班前提交'] },
		finance: { titles: ['付款审批提醒', '发票到期通知', '预算超支预警'], summaries: ['供应商付款申请单待审批', '发票即将到期', '部门预算使用率已达85%'] },
		hr: { titles: ['入职手续提醒', '绩效考核通知', '培训报名确认'], summaries: ['新员工今日入职', '季度绩效考核已开启', '已成功报名领导力培训'] },
	}
	const now = Date.now()
	return Array.from({ length: 15 }, (_, i) => {
		const type = types[i % types.length]
		const t = templates[type]
		const idx = i % t.titles.length
		return {
			id: i + 1, type, title: t.titles[idx], summary: t.summaries[idx],
			content: `${t.summaries[idx]}。\n\n详细信息请登录ERP系统查看。`,
			time: new Date(now - Math.random() * 30 * 86400000),
			isRead: Math.random() > 0.5, priority: ['high', 'medium', 'low'][Math.floor(Math.random() * 3)],
			needAction: type === 'approval' || type === 'todo', isProcessed: false,
			sender: '系统管理员',
		}
	}).sort((a, b) => b.time - a.time)
}

onMounted(() => { messageList.value = generateMockMessages() })
</script>

<style scoped>
.message-page { background: #F5F7FA; min-height: 100vh; }
.stats-bar { display: flex; background: #FFFFFF; padding: 16px; gap: 12px; }
.stat-item { flex: 1; text-align: center; }
.stat-value { font-size: 22px; font-weight: 600; color: #303133; }
.stat-value.danger { color: #F56C6C; }
.stat-value.warning { color: #E6A23C; }
.stat-label { font-size: 12px; color: #909399; display: block; margin-top: 4px; }
.filter-bar { background: #FFFFFF; padding: 12px 16px; margin-top: 8px; }
.filter-input-wrapper { display: flex; align-items: center; border: 1px solid #DCDFE6; border-radius: 8px; padding: 0 10px; height: 36px; margin-bottom: 10px; }
.filter-icon { margin-right: 6px; font-size: 14px; }
.filter-input { flex: 1; font-size: 14px; }
.filter-tags { white-space: nowrap; }
.filter-tag { display: inline-flex; padding: 4px 12px; border-radius: 14px; font-size: 13px; color: #606266; background: #F5F7FA; margin-right: 8px; }
.filter-tag-active { background: #409EFF; color: #FFFFFF; }
.message-list { padding: 8px 0; }
.message-item { display: flex; background: #FFFFFF; padding: 14px 16px; gap: 12px; margin-bottom: 1px; }
.message-unread { background: #F0F7FF; }
.message-icon { width: 40px; height: 40px; border-radius: 10px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.icon-system { background: #F0F2F5; }
.icon-approval { background: #FDF6EC; }
.icon-todo { background: #FEF0F0; }
.icon-finance { background: #F0F9EB; }
.icon-hr { background: #ECF5FF; }
.icon-text { font-size: 18px; }
.message-content { flex: 1; min-width: 0; }
.message-title-row { display: flex; align-items: center; gap: 6px; }
.message-title { font-size: 15px; font-weight: 500; color: #303133; }
.unread-dot { width: 8px; height: 8px; border-radius: 50%; background: #F56C6C; flex-shrink: 0; }
.message-summary { font-size: 13px; color: #909399; margin-top: 4px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.message-meta { display: flex; align-items: center; gap: 8px; margin-top: 6px; }
.message-tag { padding: 1px 6px; border-radius: 3px; }
.tag-text { font-size: 11px; }
.tag-system { background: #F0F2F5; } .tag-system .tag-text { color: #909399; }
.tag-approval { background: #FDF6EC; } .tag-approval .tag-text { color: #E6A23C; }
.tag-todo { background: #FEF0F0; } .tag-todo .tag-text { color: #F56C6C; }
.tag-finance { background: #F0F9EB; } .tag-finance .tag-text { color: #67C23A; }
.tag-hr { background: #ECF5FF; } .tag-hr .tag-text { color: #409EFF; }
.tag-danger { background: #FEF0F0; } .tag-danger .tag-text { color: #F56C6C; }
.message-time { font-size: 12px; color: #C0C4CC; }
.empty-state { display: flex; flex-direction: column; align-items: center; padding: 60px 0; }
.empty-icon { font-size: 48px; }
.empty-text { font-size: 14px; color: #909399; margin-top: 12px; }
.detail-overlay { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); z-index: 1000; display: flex; align-items: flex-end; }
.detail-panel { width: 100%; max-height: 80vh; background: #FFFFFF; border-radius: 16px 16px 0 0; padding: 20px; }
.detail-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
.detail-title { font-size: 17px; font-weight: 500; }
.detail-close { font-size: 20px; color: #909399; padding: 4px; }
.detail-body { }
.detail-tags { display: flex; gap: 8px; margin-bottom: 12px; }
.detail-tag { padding: 2px 8px; border-radius: 4px; }
.detail-msg-title { font-size: 18px; font-weight: 600; color: #303133; margin-bottom: 12px; }
.detail-info { display: flex; margin-bottom: 6px; }
.detail-label { font-size: 13px; color: #909399; }
.detail-value { font-size: 13px; color: #606266; }
.detail-content { margin-top: 16px; font-size: 14px; color: #606266; line-height: 1.8; white-space: pre-wrap; }
</style>
