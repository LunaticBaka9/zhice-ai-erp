<template>
	<view class="list-panel">
		<view class="list-header" v-if="title">
			<text class="list-title">{{ title }}</text>
			<text class="list-count">共 {{ count }} 条</text>
		</view>
		<scroll-view scroll-y class="list-scroll" :style="{ height: scrollHeight }">
			<view v-if="loading" class="list-loading">
				<text>加载中...</text>
			</view>
			<slot v-else></slot>
			<view v-if="!loading && empty" class="list-empty">
				<text>暂无数据</text>
			</view>
		</scroll-view>
	</view>
</template>

<script setup>
defineProps({
	title: { type: String, default: '' },
	count: { type: Number, default: 0 },
	loading: { type: Boolean, default: false },
	empty: { type: Boolean, default: true },
	scrollHeight: { type: String, default: '60vh' },
})
</script>

<style scoped>
.list-panel { background: #FFFFFF; border-radius: 8px; overflow: hidden; }
.list-header {
	display: flex; align-items: center; justify-content: space-between;
	padding: 12px 16px; border-bottom: 1px solid #EBEEF5;
}
.list-title { font-size: 15px; font-weight: 500; color: #303133; }
.list-count { font-size: 13px; color: #909399; }
.list-scroll { width: 100%; }
.list-loading, .list-empty {
	display: flex; align-items: center; justify-content: center;
	padding: 40px 0; color: #909399; font-size: 14px;
}
</style>
