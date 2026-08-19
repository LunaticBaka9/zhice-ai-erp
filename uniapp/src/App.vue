<script>
export default {
	onLaunch: function () {
		console.log('App Launch')
		const token = uni.getStorageSync('token')
		if (!token) {
			uni.redirectTo({ url: '/pages/login/index' })
		}
	},
	onShow: function () {
		console.log('App Show')
	},
	onHide: function () {
		console.log('App Hide')
	},
}
</script>

<style>
page {
	background-color: #F5F7FA;
	font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
	font-size: 14px;
	color: #303133;
}

view, text {
	box-sizing: border-box;
}

.container {
	padding: 20rpx;
}

/* 通用工具类 */
.flex {
	display: flex;
}
.flex-col {
	display: flex;
	flex-direction: column;
}
.flex-center {
	display: flex;
	align-items: center;
	justify-content: center;
}
.flex-between {
	display: flex;
	align-items: center;
	justify-content: space-between;
}
.flex-wrap {
	flex-wrap: wrap;
}
.flex-1 {
	flex: 1;
}
.items-center {
	align-items: center;
}
.gap-sm {
	gap: 8rpx;
}
.gap-base {
	gap: 12rpx;
}
.gap-md {
	gap: 16rpx;
}
.gap-lg {
	gap: 20rpx;
}

.text-center {
	text-align: center;
}
.text-right {
	text-align: right;
}
.text-primary {
	color: #409EFF;
}
.text-success {
	color: #67C23A;
}
.text-warning {
	color: #E6A23C;
}
.text-danger {
	color: #F56C6C;
}
.text-info {
	color: #909399;
}
.text-regular {
	color: #606266;
}
.text-secondary {
	color: #909399;
}
.text-bold {
	font-weight: 600;
}
.text-sm {
	font-size: 12px;
}
.text-base {
	font-size: 14px;
}
.text-md {
	font-size: 16px;
}
.text-lg {
	font-size: 18px;
}
.text-xl {
	font-size: 20px;
}
.text-xxl {
	font-size: 24px;
}
.text-ellipsis {
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
}

.bg-white {
	background-color: #FFFFFF;
}
.bg-page {
	background-color: #F5F7FA;
}
.rounded {
	border-radius: 8px;
}
.rounded-sm {
	border-radius: 4px;
}
.p-sm {
	padding: 8rpx;
}
.p-base {
	padding: 12rpx;
}
.p-md {
	padding: 16rpx;
}
.p-lg {
	padding: 20rpx;
}
.p-xl {
	padding: 24rpx;
}
.px-md {
	padding-left: 16rpx;
	padding-right: 16rpx;
}
.py-md {
	padding-top: 16rpx;
	padding-bottom: 16rpx;
}
.mt-sm {
	margin-top: 8rpx;
}
.mt-base {
	margin-top: 12rpx;
}
.mt-md {
	margin-top: 16rpx;
}
.mt-lg {
	margin-top: 20rpx;
}
.mb-sm {
	margin-bottom: 8rpx;
}
.mb-base {
	margin-bottom: 12rpx;
}
.mb-md {
	margin-bottom: 16rpx;
}
.mb-lg {
	margin-bottom: 20rpx;
}
.w-full {
	width: 100%;
}
.hidden {
	overflow: hidden;
}
</style>
