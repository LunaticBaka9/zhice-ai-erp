<template>
    <div class="meeting-page">
        <!-- 顶部 -->
        <el-card class="header-card" shadow="never">
            <div class="header">
                <div class="title">
                    <el-icon><Grid /></el-icon>
                    <span>会议系统管理</span>
                </div>
                <el-button type="primary" :icon="Plus" round @click="goCreate"> 发布会议 </el-button>
            </div>
        </el-card>

        <!-- 搜索 -->
        <el-card class="search-card" shadow="never">
            <el-form :inline="true">
                <el-form-item label="搜索会议">
                    <el-input
                        v-model="query.keyword"
                        placeholder="请输入会议标题..."
                        clearable
                        style="width: 500px"
                        @clear="handleSearch"
                        @keyup.enter="handleSearch"
                    />
                </el-form-item>
                <el-form-item label="会议状态">
                    <el-select v-model="query.status" style="width: 220px" @change="handleSearch">
                        <el-option label="全部状态" value="" />
                        <el-option label="未开始" :value="0" />
                        <el-option label="进行中" :value="1" />
                        <el-option label="已结束" :value="2" />
                    </el-select>
                </el-form-item>
                <el-button type="primary" :icon="Search" @click="handleSearch"> 搜索 </el-button>
            </el-form>
        </el-card>

        <!-- 列表 -->
        <el-card class="list-card" shadow="never" v-loading="loading">
            <template #header>
                <div class="card-title">
                    <el-icon><Tickets /></el-icon>
                    <span>会议列表</span>
                </div>
            </template>
            <div class="meeting-item" v-for="item in meetingList" :key="item.id" @click="goDetail(item.id)" style="cursor: pointer">
                <div class="top">
                    <div class="name">
                        <el-icon><ChatDotRound /></el-icon>
                        {{ item.title }}
                    </div>

                    <el-tag round :type="statusType(item.status)">
                        {{ statusText(item.status) }}
                    </el-tag>   
                </div>
                <div class="info">
                    <span>
                        <el-icon><OfficeBuilding /></el-icon>
                        部门：{{ item.deptName }}
                    </span>
                    <span>
                        <el-icon><Clock /></el-icon>
                        开始时间：{{ item.startTime }}
                    </span>
                </div>
                <div class="content">
                    {{ stripHtml(item.content) }}
                </div>
            </div>
            <div class="pagination">
                <el-pagination
                    background
                    v-model:current-page="pagination.pageNum"
                    v-model:page-size="pagination.pageSize"
                    layout="total, sizes, prev, pager, next, jumper"
                    :total="pagination.total"
                    :page-sizes="[5, 10, 20, 50]"
                    @current-change="handleCurrentChange"
                    @size-change="handleSizeChange"
                />
            </div>
        </el-card>
    </div>
</template>

<script setup>
import { Plus, Search, Grid, Tickets, ChatDotRound, Clock, OfficeBuilding } from "@element-plus/icons-vue";
import { reactive, ref, onMounted } from "vue";
import { useRouter } from "vue-router";
import { ElMessage } from "element-plus";
import {getMeetingList} from "../../api/index.js";

const router = useRouter();

const query = reactive({
    keyword: "",
    status: "",
});

const loading = ref(false);
const meetingList = ref([]);
const pagination = reactive({
    pageNum: 1,
    pageSize: 10,
    total: 0,
});

const fetchMeetingList = async () => {
    loading.value = true;
    try {
        const params = {
            currentPage: pagination.pageNum,
            pageSize: pagination.pageSize,
        };
        if (query.keyword) params.searchQuery = query.keyword;
        if (query.status !== "") params.statusFilter = query.status;
        const res = await getMeetingList(params);
        if (res.code === "200") {
            meetingList.value = res.data.records || [];
            pagination.total = res.data.total || 0;
        } else {
            ElMessage.error(res.msg || "获取会议列表失败");
        }
    } catch {
        ElMessage.error("获取会议列表失败");
    } finally {
        loading.value = false;
    }
};

const handleSearch = () => {
    pagination.pageNum = 1;
    fetchMeetingList();
};

const handleCurrentChange = (val) => {
    pagination.pageNum = val;
    fetchMeetingList();
};

const handleSizeChange = (val) => {
    pagination.pageSize = val;
    pagination.pageNum = 1;
    fetchMeetingList();
};

const goCreate = () => {
    router.push("/meeting/create");
};

const goDetail = (id) => {
    router.push(`/meeting/detail?id=${id}`);
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
            return "未开始"
        case 1:
            return "进行中"
        case 2:
            return "已结束"
        default:
            return "未知"
    }
}

const stripHtml = (html) => {
    if (!html) return ""
    const doc = new DOMParser().parseFromString(html, "text/html")
    return doc.body.textContent || ""
}

onMounted(() => {
    fetchMeetingList();
});
</script>

<style scoped>
.meeting-page {
    padding: 20px;
    background-color: #f5f7fa;
    min-height: calc(100vh - 60px);
}

.header-card,
.search-card,
.list-card {
    margin-bottom: 20px;
}

.header {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.title {
    display: flex;
    align-items: center;
    font-size: 24px;
    font-weight: 600;
    color: #303133;
    gap: 12px;
}

.card-title {
    display: flex;
    gap: 10px;
    color: #303133;
    font-size: 18px;
    font-weight: 600;
}

.meeting-item {
    padding: 20px 0;
    border-bottom: 1px solid #ebeef5;

    &:last-child {
        border: none;
    }
}

.top {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.name {
    color: #303133;
    font-size: 18px;
    font-weight: 600;
    display: flex;
    gap: 8px;
    align-items: center;
}

.info {
    display: flex;
    gap: 30px;
    margin: 12px 0;
    color: #909399;
    font-size: 14px;
}

.content {
    color: #606266;
    overflow: hidden;
    white-space: nowrap;
    text-overflow: ellipsis;
    font-size: 14px;
}

.pagination {
    margin-top: 20px;
    display: flex;
    justify-content: flex-end;
}
</style>
