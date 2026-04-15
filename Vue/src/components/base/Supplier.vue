<template>
    <div class="supplier-management">
        <!-- 搜索卡片 -->
        <el-card class="search-card" shadow="never">
            <el-form :inline="true" :model="searchForm" class="search-form">
                <el-form-item label="供应商名称">
                    <el-input
                        v-model="searchForm.name"
                        placeholder="请输入供应商名称"
                        clearable
                        @clear="handleSearch"
                        @keyup.enter="handleSearch"
                        style="width: 200px"
                    />
                </el-form-item>
                <el-form-item label="联系人">
                    <el-input
                        v-model="searchForm.contactPerson"
                        placeholder="请输入联系人姓名"
                        clearable
                        @clear="handleSearch"
                        @keyup.enter="handleSearch"
                        style="width: 150px"
                    />
                </el-form-item>
                <el-form-item label="联系电话">
                    <el-input
                        v-model="searchForm.phone"
                        placeholder="请输入联系电话"
                        clearable
                        @clear="handleSearch"
                        @keyup.enter="handleSearch"
                        style="width: 150px"
                    />
                </el-form-item>
                <el-form-item label="供应商状态">
                    <el-select
                        v-model="searchForm.status"
                        placeholder="请选择状态"
                        clearable
                        @change="handleSearch"
                        style="width: 120px"
                    >
                        <el-option label="启用" value="enabled" />
                        <el-option label="禁用" value="disabled" />
                    </el-select>
                </el-form-item>
                <el-form-item label="供应商类型">
                    <el-select
                        v-model="searchForm.type"
                        placeholder="请选择类型"
                        clearable
                        @change="handleSearch"
                        style="width: 120px"
                    >
                        <el-option label="制造商" value="manufacturer" />
                        <el-option label="代理商" value="agent" />
                        <el-option label="分销商" value="distributor" />
                        <el-option label="服务商" value="service" />
                    </el-select>
                </el-form-item>
            </el-form>
            <el-form :inline="true" :model="searchForm" class="search-form">
                <el-form-item>
                    <el-button type="primary" @click="handleSearch">
                        <el-icon><Search /></el-icon>
                        搜索
                    </el-button>
                    <el-button @click="resetSearch">
                        <el-icon><Refresh /></el-icon>
                        重置
                    </el-button>
                    <el-button type="success" @click="handleAdd">
                        <el-icon><Plus /></el-icon>
                        新增供应商
                    </el-button>
                    <el-button @click="handleImport">
                        <el-icon><UploadFilled /></el-icon>
                        导入
                    </el-button>
                    <el-button @click="handleExport">
                        <el-icon><Download /></el-icon>
                        导出
                    </el-button>
                </el-form-item>
            </el-form>
        </el-card>

        <!-- 供应商列表表格 -->
        <el-card class="table-card" shadow="never">
            <el-table :data="supplierList" v-loading="loading" stripe border style="width: 100%">
                <el-table-column prop="supplierCode" label="供应商编码" width="120" />
                <el-table-column prop="name" label="供应商名称" width="180" />
                <el-table-column prop="type" label="类型" width="100">
                    <template #default="{ row }">
                        <el-tag :type="getTypeTagType(row.type)" size="small">
                            {{ getTypeText(row.type) }}
                        </el-tag>
                    </template>
                </el-table-column>
                <el-table-column prop="contactPerson" label="联系人" width="120" />
                <el-table-column prop="phone" label="联系电话" width="130" />
                <el-table-column prop="email" label="邮箱" width="180" />
                <el-table-column prop="address" label="地址" width="200" />
                <el-table-column prop="creditRating" label="信用等级" width="100">
                    <template #default="{ row }">
                        <el-rate
                            v-model="row.creditRating"
                            :max="5"
                            disabled
                            show-score
                            score-template="{value}"
                            :colors="['#99A9BF', '#F7BA2A', '#FF9900']"
                        />
                    </template>
                </el-table-column>
                <el-table-column prop="cooperationYears" label="合作年限" width="100" />
                <el-table-column prop="status" label="状态" width="100">
                    <template #default="{ row }">
                        <el-tag :type="getStatusTagType(row.status)" size="small">
                            {{ getStatusText(row.status) }}
                        </el-tag>
                    </template>
                </el-table-column>
                <el-table-column prop="createDate" label="创建日期" width="150">
                    <template #default="{ row }">
                        {{ formatDateTime(row.createDate) }}
                    </template>
                </el-table-column>
                <el-table-column label="操作" width="200" fixed="right">
                    <template #default="{ row }">
                        <el-button link type="primary" size="small" @click="handleView(row)">
                            <el-icon><View /></el-icon>
                            查看
                        </el-button>
                        <el-button link type="success" size="small" @click="handleEdit(row)">
                            <el-icon><Edit /></el-icon>
                            编辑
                        </el-button>
                        <el-button link type="danger" size="small" @click="handleDelete(row)">
                            <el-icon><Delete /></el-icon>
                            删除
                        </el-button>
                        <el-dropdown trigger="click">
                            <el-button link size="small" type="info">
                                更多
                                <el-icon><ArrowDown /></el-icon>
                            </el-button>
                            <template #dropdown>
                                <el-dropdown-menu>
                                    <el-dropdown-item @click="handleToggleStatus(row)">
                                        <el-icon><CircleClose /></el-icon>
                                        {{ row.status === "enabled" ? "禁用" : "启用" }}
                                    </el-dropdown-item>
                                    <el-dropdown-item @click="handleViewProducts(row)">
                                        <el-icon><Box /></el-icon>
                                        查看供应产品
                                    </el-dropdown-item>
                                    <el-dropdown-item @click="handleViewOrders(row)">
                                        <el-icon><Document /></el-icon>
                                        采购订单
                                    </el-dropdown-item>
                                </el-dropdown-menu>
                            </template>
                        </el-dropdown>
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

        <!-- 查看供应商详情对话框 -->
        <el-dialog v-model="viewDialog.visible" title="供应商详情" width="600px">
            <el-descriptions :column="1" border>
                <el-descriptions-item label="供应商编码">{{ viewDialog.data.supplierCode }}</el-descriptions-item>
                <el-descriptions-item label="供应商名称">{{ viewDialog.data.name }}</el-descriptions-item>
                <el-descriptions-item label="供应商类型">
                    <el-tag :type="getTypeTagType(viewDialog.data.type)">
                        {{ getTypeText(viewDialog.data.type) }}
                    </el-tag>
                </el-descriptions-item>
                <el-descriptions-item label="联系人">{{ viewDialog.data.contactPerson }}</el-descriptions-item>
                <el-descriptions-item label="联系电话">{{ viewDialog.data.phone }}</el-descriptions-item>
                <el-descriptions-item label="邮箱">{{ viewDialog.data.email }}</el-descriptions-item>
                <el-descriptions-item label="地址">{{ viewDialog.data.address }}</el-descriptions-item>
                <el-descriptions-item label="邮政编码">{{ viewDialog.data.postalCode }}</el-descriptions-item>
                <el-descriptions-item label="信用等级">
                    <el-rate
                        v-model="viewDialog.data.creditRating"
                        :max="5"
                        disabled
                        show-score
                        score-template="{value}"
                        :colors="['#99A9BF', '#F7BA2A', '#FF9900']"
                    />
                </el-descriptions-item>
                <el-descriptions-item label="合作年限"
                    >{{ viewDialog.data.cooperationYears || 0 }}年</el-descriptions-item
                >
                <el-descriptions-item label="银行账户">{{ viewDialog.data.bankAccount }}</el-descriptions-item>
                <el-descriptions-item label="开户银行">{{ viewDialog.data.bankName }}</el-descriptions-item>
                <el-descriptions-item label="纳税人识别号">{{ viewDialog.data.taxId }}</el-descriptions-item>
                <el-descriptions-item label="状态">
                    <el-tag :type="getStatusTagType(viewDialog.data.status)">
                        {{ getStatusText(viewDialog.data.status) }}
                    </el-tag>
                </el-descriptions-item>
                <el-descriptions-item label="备注">{{ viewDialog.data.remarks }}</el-descriptions-item>
                <el-descriptions-item label="创建时间">{{
                    formatDateTime(viewDialog.data.createDate)
                }}</el-descriptions-item>
                <el-descriptions-item label="更新时间">{{
                    formatDateTime(viewDialog.data.updateDate)
                }}</el-descriptions-item>
            </el-descriptions>
        </el-dialog>

        <!-- 新增/编辑供应商对话框 -->
        <el-dialog
            v-model="editDialog.visible"
            :title="editDialog.isEdit ? '编辑供应商' : '新增供应商'"
            width="700px"
            :close-on-click-modal="false"
        >
            <el-form ref="editFormRef" :model="editDialog.form" :rules="editFormRules" label-width="120px">
                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="供应商编码" prop="supplierCode">
                            <el-input
                                v-model="editDialog.form.supplierCode"
                                :disabled="editDialog.isEdit"
                                placeholder="请输入供应商编码"
                            />
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="供应商名称" prop="name">
                            <el-input v-model="editDialog.form.name" placeholder="请输入供应商名称" />
                        </el-form-item>
                    </el-col>
                </el-row>
                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="供应商类型" prop="type">
                            <el-select
                                v-model="editDialog.form.type"
                                placeholder="请选择供应商类型"
                                style="width: 100%"
                            >
                                <el-option label="制造商" value="manufacturer" />
                                <el-option label="代理商" value="agent" />
                                <el-option label="分销商" value="distributor" />
                                <el-option label="服务商" value="service" />
                            </el-select>
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="状态" prop="status">
                            <el-select v-model="editDialog.form.status" placeholder="请选择状态" style="width: 100%">
                                <el-option label="启用" value="enabled" />
                                <el-option label="禁用" value="disabled" />
                            </el-select>
                        </el-form-item>
                    </el-col>
                </el-row>
                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="联系人" prop="contactPerson">
                            <el-input v-model="editDialog.form.contactPerson" placeholder="请输入联系人姓名" />
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="联系电话" prop="phone">
                            <el-input v-model="editDialog.form.phone" placeholder="请输入联系电话" />
                        </el-form-item>
                    </el-col>
                </el-row>
                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="邮箱" prop="email">
                            <el-input v-model="editDialog.form.email" placeholder="请输入邮箱地址" />
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="邮政编码">
                            <el-input v-model="editDialog.form.postalCode" placeholder="请输入邮政编码" />
                        </el-form-item>
                    </el-col>
                </el-row>
                <el-form-item label="地址" prop="address">
                    <el-input
                        v-model="editDialog.form.address"
                        type="textarea"
                        :rows="3"
                        placeholder="请输入完整地址"
                    />
                </el-form-item>
                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="信用等级">
                            <el-rate
                                v-model="editDialog.form.creditRating"
                                :max="5"
                                allow-half
                                show-text
                                :texts="['极差', '失望', '一般', '满意', '惊喜', '完美']"
                            />
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="合作年限">
                            <el-input-number
                                v-model="editDialog.form.cooperationYears"
                                :min="0"
                                :max="50"
                                controls-position="right"
                                placeholder="合作年限"
                                style="width: 100%"
                            />
                        </el-form-item>
                    </el-col>
                </el-row>
                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="银行账户">
                            <el-input v-model="editDialog.form.bankAccount" placeholder="请输入银行账户" />
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="开户银行">
                            <el-input v-model="editDialog.form.bankName" placeholder="请输入开户银行" />
                        </el-form-item>
                    </el-col>
                </el-row>
                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="纳税人识别号">
                            <el-input v-model="editDialog.form.taxId" placeholder="请输入纳税人识别号" />
                        </el-form-item>
                    </el-col>
                </el-row>
                <el-form-item label="备注">
                    <el-input
                        v-model="editDialog.form.remarks"
                        type="textarea"
                        :rows="3"
                        placeholder="请输入备注信息"
                    />
                </el-form-item>
            </el-form>
            <template #footer>
                <span class="dialog-footer">
                    <el-button @click="editDialog.visible = false">取消</el-button>
                    <el-button type="primary" @click="submitEditForm">保存</el-button>
                </span>
            </template>
        </el-dialog>
    </div>
