<template>
    <div class="management">
        <!-- 搜索栏 -->
        <el-card class="search-card" shadow="never">
            <el-form :inline="true" :model="searchForm" class="search-form">
                <el-form-item label="仓库编号">
                    <el-input
                        v-model="searchForm.code"
                        placeholder="仓库编号"
                        clearable
                        @clear="handleSearch"
                        @keyup.enter="handleSearch"
                    />
                </el-form-item>
                <el-form-item label="仓库名称">
                    <el-input
                        v-model="searchForm.name"
                        placeholder="请输入仓库名称"
                        clearable
                        @clear="handleSearch"
                        @keyup.enter="handleSearch"
                    />
                </el-form-item>
                <el-form-item label="仓库类型">
                    <el-select
                        v-model="searchForm.type"
                        placeholder="请选择类型"
                        clearable
                        @change="handleSearch"
                        style="width: 120px"
                    >
                        <el-option label="全部" value="" />
                        <el-option label="原料仓" value="原料仓" />
                        <el-option label="半成品仓" value="半成品仓" />
                        <el-option label="成品仓" value="成品仓" />
                        <el-option label="备件仓" value="备件仓" />
                    </el-select>
                </el-form-item>
                <el-form-item label="状态">
                    <el-select
                        v-model="searchForm.status"
                        placeholder="请选择状态"
                        clearable
                        @change="handleSearch"
                        style="width: 120px"
                    >
                        <el-option label="全部" value="" />
                        <el-option label="启用" value="1" />
                        <el-option label="禁用" value="0" />
                    </el-select>
                </el-form-item>
                <el-form-item>
                    <el-button type="primary" @click="handleSearch">
                        <el-icon><Search /></el-icon>
                        搜索
                    </el-button>
                    <el-button @click="resetSearch">
                        <el-icon><Refresh /></el-icon>
                        重置
                    </el-button>
                </el-form-item>
            </el-form>
        </el-card>

        <div class="card" style="margin-bottom: 10px">
            <el-button type="primary" @click="handleAdd">
                <el-icon><Plus /></el-icon>
                新增仓库
            </el-button>
        </div>

        <!-- 表格区域 -->
        <el-card class="table-card" shadow="never">
            <el-table
                :data="wList"
                v-loading="loading"
                stripe
                border
                style="width: 100%"
                @selection-change="handleSelectionChange"
            >
                <el-table-column type="selection" width="55" />
                <el-table-column prop="code" label="仓库编码" width="150" />
                <el-table-column prop="name" label="仓库名称" width="180" />
                <el-table-column prop="kind" label="仓库类型" width="120" />
                <el-table-column prop="address" label="仓库地址" />
                <el-table-column prop="manager" label="负责人" width="100" />
                <el-table-column prop="phone" label="联系电话" width="120" />
                <el-table-column
                    prop="status"
                    label="状态"
                    width="100"
                    :formatter="formatStatus"
                />
                <el-table-column label="操作" width="200" fixed="right">
                    <template #default="{ row }">
                        <el-button
                            link
                            type="primary"
                            size="small"
                            @click="handleEdit(row)"
                        >
                            <el-icon><Edit /></el-icon>
                            编辑
                        </el-button>
                        <el-button
                            link
                            type="danger"
                            size="small"
                            @click="handleDelete(row)"
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
                    v-model:current-page="pagination.pageNum"
                    v-model:page-size="pagination.pageSize"
                    :page-sizes="[5, 10, 20, 50, 100]"
                    :total="pagination.total"
                    layout="total, sizes, prev, pager, next, jumper"
                    @size-change="handleSizeChange"
                    @current-change="handleCurrentChange"
                />
            </div>
        </el-card>

        <!-- 新增/编辑弹窗 -->
        <el-dialog
            v-model="dialog.visible"
            :title="dialog.title"
            width="500px"
            :close-on-click-modal="false"
            @close="handleDialogClose"
        >
            <el-form
                ref="formRef"
                :model="dialog.form"
                :rules="dialog.rules"
                label-width="100px"
                label-position="right"
            >
                <el-form-item label="仓库编码" prop="code">
                    <el-input
                        v-model="dialog.form.code"
                        placeholder="例如: WH001"
                        :disabled="dialog.isEdit"
                    />
                </el-form-item>
                <el-form-item label="仓库名称" prop="name">
                    <el-input
                        v-model="dialog.form.name"
                        placeholder="请输入仓库名称"
                    />
                </el-form-item>
                <el-form-item label="仓库类型" prop="kind">
                    <el-select
                        v-model="dialog.form.kind"
                        placeholder="请选择类型"
                        style="width: 100%"
                    >
                        <el-option label="原料仓" value="原料仓" />
                        <el-option label="半成品仓" value="半成品仓" />
                        <el-option label="成品仓" value="成品仓" />
                        <el-option label="备件仓" value="备件仓" />
                    </el-select>
                </el-form-item>
                <el-form-item label="详细地址" prop="address">
                    <el-input
                        v-model="dialog.form.address"
                        placeholder="请输入详细地址"
                    />
                </el-form-item>
                <el-form-item label="联系人" prop="manager">
                    <el-input
                        v-model="dialog.form.manager"
                        placeholder="请输入联系人"
                    />
                </el-form-item>
                <el-form-item label="联系电话" prop="phone">
                    <el-input
                        v-model="dialog.form.phone"
                        placeholder="请输入手机/固话"
                    />
                </el-form-item>
                <el-form-item label="默认状态" prop="status">
                    <el-switch
                        v-model="dialog.form.status"
                        active-value="1"
                        inactive-value="0"
                        active-text="启用"
                        inactive-text="禁用"
                    />
                </el-form-item>
                <el-form-item label="备注" prop="remark">
                    <el-input
                        v-model="dialog.form.remark"
                        type="textarea"
                        :rows="2"
                        placeholder="选填"
                    />
                </el-form-item>
            </el-form>
            <template #footer>
                <span class="dialog-footer">
                    <el-button @click="dialog.visible = false">取消</el-button>
                    <el-button
                        type="primary"
                        @click="submitForm"
                        :loading="dialog.loading"
                    >
                        确认
                    </el-button>
                </span>
            </template>
        </el-dialog>
    </div>
