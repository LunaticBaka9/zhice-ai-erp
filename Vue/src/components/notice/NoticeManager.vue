<template>
    <div class="user-management">
        <!-- 搜索栏 -->
        <el-card class="search-card" shadow="never" style="margin-bottom: 5px">
            <el-form :inline="true">
                <el-form-item label="标题">
                    <el-input
                        v-model="data.title"
                        placeholder="请输入标题"
                        clearable
                        @clear="load"
                        @keyup.enter="load"
                    />
                </el-form-item>

                <el-form-item label="发布者">
                    <el-input
                        v-model="data.author"
                        placeholder="请输入发布者"
                        clearable
                        @clear="load"
                        @keyup.enter="load"
                    />
                </el-form-item>

                <el-form-item label="公告类型">
                    <el-select
                        v-model="data.type"
                        placeholder="选择公告类型"
                        clearable
                        @clear="load"
                    >
                        <el-option label="系统更新" value="系统更新" />
                        <el-option label="维护通知" value="维护通知" />
                        <el-option label="功能上线" value="功能上线" />
                        <el-option label="其他公告" value="其他公告" />
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
            <el-button type="primary" @click="exportData"> 导出表格 </el-button>
            <el-upload
                action="/api/notice/importData"
                :on-success="handleImport"
                style="display: inline-block; margin-left: 10px"
                :show-file-list="false"
            >
                <el-button type="primary">导入表格</el-button>
            </el-upload>
        </div>

        <!-- 公告信息表格 -->
        <el-card class="table-card" shadow="never">
            <el-table
                :data="data.tableData"
                stripe
                border
                style="width: 100%"
                :table-layout="fixed"
                @selection-change="handleSelectionChange"
            >
                <el-table-column type="selection" />
                <el-table-column prop="nid" label="ID" width="50" />
                <el-table-column prop="title" label="公告标题" width="200" />
                <el-table-column prop="summary" label="公告摘要" width="200" />
                <el-table-column prop="content" label="公告内容">
                    <template #default="{ row }">
                        <div class="ellipsis-text">
                            {{ row.content }}
                        </div>
                    </template>
                </el-table-column>
                <el-table-column prop="author" label="发布者" width="100" />
                <el-table-column prop="type" label="公告类型" width="100">
                    <template #default="{ row }">
                        <el-tag :type="getTagType(row.type)" size="small">
                            {{ row.type }}
                        </el-tag>
                    </template>
                </el-table-column>
                <el-table-column
                    prop="publishDate"
                    label="发布时间"
                    width="160"
                    sortable
                >
                    <template #default="{ row }">
                        {{
                            row.publishDate
                                ? formatDateTime(row.publishDate)
                                : ""
                        }}
                    </template>
                </el-table-column>
                <el-table-column prop="status" label="公告状态" width="90" />
                <el-table-column prop="views" label="阅读次数" width="90" />
                <el-table-column label="操作" width="150" fixed="right">
                    <template #default="scope">
                        <el-button
                            link
                            type="primary"
                            size="small"
                            @click="handleEdit(scope.row)"
                        >
                            <el-icon><Edit /></el-icon>
                            编辑
                        </el-button>
                        <el-button
                            link
                            type="danger"
                            size="small"
                            @click="handleDelete(scope.row)"
                        >
                            <el-icon><Delete /></el-icon>
                            删除
                        </el-button>
                    </template>
                </el-table-column>
            </el-table>
            <!-- 分页 -->
            <div class="pagination-container">
                <el-pagination
                    v-model:current-page="data.pageNum"
                    v-model:page-size="data.pageSize"
                    :page-sizes="[10, 20, 50, 100]"
                    :total="data.total"
                    layout="total, sizes, prev, pager, next, jumper"
                    @current-change="load"
                    @size-change="load"
                />
            </div>
        </el-card>
    </div>
</template>

<script setup>
import { ref, reactive } from "vue";
import { useRouter } from "vue-router";
import { ElMessage, ElMessageBox } from "element-plus";
import { Search, Refresh, Edit, Delete, Plus } from "@element-plus/icons-vue";
import request from "../../utils/request.js";
import { formatDateTime, parseDate } from "../../utils/date.js";

