<template>
	<view class="pagination" v-if="total > 0">
		<view class="pagination-info">
			<text class="pagination-text">共 {{ total }} 条</text>
		</view>
		<view class="pagination-btns">
			<view class="pagination-btn" :class="{ 'pagination-btn-disabled': currentPage <= 1 }" @click="handlePrev">
				<text>上一页</text>
			</view>
			<view class="pagination-current">
				<text>{{ currentPage }} / {{ totalPages }}</text>
			</view>
			<view class="pagination-btn" :class="{ 'pagination-btn-disabled': currentPage >= totalPages }" @click="handleNext">
				<text>下一页</text>
			</view>
		</view>
	</view>
</template>

<script setup>
import { computed } from 'vue'
const props = defineProps({
	currentPage: { type: Number, default: 1 },
	pageSize: { type: Number, default: 10 },
	total: { type: Number, default: 0 },
})
const emit = defineEmits(['update:currentPage', 'change'])
const totalPages = computed(() => Math.max(1, Math.ceil(props.total / props.pageSize)))
function handlePrev() {
	if (props.currentPage > 1) {
		emit('update:currentPage', props.currentPage - 1)
		emit('change')
	}
}
function handleNext() {
	if (props.currentPage < totalPages.value) {
		emit('update:currentPage', props.currentPage + 1)
		emit('change')
	}
}
</script>

<style scoped>
.pagination { display: flex; align-items: center; justify-content: space-between; padding: 12px 0; }
.pagination-text { font-size: 13px; color: #909399; }
.pagination-btns { display: flex; align-items: center; gap: 8px; }
.pagination-btn { padding: 6px 14px; border: 1px solid #DCDFE6; border-radius: 6px; font-size: 13px; color: #606266; background: #FFFFFF; }
.pagination-btn-disabled { opacity: 0.5; }
.pagination-current { font-size: 13px; color: #606266; padding: 0 8px; }
</style>
