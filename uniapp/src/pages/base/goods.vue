<template>
	<view class="page">
		<view class="search-section">
			<view class="search-bar">
				<view class="search-input-wrapper">
					<text class="search-icon">🔍</text>
					<input class="search-input" v-model="keyword" placeholder="搜索商品名称/SKU" @confirm="handleSearch" />
				</view>
				<view class="search-btn" @click="handleSearch"><text class="search-btn-text">搜索</text></view>
			</view>
		</view>
		<view class="toolbar">
			<view class="toolbar-btn primary" @click="handleAdd"><text class="btn-text">+ 添加商品</text></view>
			<view class="toolbar-btn" @click="refreshList"><text class="btn-text">刷新</text></view>
		</view>
		<view class="goods-grid">
			<view class="goods-card" v-for="item in productList" :key="item.id || item.skuCode" @click="handleView(item)">
				<image class="goods-img" :src="item.img || ''" mode="aspectFill" v-if="item.img"></image>
				<view class="goods-img-placeholder" v-else><text class="placeholder-icon">📦</text></view>
				<view class="goods-info">
					<text class="goods-name">{{ item.name || item.skuCode }}</text>
					<text class="goods-meta">SKU：{{ item.skuCode || '-' }}</text>
					<text class="goods-meta">品牌：{{ item.brand || '-' }}</text>
					<text class="goods-meta">规格：{{ item.spec || '-' }}</text>
					<text class="goods-price">¥{{ item.salePrice || 0 }} / {{ item.unit || '个' }}</text>
				</view>
				<view class="goods-actions">
					<view class="action-btn edit" @click.stop="handleEdit(item)"><text>编辑</text></view>
					<view class="action-btn delete" @click.stop="handleDelete(item)"><text>删除</text></view>
				</view>
			</view>
			<view v-if="productList.length === 0 && !loading" class="empty"><text>暂无商品数据</text></view>
		</view>
		<Pagination :currentPage="pageNum" :pageSize="pageSize" :total="total" @update:currentPage="pageNum = $event" @change="loadList" />

		<view v-if="showModal" class="modal-mask" @click="showModal = false">
			<view class="modal-box" @click.stop>
				<text class="modal-title">{{ formData.id ? '编辑商品' : '添加商品' }}</text>
				<scroll-view scroll-y class="modal-scroll">
					<view class="modal-field">
						<text class="field-label">SKU编码 <text class="required">*</text></text>
						<input class="field-input" v-model="formData.skuCode" placeholder="全局唯一编码" />
					</view>
					<view class="modal-field">
						<text class="field-label">商品名称 <text class="required">*</text></text>
						<input class="field-input" v-model="formData.name" placeholder="请输入商品名称" />
					</view>
					<view class="modal-field">
						<text class="field-label">品牌</text>
						<input class="field-input" v-model="formData.brand" placeholder="如：农夫山泉" />
					</view>
					<view class="modal-field">
						<text class="field-label">规格型号</text>
						<input class="field-input" v-model="formData.spec" placeholder="如：550ml/瓶" />
					</view>
					<view class="modal-field">
						<text class="field-label">单位</text>
						<picker :range="unitOptions" @change="formData.unit = unitOptions[$event.detail.value]">
							<view class="field-input picker-field"><text>{{ formData.unit || '请选择单位' }}</text></view>
						</picker>
					</view>
					<view class="modal-field">
						<text class="field-label">条码</text>
						<input class="field-input" v-model="formData.barcode" placeholder="商品条形码" />
					</view>
					<view class="modal-field">
						<text class="field-label">采购价</text>
						<input class="field-input" v-model="formData.purchasePrice" type="digit" placeholder="0.00" />
					</view>
					<view class="modal-field">
						<text class="field-label">标准售价</text>
						<input class="field-input" v-model="formData.salePrice" type="digit" placeholder="0.00" />
					</view>
					<view class="modal-field">
						<text class="field-label">成本价</text>
						<input class="field-input" v-model="formData.costPrice" type="digit" placeholder="0.00" />
					</view>
				</scroll-view>
				<view class="modal-btns">
					<view class="modal-btn cancel" @click="showModal = false"><text>取消</text></view>
					<view class="modal-btn confirm" @click="submitForm"><text>保存</text></view>
				</view>
			</view>
		</view>
	</view>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { getGoodsList, addGoods, updateGoods, deleteGoods } from '@/api/goods'
import Pagination from '@/components/Pagination.vue'

const keyword = ref('')
const productList = ref([])
const loading = ref(false)
const pageNum = ref(1)
const pageSize = ref(10)
const total = ref(0)
const showModal = ref(false)
const unitOptions = ['个', '台', '箱', '袋', '瓶', '盒']
const formData = reactive({
	id: null, skuCode: '', name: '', img: '', brand: '', spec: '', unit: '个',
	barcode: '', purchasePrice: 0, salePrice: 0, costPrice: 0, stockLow: 0, stockHigh: 0,
})

async function loadList() {
	loading.value = true
	try {
		const res = await getGoodsList({ pageNum: pageNum.value, pageSize: pageSize.value, keyword: keyword.value })
		if (res.code === '200') {
			productList.value = res.data.records || res.data.list || []
			total.value = res.data.total || productList.value.length
		}
	} catch (e) { console.error(e) }
	finally { loading.value = false }
}