</template>

<script setup>
import { ref, reactive, onMounted } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import {
    Plus,
    Search,
    Refresh,
    View,
    Edit,
    Delete,
    Document,
    Box,
    ArrowDown,
    CircleClose,
    UploadFilled,
    Download,
} from "@element-plus/icons-vue";
import request from "@/utils/request.js";
import { formatDateTime } from "@/utils/date.js";

// 搜索表单
const searchForm = reactive({
    name: "",
    contactPerson: "",
    phone: "",
    status: "",
    type: "",
});

// 供应商列表数据
const supplierList = ref([]);
const loading = ref(false);

// 分页参数
const pagination = reactive({
    pageNum: 1,
    pageSize: 10,
    total: 0,
});

// 查看详情对话框
const viewDialog = reactive({
    visible: false,
    data: {},
});

// 编辑对话框
const editDialog = reactive({
    visible: false,
    isEdit: false,
    form: {
        id: null,
        supplierCode: "",
        name: "",
        type: "",
        contactPerson: "",
        phone: "",
        email: "",
        address: "",
        postalCode: "",
        creditRating: 3,
        cooperationYears: 0,
        bankAccount: "",
        bankName: "",
        taxId: "",
        status: "enabled",
        remarks: "",
    },
});

// 编辑表单验证规则
const editFormRules = {
    supplierCode: [
        { required: true, message: "请输入供应商编码", trigger: "blur" },
        { pattern: /^[A-Z0-9]{6,20}$/, message: "供应商编码格式不正确", trigger: "blur" },
    ],
    name: [
        { required: true, message: "请输入供应商名称", trigger: "blur" },
        { min: 2, max: 50, message: "供应商名称长度应在2-50个字符之间", trigger: "blur" },
    ],
    type: [{ required: true, message: "请选择供应商类型", trigger: "change" }],
    contactPerson: [{ required: true, message: "请输入联系人姓名", trigger: "blur" }],
    phone: [
        { required: true, message: "请输入联系电话", trigger: "blur" },
        { pattern: /^1[3-9]\d{9}$|^(0\d{2,3}-?)?\d{7,8}$/, message: "电话号码格式不正确", trigger: "blur" },
    ],
    email: [
        { required: true, message: "请输入邮箱地址", trigger: "blur" },
        { type: "email", message: "邮箱格式不正确", trigger: "blur" },
    ],
    address: [{ required: true, message: "请输入地址", trigger: "blur" }],
    status: [{ required: true, message: "请选择状态", trigger: "change" }],
};

