<template>
	<view class="page">
		<view class="search-bar">
			<view class="search-input-wrapper">
				<input class="search-input" v-model="keyword" placeholder="搜索部门名称" @confirm="handleSearch" />
			</view>
			<view class="search-btn" @click="handleSearch"><text class="btn-text">搜索</text></view>
			<view class="search-btn outline" @click="resetSearch"><text class="btn-text outline-text">重置</text></view>
		</view>
		<view class="toolbar">
			<view class="toolbar-btn primary" @click="handleAdd(null)"><text class="btn-text white">+ 新增部门</text></view>
		</view>

		<!-- 树形部门列表 -->
		<view class="list">
			<template v-for="dept in deptList" :key="dept.id">
				<view class="list-item">
					<view class="item-main" @click="toggleExpand(dept.id)">
						<text v-if="dept.children && dept.children.length" class="expand-icon">{{ expandedIds.includes(dept.id) ? '▼' : '▶' }}</text>
						<text v-else class="expand-icon placeholder"></text>
						<view class="item-info">
							<text class="item-name">{{ dept.name }}</text>
							<text class="item-desc" v-if="dept.intro">{{ dept.intro }}</text>
						</view>
							<view class="item-actions">
							<text class="action-btn edit" @click.stop="handleAdd(dept)">添加子部门</text>
							<text class="action-btn edit" @click.stop="handleEdit(dept)">编辑</text>
							<text class="action-btn delete" @click.stop="handleDelete(dept)">删除</text>
						</view>
					</view>
					<!-- 子部门 -->
					<template v-if="dept.children && expandedIds.includes(dept.id)">
						<view class="list-item child" v-for="child in dept.children" :key="child.id">
							<view class="item-main">
								<view class="item-info">
									<text class="item-name">{{ child.name }}</text>
									<text class="item-desc" v-if="child.intro">{{ child.intro }}</text>
								</view>
								<view class="item-actions">
									<text class="action-btn edit" @click="handleEdit(child)">编辑</text>
									<text class="action-btn delete" @click="handleDelete(child)">删除</text>
								</view>
							</view>
							<template v-if="child.children && child.children.length">
								<view class="list-item child2" v-for="gc in child.children" :key="gc.id">
									<view class="item-main">
										<view class="item-info">
											<text class="item-name">{{ gc.name }}</text>
										</view>
										<view class="item-actions">
											<text class="action-btn edit" @click="handleEdit(gc)">编辑</text>
											<text class="action-btn delete" @click="handleDelete(gc)">删除</text>
										</view>
									</view>
								</view>
							</template>
						</view>
					</template>
				</view>
			</template>
			<view v-if="deptList.length === 0 && !loading" class="empty"><text>暂无部门数据</text></view>
		</view>

		<!-- 新增/编辑弹窗 -->
		<view v-if="showModal" class="modal-mask" @click="showModal = false">
			<view class="modal-box" @click.stop>
				<text class="modal-title">{{ form.id ? '编辑部门' : '新增部门' }}</text>
				<scroll-view scroll-y class="modal-scroll">
					<view class="modal-field">
						<text class="field-label">部门名称 <text class="required">*</text></text>
						<input class="field-input" v-model="form.name" placeholder="请输入部门名称" />
					</view>
					<view class="modal-field">
						<text class="field-label">部门代码</text>
						<input class="field-input" v-model="form.code" placeholder="请输入部门代码" />
					</view>
					<view class="modal-field">
						<text class="field-label">父级部门</text>
						<picker :range="parentOptions" range-key="label" @change="handleParentChange">
							<view class="field-input picker-field">
								<text>{{ parentLabel || '请选择（留空为顶级）' }}</text>
							</view>
						</picker>
					</view>
					<view class="modal-field">
						<text class="field-label">状态</text>
						<picker :range="statusOptions" range-key="label" @change="handleStatusPickerChange">
							<view class="field-input picker-field">
								<text>{{ form.status === 1 ? '启用' : '禁用' }}</text>
							</view>
						</picker>
					</view>
					<view class="modal-field">
						<text class="field-label">部门简介</text>
						<textarea class="field-textarea" v-model="form.intro" placeholder="请输入部门简介" :maxlength="200" />
					</view>
				</scroll-view>
				<view class="modal-btns">
					<view class="modal-btn cancel" @click="showModal = false"><text>取消</text></view>
					<view class="modal-btn confirm" @click="submitForm"><text>确认</text></view>
				</view>
			</view>
		</view>
	</view>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { getDeptList, addDept, updateDept, deleteDept } from '@/api/dept'

const keyword = ref('')
const deptList = ref([])
const loading = ref(false)
const showModal = ref(false)
const expandedIds = ref([])

const form = reactive({ id: null, parentId: null, name: '', code: '', status: 1, intro: '' })

const statusOptions = [{ value: 1, label: '启用' }, { value: 0, label: '禁用' }]

const parentOptions = computed(() => {
	const opts = [{ value: null, label: '无（顶级）' }]
	const flatten = (list, prefix = '') => {
		for (const d of list) {
			opts.push({ value: d.id, label: prefix + d.name })
			if (d.children && d.children.length) flatten(d.children, prefix + d.name + ' / ')
		}
	}
	flatten(deptList.value)
	return opts
})

