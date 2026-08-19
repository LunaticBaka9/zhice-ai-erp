<template>
	<view class="select-wrapper" @click="handleToggle">
		<text v-if="modelValue" class="select-text">{{ selectedLabel }}</text>
		<text v-else class="select-placeholder">{{ placeholder }}</text>
		<text class="select-arrow">▾</text>
	</view>
	<view v-if="visible" class="select-mask" @click="handleToggle"></view>
	<view v-if="visible" class="select-dropdown">
		<view v-for="opt in options" :key="opt.value" class="select-option"
			:class="{ 'select-option-active': opt.value === modelValue }" @click="handleSelect(opt)">
			<text>{{ opt.label }}</text>
		</view>
		<view v-if="options.length === 0" class="select-empty">
			<text>暂无数据</text>
		</view>
	</view>
</template>

<script setup>
import { ref, computed } from 'vue'
const props = defineProps({
	modelValue: { type: [String, Number, null], default: null },
	options: { type: Array, default: () => [] },
	placeholder: { type: String, default: '请选择' },
})
const emit = defineEmits(['update:modelValue', 'change'])
const visible = ref(false)
const selectedLabel = computed(() => {
	const found = props.options.find(o => o.value === props.modelValue)
	return found ? found.label : ''
})
function handleToggle() { visible.value = !visible.value }
function handleSelect(opt) {
	emit('update:modelValue', opt.value)
	emit('change', opt.value)
	visible.value = false
}
</script>

<style scoped>
.select-wrapper {
	display: flex;
	align-items: center;
	border: 1px solid #DCDFE6;
	border-radius: 8px;
	padding: 0 12px;
	height: 40px;
	background: #FFFFFF;
}
.select-text { flex: 1; font-size: 14px; color: #303133; }
.select-placeholder { flex: 1; font-size: 14px; color: #C0C4CC; }
.select-arrow { color: #C0C4CC; font-size: 12px; margin-left: 8px; }
.select-mask { position: fixed; top: 0; left: 0; right: 0; bottom: 0; z-index: 998; background: transparent; }
.select-dropdown {
	position: fixed; z-index: 999; background: #FFFFFF; border: 1px solid #EBEEF5;
	border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); max-height: 300px; overflow-y: auto;
	min-width: 200px; top: 50%; left: 50%; transform: translate(-50%, -50%);
}
.select-option {
	padding: 10px 16px; font-size: 14px; color: #606266;
}
.select-option-active { color: #409EFF; background: #F5F7FA; }
.select-empty { padding: 20px; text-align: center; color: #909399; font-size: 14px; }
</style>
