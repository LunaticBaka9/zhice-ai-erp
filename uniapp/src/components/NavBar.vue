<template>
	<view class="navbar" :style="{ background: bgColor }">
		<view class="navbar-status"></view>
		<view class="navbar-content">
			<view class="navbar-left" @click="handleBack" v-if="showBack">
				<text class="back-icon">‹</text>
			</view>
			<view class="navbar-left" v-else></view>
			<view class="navbar-title">
				<text :style="{ color: titleColor }">{{ title }}</text>
			</view>
			<view class="navbar-right">
				<slot name="right"></slot>
			</view>
		</view>
	</view>
	<view class="navbar-placeholder" :style="{ height: statusBarHeight + 44 + 'px' }"></view>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const props = defineProps({
	title: { type: String, default: '' },
	showBack: { type: Boolean, default: true },
	bgColor: { type: String, default: '#FFFFFF' },
	titleColor: { type: String, default: '#303133' },
})

const emit = defineEmits(['back'])

const statusBarHeight = ref(0)

onMounted(() => {
	const sysInfo = uni.getSystemInfoSync()
	statusBarHeight.value = sysInfo.statusBarHeight || 0
})

function handleBack() {
	emit('back')
	uni.navigateBack({ delta: 1 })
}
</script>

<style scoped>
.navbar {
	position: fixed;
	top: 0;
	left: 0;
	right: 0;
	z-index: 999;
}
.navbar-status {
	width: 100%;
}
.navbar-content {
	display: flex;
	align-items: center;
	height: 44px;
	padding: 0 12px;
}
.navbar-left {
	width: 60px;
	display: flex;
	align-items: center;
}
.back-icon {
	font-size: 28px;
	color: #303133;
	font-weight: bold;
}
.navbar-title {
	flex: 1;
	text-align: center;
	font-size: 17px;
	font-weight: 500;
}
.navbar-right {
	width: 60px;
	display: flex;
	align-items: center;
	justify-content: flex-end;
}
.navbar-placeholder {
	width: 100%;
}
</style>
