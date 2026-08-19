<template>
	<view class="empty">
		<text class="empty-icon">📭</text>
		<text class="empty-text">{{ description }}</text>
	</view>
</template>

<script setup>
defineProps({
	description: { type: String, default: '暂无数据' },
})
</script>

<style scoped>
.empty {
	display: flex; flex-direction: column; align-items: center; justify-content: center;
	padding: 60px 0;
}
.empty-icon { font-size: 48px; margin-bottom: 12px; }
.empty-text { font-size: 14px; color: #909399; }
</style>
