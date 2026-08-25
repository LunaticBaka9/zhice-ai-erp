<template>
    <div class="meeting-detail" v-loading="loading">
        <el-card shadow="never" class="header-card">
            <div class="page-header">
                <div class="page-title">
                    <el-icon>
                        <Grid />
                    </el-icon>
                    <span>会议详情</span>
                </div>
                <div>
                    <el-button @click="$router.back()">
                        <el-icon>
                            <Back />
                        </el-icon>
                        返回列表
                    </el-button>
                    <el-button v-if="canDeleteMeeting" type="danger" plain round :icon="Delete" @click="handleDelete">
                        删除会议
                    </el-button>
                </div>
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
                        <Clock />
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
                        <InfoFilled />
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
            </el-descriptions>
        </el-card>

        <el-card shadow="never" v-if="meeting">
            <template #header>
                <div class="section-title">
                    <el-icon>
                        <UserFilled />
                    </el-icon>
                    <span>参会统计</span>
                </div>
            </template>
            <el-row :gutter="20">
                <el-col :span="6">
                    <el-card shadow="hover">
                        <el-statistic title="应到人数" :value="shouldCount" />
                    </el-card>
                </el-col>
                <el-col :span="6">
                    <el-card shadow="hover">
                        <el-statistic title="实到人数" :value="actualCount" />
                    </el-card>
                </el-col>
                <el-col :span="6">
                    <el-card shadow="hover">
                        <el-statistic title="未到人数" :value="absentCount" />
                    </el-card>
                </el-col>
                <el-col :span="6">
                    <el-card shadow="hover">
                        <el-statistic title="出勤率" :value="attendanceRate" suffix="%" />
                    </el-card>
                </el-col>
            </el-row>
        </el-card>

        <el-card shadow="never" v-if="meeting">
            <template #header>
                <div class="section-title">
                    <el-icon>
                        <Document />
                    </el-icon>
                    <span>会议内容</span>
                </div>
            </template>
            <div class="meeting-content" v-html="meeting.content || ''"></div>
        </el-card>

        <!-- 应到人员 -->
        <el-card shadow="never" class="person-section">
            <template #header>
                <div class="section-title">
                    <el-icon>
                        <UserFilled />
                    </el-icon>
                    <span>应到人员（{{ shouldList.length }}）</span>
                </div>
            </template>
            <div class="person-grid">
                <div v-for="person in shouldList" :key="person.name" class="person-chip person-chip--purple">
                    <el-icon>
                        <UserFilled />
                    </el-icon>
                    <span>{{ person.name }}</span>
                </div>
            </div>
        </el-card>

        <!-- 实到人员 -->
        <el-card shadow="never" class="person-section">
            <template #header>
                <div class="section-title">
                    <el-icon>
                        <Avatar />
                    </el-icon>
                    <span>实到人员（{{ actualList.length }}）</span>
                </div>
            </template>
            <div class="person-grid">
                <div v-for="person in actualList" :key="person.name" class="person-chip person-chip--green">
                    <el-icon>
                        <Avatar />
                    </el-icon>
                    <span>{{ person.name }}</span>
                </div>
            </div>
        </el-card>

        <!-- 未到人员 -->
        <el-card shadow="never" class="person-section" v-if="meeting && meeting.status !== 0">
            <template #header>
                <div class="section-title">
                    <el-icon>
                        <CircleCloseFilled />
                    </el-icon>
                    <span>未到人员（{{ absentList.length }}）</span>
                </div>
            </template>
            <div class="person-grid">
                <div v-for="person in absentList" :key="person.name" class="person-chip person-chip--red">
                    <el-icon>
                        <CircleCloseFilled />
                    </el-icon>
                    <span>{{ person.name }}</span>
                </div>
            </div>
        </el-card>
    </div>
</template>

<script setup>
import { computed, onMounted, ref } from "vue";
import { useRoute, useRouter } from "vue-router";
import { ElMessage, ElMessageBox } from "element-plus";
import {
    Avatar,
    Back,
    Check,
    CircleCloseFilled,
    Clock,
    Delete,
    Document,
    Grid,
    InfoFilled,
    UserFilled,
} from "@element-plus/icons-vue";
import { checkinMeeting, deleteMeeting, getMeetingById } from "../../api/index.js";

