<template>
    <div class="meeting-detail" v-loading="loading">
        <el-card shadow="never" class="header-card">
            <div class="page-header">
                <div class="page-title">
                    <el-icon>
                        <Grid/>
                    </el-icon>
                    <span>会议详情</span>
                </div>
                <el-button @click="$router.back()">
                    <el-icon>
                        <Back/>
                    </el-icon>
                    返回列表
                </el-button>
            </div>
        </el-card>

        <el-card shadow="never" v-if="meeting">
            <div class="meeting-title">
                <h1>{{ meeting.title }}</h1>
                <div class="actions">
                    <el-button type="primary" round :icon="Check" @click="handleCheckin">参加会议</el-button>
                </div>
                <el-tag round :type="statusType(meeting.status)" size="large" style="margin-top: 16px">
                    {{ statusText(meeting.status) }}
                </el-tag>
            </div>
        </el-card>

        <el-card shadow="never" v-if="meeting">
            <template #header>
                <div class="section-title">
                    <el-icon>
                        <Clock/>
                    </el-icon>
                    <span>时间信息</span>
                </div>
            </template>
            <el-row :gutter="20">
                <el-col :span="8">
                    <el-descriptions border :column="1">
                        <el-descriptions-item label="开始时间">
                            {{ meeting.startTime }}
                        </el-descriptions-item>
                    </el-descriptions>
                </el-col>
                <el-col :span="8">
                    <el-descriptions border :column="1">
                        <el-descriptions-item label="结束时间">
                            {{ meeting.endTime }}
                        </el-descriptions-item>
                    </el-descriptions>
                </el-col>
                <el-col :span="8">
                    <el-descriptions border :column="1">
                        <el-descriptions-item label="发布时间">
                            {{ meeting.publishTime }}
                        </el-descriptions-item>
                    </el-descriptions>
                </el-col>
            </el-row>
        </el-card>

        <el-card shadow="never" v-if="meeting">
            <template #header>
                <div class="section-title">
                    <el-icon>
                        <InfoFilled/>
                    </el-icon>
                    <span>会议信息</span>
                </div>
            </template>
            <el-descriptions border :column="2">
                <el-descriptions-item label="所属部门">
                    {{ meeting.deptName }}
                </el-descriptions-item>
                <el-descriptions-item label="会议地点">
                    {{ meeting.address }}
                </el-descriptions-item>
                <el-descriptions-item label="主持人">
                    {{ meeting.userName }}
                </el-descriptions-item>
<!--                <el-descriptions-item label="参会人员">-->
<!--                    {{ meeting.makeUser || "无" }}-->
<!--                </el-descriptions-item>-->
            </el-descriptions>
        </el-card>

        <el-card shadow="never" v-if="meeting">
            <template #header>
                <div class="section-title">
                    <el-icon>
                        <UserFilled/>
                    </el-icon>
                    <span>参会统计</span>
                </div>
            </template>
            <el-row :gutter="20">
                <el-col :span="6">
                    <el-card shadow="hover">
                        <el-statistic title="应到人数" :value="shouldCount"/>
                    </el-card>
                </el-col>
                <el-col :span="6">
                    <el-card shadow="hover">
                        <el-statistic title="实到人数" :value="actualCount"/>
                    </el-card>
                </el-col>
                <el-col :span="6">
                    <el-card shadow="hover">
                        <el-statistic title="未到人数" :value="absentCount"/>
                    </el-card>
                </el-col>
                <el-col :span="6">
                    <el-card shadow="hover">
                        <el-statistic title="出勤率" :value="attendanceRate" suffix="%"/>
                    </el-card>
                </el-col>
            </el-row>
        </el-card>

        <el-card shadow="never" v-if="meeting">
            <template #header>
                <div class="section-title">
                    <el-icon>
                        <Document/>
                    </el-icon>
                    <span>会议内容</span>
                </div>
            </template>
            <div class="meeting-content" v-html="meeting.content || ''"></div>
        </el-card>

        <el-card shadow="never">
            <template #header>
                <div class="section-title">
                    <el-icon>
                        <UserFilled/>
                    </el-icon>
                    <span>应到人员（{{ shouldList.length }}）</span>
                </div>
            </template>
            <el-table :data="shouldList" border>
                <el-table-column prop="name" label="姓名"/>
            </el-table>
        </el-card>

        <el-card shadow="never">
            <template #header>
                <div class="section-title">
                    <el-icon>
                        <Avatar/>
                    </el-icon>
                    <span>实到人员（{{ actualList.length }}）</span>
                </div>
            </template>
            <el-table :data="actualList" border>
                <el-table-column prop="name" label="姓名"/>
            </el-table>
        </el-card>
    </div>
