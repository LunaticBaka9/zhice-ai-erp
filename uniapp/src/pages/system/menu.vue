<template>
	<view class="page">
		<view class="toolbar">
			<view class="toolbar-btn primary" @click="handleAdd(null)"><text class="btn-text white">+ 新增菜单</text></view>
			<view class="toolbar-btn" @click="loadMenuList"><text class="btn-text">刷新</text></view>
		</view>

		<view class="list">
			<template v-for="menu in menuList" :key="menu.id">
				<view class="list-item">
					<view class="item-main" @click="toggleExpand(menu.id)">
						<text v-if="menu.children && menu.children.length" class="expand-icon">{{ expandedIds.includes(menu.id) ? '▼' : '▶' }}</text>
						<text v-else class="expand-icon placeholder"></text>
						<view class="item-info">
							<text class="item-name">{{ menu.name }}</text>
							<view class="status-tag" :class="menu.status ? 'active' : 'inactive'">
								<text class="status-text">{{ menu.status ? '启用' : '禁用' }}</text>
							</view>
						</view>
						<view class="item-actions">
							<text class="action-btn edit" @click.stop="handleAdd(menu)">添加子菜单</text>
							<text class="action-btn edit" @click.stop="handleEdit(menu)">编辑</text>
							<text class="action-btn delete" @click.stop="handleDelete(menu)">删除</text>
						</view>
					</view>
					<template v-if="menu.children && expandedIds.includes(menu.id)">
						<view class="list-item child" v-for="child in menu.children" :key="child.id">
							<view class="item-main">
								<view class="item-info">
									<text class="item-name">{{ child.name }}</text>
									<view class="status-tag" :class="child.status ? 'active' : 'inactive'">
										<text class="status-text">{{ child.status ? '启用' : '禁用' }}</text>
									</view>
								</view>
								<view class="item-actions">
									<text class="action-btn edit" @click.stop="handleAdd(child)">添加子菜单</text>
									<text class="action-btn edit" @click.stop="handleEdit(child)">编辑</text>
									<text class="action-btn delete" @click.stop="handleDelete(child)">删除</text>
								</view>
							</view>
							<template v-if="child.children && child.children.length">
								<view class="list-item child2" v-for="gc in child.children" :key="gc.id">
									<view class="item-main">
										<view class="item-info">
											<text class="item-name">{{ gc.name }}</text>
											<view class="status-tag" :class="gc.status ? 'active' : 'inactive'">
												<text class="status-text">{{ gc.status ? '启用' : '禁用' }}</text>
											</view>
										</view>
										<view class="item-actions">
											<text class="action-btn edit" @click.stop="handleEdit(gc)">编辑</text>
											<text class="action-btn delete" @click.stop="handleDelete(gc)">删除</text>
										</view>
									</view>
								</view>
							</template>
						</view>
					</template>
				</view>
			</template>
			<view v-if="menuList.length === 0 && !loading" class="empty"><text>暂无菜单数据</text></view>
		</view>

		<view v-if="showModal" class="modal-mask" @click="showModal = false">
			<view class="modal-box" @click.stop>
				<text class="modal-title">{{ form.id ? '编辑菜单' : '新增菜单' }}</text>
				<scroll-view scroll-y class="modal-scroll">
					<view class="modal-field">
						<text class="field-label">菜单 <text class="required">*</text></text>
						<input class="field-input" v-model="form.name" placeholder="请输入菜单" />
					</view>
					<view class="modal-field">
						<text class="field-label">父级菜单</text>
						<picker :range="parentOptions" range-key="label" @change="handleParentChange">
							<view class="field-input picker-field">
								<text>{{ parentLabel || '请选择（留空为顶级）' }}</text>
							</view>
						</picker>
					</view>
					<view class="modal-field">
						<text class="field-label">状态</text>
						<picker :range="statusOptions" range-key="label" @change="handleStatusChange">
							<view class="field-input picker-field">
								<text>{{ form.status ? '启用' : '禁用' }}</text>
							</view>
						</picker>
					</view>
					<view class="modal-field">
						<text class="field-label">菜单简介</text>
						<textarea class="field-textarea" v-model="form.bio" placeholder="请输入菜单简介" :maxlength="200" />
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
import { getMenuList, addMenu, updateMenu, deleteMenu } from '@/api/menu'

const menuList = ref([])
const loading = ref(false)
const showModal = ref(false)
const expandedIds = ref([])

const form = reactive({ id: null, pid: null, name: '', bio: '', status: true })

const statusOptions = [{ value: true, label: '启用' }, { value: false, label: '禁用' }]