const route = useRoute();
const router = useRouter();

const loading = ref(false);
const meeting = ref(null);
const localUser = ref(null);

const shouldList = computed(() => {
    if (!meeting.value?.makeUser) return [];
    return meeting.value.makeUser
        .split(",")
        .filter(Boolean)
        .map((name) => ({ name: name.trim() }));
});

const actualList = computed(() => {
    if (!meeting.value?.actualUser) return [];
    return meeting.value.actualUser
        .split(",")
        .filter(Boolean)
        .map((name) => ({ name: name.trim() }));
});

const shouldCount = computed(() => shouldList.value.length);
const actualCount = computed(() => actualList.value.length);
const absentList = computed(() => {
    return shouldList.value.filter((s) => !actualList.value.find((a) => a.name === s.name));
});
const absentCount = computed(() => absentList.value.length);
const attendanceRate = computed(() => {
    if (shouldCount.value === 0) return 0;
    return Math.round((actualCount.value / shouldCount.value) * 100);
});

const canDeleteMeeting = computed(() => {
    if (!localUser.value || !meeting.value) return false;
    const roleName = localUser.value.roleName;
    const isAdmin = String(roleName).includes("超级管理员") || String(roleName).includes("系统管理员");
    const isHost = String(localUser.value.uid) === String(meeting.value.userId);
    return isAdmin || isHost;
});

const fetchMeeting = async () => {
    const id = route.query.id;
    if (!id) {
        ElMessage.error("会议ID不存在");
        return;
    }
    loading.value = true;
    try {
        const res = await getMeetingById(id);
        if (res.code === "200") {
            meeting.value = res.data;
        } else {
            ElMessage.error(res.msg || "获取会议详情失败");
        }
    } catch {
        ElMessage.error("获取会议详情失败");
    } finally {
        loading.value = false;
    }
};

const statusType = (status) => {
    switch (status) {
        case 0:
            return "warning";
        case 1:
            return "primary";
        case 2:
            return "success";
        default:
            return "info";
    }
};

const statusText = (status) => {
    switch (status) {
        case 0:
            return "未开始";
        case 1:
            return "进行中";
        case 2:
            return "已结束";
        default:
            return "未知";
    }
};

const handleCheckin = async () => {
    const id = route.query.id;
    if (!id) return;
    try {
        const res = await checkinMeeting(id);
        if (res.code === "200") {
            ElMessage.success("签到成功");
            fetchMeeting();
        } else {
            ElMessage.error(res.msg || "签到失败");
        }
    } catch {
        ElMessage.error("签到失败");
    }
};

const handleDelete = async () => {
    if (!meeting.value) return;
    try {
        await ElMessageBox.confirm("确认删除该会议吗？", "删除会议", {
            confirmButtonText: "确定",
            cancelButtonText: "取消",
            type: "warning",
        });
        const res = await deleteMeeting({ id: meeting.value.id });
        if (res.code === "200") {
            ElMessage.success("删除成功");
            router.push("/meeting/index");
        } else {
            ElMessage.error(res.msg || "删除失败");
        }
    } catch (error) {
        if (error !== "cancel" && error !== "cancelled") {
            ElMessage.error("删除失败");
        }
    }
};

onMounted(() => {
    const localUserStr = localStorage.getItem("local_user");
    if (localUserStr) {
        try {
            localUser.value = JSON.parse(localUserStr);
        } catch (e) {
            localUser.value = null;
        }
    }
    fetchMeeting();
});
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

.person-section :deep(.el-card__header) {
    border-bottom: 1px solid #ebeef5;
}

.person-grid {
    display: flex;
    flex-wrap: wrap;
    gap: 12px;
}

.person-chip {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 12px 20px;
    border-radius: 8px;
    background: #f5f7fa;
    font-size: 14px;
    color: #606266;
    transition: all 0.2s;
}

.person-chip--purple {
    border-left: 3px solid #9b59b6;
}

.person-chip--purple .el-icon {
    color: #9b59b6;
}

.person-chip--green {
    border-left: 3px solid #67c23a;
}

.person-chip--green .el-icon {
    color: #67c23a;
}

.person-chip--red {
    border-left: 3px solid #f56c6c;
}

.person-chip--red .el-icon {
    color: #f56c6c;
}
</style>