</template>

<script setup>
import {computed, onMounted, ref} from "vue"
import {useRoute} from "vue-router"
import {ElMessage} from "element-plus"
import {Avatar, Back, Check, Clock, Document, Grid, InfoFilled, Select, UserFilled} from "@element-plus/icons-vue"
import {checkinMeeting, getMeetingById} from "../../api/index.js";

const route = useRoute()

const loading = ref(false)
const meeting = ref(null)

const shouldList = computed(() => {
    if (!meeting.value?.makeUser) return []
    return meeting.value.makeUser.split(",").filter(Boolean).map(name => ({name: name.trim()}))
})

const actualList = computed(() => {
    if (!meeting.value?.actualUser) return []
    return meeting.value.actualUser.split(",").filter(Boolean).map(name => ({name: name.trim()}))
})

const shouldCount = computed(() => shouldList.value.length)
const actualCount = computed(() => actualList.value.length)
const absentCount = computed(() => shouldCount.value - actualCount.value)
const attendanceRate = computed(() => {
    if (shouldCount.value === 0) return 0
    return Math.round((actualCount.value / shouldCount.value) * 100)
})

const fetchMeeting = async () => {
    const id = route.query.id
    if (!id) {
        ElMessage.error("会议ID不存在")
        return
    }
    loading.value = true
    try {
        const res = await getMeetingById(id)
        if (res.code === "200") {
            meeting.value = res.data
        } else {
            ElMessage.error(res.msg || "获取会议详情失败")
        }
    } catch {
        ElMessage.error("获取会议详情失败")
    } finally {
        loading.value = false
    }
}

const statusType = (status) => {
    switch (status) {
        case 0:
            return "warning"
        case 1:
            return "primary"
        case 2:
            return "success"
        default:
            return "info"
    }
}

const statusText = (status) => {
    switch (status) {
        case 0:
            return "未开始"
        case 1:
            return "进行中"
        case 2:
            return "已结束"
        default:
            return "未知"
    }
}

const handleCheckin = async () => {
    const id = route.query.id
    if (!id) return
    try {
        const res = await checkinMeeting(id)
        if (res.code === "200") {
            ElMessage.success("签到成功")
            fetchMeeting()
        } else {
            ElMessage.error(res.msg || "签到失败")
        }
    } catch {
        ElMessage.error("签到失败")
    }
}

onMounted(() => {
    fetchMeeting()
})
</script>

<style scoped>
.meeting-detail {
    background: #f5f7fa;
    min-height: calc(100vh - 60px);
    padding: 20px;
}

.header-card,
.el-card {
    margin-bottom: 20px;
}

.page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.page-title {
    display: flex;
    align-items: center;
    gap: 10px;
    font-size: 24px;
    font-weight: 600;
    color: #303133;
}

.meeting-title {
    text-align: center;
}

.meeting-title h1 {
    font-size: 24px;
    color: #303133;
    margin-bottom: 16px;
}

.section-title {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 18px;
    font-weight: 600;
    color: #303133;
}

.meeting-content {
    line-height: 2;
    color: #606266;
    font-size: 14px;
}

:deep(.el-descriptions__label) {
    color: #909399;
}

:deep(.el-descriptions__content) {
    color: #606266;
}

:deep(.el-card__header) {
    padding: 16px 20px;
}

:deep(.el-card__body) {
    padding: 20px;
}
</style>
