<template>
	<view class="page">
		<scroll-view scroll-y class="form-scroll">
			<view class="form-section">
				<view class="modal-field">
					<text class="field-label">会议主题 <text class="required">*</text></text>
					<input class="field-input" v-model="form.title" placeholder="请输入会议主题" />
				</view>
				<view class="modal-field">
					<text class="field-label">会议描述</text>
					<textarea class="field-textarea" v-model="form.description" placeholder="请输入会议描述" :maxlength="500" />
				</view>
				<view class="modal-field">
					<text class="field-label">开始时间 <text class="required">*</text></text>
					<picker mode="datetime" :value="form.startTime" @change="form.startTime = $event.detail.value">
						<view class="field-input picker-field">
							<text>{{ form.startTime || '请选择开始时间' }}</text>
						</view>
					</picker>
				</view>
				<view class="modal-field">
					<text class="field-label">结束时间 <text class="required">*</text></text>
					<picker mode="datetime" :value="form.endTime" @change="form.endTime = $event.detail.value">
						<view class="field-input picker-field">
							<text>{{ form.endTime || '请选择结束时间' }}</text>
						</view>
					</picker>
				</view>
				<view class="modal-field">
					<text class="field-label">会议地点</text>
					<input class="field-input" v-model="form.location" placeholder="请输入会议地点" />
				</view>
				<view class="modal-field">
					<text class="field-label">参与人 <text class="required">*</text></text>
					<view class="participants-list">
						<view v-for="(user, idx) in allUsers" :key="user.id" class="participant-item" @click="toggleParticipant(user)">
							<view class="checkbox" :class="{ 'checkbox-checked': isSelected(user.id) }">
								<text v-if="isSelected(user.id)" class="check-icon">✓</text>
							</view>
							<text class="participant-name">{{ user.username || user.name }}</text>
						</view>
						<view v-if="allUsers.length === 0" class="empty"><text>暂无可选参与人</text></view>
					</view>
					<view v-if="form.participantIds.length > 0" class="selected-info">
						<text class="selected-text">已选 {{ form.participantIds.length }} 人</text>
					</view>
				</view>
			</view>
		</scroll-view>
		<view class="bottom-bar">
			<view class="bottom-btn cancel" @click="goBack"><text>取消</text></view>
			<view class="bottom-btn confirm" @click="submitForm"><text>创建会议</text></view>
		</view>
	</view>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { createMeeting } from '@/api/meeting'
import { useUserStore } from '@/store/user'

const userStore = useUserStore()
const allUsers = computed(() => userStore.allUsers)

const form = reactive({
	title: '',
	description: '',
	startTime: '',
	endTime: '',
	location: '',
	participantIds: [],
})

function isSelected(userId) {
	return form.participantIds.includes(userId)
}

function toggleParticipant(user) {
	const idx = form.participantIds.indexOf(user.id)
	if (idx >= 0) {
		form.participantIds.splice(idx, 1)
	} else {
		form.participantIds.push(user.id)
	}
}

function goBack() { uni.navigateBack() }

async function submitForm() {
	if (!form.title) { uni.showToast({ title: '请输入会议主题', icon: 'none' }); return }
	if (!form.startTime) { uni.showToast({ title: '请选择开始时间', icon: 'none' }); return }
	if (!form.endTime) { uni.showToast({ title: '请选择结束时间', icon: 'none' }); return }
	if (!form.participantIds.length) { uni.showToast({ title: '请选择参与人', icon: 'none' }); return }
	try {
		const res = await createMeeting(form)
		if (res.code === '200') {
			uni.showToast({ title: '创建成功', icon: 'success' })
			setTimeout(() => { uni.navigateBack() }, 1500)
		} else uni.showToast({ title: res.msg || '创建失败', icon: 'none' })
	} catch (e) { uni.showToast({ title: '提交失败', icon: 'none' }) }
}

onMounted(() => { userStore.fetchAllUsers() })
</script>

<style scoped>
.page { background: #F5F7FA; min-height: 100vh; display: flex; flex-direction: column; }
.form-scroll { flex: 1; padding: 12px; }
.form-section { background: #FFFFFF; border-radius: 10px; padding: 16px; }
.modal-field { margin-bottom: 16px; }
.field-label { font-size: 14px; color: #606266; margin-bottom: 6px; display: block; }
.required { color: #F56C6C; }
.field-input { border: 1px solid #DCDFE6; border-radius: 8px; padding: 0 12px; height: 40px; font-size: 14px; width: 100%; }
.picker-field { display: flex; align-items: center; }
.field-textarea { border: 1px solid #DCDFE6; border-radius: 8px; padding: 10px 12px; font-size: 14px; width: 100%; height: 100px; }
.participants-list { border: 1px solid #DCDFE6; border-radius: 8px; padding: 8px; max-height: 200px; overflow: hidden; }
.participant-item { display: flex; align-items: center; padding: 8px 4px; gap: 8px; }
.checkbox { width: 20px; height: 20px; border: 2px solid #DCDFE6; border-radius: 4px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.checkbox-checked { background: #409EFF; border-color: #409EFF; }
.check-icon { font-size: 12px; color: #FFFFFF; }
.participant-name { font-size: 14px; color: #303133; }
.selected-info { margin-top: 8px; }
.selected-text { font-size: 13px; color: #409EFF; }
.empty { padding: 20px 0; text-align: center; color: #909399; font-size: 13px; }
.bottom-bar { display: flex; background: #FFFFFF; border-top: 1px solid #F2F6FC; }
.bottom-btn { flex: 1; height: 50px; display: flex; align-items: center; justify-content: center; font-size: 16px; }
.cancel { color: #606266; border-right: 1px solid #F2F6FC; }
.confirm { color: #FFFFFF; background: #409EFF; }
</style>