const parentLabel = computed(() => {
	if (!form.parentId) return ''
	const opt = parentOptions.value.find(o => o.value === form.parentId)
	return opt ? opt.label : ''
})

function toggleExpand(id) {
	const idx = expandedIds.value.indexOf(id)
	if (idx > -1) expandedIds.value.splice(idx, 1)
	else expandedIds.value.push(id)
}

function handleParentChange(e) {
	const idx = e.detail.value
	form.parentId = parentOptions.value[idx]?.value ?? null
}

function handleStatusPickerChange(e) {
	const idx = e.detail.value
	form.status = statusOptions[idx]?.value ?? 1
}

async function loadDeptList() {
	loading.value = true
	try {
		const res = await getDeptList()
		if (res.code === '200') {
			deptList.value = Array.isArray(res.data) ? res.data : (res.data.records || [])
		}
	} catch (e) { console.error(e) }
	finally { loading.value = false }
}

function handleSearch() { loadDeptList() }
function resetSearch() { keyword.value = ''; loadDeptList() }

function handleAdd(parent) {
	Object.assign(form, { id: null, parentId: parent ? parent.id : null, name: '', code: '', status: 1, intro: '' })
	showModal.value = true
}

function handleEdit(row) {
	Object.assign(form, { id: row.id, parentId: row.parentId || null, name: row.name || '', code: row.code || '', status: row.status ?? 1, intro: row.intro || '' })
	showModal.value = true
}

async function submitForm() {
	if (!form.name) { uni.showToast({ title: '请输入部门名称', icon: 'none' }); return }
	try {
		const fn = form.id ? updateDept : addDept
		const res = await fn({ ...form })
		if (res.code === '200') {
			uni.showToast({ title: '保存成功', icon: 'success' })
			showModal.value = false; loadDeptList()
		} else uni.showToast({ title: res.msg || '操作失败', icon: 'none' })
	} catch (e) { uni.showToast({ title: '提交失败', icon: 'none' }) }
}

function handleDelete(row) {
	uni.showModal({
		title: '提示', content: `确认删除部门「${row.name}」？`,
		success: async (res) => {
			if (res.confirm) {
				try {
					const r = await deleteDept({ id: row.id })
					if (r.code === '200') { uni.showToast({ title: '删除成功', icon: 'success' }); loadDeptList() }
					else uni.showToast({ title: r.msg || '删除失败', icon: 'none' })
				} catch (e) { uni.showToast({ title: '删除失败', icon: 'none' }) }
			}
		}
	})
}

onMounted(() => { loadDeptList() })
</script>

<style scoped>
.page { background: #F5F7FA; min-height: 100vh; padding: 12px; }
.search-bar { display: flex; gap: 8px; margin-bottom: 12px; }
.search-input-wrapper { flex: 1; display: flex; align-items: center; background: #FFFFFF; border: 1px solid #DCDFE6; border-radius: 8px; padding: 0 10px; height: 38px; }
.search-input { flex: 1; font-size: 14px; }
.search-btn { background: #409EFF; border-radius: 8px; padding: 0 16px; display: flex; align-items: center; height: 38px; }
.search-btn.outline { background: #FFFFFF; border: 1px solid #DCDFE6; }
.btn-text { font-size: 14px; color: #FFFFFF; }
.outline-text { color: #606266; }
.toolbar { display: flex; gap: 10px; margin-bottom: 12px; }
.toolbar-btn { background: #FFFFFF; border: 1px solid #DCDFE6; border-radius: 8px; padding: 0 16px; height: 36px; display: flex; align-items: center; }
.toolbar-btn.primary { background: #409EFF; border-color: #409EFF; }
.white { color: #FFFFFF; }
.list { display: flex; flex-direction: column; }
.list-item { background: #FFFFFF; border-radius: 10px; margin-bottom: 6px; padding: 14px; }
.list-item.child { margin-left: 24px; }
.list-item.child2 { margin-left: 24px; }
.item-main { display: flex; align-items: center; gap: 8px; }
.expand-icon { font-size: 12px; color: #909399; width: 16px; }
.expand-icon.placeholder { visibility: hidden; }
.item-info { flex: 1; }
.item-name { font-size: 15px; font-weight: 500; color: #303133; display: block; }
.item-desc { font-size: 12px; color: #909399; display: block; margin-top: 2px; }
.item-actions { display: flex; gap: 12px; flex-shrink: 0; }
.action-btn { font-size: 13px; }
.action-btn.edit { color: #409EFF; }
.action-btn.delete { color: #F56C6C; }
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
.field-textarea { border: 1px solid #DCDFE6; border-radius: 8px; padding: 10px 12px; font-size: 14px; width: 100%; height: 100px; }
.modal-btns { display: flex; border-top: 1px solid #F2F6FC; }
.modal-btn { flex: 1; height: 48px; display: flex; align-items: center; justify-content: center; font-size: 15px; }
.cancel { color: #606266; border-right: 1px solid #F2F6FC; }
.confirm { color: #409EFF; font-weight: 500; }
</style>
