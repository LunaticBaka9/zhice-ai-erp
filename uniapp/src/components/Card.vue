<template>
	<view class="card" :class="{ 'card-shadow': shadow, 'card-border': border }" :style="cardStyle">
		<view class="card-header" v-if="title || $slots.header">
			<slot name="header">
				<text class="card-title">{{ title }}</text>
			</slot>
		</view>
		<view class="card-body">
			<slot></slot>
		</view>
	</view>
</template>

<script setup>
defineProps({
	title: { type: String, default: '' },
	shadow: { type: Boolean, default: false },
	border: { type: Boolean, default: true },
	padding: { type: String, default: '16px' },
	cardStyle: { type: Object, default: () => ({}) },
})
</script>

<style scoped>
.card {
	background: #FFFFFF;
	border-radius: 8px;
	overflow: hidden;
}
.card-border {
	border: 1px solid #EBEEF5;
}
.card-shadow {
	box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
}
.card-header {
	padding: 16px 16px 0;
	display: flex;
	align-items: center;
	justify-content: space-between;
}
.card-title {
	font-size: 16px;
	font-weight: 500;
	color: #303133;
}
.card-body {
	padding: v-bind('padding');
}
</style>
