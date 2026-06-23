<template>
    <div class="user-management">
        <!-- 搜索栏 -->
        <el-card class="search-card" shadow="never">
            <el-form :inline="true" :model="searchForm" class="search-form">
                <el-form-item label="用户角色名">
                    <el-input
                        v-model="searchForm.name"
                        placeholder="请输入用户角色名"
                        clearable
                        @clear="handleSearch"
                        @keyup.enter="handleSearch"
                    />
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

        <div class="card" style="margin-bottom: 10px; display: flex; align-items: center; gap: 10px">
            <el-button type="primary" @click="handleAdd">
                <el-icon><Plus /></el-icon>
                新增用户角色
            </el-button>
            <el-button type="primary" @click="exportData"> 导出表格 </el-button>
            <el-upload
                action="/role/importData"
                :on-success="handleImport"
                style="display: inline-block; margin-left: 10px"
                :show-file-list="false"
            >
                <el-button type="primary">导入表格</el-button>
            </el-upload>
        </div>

        <!-- 用户角色表格 -->
        <el-card class="table-card" shadow="never">
            <el-table
                :data="roleList"
                v-loading="loading"
                stripe
                border
                style="width: 100%"
                :table-layout="fixed"
                @selection-change="handleSelectionChange"
            >
                <el-table-column type="selection" width="55" />
                <el-table-column prop="id" label="ID" width="80" />
                <el-table-column prop="name" label="用户角色" />
                <el-table-column prop="bio" label="简介" />
                <el-table-column label="状态" >
                    <template #default="{ row }">
                        <el-switch
                            v-model="row.status"
                            :active-value="1"
                            :inactive-value="0"
                            @change="handleStatusChange(row)"
                        />
                    </template>
                </el-table-column>
                <el-table-column label="操作" fixed="right">
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

        <!-- 新增/编辑用户角色对话框 -->
        <el-dialog
            v-model="dialog.visible"
            :title="dialog.title"
            width="600px"
            :close-on-click-modal="false"
            @close="handleDialogClose"
        >
            <el-form
                ref="roleFormRef"
                :model="dialog.form"
                :rules="dialog.rules"
                label-width="100px"
                status-icon
                :key="dialog.form.id || 'add'"
            >
                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="用户角色" prop="name">
                            <el-input
                                v-model="dialog.form.name"
                                placeholder="请输入用户角色"
                                :disabled="dialog.isView"
                            />
                        </el-form-item>
                    </el-col>
                </el-row>

                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="状态" prop="status">
                            <el-select
                                v-model="dialog.form.status"
                                placeholder="请选择状态"
                                style="width: 100%"
                                :disabled="dialog.isView"
                            >
                                <el-option :label="'启用'" :value="1" />
                                <el-option :label="'禁用'" :value="0" />
                            </el-select>
                        </el-form-item>
                    </el-col>
                </el-row>

                <el-form-item label="用户角色简介" prop="bio">
                    <el-input
                        v-model="dialog.form.bio"
                        type="textarea"
                        placeholder="请输入用户角色简介"
                        :rows="4"
                        maxlength="200"
                        show-word-limit
                        :disabled="dialog.isView"
                    />
                </el-form-item>
            </el-form>

            <template #footer>
                <span class="dialog-footer">
                    <el-button @click="dialog.visible = false">取消</el-button>
                    <el-button
                        v-if="!dialog.isView"
                        type="primary"
                        @click="submitRole"
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
import {onMounted, reactive, ref} from "vue";
import {ElMessage, ElMessageBox} from "element-plus";
import {Delete, Edit, Plus, Refresh, Search,} from "@element-plus/icons-vue";
import request from "../../utils/request";

// 搜索表单
const searchForm = reactive({
    name: "",
    status: ""
});

// 用户列表数据
const roleList = ref([]);
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
const roleFormRef = ref();
const dialog = reactive({
    visible: false,
    title: "",
    isAdd: false,
    isView: false,
    loading: false,
    form: {
        id: null,
        name: "",
        bio: "",
        status: 1,
    },
    rules: {
        name: [
            { required: true, message: "请输入用户角色", trigger: "blur" },
            {
                min: 2,
                max: 20,
                message: "长度在 2 到 20 个字符",
                trigger: "blur",
            },
        ],
    },
});