function handleSearch() { pageNum.value = 1; loadList() }
function refreshList() { loadList() }

function handleAdd() {
	Object.assign(formData, { id: null, skuCode: '', name: '', img: '', brand: '', spec: '', unit: '个', barcode: '', purchasePrice: 0, salePrice: 0, costPrice: 0, stockLow: 0, stockHigh: 0 })
	showModal.value = true
}
function handleEdit(item) {
	Object.assign(formData, { ...item })
	showModal.value = true
}
function handleView(item) {
	uni.showModal({ title: item.name, content: `SKU: ${item.skuCode}\n品牌: ${item.brand || '-'}\n规格: ${item.spec || '-'}\n售价: ¥${item.salePrice || 0}`, showCancel: false })
}
function handleDelete(item) {
	uni.showModal({
		title: '提示', content: `确认删除商品【${item.name || item.skuCode}】？`,
		success: async (res) => {
			if (res.confirm) {
				try {
					const r = await deleteGoods(item)
					if (r.code === '200') { uni.showToast({ title: '删除成功', icon: 'success' }); loadList() }
					else uni.showToast({ title: r.msg || '删除失败', icon: 'none' })
				} catch (e) { uni.showToast({ title: '删除失败', icon: 'none' }) }
			}
		}
	})
}
async function submitForm() {
	if (!formData.name || !formData.skuCode) { uni.showToast({ title: '请填写商品名称和SKU', icon: 'none' }); return }
	try {
		const res = formData.id ? await updateGoods(formData) : await addGoods(formData)
		if (res.code === '200') {
			uni.showToast({ title: formData.id ? '更新成功' : '添加成功', icon: 'success' })
			showModal.value = false; loadList()
		} else uni.showToast({ title: res.msg || '操作失败', icon: 'none' })
	} catch (e) { uni.showToast({ title: '提交失败', icon: 'none' }) }
}

onMounted(() => { loadList() })
</script>

<style scoped>
.page { background: #F5F7FA; min-height: 100vh; padding: 12px; }
.search-section { margin-bottom: 12px; }
.search-bar { display: flex; gap: 8px; }
.search-input-wrapper { flex: 1; display: flex; align-items: center; background: #FFFFFF; border: 1px solid #DCDFE6; border-radius: 8px; padding: 0 10px; height: 38px; }
.search-icon { margin-right: 6px; font-size: 14px; }
.search-input { flex: 1; font-size: 14px; }
.search-btn { background: #409EFF; border-radius: 8px; padding: 0 16px; display: flex; align-items: center; }
.search-btn-text { color: #FFFFFF; font-size: 14px; }
.toolbar { display: flex; gap: 10px; margin-bottom: 12px; }
.toolbar-btn { background: #FFFFFF; border: 1px solid #DCDFE6; border-radius: 8px; padding: 0 16px; height: 36px; display: flex; align-items: center; }
.toolbar-btn.primary { background: #409EFF; border-color: #409EFF; }
.btn-text { font-size: 14px; color: #303133; }
.toolbar-btn.primary .btn-text { color: #FFFFFF; }
.goods-grid { display: flex; flex-direction: column; gap: 12px; }
.goods-card { background: #FFFFFF; border-radius: 10px; overflow: hidden; }
.goods-img { width: 100%; height: 180px; }
.goods-img-placeholder { width: 100%; height: 120px; background: #F5F7FA; display: flex; align-items: center; justify-content: center; }
.placeholder-icon { font-size: 36px; }
.goods-info { padding: 12px; }
.goods-name { font-size: 16px; font-weight: 600; color: #303133; display: block; margin-bottom: 6px; }
.goods-meta { font-size: 13px; color: #909399; display: block; margin-bottom: 2px; }
.goods-price { font-size: 15px; color: #F56C6C; font-weight: 500; display: block; margin-top: 6px; }
.goods-actions { display: flex; border-top: 1px solid #F2F6FC; }
.action-btn { flex: 1; height: 40px; display: flex; align-items: center; justify-content: center; font-size: 14px; }
.action-btn.edit { color: #409EFF; }
.action-btn.delete { color: #F56C6C; border-left: 1px solid #F2F6FC; }
.empty { padding: 60px 0; text-align: center; color: #909399; font-size: 14px; }
.modal-mask { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); z-index: 1000; display: flex; align-items: center; justify-content: center; }
.modal-box { background: #FFFFFF; border-radius: 12px; width: 90%; max-height: 80vh; display: flex; flex-direction: column; }
.modal-title { font-size: 17px; font-weight: 500; text-align: center; padding: 16px; border-bottom: 1px solid #F2F6FC; }
.modal-scroll { flex: 1; max-height: 55vh; padding: 16px; }
.modal-field { margin-bottom: 14px; }
.field-label { font-size: 14px; color: #606266; margin-bottom: 6px; display: block; }
.required { color: #F56C6C; }
.field-input { border: 1px solid #DCDFE6; border-radius: 8px; padding: 0 12px; height: 40px; font-size: 14px; width: 100%; }
.picker-field { display: flex; align-items: center; }
.modal-btns { display: flex; border-top: 1px solid #F2F6FC; }
.modal-btn { flex: 1; height: 48px; display: flex; align-items: center; justify-content: center; font-size: 15px; }
.cancel { color: #606266; border-right: 1px solid #F2F6FC; }
.confirm { color: #409EFF; font-weight: 500; }
</style>
