<template>
	<view class="form-item">
		<view class="form-label" :style="{ width: labelWidth }">
			<text v-if="required" class="form-required">*</text>
			<text>{{ label }}</text>
		</view>
		<view class="form-content">
			<slot></slot>
		</view>
	</view>
</template>

<script setup>
defineProps({
	label: { type: String, default: '' },
	labelWidth: { type: String, default: '80px' },
	required: { type: Boolean, default: false },
})
</script>

<style scoped>
.form-item { display: flex; align-items: flex-start; margin-bottom: 16px; }
.form-label { font-size: 14px; color: #606266; line-height: 40px; text-align: right; padding-right: 12px; flex-shrink: 0; }
.form-required { color: #F56C6C; margin-right: 2px; }
.form-content { flex: 1; }
</style>
