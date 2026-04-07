<template>
    <div class="operation-log-management">
        <!-- 搜索栏 -->
        <el-card class="search-card" shadow="never" style="margin-bottom: 5px">
            <el-form :inline="true">
                <el-form-item label="操作用户">
                    <el-input
                        v-model="searchForm.username"
                        placeholder="请输入操作用户"
                        clearable
                        @clear="load"
                        @keyup.enter="load"
                    />
                </el-form-item>

                <el-form-item label="模块名称">
                    <el-input
                        v-model="searchForm.module"
                        placeholder="请输入模块名称"
                        clearable
                        @clear="load"
                        @keyup.enter="load"
                    />
                </el-form-item>

                <el-form-item label="操作类型">
                    <el-select
                        v-model="searchForm.type"
                        placeholder="选择操作类型"
                        clearable
                        @clear="load"
                    >
                        <el-option label="新增" value="新增" />
                        <el-option label="删除" value="删除" />
                        <el-option label="修改" value="修改" />
                        <el-option label="查询" value="查询" />
                    </el-select>
                </el-form-item>

                <el-form-item>
                    <el-button type="primary" @click="load">
                        <el-icon><Search /></el-icon>
                        查询
                    </el-button>
                    <el-button @click="resetSearch">
                        <el-icon><Refresh /></el-icon>
                        重置
                    </el-button>
                </el-form-item>
            </el-form>
        </el-card>

        <div class="card" style="margin-bottom: 10px">
            <el-button
                type="danger"
                @click="handleDeleteAll"
                :disabled="data.tableData.length === 0"
            >
                <el-icon><Delete /></el-icon>
                清空日志
            </el-button>
        </div>

        <!-- 操作日志表格 -->
        <el-card class="table-card" shadow="never">
            <el-table
                :data="data.tableData"
                stripe
                border
                style="width: 100%"
                :table-layout="fixed"
                @selection-change="handleSelectionChange"
            >
                <el-table-column type="selection" width="50" />
                <el-table-column prop="id" label="ID" width="60" />
                <el-table-column prop="username" label="操作用户" width="120" />
                <el-table-column prop="module" label="模块名称" width="120" />
                <el-table-column prop="type" label="操作类型" width="100">
                    <template #default="{ row }">
                        <el-tag :type="getTypeTagType(row.type)" size="small">
                            {{ row.type }}
                        </el-tag>
                    </template>
                </el-table-column>
                <el-table-column
                    prop="operation"
                    label="操作描述"
                    width="200"
                />
                <el-table-column prop="method" label="方法名">
                    <template #default="{ row }">
                        <span class="ellipsis-text">{{ row.method }}</span>
                    </template>
                </el-table-column>
                <el-table-column prop="time" label="执行时间" width="100">
                    <template #default="{ row }"> {{ row.time }}ms </template>
                </el-table-column>
                <el-table-column prop="ip" label="IP地址" width="140" />
                <el-table-column prop="createTime" label="操作时间" width="160">
                    <template #default="{ row }">
                        {{ formatDateTime(row.createTime) }}
                    </template>
                </el-table-column>
                <el-table-column label="操作" width="100" fixed="right">
                    <template #default="{ row }">
                        <el-button type="primary" link @click="viewDetail(row)">
                            详情
                        </el-button>
                    </template>
                </el-table-column>
            </el-table>

            <!-- 分页 -->
            <div class="pagination-wrapper">
                <el-pagination
                    v-model:current-page="data.pageNum"
                    v-model:page-size="data.pageSize"
                    :page-sizes="[10, 20, 50, 100]"
                    :total="data.total"
                    layout="total, sizes, prev, pager, next, jumper"
                    @size-change="handleSizeChange"
                    @current-change="handleCurrentChange"
                />
            </div>
        </el-card>

        <!-- 详情弹窗 -->
        <el-dialog v-model="detailVisible" title="操作日志详情" width="800px">
            <el-descriptions :column="2" border v-if="currentLog">
                <el-descriptions-item label="ID">{{
                    currentLog.id
                }}</el-descriptions-item>
                <el-descriptions-item label="操作用户">{{
                    currentLog.username
                }}</el-descriptions-item>
                <el-descriptions-item label="模块名称">{{
                    currentLog.module
                }}</el-descriptions-item>
                <el-descriptions-item label="操作类型">{{
                    currentLog.type
                }}</el-descriptions-item>
                <el-descriptions-item label="操作描述" :span="2">{{
                    currentLog.operation
                }}</el-descriptions-item>
                <el-descriptions-item label="方法名" :span="2">{{
                    currentLog.method
                }}</el-descriptions-item>
                <el-descriptions-item label="执行时间"
                    >{{ currentLog.time }}ms</el-descriptions-item
                >
                <el-descriptions-item label="IP地址">{{
                    currentLog.ip
                }}</el-descriptions-item>
                <el-descriptions-item label="操作时间" :span="2">{{
                    formatDateTime(currentLog.createTime)
                }}</el-descriptions-item>
                <el-descriptions-item label="请求参数" :span="2">
                    <pre class="params-pre">{{
                        formatParams(currentLog.params)
                    }}</pre>
                </el-descriptions-item>
            </el-descriptions>
        </el-dialog>
    </div>