// 获取供应商列表
const getSupplierList = async () => {
    loading.value = true;
    try {
        const params = {
            pageNum: pagination.pageNum,
            pageSize: pagination.pageSize,
            ...searchForm,
        };

        const res = await request.get("/supplier/list", { params });
        if (res.code === "200") {
            const data = res.data.records || res.data.list || [];
            supplierList.value = data;
            pagination.total = res.data.total || data.length;
        } else {
            ElMessage.error(res.msg || "获取供应商列表失败");
        }
    } catch (error) {
        console.error("获取供应商列表失败:", error);
        ElMessage.error("获取供应商列表失败");
    } finally {
        loading.value = false;
    }
};

// 获取供应商类型标签类型
const getTypeTagType = (type) => {
    switch (type) {
        case "manufacturer":
            return "primary";
        case "agent":
            return "success";
        case "distributor":
            return "warning";
        case "service":
            return "info";
        default:
            return "info";
    }
};

// 获取供应商类型文本
const getTypeText = (type) => {
    switch (type) {
        case "manufacturer":
            return "制造商";
        case "agent":
            return "代理商";
        case "distributor":
            return "分销商";
        case "service":
            return "服务商";
        default:
            return type;
    }
};

// 获取状态标签类型
const getStatusTagType = (status) => {
    return status === "enabled" ? "success" : "danger";
};

