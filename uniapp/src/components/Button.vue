<template>
	<button class="btn" :class="['btn-' + type, 'btn-' + size, { 'btn-plain': plain, 'btn-disabled': disabled }]"
		:disabled="disabled || loading" @click="handleClick">
		<text v-if="loading" class="btn-loading">⟳</text>
		<slot></slot>
	</button>
</template>

<script setup>
const props = defineProps({
	type: { type: String, default: 'default' },
	size: { type: String, default: 'default' },
	plain: { type: Boolean, default: false },
	disabled: { type: Boolean, default: false },
	loading: { type: Boolean, default: false },
})
const emit = defineEmits(['click'])
function handleClick(e) {
	if (!props.disabled && !props.loading) emit('click', e)
}
</script>

<style scoped>
.btn {
	display: inline-flex;
	align-items: center;
	justify-content: center;
	gap: 4px;
	border: 1px solid #DCDFE6;
	background: #FFFFFF;
	color: #606266;
	border-radius: 8px;
	padding: 0 16px;
	height: 36px;
	font-size: 14px;
}
.btn::after { border: none; }
.btn-default { }
.btn-primary { background: #409EFF; color: #FFFFFF; border-color: #409EFF; }
.btn-success { background: #67C23A; color: #FFFFFF; border-color: #67C23A; }
.btn-warning { background: #E6A23C; color: #FFFFFF; border-color: #E6A23C; }
.btn-danger { background: #F56C6C; color: #FFFFFF; border-color: #F56C6C; }
.btn-info { background: #909399; color: #FFFFFF; border-color: #909399; }
.btn-plain.btn-primary { background: #FFFFFF; color: #409EFF; }
.btn-plain.btn-success { background: #FFFFFF; color: #67C23A; }
.btn-plain.btn-warning { background: #FFFFFF; color: #E6A23C; }
.btn-plain.btn-danger { background: #FFFFFF; color: #F56C6C; }
.btn-plain.btn-info { background: #FFFFFF; color: #909399; }
.btn-small { height: 28px; padding: 0 12px; font-size: 12px; }
.btn-mini { height: 24px; padding: 0 8px; font-size: 12px; }
.btn-disabled { opacity: 0.5; cursor: not-allowed; }
.btn-loading { animation: spin 1s linear infinite; }
@keyframes spin { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }
</style>