const user = JSON.parse(localStorage.getItem("local_user"));

const data = reactive({
    title: null,
    author: null,
    type: null,
    pageNum: 1,
    pageSize: 10,
    total: 6,
    tableData: [],
    formVisible: false,
    form: {},
    rows: [],
});

const formRef = ref();
const router = useRouter();

const load = () => {
    const isAdmin = user && user.role && String(user.role).includes("管理员");
    request
        .get("/notice/list", {
            params: {
                pageNum: data.pageNum,
                pageSize: data.pageSize,
                title: data.title,
                author: data.author,
                type: data.type,
                // 非管理员传 uid 给后端过滤
                uid: isAdmin
                    ? undefined
                    : user && user.uid
                      ? user.uid
                      : undefined,
            },
        })
        .then((res) => {
            if (res.code === "200") {
                data.tableData = (res.data.list || []).map((it) => ({
                    ...it,
                    publishDate: it.publishDate
                        ? parseDate(it.publishDate)
                        : null,
                }));
                data.total = res.data.total;
                console.log(data);
            } else {
                ElMessage.error(res.msg);
            }
        });
};
load();

const resetSearch = () => {
    data.title = null;
    data.type = null;
    data.author = null;
    load();
};

// 编辑公告
const handleEdit = (row) => {
    try {
        sessionStorage.setItem("editNotice", JSON.stringify(row));
    } catch (e) {
        console.warn("无法写入 sessionStorage", e);
    }
    router.push({ name: "noticePost" });
};

const handleSelectionChange = (rows) => {
    data.rows = rows;
};

const handleDelete = (row) => {
    ElMessageBox.confirm("确认删除此公告", "删除确认", { type: "warning" })
        .then((res) => {
            request.post("/notice/delete", row).then((res) => {
                if (res.code === "200") {
                    ElMessage.success("删除成功");
                    load();
                } else {
                    ElMessage.error(res.msg);
                }
            });
        })
        .catch((err) => {});
};

const exportData = () => {
    window.open("http://localhost:8080/notice/exportData");
};

const handleImport = (res, file, filelist) => {
    if (res.code === "200") {
        ElMessage.success("数据导入成功");
    } else {
        ElMessage.error(res.msg);
    }
    load();
};

// 方法
const getTagType = (type) => {
    const typeMap = {
        系统更新: "primary",
        维护通知: "warning",
        功能上线: "success",
        其他公告: "info",
    };
    return typeMap[type] || "info";
};
</script>

<style scoped>
.user-management {
    padding: 20px;
    background-color: #f5f7fa;
    min-height: 100vh;
}

.el-select {
    --el-select-width: 220px;
}

.page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
}

.page-title {
    margin: 0;
    font-size: 24px;
    font-weight: 500;
    color: #303133;
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

/* 响应式调整 */
@media (max-width: 768px) {
    .user-management {
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

    .page-header {
        flex-direction: column;
        align-items: flex-start;
        gap: 12px;
    }

    :deep(.el-table) {
        overflow-x: auto;
    }
}

/* 表格样式优化 */
:deep(.el-table) {
    font-size: 14px;
}

:deep(.el-table th) {
    background-color: #f5f7fa;
    color: #606266;
    font-weight: 500;
}

:deep(.el-table .el-table__row) {
    transition: background-color 0.2s;
}

:deep(.el-table .el-table__row:hover) {
    background-color: #f5f7fa;
}

/* 设置表格行高 */
:deep(.el-table__row) {
    height: 60px;
}

/* 或者设置单元格内边距 */
:deep(.el-table__body td) {
    padding: 15px 0;
}

/* 或者设置单元格的高度 */
:deep(.el-table td),
:deep(.el-table th) {
    padding: 12px 0;
}

/* 头像样式 */
:deep(.el-avatar) {
    margin: 4px 0;
}

/* 标签样式 */
:deep(.el-tag) {
    font-weight: normal;
}

/* 按钮组样式 */
:deep(.el-button--link) {
    margin: 0 4px;
}

/* 字数省略样式 */
.ellipsis-text {
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}
</style>