</template>

<script setup>
import { ref, reactive, onMounted } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import { Plus, Search, Refresh, Edit, Delete } from "@element-plus/icons-vue";
import request from "../../utils/request.js";

// 搜索表单
const searchForm = reactive({
    code: "",
    name: "",
    type: "",
    status: "",
});

// 仓库列表数据
const wList = ref([]);
const loading = ref(false);

// 分页参数
const pagination = reactive({
    pageNum: 1,
    pageSize: 10,
    total: 0,
});

// 选中的行
const selectedRows = ref([]);

// 新增/编辑对话框
const formRef = ref();
const dialog = reactive({
    visible: false,
    title: "",
    isEdit: false,
    loading: false,
    form: {
        id: null,
        code: "",
        name: "",
        kind: "",
        address: "",
        manager: "",
        phone: "",
        status: "1",
    },
    rules: {
        code: [
            { required: true, message: "请输入仓库编码", trigger: "blur" },
            {
                pattern: /^[A-Z0-9]{2,20}$/,
                message: "编码仅支持大写字母和数字",
                trigger: "blur",
            },
        ],
        name: [{ required: true, message: "请输入仓库名称", trigger: "blur" }],
        kind: [
            { required: true, message: "请选择仓库类型", trigger: "change" },
        ],
        address: [
            { required: true, message: "请输入详细地址", trigger: "blur" },
        ],
        manager: [{ required: true, message: "请输入联系人", trigger: "blur" }],
        phone: [
            { required: true, message: "请输入联系电话", trigger: "blur" },
            {
                pattern: /^1[3-9]\d{9}$|^0\d{2,3}-?\d{7,8}$/,
                message: "手机号或固话格式不正确",
                trigger: "blur",
            },
        ],
    },
});