</template>

<script setup>
import { ref, reactive, onMounted } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import { Search, Refresh, Delete } from "@element-plus/icons-vue";
import request from "../../utils/request.js";
import { formatDateTime } from "../../utils/date.js";

const data = reactive({
    tableData: [],
    pageNum: 1,
    pageSize: 10,
    total: 0,
    selectedRows: [],
});

const searchForm = reactive({
    username: "",
    module: "",
    type: "",
});

const detailVisible = ref(false);
const currentLog = ref(null);

// 加载数据
const load = async () => {
    try {
        const res = await request.get("/operationLog/list", {
            params: {
                pageNum: data.pageNum,
                pageSize: data.pageSize,
                username: searchForm.username,
                module: searchForm.module,
                type: searchForm.type,
            },
        });
        if (res && (res.code === "200" || res.code === 200)) {
            data.tableData = res.data?.list || [];
            data.total = res.data?.total || 0;
        } else {
            ElMessage.error(res.msg || "获取操作日志失败");
        }
    } catch (e) {
        ElMessage.error("获取操作日志失败");
    }
};

// 重置搜索
const resetSearch = () => {
    searchForm.username = "";
    searchForm.module = "";
    searchForm.type = "";
    data.pageNum = 1;
    load();
};

// 分页大小变化
const handleSizeChange = (val) => {
    data.pageSize = val;
    data.pageNum = 1;
    load();
};

// 页码变化
const handleCurrentChange = (val) => {
    data.pageNum = val;
    load();
};

// 选择变化
const handleSelectionChange = (val) => {
    data.selectedRows = val;
};

// 查看详情
const viewDetail = (row) => {
    currentLog.value = row;
    detailVisible.value = true;
};

// 格式化参数
const formatParams = (params) => {
    if (!params) return "无";
    try {
        return JSON.stringify(JSON.parse(params), null, 2);
    } catch (e) {
        return params;
    }
};

// 获取操作类型标签颜色
const getTypeTagType = (type) => {
    const typeMap = {
        新增: "success",
        删除: "danger",
        修改: "warning",
        查询: "info",
    };
    return typeMap[type] || "info";
};

// 清空日志
const handleDeleteAll = () => {
    ElMessageBox.confirm("确定要清空所有操作日志吗？此操作不可恢复！", "警告", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning",
    })
        .then(async () => {
            try {
                const res = await request.post("/operationLog/deleteAll");
                if (res && (res.code === "200" || res.code === 200)) {
                    ElMessage.success("清空成功");
                    load();
                } else {
                    ElMessage.error(res.msg || "清空失败");
                }
            } catch (e) {
                ElMessage.error("清空失败");
            }
        })
        .catch(() => {});
};

onMounted(() => {
    load();
});
</script>

<style scoped>
.operation-log-management {
    padding: 20px;
}

.search-card {
    margin-bottom: 10px;
}

.el-select {
    --el-select-width: 220px;
}

.pagination-wrapper {
    display: flex;
    justify-content: flex-end;
    margin-top: 20px;
}

.ellipsis-text {
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.params-pre {
    max-height: 300px;
    overflow-y: auto;
    background-color: #f5f7fa;
    padding: 10px;
    border-radius: 4px;
    font-size: 12px;
    margin: 0;
}
</style>
