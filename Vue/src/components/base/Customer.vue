<template>
    <div class="customer-management">
        <el-card class="search-card" shadow="never">
            <el-form :inline="true" :model="searchForm" class="search-form">
                <el-form-item label="客户编码">
                    <el-input
                        v-model="searchForm.code"
                        placeholder="客户编码"
                        clearable
                        @clear="handleSearch"
                        @keyup.enter="handleSearch"
                        style="width: 100px"
                    />
                </el-form-item>
                <el-form-item label="客户名称">
                    <el-input
                        v-model="searchForm.name"
                        placeholder="请输入客户名称"
                        clearable
                        @clear="handleSearch"
                        @keyup.enter="handleSearch"
                    />
                </el-form-item>
                <el-form-item label="联系人">
                    <el-input
                        v-model="searchForm.contactPerson"
                        placeholder="请输入联系人"
                        clearable
                        @clear="handleSearch"
                        @keyup.enter="handleSearch"
                        style="width: 120px"
                    />
                </el-form-item>
                <el-form-item label="电话">
                    <el-input
                        v-model="searchForm.phone"
                        placeholder="请输入电话"
                        clearable
                        @clear="handleSearch"
                        @keyup.enter="handleSearch"
                    />
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
                新增客户
            </el-button>
            <el-button @click="handleExport">
                <el-icon><Download /></el-icon>
                导出
            </el-button>
        </div>

        <el-card class="table-card" shadow="never">
            <el-table :data="customerList" v-loading="loading" stripe border style="width: 100%">
                <el-table-column type="selection" width="55" />
                <el-table-column prop="code" label="客户编码" width="100" />
                <el-table-column prop="name" label="客户名称" min-width="180" />
                <el-table-column prop="contactPerson" label="联系人" width="80" />
                <el-table-column prop="phone" label="联系电话" width="130" />
                <el-table-column prop="email" label="邮箱" min-width="180" />
                <el-table-column prop="address" label="地址" min-width="200" />
                <el-table-column prop="priceLevel" label="价格等级" width="100">
                    <template #default="{ row }">
                        <el-tag v-if="row.priceLevel === 1" type="success">零售价</el-tag>
                        <el-tag v-else-if="row.priceLevel === 2" type="warning">批发价</el-tag>
                        <el-tag v-else-if="row.priceLevel === 3" type="danger">VIP价</el-tag>
                        <span v-else>-</span>
                    </template>
                </el-table-column>
                <el-table-column prop="creditLimit" label="信用额度" width="120">
                    <template #default="{ row }">
                        {{ row.creditLimit ? row.creditLimit.toLocaleString() : "0.00" }}
                    </template>
                </el-table-column>
                <el-table-column prop="status" label="状态" width="80">
                    <template #default="{ row }">
                        <el-tag :type="row.status === 1 ? 'success' : 'danger'">
                            {{ row.status === 1 ? "启用" : "禁用" }}
                        </el-tag>
                    </template>
                </el-table-column>
                <el-table-column label="操作" width="180" fixed="right">
                    <template #default="{ row }">
                        <el-button link type="primary" size="small" @click="handleEdit(row)">
                            <el-icon><Edit /></el-icon>
                            编辑
                        </el-button>
                        <el-button link type="danger" size="small" @click="handleDelete(row)">
                            <el-icon><Delete /></el-icon>
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

        <el-dialog
            v-model="dialog.visible"
            :title="dialog.title"
            width="600px"
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
                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="客户编码" prop="code">
                            <el-input v-model="dialog.form.code" placeholder="例如: C001" :disabled="dialog.isEdit" />
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="客户名称" prop="name">
                            <el-input v-model="dialog.form.name" placeholder="请输入客户名称" />
                        </el-form-item>
                    </el-col>
                </el-row>

                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="联系人" prop="contactPerson">
                            <el-input v-model="dialog.form.contactPerson" placeholder="请输入联系人" />
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="联系电话" prop="phone">
                            <el-input v-model="dialog.form.phone" placeholder="请输入联系电话" />
                        </el-form-item>
                    </el-col>
                </el-row>

                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="邮箱" prop="email">
                            <el-input v-model="dialog.form.email" placeholder="请输入邮箱" />
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="价格等级" prop="priceLevel">
                            <el-select
                                v-model="dialog.form.priceLevel"
                                placeholder="请选择价格等级"
                                style="width: 100%"
                            >
                                <el-option label="零售价" :value="1" />
                                <el-option label="批发价" :value="2" />
                                <el-option label="VIP价" :value="3" />
                            </el-select>
                        </el-form-item>
                    </el-col>
                </el-row>

                <el-form-item label="信用额度" prop="creditLimit">
                    <el-input-number
                        v-model="dialog.form.creditLimit"
                        :min="0"
                        :precision="2"
                        :step="1000"
                        style="width: 100%"
                        placeholder="请输入信用额度"
                    />
                </el-form-item>

                <el-form-item label="详细地址" prop="address">
                    <el-input v-model="dialog.form.address" type="textarea" :rows="2" placeholder="请输入详细地址" />
                </el-form-item>

                <el-form-item label="状态" prop="status">
                    <el-switch
                        v-model="dialog.form.status"
                        :active-value="1"
                        :inactive-value="0"
                        active-text="启用"
                        inactive-text="禁用"
                    />
                </el-form-item>
            </el-form>
            <template #footer>
                <span class="dialog-footer">
                    <el-button @click="dialog.visible = false">取消</el-button>
                    <el-button type="primary" @click="submitForm" :loading="dialog.loading"> 确认 </el-button>
                </span>
            </template>
        </el-dialog>
    </div>
