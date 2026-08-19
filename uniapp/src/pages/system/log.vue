<template>
	<view class="page">
		<view class="search-bar">
			<view class="search-input-wrapper">
				<input class="search-input" v-model="searchForm.username" placeholder="操作用户" @confirm="handleSearch" />
			</view>
			<view class="search-input-wrapper">
				<input class="search-input" v-model="searchForm.module" placeholder="模块名称" @confirm="handleSearch" />
			</view>
			<picker :range="typeOptions" range-key="label" @change="handleTypeChange">
				<view class="search-input-wrapper picker-field">
					<text class="picker-placeholder" v-if="!searchForm.type">操作类型</text>
					<text v-else>{{ searchForm.type }}</text>
				</view>
			</picker>
			<view class="search-btn" @click="handleSearch"><text class="search-btn-text">搜索</text></view>
			<view class="search-btn reset" @click="resetSearch"><text class="search-btn-text reset-text">重置</text></view>
		</view>

		<view class="toolbar">
			<view class="toolbar-btn danger" @click="handleDeleteAll">
				<text class="btn-text danger-text">清空日志</text>
			</view>
		</view>

		<view class="list">
			<view class="list-item" v-for="item in list" :key="item.id">
				<view class="item-row">
					<text class="item-label">ID</text>
					<text class="item-value">{{ item.id }}</text>
				</view>
				<view class="item-row">
					<text class="item-label">操作用户</text>
					<text class="item-value">{{ item.username }}</text>
				</view>
				<view class="item-row">
					<text class="item-label">模块名称</text>
					<text class="item-value">{{ item.module }}</text>
				</view>
				<view class="item-row">
					<text class="item-label">操作类型</text>
					<view class="type-tag" :style="{ background: getTypeColor(item.type) + '20', color: getTypeColor(item.type) }">
						<text class="type-tag-text" :style="{ color: getTypeColor(item.type) }">{{ item.type }}</text>
					</view>
				</view>
				<view class="item-row">
					<text class="item-label">操作描述</text>
					<text class="item-value">{{ item.operation }}</text>
				</view>
				<view class="item-row">
					<text class="item-label">执行时间</text>
					<text class="item-value">{{ item.time }}ms</text>
				</view>
				<view class="item-row">
					<text class="item-label">IP地址</text>
					<text class="item-value">{{ item.ip }}</text>
				</view>
				<view class="item-row">
					<text class="item-label">操作时间</text>
					<text class="item-value">{{ formatDateTime(item.createTime) }}</text>
				</view>
				<view class="item-footer">
					<view class="action-btn" @click="viewDetail(item)">
						<text class="action-text">详情</text>
					</view>
				</view>
			</view>
			<view v-if="list.length === 0 && !loading" class="empty"><text>暂无日志数据</text></view>
		</view>

		<Pagination :currentPage="pageNum" :pageSize="pageSize" :total="total" @update:currentPage="pageNum = $event" @change="loadList" />

		<view v-if="showDetail" class="modal-mask" @click="showDetail = false">
			<view class="modal-box" @click.stop>
				<text class="modal-title">操作日志详情</text>
				<scroll-view scroll-y class="modal-scroll">
					<view class="detail-list" v-if="currentLog">
						<view class="detail-row">
							<text class="detail-label">ID</text>
							<text class="detail-value">{{ currentLog.id }}</text>
						</view>
						<view class="detail-row">
							<text class="detail-label">操作用户</text>
							<text class="detail-value">{{ currentLog.username }}</text>
						</view>
						<view class="detail-row">
							<text class="detail-label">模块名称</text>
							<text class="detail-value">{{ currentLog.module }}</text>
						</view>
						<view class="detail-row">
							<text class="detail-label">操作类型</text>
							<text class="detail-value">{{ currentLog.type }}</text>
						</view>
						<view class="detail-row">
							<text class="detail-label">操作描述</text>
							<text class="detail-value">{{ currentLog.operation }}</text>
						</view>
						<view class="detail-row">
							<text class="detail-label">方法名</text>
							<text class="detail-value">{{ currentLog.method }}</text>
						</view>
						<view class="detail-row">
							<text class="detail-label">执行时间</text>
							<text class="detail-value">{{ currentLog.time }}ms</text>
						</view>
						<view class="detail-row">
							<text class="detail-label">IP地址</text>
							<text class="detail-value">{{ currentLog.ip }}</text>
						</view>
						<view class="detail-row">
							<text class="detail-label">操作时间</text>
							<text class="detail-value">{{ formatDateTime(currentLog.createTime) }}</text>
						</view>
						<view class="detail-row full">
							<text class="detail-label">请求参数</text>
						</view>
						<view class="params-block">
							<pre class="params-pre">{{ formatParams(currentLog.params) }}</pre>
						</view>
					</view>
				</scroll-view>
				<view class="modal-btns">
					<view class="modal-btn confirm" @click="showDetail = false"><text>关闭</text></view>
				</view>
			</view>
		</view>
	</view>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { getLogList, deleteAllLogs } from '@/api/operationLog'
import { formatDateTime } from '@/utils/date'
import Pagination from '@/components/Pagination.vue'

const list = ref([])
const loading = ref(false)
const pageNum = ref(1)
const pageSize = ref(10)
const total = ref(0)
const showDetail = ref(false)
const currentLog = ref(null)

const searchForm = reactive({ username: '', module: '', type: '' })

const typeOptions = [
	{ value: '登录', label: '登录' },
	{ value: '新增', label: '新增' },
	{ value: '删除', label: '删除' },
	{ value: '修改', label: '修改' },
	{ value: '查询', label: '查询' },
]