// 获取用户角色列表
const getRoleList = async () => {
    loading.value = true;
    try {
        const params = {
            pageNum: pagination.pageNum,
            pageSize: pagination.pageSize,
        };
        Object.entries(searchForm).forEach(([key, value]) => {
            if (value !== '') {
                params[key] = value;
            }
        });
        const res = await request.get("/role/list", { params });
        if (res.code === "200") {
            roleList.value = res.data.records;
            pagination.total = res.data.total || 0;
        } else {
            ElMessage.error(res.msg || "获取用户角色列表失败");
        }
    } catch (error) {
        ElMessage.error("获取用户角色列表失败");
    } finally {
        loading.value = false;
    }
};

// 搜索
const handleSearch = () => {
    pagination.pageNum = 1;
    getRoleList();
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
    getRoleList();
};

const handleCurrentChange = (val) => {
    pagination.pageNum = val;
    getRoleList();
};

// 表格选择变化
const handleSelectionChange = (val) => {
    selectedRows.value = val;
};

// 新增用户角色
const handleAdd = () => {
    dialog.title = "新增用户角色";
    dialog.isAdd = true;
    dialog.isView = false;
    dialog.form = {
        id: null,
        name: "",
        status: 1,
        bio: "",
    };
    dialog.visible = true;
};

// 编辑用户角色
const handleEdit = (row) => {
    dialog.title = "编辑用户角色";
    dialog.isAdd = false;
    dialog.isView = false;
    dialog.form = {
        id: row.id || null,
        name: row.name || "",
        status: row.status ?? 1,
        bio: row.bio || "",
    };
    dialog.visible = true;
};

// 提交用户
const submitRole = async () => {
    if (!roleFormRef.value) return;
    await roleFormRef.value.validate(async (valid) => {
        if (valid) {
            dialog.loading = true;
            try {
                const submitData = { ...dialog.form };
                if (dialog.isAdd) {
                    const res = await request.post("/role/add", submitData);
                    if (res.code === "200") {
                        ElMessage.success("新增用户角色成功");
                        dialog.visible = false;
                        getRoleList();
                    } else {
                        ElMessage.error(res.msg || "新增用户角色失败");
                    }
                } else {
                    const res = await request.post(
                        "/role/updateInfo",
                        submitData,
                    );
                    if (res.code === "200") {
                        ElMessage.success("更新用户角色成功");
                        dialog.visible = false;
                        getRoleList();
                    } else {
                        ElMessage.error(res.msg || "更新用户角色失败");
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

// 删除用户
const handleDelete = (row) => {
    ElMessageBox.confirm(`确定要删除用户角色"${row.name}"吗？`, "提示", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning",
    })
        .then(async () => {
            try {
                const res = await request.post(`/role/delete`, row);
                if (res.code === "200") {
                    ElMessage.success("删除成功");
                    getRoleList();
                } else {
                    ElMessage.error(res.msg || "删除失败");
                }
            } catch (error) {
                ElMessage.error("删除失败");
            }
        })
        .catch(() => {});
};

const handleStatusChange = async (row) => {
    try {
        const res = await request.post(`/role/updateStatus`, { id: row.id, status: row.status });
        if (res.code !== "200") {
            ElMessage.error("状态修改失败");
            row.status = row.status === 1 ? 0 : 1;
        }
    } catch (error) {
        ElMessage.error("状态修改失败");
        row.status = row.status === 1 ? 0 : 1;
    }
};


const handleImport = (res, file, filelist) => {
    if (res.code === "200") {
        ElMessage.success("数据导入成功");
    } else {
        ElMessage.error(res.msg);
    }
    getRoleList();
};

// 关闭对话框
const handleDialogClose = () => {
    roleFormRef.value?.clearValidate();
};

const exportData = async () => {
    try {
        const res = await request.get("/role/exportData", { responseType: "blob" });
        const blob = new Blob([res], { type: "application/vnd.ms-excel" });
        const url = window.URL.createObjectURL(blob);
        const link = document.createElement("a");
        link.href = url;
        link.download = "用户角色信息表.xls";
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        window.URL.revokeObjectURL(url);
    } catch (e) {
        ElMessage.error("导出失败");
    }
};

// 页面加载时获取数据
onMounted(() => {
    getRoleList();
});
</script>

<style src="@/assets/css/manager.css" scoped></style>