// 获取仓库列表
const getWareHouseList = async () => {
    loading.value = true;
    try {
        // 构建查询参数，过滤空值
        const params = {
            pageNum: pagination.pageNum,
            pageSize: pagination.pageSize,
        };

        // 只添加非空参数
        Object.keys(searchForm).forEach((key) => {
            const value = searchForm[key];
            if (value !== "" && value !== null && value !== undefined) {
                params[key] = value;
            }
        });

        const res = await request.get("/warehouse/list", { params });
        if (res.code === "200") {
            wList.value = res.data.records || res.data.list || [];
            pagination.total = res.data.total || 0;
        } else {
            ElMessage.error(res.msg || "获取仓库列表失败");
        }
    } catch (error) {
        ElMessage.error("获取仓库列表失败");
    } finally {
        loading.value = false;
    }
};

const formatStatus = (row, column, cellValue) => {
    // 定义一个状态映射表，清晰直观
    const statusMap = {
        0: "禁用",
        1: "启用",
    };
    // 返回映射后的文字，如果数字不在映射表中，可以返回一个默认值，比如 '未知状态'
    return statusMap[cellValue] || "未知状态";
};

// 搜索
const handleSearch = () => {
    pagination.pageNum = 1;
    getWareHouseList();
};

// 重置搜索
const resetSearch = () => {
    Object.keys(searchForm).forEach((key) => {
        searchForm[key] = "";
    });
    handleSearch();
};

// 分页改变
const handleSizeChange = (val) => {
    pagination.pageSize = val;
    getWareHouseList();
};

const handleCurrentChange = (val) => {
    pagination.pageNum = val;
    getWareHouseList();
};

// 表格选择变化
const handleSelectionChange = (val) => {
    selectedRows.value = val;
};

// 新增仓库
const handleAdd = () => {
    dialog.title = "新增仓库";
    dialog.isEdit = false;
    dialog.form = {
        id: null,
        code: "",
        name: "",
        type: "",
        address: "",
        contact: "",
        phone: "",
        status: "1",
        remark: "",
    };
    dialog.visible = true;
};

// 编辑仓库
const handleEdit = (row) => {
    dialog.title = "编辑仓库";
    dialog.isEdit = true;
    dialog.form = { ...row };
    dialog.visible = true;
};

// 删除仓库
const handleDelete = (row) => {
    ElMessageBox.confirm(`确定要删除仓库"${row.name}"吗？`, "提示", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning",
    })
        .then(async () => {
            try {
                const res = await request.post(`/warehouse/delete`, row);
                if (res.code === "200") {
                    ElMessage.success("删除成功");
                    getWareHouseList();
                } else {
                    ElMessage.error(res.msg || "删除失败");
                }
            } catch (error) {
                ElMessage.error("删除失败");
            }
        })
        .catch(() => {});
};

// 提交表单
const submitForm = async () => {
    if (!formRef.value) return;

    await formRef.value.validate(async (valid) => {
        if (valid) {
            dialog.loading = true;
            try {
                const submitData = { ...dialog.form };

                if (dialog.isEdit) {
                    const res = await request.post(
                        "/warehouse/update",
                        submitData,
                    );
                    if (res.code === "200") {
                        ElMessage.success("更新仓库成功");
                        dialog.visible = false;
                        getWareHouseList();
                    } else {
                        ElMessage.error(res.msg || "更新仓库失败");
                    }
                } else {
                    const res = await request.post(
                        "/warehouse/add",
                        submitData,
                    );
                    if (res.code === "200") {
                        ElMessage.success("新增仓库成功");
                        dialog.visible = false;
                        getWareHouseList();
                    } else {
                        ElMessage.error(res.msg || "新增仓库失败");
                    }
                }
            } catch (error) {
                ElMessage.error("操作失败");
            } finally {
                dialog.loading = false;
            }
        }
    });
};

// 对话框关闭
const handleDialogClose = () => {
    dialog.visible = false;
};

onMounted(() => {
    getWareHouseList();
});
</script>

<style scoped>
.management {
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

/* 响应式调整 */
@media (max-width: 768px) {
    .management {
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

/* 按钮组样式 */
:deep(.el-button--link) {
    margin: 0 4px;
}
</style>
