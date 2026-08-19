<template>
	<view class="search-bar">
		<view class="search-input-wrapper">
			<text class="search-icon">🔍</text>
			<input class="search-input" :value="modelValue" :placeholder="placeholder"
				@input="handleInput" @confirm="handleSearch" confirm-type="search" />
			<text v-if="modelValue" class="search-clear" @click="handleClear">✕</text>
		</view>
		<view class="search-btn" @click="handleSearch">
			<text class="search-btn-text">搜索</text>
		</view>
	</view>
</template>

<script setup>
const props = defineProps({
	modelValue: { type: String, default: '' },
	placeholder: { type: String, default: '搜索...' },
})
const emit = defineEmits(['update:modelValue', 'search', 'clear'])
function handleInput(e) { emit('update:modelValue', e.detail.value) }
function handleSearch() { emit('search') }
function handleClear() { emit('update:modelValue', ''); emit('clear') }
</script>

<style scoped>
.search-bar { display: flex; align-items: center; gap: 8px; }
.search-input-wrapper {
	flex: 1; display: flex; align-items: center;
	border: 1px solid #DCDFE6; border-radius: 8px; padding: 0 12px; height: 36px; background: #FFFFFF;
}
.search-icon { margin-right: 8px; font-size: 14px; }
.search-input { flex: 1; font-size: 14px; }
.search-clear { margin-left: 8px; color: #C0C4CC; font-size: 14px; }
.search-btn { padding: 0 16px; height: 36px; display: flex; align-items: center; background: #409EFF; border-radius: 8px; }
.search-btn-text { color: #FFFFFF; font-size: 14px; }
</style>