// 获取状态文本
const getStatusText = (status) => {
    return status === "enabled" ? "启用" : "禁用";
};

// 搜索
const handleSearch = () => {
    pagination.pageNum = 1;
    getSupplierList();
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
    getSupplierList();
};

const handleCurrentChange = (val) => {
    pagination.pageNum = val;
    getSupplierList();
};

// 新增供应商
const handleAdd = () => {
    editDialog.isEdit = false;
    editDialog.form = {
        id: null,
        supplierCode: "",
        name: "",
        type: "",
        contactPerson: "",
        phone: "",
        email: "",
        address: "",
        postalCode: "",
        creditRating: 3,
        cooperationYears: 0,
        bankAccount: "",
        bankName: "",
        taxId: "",
        status: "enabled",
        remarks: "",
    };
    editDialog.visible = true;
};

// 编辑供应商
const handleEdit = (row) => {
    editDialog.isEdit = true;
    editDialog.form = { ...row };
    editDialog.visible = true;
};

// 查看供应商
const handleView = (row) => {
    viewDialog.data = { ...row };
    viewDialog.visible = true;
};

// 删除供应商
const handleDelete = (row) => {
    ElMessageBox.confirm(`确定要删除供应商 "${row.name}" 吗？`, "警告", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning",
    }).then(async () => {
        try {
            const res = await request.delete(`/supplier/delete/${row.id}`);
            if (res.code === "200") {
                ElMessage.success("删除成功");
                getSupplierList();
            } else {
                ElMessage.error(res.msg || "删除失败");
            }
        } catch (error) {
            ElMessage.error("删除失败");
        }
    });
};

