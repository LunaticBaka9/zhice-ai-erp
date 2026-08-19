<template>
	<view v-if="visible" class="modal-mask" @click="handleMaskClick">
		<view class="modal-container" @click.stop>
			<view class="modal-header">
				<text class="modal-title">{{ title }}</text>
				<text class="modal-close" @click="handleClose">✕</text>
			</view>
			<view class="modal-body">
				<slot></slot>
			</view>
			<view class="modal-footer" v-if="showFooter">
				<slot name="footer">
					<view class="modal-footer-btn" @click="handleClose">
						<text>取消</text>
					</view>
					<view class="modal-footer-btn modal-footer-primary" @click="handleConfirm">
						<text>确定</text>
					</view>
				</slot>
			</view>
		</view>
	</view>
</template>

<script setup>
const props = defineProps({
	visible: { type: Boolean, default: false },
	title: { type: String, default: '' },
	showFooter: { type: Boolean, default: true },
	closeOnMask: { type: Boolean, default: true },
})
const emit = defineEmits(['update:visible', 'confirm', 'close'])
function handleMaskClick() {
	if (props.closeOnMask) handleClose()
}
function handleClose() {
	emit('update:visible', false)
	emit('close')
}
function handleConfirm() {
	emit('confirm')
}
</script>

<style scoped>
.modal-mask {
	position: fixed; top: 0; left: 0; right: 0; bottom: 0; z-index: 1000;
	background: rgba(0,0,0,0.5); display: flex; align-items: center; justify-content: center;
}
.modal-container {
	background: #FFFFFF; border-radius: 12px; width: 85%; max-height: 80vh; overflow: hidden;
}
.modal-header {
	display: flex; align-items: center; justify-content: space-between;
	padding: 16px 20px; border-bottom: 1px solid #EBEEF5;
}
.modal-title { font-size: 16px; font-weight: 500; color: #303133; }
.modal-close { font-size: 18px; color: #909399; padding: 4px; }
.modal-body { padding: 20px; max-height: 60vh; overflow-y: auto; }
.modal-footer {
	display: flex; justify-content: flex-end; gap: 12px;
	padding: 12px 20px; border-top: 1px solid #EBEEF5;
}
.modal-footer-btn {
	padding: 8px 20px; border-radius: 6px; font-size: 14px; color: #606266;
	background: #F5F7FA;
}
.modal-footer-primary { background: #409EFF; color: #FFFFFF; }
</style>
