<template>
	<view class="tag" :class="['tag-' + type, 'tag-' + size, { 'tag-dark': dark }]">
		<text class="tag-text">{{ text }}</text>
	</view>
</template>

<script setup>
defineProps({
	text: { type: String, default: '' },
	type: { type: String, default: 'primary' },
	size: { type: String, default: 'small' },
	dark: { type: Boolean, default: false },
})
</script>

<style scoped>
.tag {
	display: inline-flex;
	align-items: center;
	justify-content: center;
	border-radius: 4px;
	padding: 2px 8px;
}
.tag-small {
	padding: 2px 6px;
}
.tag-text {
	font-size: 12px;
	line-height: 1.4;
}
.tag-primary {
	background: #ECF5FF;
}
.tag-primary .tag-text { color: #409EFF; }
.tag-success {
	background: #F0F9EB;
}
.tag-success .tag-text { color: #67C23A; }
.tag-warning {
	background: #FDF6EC;
}
.tag-warning .tag-text { color: #E6A23C; }
.tag-danger {
	background: #FEF0F0;
}
.tag-danger .tag-text { color: #F56C6C; }
.tag-info {
	background: #F4F4F5;
}
.tag-info .tag-text { color: #909399; }
.tag-dark.tag-primary { background: #409EFF; }
.tag-dark.tag-primary .tag-text { color: #FFFFFF; }
.tag-dark.tag-success { background: #67C23A; }
.tag-dark.tag-success .tag-text { color: #FFFFFF; }
.tag-dark.tag-warning { background: #E6A23C; }
.tag-dark.tag-warning .tag-text { color: #FFFFFF; }
.tag-dark.tag-danger { background: #F56C6C; }
.tag-dark.tag-danger .tag-text { color: #FFFFFF; }
</style>