// 提交编辑表单
const submitEditForm = async () => {
    try {
        // 这里可以添加表单验证
        const res = await request[editDialog.isEdit ? "put" : "post"](
            `/supplier/${editDialog.isEdit ? "update" : "add"}`,
            editDialog.form,
        );

        if (res.code === "200") {
            ElMessage.success(editDialog.isEdit ? "更新成功" : "添加成功");
            editDialog.visible = false;
            getSupplierList();
        } else {
            ElMessage.error(res.msg || "操作失败");
        }
    } catch (error) {
        ElMessage.error("操作失败");
    }
};

// 切换供应商状态
const handleToggleStatus = async (row) => {
    const newStatus = row.status === "enabled" ? "disabled" : "enabled";
    const actionText = newStatus === "enabled" ? "启用" : "禁用";

    try {
        const res = await request.put(`/supplier/toggle-status/${row.id}`, {
            status: newStatus,
        });

        if (res.code === "200") {
            ElMessage.success(`${actionText}成功`);
            // 更新本地数据
            row.status = newStatus;
        } else {
            ElMessage.error(res.msg || `${actionText}失败`);
        }
    } catch (error) {
        ElMessage.error(`${actionText}失败`);
    }
};

// 查看供应产品
const handleViewProducts = (row) => {
    ElMessage.info(`正在查看供应商 ${row.name} 的供应产品`);
    // 这里可以跳转到产品管理页面并传递供应商ID作为筛选条件
};

// 查看采购订单
const handleViewOrders = (row) => {
    ElMessage.info(`正在查看供应商 ${row.name} 的采购订单`);
    // 这里可以跳转到采购订单页面并传递供应商ID作为筛选条件
};

// 导入功能
const handleImport = () => {
    ElMessage.info("导入功能待实现");
};

// 导出功能
const handleExport = () => {
    ElMessage.info("导出功能待实现");
};

onMounted(() => {
    getSupplierList();
});
</script>

<style scoped>
.supplier-management {
    padding: 20px;
    background-color: #f5f7fa;
    min-height: 100vh;
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
    .supplier-management {
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
</style>
