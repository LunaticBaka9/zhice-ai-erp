<template>
	<view class="page">
		<view class="search-bar">
			<view class="search-input-wrapper">
				<text class="search-icon">🔍</text>
				<input class="search-input" v-model="keyword" placeholder="搜索公告" @confirm="handleSearch" />
			</view>
			<view class="search-btn" @click="handleSearch"><text class="search-btn-text">搜索</text></view>
		</view>
		<view class="list">
			<view class="list-item" v-for="item in list" :key="item.nid || item.id" @click="handleView(item)">
				<view class="item-header">
					<text class="item-title">{{ item.title }}</text>
					<view class="type-tag" :class="'type-' + (item.type || 0)">
						<text class="type-text">{{ typeMap[item.type] || '其他' }}</text>
					</view>
				</view>
				<text class="item-summary">{{ item.content || '暂无内容' }}</text>
				<view class="item-footer">
					<text class="item-time">{{ item.createTime || '-' }}</text>
					<view v-if="!item.isRead" class="unread-dot"><text class="dot-text">未读</text></view>
				</view>
			</view>
			<view v-if="list.length === 0 && !loading" class="empty"><text>暂无公告</text></view>
		</view>
		<Pagination :currentPage="pageNum" :pageSize="pageSize" :total="total" @update:currentPage="pageNum = $event" @change="loadList" />

		<view v-if="showDetail && selectedNotice" class="modal-mask" @click="showDetail = false">
			<view class="modal-box" @click.stop>
				<text class="modal-title">公告详情</text>
				<scroll-view scroll-y class="modal-scroll">
					<view class="detail-header">
						<view class="type-tag" :class="'type-' + (selectedNotice.type || 0)">
							<text class="type-text">{{ typeMap[selectedNotice.type] || '其他' }}</text>
						</view>
						<text class="detail-title">{{ selectedNotice.title }}</text>
					</view>
					<view class="detail-meta">
						<text class="meta-item">发布人：{{ selectedNotice.author || '系统管理员' }}</text>
						<text class="meta-item">时间：{{ selectedNotice.createTime || '-' }}</text>
					</view>
					<text class="detail-content">{{ selectedNotice.content }}</text>
				</scroll-view>
				<view class="modal-btns">
					<view class="modal-btn cancel" @click="showDetail = false"><text>关闭</text></view>
				</view>
			</view>
		</view>
	</view>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getNoticeList, getNoticeById, markAsRead } from '@/api/notice'
import Pagination from '@/components/Pagination.vue'

const keyword = ref('')
const list = ref([])
const loading = ref(false)
const pageNum = ref(1)
const pageSize = ref(10)
const total = ref(0)
const showDetail = ref(false)
const selectedNotice = ref(null)

const typeMap = { 0: '系统更新', 1: '维护通知', 2: '功能上线', 3: '其他' }

async function loadList() {
	loading.value = true
	try {
		const res = await getNoticeList({ pageNum: pageNum.value, pageSize: pageSize.value, keyword: keyword.value })
		if (res.code === '200') {
			list.value = (res.data.records || res.data.list || []).map(n => ({ ...n, isRead: false }))
			total.value = res.data.total || list.value.length
		}
	} catch (e) { console.error(e) }
	finally { loading.value = false }
}

function handleSearch() { pageNum.value = 1; loadList() }

async function handleView(item) {
	selectedNotice.value = item
	showDetail.value = true
	if (!item.isRead) {
		item.isRead = true
		try {
			await markAsRead({ id: item.nid || item.id })
		} catch (e) { console.error(e) }
	}
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
.list { display: flex; flex-direction: column; gap: 8px; }
.list-item { background: #FFFFFF; border-radius: 10px; padding: 14px; }
.item-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 6px; }
.item-title { font-size: 16px; font-weight: 500; color: #303133; flex: 1; margin-right: 8px; }
.type-tag { padding: 2px 8px; border-radius: 4px; flex-shrink: 0; }
.type-text { font-size: 12px; }
.type-0 { background: #ECF5FF; } .type-0 .type-text { color: #409EFF; }
.type-1 { background: #FDF6EC; } .type-1 .type-text { color: #E6A23C; }
.type-2 { background: #F0F9EB; } .type-2 .type-text { color: #67C23A; }
.type-3 { background: #F0F2F5; } .type-3 .type-text { color: #909399; }
.item-summary { font-size: 13px; color: #909399; display: block; margin-bottom: 8px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.item-footer { display: flex; justify-content: space-between; align-items: center; }
.item-time { font-size: 12px; color: #C0C4CC; }
.unread-dot { background: #F56C6C; border-radius: 10px; padding: 1px 6px; }
.dot-text { font-size: 11px; color: #FFFFFF; }
.empty { padding: 60px 0; text-align: center; color: #909399; font-size: 14px; }
.modal-mask { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); z-index: 1000; display: flex; align-items: center; justify-content: center; }
.modal-box { background: #FFFFFF; border-radius: 12px; width: 90%; max-height: 80vh; display: flex; flex-direction: column; }
.modal-title { font-size: 17px; font-weight: 500; text-align: center; padding: 16px; border-bottom: 1px solid #F2F6FC; }
.modal-scroll { flex: 1; max-height: 55vh; padding: 16px; }
.detail-header { margin-bottom: 12px; }
.detail-title { font-size: 18px; font-weight: 600; color: #303133; display: block; margin-top: 8px; }
.detail-meta { margin-bottom: 16px; padding-bottom: 12px; border-bottom: 1px solid #F2F6FC; }
.meta-item { font-size: 13px; color: #909399; display: block; margin-bottom: 4px; }
.detail-content { font-size: 14px; color: #606266; line-height: 1.8; white-space: pre-wrap; }
.modal-btns { display: flex; border-top: 1px solid #F2F6FC; }
.modal-btn { flex: 1; height: 48px; display: flex; align-items: center; justify-content: center; font-size: 15px; }
.cancel { color: #606266; }
</style>