const allMenus = ref([])

const flatMenus = (menus, result = []) => {
	for (const m of menus) {
		result.push(m)
		if (m.children && m.children.length) flatMenus(m.children, result)
	}
	return result
}

const parentOptions = computed(() => {
	const opts = [{ value: null, label: '无（顶级）' }]
	const flatten = (list, prefix = '') => {
		for (const m of list) {
			opts.push({ value: m.id, label: prefix + m.name })
			if (m.children && m.children.length) flatten(m.children, prefix + m.name + ' / ')
		}
	}
	flatten(menuList.value)
	return opts
})

const parentLabel = computed(() => {
	if (!form.pid) return ''
	const opt = parentOptions.value.find(o => o.value === form.pid)
	return opt ? opt.label : ''
})

function toggleExpand(id) {
	const idx = expandedIds.value.indexOf(id)
	if (idx > -1) expandedIds.value.splice(idx, 1)
	else expandedIds.value.push(id)
}

function handleParentChange(e) {
	const idx = e.detail.value
	form.pid = parentOptions.value[idx]?.value ?? null
}

function handleStatusChange(e) {
	const idx = e.detail.value
	form.status = statusOptions[idx]?.value ?? true
}

async function loadMenuList() {
	loading.value = true
	try {
		const res = await getMenuList()
		if (res.code === '200') {
			const data = Array.isArray(res.data) ? res.data : (res.data.records || [])
			menuList.value = data
			allMenus.value = flatMenus(data)
		}
	} catch (e) { console.error(e) }
	finally { loading.value = false }
}

function handleAdd(parent) {
	Object.assign(form, { id: null, pid: parent ? parent.id : null, name: '', bio: '', status: true })
	showModal.value = true
}

function handleEdit(row) {
	Object.assign(form, { id: row.id || null, pid: row.pid || null, name: row.name || '', status: row.status ?? true, bio: row.bio || '' })
	showModal.value = true
}

async function submitForm() {
	if (!form.name) { uni.showToast({ title: '请输入菜单名称', icon: 'none' }); return }
	try {
		const fn = form.id ? updateMenu : addMenu
		const res = await fn({ ...form })
		if (res.code === '200') {
			uni.showToast({ title: '保存成功', icon: 'success' })
			showModal.value = false; loadMenuList()
		} else uni.showToast({ title: res.msg || '操作失败', icon: 'none' })
	} catch (e) { uni.showToast({ title: '提交失败', icon: 'none' }) }
}

function handleDelete(row) {
	uni.showModal({
		title: '提示', content: `确定要删除菜单"${row.name}"吗？`,
		success: async (res) => {
			if (res.confirm) {
				try {
					const r = await deleteMenu({ id: row.id })
					if (r.code === '200') { uni.showToast({ title: '删除成功', icon: 'success' }); loadMenuList() }
					else uni.showToast({ title: r.msg || '删除失败', icon: 'none' })
				} catch (e) { uni.showToast({ title: '删除失败', icon: 'none' }) }
			}
		}
	})
}

onMounted(() => { loadMenuList() })
</script>

<style scoped>
.page { background: #F5F7FA; min-height: 100vh; padding: 12px; }
.toolbar { display: flex; gap: 10px; margin-bottom: 12px; }
.toolbar-btn { background: #FFFFFF; border: 1px solid #DCDFE6; border-radius: 8px; padding: 0 16px; height: 36px; display: flex; align-items: center; }
.toolbar-btn.primary { background: #409EFF; border-color: #409EFF; }
.btn-text { font-size: 14px; color: #303133; }
.btn-text.white { color: #FFFFFF; }
.list { display: flex; flex-direction: column; }
.list-item { background: #FFFFFF; border-radius: 10px; margin-bottom: 6px; padding: 14px; }
.list-item.child { margin-left: 24px; }
.list-item.child2 { margin-left: 24px; }
.item-main { display: flex; align-items: center; gap: 8px; }
.expand-icon { font-size: 12px; color: #909399; width: 16px; }
.expand-icon.placeholder { visibility: hidden; }
.item-info { flex: 1; display: flex; align-items: center; gap: 8px; }
.item-name { font-size: 15px; font-weight: 500; color: #303133; }
.status-tag { padding: 2px 8px; border-radius: 4px; }
.status-tag.active { background: #F0F9EB; }
.status-tag.active .status-text { color: #67C23A; font-size: 12px; }
.status-tag.inactive { background: #FEF0F0; }
.status-tag.inactive .status-text { color: #F56C6C; font-size: 12px; }
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