</template>

<script setup>
import { ref, reactive, onMounted } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import { Plus, Search, Refresh, Edit, Delete, Download } from "@element-plus/icons-vue";
import request from "../../utils/request.js";

const searchForm = reactive({
    code: "",
    name: "",
    contactPerson: "",
    phone: "",
    status: "",
});

const customerList = ref([]);
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
        code: "",
        name: "",
        contactPerson: "",
        phone: "",
        email: "",
        address: "",
        priceLevel: 1,
        creditLimit: 0,
        status: 1,
    },
    rules: {
        code: [{ required: true, message: "请输入客户编码", trigger: "blur" }],
        name: [{ required: true, message: "请输入客户名称", trigger: "blur" }],
        phone: [
            {
                pattern: /^1[3-9]\d{9}$|^0\d{2,3}-?\d{7,8}$/,
                message: "手机号或固话格式不正确",
                trigger: "blur",
            },
        ],
        email: [{ type: "email", message: "邮箱格式不正确", trigger: "blur" }],
    },
});

const getCustomerList = async () => {
    loading.value = true;
    try {
        const params = {};

        Object.keys(searchForm).forEach((key) => {
            const value = searchForm[key];
            if (value !== "" && value !== null && value !== undefined) {
                if (key === "status") {
                    params[key] = parseInt(value);
                } else {
                    params[key] = value;
                }
            }
        });

        const res = await request.get("/customer/list", { params });
        if (res.code === "200") {
            if (Array.isArray(res.data)) {
                customerList.value = res.data;
            } else {
                customerList.value = res.data?.records || res.data?.list || [];
            }
            pagination.total = customerList.value.length;
        } else {
            ElMessage.error(res.msg || "获取客户列表失败");
        }
    } catch (error) {
        ElMessage.error("获取客户列表失败");
    } finally {
        loading.value = false;
    }
};

const handleSearch = () => {
    pagination.pageNum = 1;
    getCustomerList();
};

const resetSearch = () => {
    Object.keys(searchForm).forEach((key) => {
        searchForm[key] = "";
    });
    handleSearch();
};

const handleSizeChange = (val) => {
    pagination.pageSize = val;
    getCustomerList();
};

const handleCurrentChange = (val) => {
    pagination.pageNum = val;
    getCustomerList();
};

const handleAdd = () => {
    dialog.title = "新增客户";
    dialog.isEdit = false;
    dialog.form = {
        id: null,
        code: "",
        name: "",
        contactPerson: "",
        phone: "",
        email: "",
        address: "",
        priceLevel: 1,
        creditLimit: 0,
        status: 1,
    };
    dialog.visible = true;
};

const handleEdit = (row) => {
    dialog.title = "编辑客户";
    dialog.isEdit = true;
    dialog.form = {
        id: row.id,
        code: row.code,
        name: row.name,
        contactPerson: row.contactPerson,
        phone: row.phone,
        email: row.email,
        address: row.address,
        priceLevel: row.priceLevel,
        creditLimit: row.creditLimit,
        status: row.status,
    };
    dialog.visible = true;
};

const handleDelete = (row) => {
    ElMessageBox.confirm(`确定要删除客户"${row.name}"吗？`, "提示", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning",
    })
        .then(async () => {
            try {
                const res = await request.delete(`/customer/${row.id}`);
                if (res.code === "200") {
                    ElMessage.success("删除成功");
                    getCustomerList();
                } else {
                    ElMessage.error(res.msg || "删除失败");
                }
            } catch (error) {
                ElMessage.error("删除失败");
            }
        })
        .catch(() => {});
};

const submitForm = async () => {
    if (!formRef.value) return;

    await formRef.value.validate(async (valid) => {
        if (valid) {
            dialog.loading = true;
            try {
                const submitData = { ...dialog.form };
                const api = dialog.isEdit ? "/customer/update" : "/customer/add";
                const method = dialog.isEdit ? "post" : "post";

                const res = await request[method](api, submitData);
                if (res.code === "200") {
                    ElMessage.success(dialog.isEdit ? "更新成功" : "新增成功");
                    dialog.visible = false;
                    getCustomerList();
                } else {
                    ElMessage.error(res.msg || "操作失败");
                }
            } catch (error) {
                ElMessage.error("操作失败");
            } finally {
                dialog.loading = false;
            }
        }
    });
};

const handleDialogClose = () => {
    dialog.visible = false;
};

const handleExport = () => {
    ElMessage.info("导出功能待实现");
};

onMounted(() => {
    getCustomerList();
});
</script>

<style scoped>
.customer-management {
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
    .customer-management {
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
