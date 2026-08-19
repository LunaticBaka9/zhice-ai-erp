<template>
	<view class="input-wrapper" :class="{ 'input-focused': focused, 'input-disabled': disabled }">
		<text v-if="prefixIcon" class="input-prefix-icon">{{ prefixIcon }}</text>
		<input class="input-field" :type="type" :value="modelValue" :placeholder="placeholder"
			:disabled="disabled" :maxlength="maxlength" @input="handleInput" @focus="handleFocus"
			@blur="handleBlur" />
		<text v-if="modelValue && clearable && !disabled" class="input-clear" @click="handleClear">✕</text>
		<slot name="suffix"></slot>
	</view>
</template>

<script setup>
import { ref } from 'vue'
defineProps({
	modelValue: { type: [String, Number], default: '' },
	type: { type: String, default: 'text' },
	placeholder: { type: String, default: '' },
	disabled: { type: Boolean, default: false },
	clearable: { type: Boolean, default: false },
	maxlength: { type: [String, Number], default: -1 },
	prefixIcon: { type: String, default: '' },
})
const emit = defineEmits(['update:modelValue', 'focus', 'blur'])
const focused = ref(false)
function handleInput(e) { emit('update:modelValue', e.detail.value) }
function handleFocus() { focused.value = true; emit('focus') }
function handleBlur() { focused.value = false; emit('blur') }
function handleClear() { emit('update:modelValue', '') }
</script>

<style scoped>
.input-wrapper {
	display: flex;
	align-items: center;
	border: 1px solid #DCDFE6;
	border-radius: 8px;
	padding: 0 12px;
	height: 40px;
	background: #FFFFFF;
	transition: border-color 0.2s;
}
.input-focused {
	border-color: #409EFF;
}
.input-disabled {
	background: #F5F7FA;
	cursor: not-allowed;
}
.input-field {
	flex: 1;
	font-size: 14px;
	height: 100%;
}
.input-prefix-icon {
	margin-right: 8px;
	color: #909399;
	font-size: 16px;
}
.input-clear {
	margin-left: 8px;
	color: #C0C4CC;
	font-size: 14px;
	padding: 4px;
}
</style>
