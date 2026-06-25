<template>
    <div class="meeting-management">
        <el-card class="search-card" shadow="never">
            <el-form :inline="true" :model="searchForm" class="search-form">
                <el-form-item label="搜索会议">
                    <el-input
                        v-model="searchForm.searchQuery"
                        placeholder="请输入会议标题"
                        clearable
                        @clear="handleSearch"
                        @keyup.enter="handleSearch"
                    />
                </el-form-item>
                <el-form-item label="会议状态">
                    <el-select
                        v-model="searchForm.statusFilter"
                        placeholder="全部状态"
                        clearable
                        @change="handleSearch"
                        style="width: 120px"
                    >
                        <el-option label="全部状态" value="-1"/>
                        <el-option label="未开始" value="0"/>
                        <el-option label="正在进行" value="1"/>
                        <el-option label="已结束" value="2"/>
                    </el-select>
                </el-form-item>
                <el-form-item>
                    <el-button type="primary" @click="handleSearch">
                        <el-icon>
                            <Search/>
                        </el-icon>
                        搜索
                    </el-button>
                    <el-button @click="resetSearch">
                        <el-icon>
                            <Refresh/>
                        </el-icon>
                        重置
                    </el-button>
                </el-form-item>
            </el-form>
        </el-card>

        <el-card class="table-card" shadow="never">
            <el-table :data="meetingList" v-loading="loading" stripe border style="width: 100%">
                <el-table-column type="index" label="序号" width="60"/>
                <el-table-column prop="title" label="会议标题" min-width="200"/>
                <el-table-column prop="deptName" label="部门" width="150"/>
                <el-table-column prop="startTime" label="开始时间" width="180"/>
                <el-table-column prop="status" label="状态" width="120">
                    <template #default="{ row }">
                        <el-tag :type="statusTypeMap[row.status] || 'info'">
                            {{ getStatusText(row.status) }}
                        </el-tag>
                    </template>
                </el-table-column>
                <el-table-column label="操作" width="180" fixed="right">
                    <template #default="{ row }">
                        <el-button link type="primary" size="small" @click="handleEdit(row)">
                            <el-icon>
                                <Edit/>
                            </el-icon>
                            编辑
                        </el-button>
                        <el-button link type="danger" size="small" @click="handleDelete(row)">
                            <el-icon>
                                <Delete/>
                            </el-icon>
                            删除
                        </el-button>
                    </template>
                </el-table-column>
            </el-table>

            <div class="pagination-container">
                <el-pagination
                    v-model:current-page="pagination.pageNum"
                    v-model:page-size="pagination.pageSize"
                    :page-sizes="[5, 10, 20, 50]"
                    :total="pagination.total"
                    layout="total, sizes, prev, pager, next, jumper"
                    @size-change="handleSizeChange"
                    @current-change="handleCurrentChange"
                />
            </div>
        </el-card>
    </div>
</template>

<script setup>
import {onMounted, reactive, ref} from "vue";
import {ElMessage, ElMessageBox} from "element-plus";
import {Delete, Edit, Plus, Refresh, Search} from "@element-plus/icons-vue";
import request from "../../utils/request.js";

const statusTypeMap = {
    0: "warning",
    1: "success",
    2: "info",
};

//搜索表单
const searchForm = reactive({
    searchQuery: "",
    statusFilter: "",
});

const meetingList = ref([]);
const loading = ref(false);

const pagination = reactive({
    pageNum: 1,
    pageSize: 10,
    total: 0,
});

const formRef = ref();
const dialog = reactive({
    visible: false,
    title: "",
    isEdit: false,
    loading: false,
    form: {
        id: null,
        title: "",
        deptName: "",
        startTime: "",
        content: "",
        status: 0,
    },
    rules: {
        title: [{required: true, message: "请输入会议标题", trigger: "blur"}],
        deptName: [{required: true, message: "请输入部门", trigger: "blur"}],
        startTime: [{required: true, message: "请选择开始时间", trigger: "change"}],
    },
});

const getStatusText = (status) => {
    const map = {0: "未开始", 1: "正在进行", 2: "已结束"};
    return map[status] || "未知";
};

const getMeetingList = async () => {
    loading.value = true;
    try {
        const params = {
            currentPage: pagination.pageNum,
            pageSize: pagination.pageSize,
        };
        Object.entries(searchForm).forEach(([key, value]) => {
            if (value !== '' && value !== '-1') {
                params[key] = value;
            }
        });
        const res = await request.get("/meeting/list", {params});
        if (res.code === "200") {
            meetingList.value = res.data.records;
            pagination.total = res.data.total || 0;
        } else {
            ElMessage.error(res.msg || "获取会议列表失败");
        }
    } catch (error) {
        ElMessage.error("获取会议列表失败");
    } finally {
        loading.value = false;
    }
};

const handleSearch = () => {
    pagination.pageNum = 1;
    getMeetingList();
};

const resetSearch = () => {
    Object.keys(searchForm).forEach((key) => {
        searchForm[key] = "";
    });
    handleSearch();
};

const handleSizeChange = (val) => {
    pagination.pageSize = val;
    getMeetingList();
};

const handleCurrentChange = (val) => {
    pagination.pageNum = val;
    getMeetingList();
};

const handleDelete = (row) => {
    ElMessageBox.confirm(`确定要删除会议"${row.title}"吗？`, "提示", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning",
    })
        .then(async () => {
            try {
                const res = await request.post("/meeting/delete", {id: row.id});
                if (res.code === "200") {
                    ElMessage.success("删除成功");
                    getMeetingList();
                } else {
                    ElMessage.error(res.msg || "删除失败");
                }
            } catch {
                ElMessage.error("删除失败");
            }
        })
        .catch(() => {
        });
};

const handleDialogClose = () => {
    dialog.visible = false;
};

onMounted(() => {
    getMeetingList();
});
</script>

<style scoped>
.meeting-management {
    padding: 20px;
    background-color: #f5f7fa;
    min-height: 100vh;
}

.search-card {
    margin-bottom: 10px;
}

.search-form {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
}

.search-form .el-form-item {
    margin-bottom: 0;
    margin-right: 20px;
}

.table-card {
    position: relative;
}

.pagination-container {
    margin-top: 20px;
    display: flex;
    justify-content: flex-end;
}

.dialog-footer {
    display: flex;
    justify-content: flex-end;
    gap: 12px;
}

:deep(.el-table) {
    font-size: 14px;
}

:deep(.el-table th) {
    background-color: #f5f7fa;
    color: #606266;
    font-weight: 500;
}

:deep(.el-table__row) {
    transition: background-color 0.2s;
}

:deep(.el-table__row:hover) {
    background-color: #f5f7fa;
}

@media (max-width: 768px) {
    .meeting-management {
        padding: 12px;
    }

    .search-form {
        flex-direction: column;
        align-items: stretch;
    }

    .search-form .el-form-item {
        margin-bottom: 12px;
        margin-right: 0;
    }
}
</style>