function handleTypeChange(e) {
	const idx = e.detail.value
	searchForm.type = typeOptions[idx]?.value ?? ''
}

function getTypeColor(type) {
	const map = { '新增': '#67C23A', '删除': '#F56C6C', '修改': '#E6A23C', '查询': '#909399', '登录': '#409EFF' }
	return map[type] || '#909399'
}

function formatParams(params) {
	if (!params) return '无'
	try {
		return JSON.stringify(JSON.parse(params), null, 2)
	} catch (e) {
		return params
	}
}

async function loadList() {
	loading.value = true
	try {
		const res = await getLogList({ pageNum: pageNum.value, pageSize: pageSize.value, username: searchForm.username, module: searchForm.module, type: searchForm.type })
		if (res.code === '200') {
			list.value = res.data?.list || []
			total.value = res.data?.total || 0
		} else {
			uni.showToast({ title: res.msg || '获取操作日志失败', icon: 'none' })
		}
	} catch (e) {
		uni.showToast({ title: '获取操作日志失败', icon: 'none' })
	} finally {
		loading.value = false
	}
}

function handleSearch() { pageNum.value = 1; loadList() }
function resetSearch() { searchForm.username = ''; searchForm.module = ''; searchForm.type = ''; pageNum.value = 1; loadList() }
function viewDetail(row) { currentLog.value = row; showDetail.value = true }

function handleDeleteAll() {
	uni.showModal({
		title: '警告', content: '确定要清空所有操作日志吗？此操作不可恢复！',
		success: async (res) => {
			if (res.confirm) {
				try {
					const r = await deleteAllLogs()
					if (r.code === '200') {
						uni.showToast({ title: '清空成功', icon: 'success' }); loadList()
					} else {
						uni.showToast({ title: r.msg || '清空失败', icon: 'none' })
					}
				} catch (e) {
					uni.showToast({ title: '清空失败', icon: 'none' })
				}
			}
		}
	})
}

onMounted(() => { loadList() })
</script>

<style scoped>
.page { background: #F5F7FA; min-height: 100vh; padding: 12px; }
.search-bar { display: flex; gap: 8px; margin-bottom: 12px; flex-wrap: wrap; }
.search-input-wrapper { flex: 1; min-width: 100px; display: flex; align-items: center; background: #FFFFFF; border: 1px solid #DCDFE6; border-radius: 8px; padding: 0 10px; height: 38px; }
.search-input { flex: 1; font-size: 14px; }
.picker-field { justify-content: center; }
.picker-placeholder { font-size: 14px; color: #C0C4CC; }
.search-btn { background: #409EFF; border-radius: 8px; padding: 0 16px; display: flex; align-items: center; }
.search-btn.reset { background: #FFFFFF; border: 1px solid #DCDFE6; }
.search-btn-text { color: #FFFFFF; font-size: 14px; }
.search-btn-text.reset-text { color: #606266; }
.toolbar { display: flex; gap: 10px; margin-bottom: 12px; }
.toolbar-btn { background: #FFFFFF; border: 1px solid #DCDFE6; border-radius: 8px; padding: 0 16px; height: 36px; display: flex; align-items: center; }
.toolbar-btn.danger { background: #FEF0F0; border-color: #F56C6C; }
.btn-text { font-size: 14px; color: #303133; }
.btn-text.danger-text { color: #F56C6C; }
.list { display: flex; flex-direction: column; gap: 8px; }
.list-item { background: #FFFFFF; border-radius: 10px; padding: 14px; }
.item-row { display: flex; align-items: flex-start; margin-bottom: 8px; }
.item-row:last-of-type { margin-bottom: 0; }
.item-label { font-size: 13px; color: #909399; width: 80px; flex-shrink: 0; }
.item-value { font-size: 14px; color: #303133; flex: 1; }
.type-tag { padding: 2px 8px; border-radius: 4px; }
.type-tag-text { font-size: 12px; }
.item-footer { display: flex; justify-content: flex-end; margin-top: 8px; padding-top: 8px; border-top: 1px solid #F2F6FC; }
.action-btn { padding: 4px 12px; }
.action-text { font-size: 14px; color: #409EFF; }
.empty { padding: 60px 0; text-align: center; color: #909399; font-size: 14px; }
.modal-mask { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); z-index: 1000; display: flex; align-items: center; justify-content: center; }
.modal-box { background: #FFFFFF; border-radius: 12px; width: 90%; max-height: 80vh; display: flex; flex-direction: column; }
.modal-title { font-size: 17px; font-weight: 500; text-align: center; padding: 16px; border-bottom: 1px solid #F2F6FC; }
.modal-scroll { flex: 1; max-height: 55vh; padding: 16px; }
.detail-list { }
.detail-row { display: flex; padding: 10px 0; border-bottom: 1px solid #F2F6FC; }
.detail-row.full { display: block; }
.detail-label { font-size: 14px; color: #909399; width: 80px; flex-shrink: 0; }
.detail-value { font-size: 14px; color: #303133; flex: 1; }
.params-block { padding: 10px 0; }
.params-pre { max-height: 300px; overflow-y: auto; background-color: #F5F7FA; padding: 10px; border-radius: 4px; font-size: 12px; margin: 0; }
.modal-btns { display: flex; border-top: 1px solid #F2F6FC; }
.modal-btn { flex: 1; height: 48px; display: flex; align-items: center; justify-content: center; font-size: 15px; }
.confirm { color: #409EFF; font-weight: 500; }
</style>
