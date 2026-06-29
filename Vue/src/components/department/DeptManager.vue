<template>
    <div class="user-management">
        <!-- 搜索栏 -->
        <el-card class="search-card" shadow="never">
            <el-form :inline="true" :model="searchForm" class="search-form">
                <el-form-item label="部门名称">
                    <el-input
                        v-model="searchForm.name"
                        placeholder="请输入部门名称"
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
                新增部门
            </el-button>
            <el-button type="primary" @click="exportData"> 导出表格 </el-button>
            <el-upload
                action="/dept/importData"
                :on-success="handleImport"
                style="display: inline-block; margin-left: 10px"
                :show-file-list="false"
            >
                <el-button type="primary">导入表格</el-button>
            </el-upload>
        </div>

        <!-- 部门表格（树形展示） -->
        <el-card class="table-card" shadow="never">
            <el-table
                :data="deptList"
                v-loading="loading"
                stripe
                border
                style="width: 100%"
                row-key="id"
                :tree-props="{ children: 'children' }"
            >
                <el-table-column prop="name" label="名称" />
                <el-table-column prop="intro" label="部门简介" />
                <el-table-column label="状态" width="100">
                    <template #default="{ row }">
                        <el-switch
                            v-model="row.status"
                            :active-value="1"
                            :inactive-value="0"
                            @change="handleStatusChange(row)"
                        />
                    </template>
                </el-table-column>
                <el-table-column label="操作" fixed="right" width="320">
                    <template #default="{ row }">
                        <el-button
                            link
                            type="primary"
                            size="small"
                            @click="handleCheck(row)"
                        >
                            查看部门详情
                        </el-button>
                        <el-button
                            link
                            type="primary"
                            size="small"
                            @click="handleAdd(row)"
                        >
                            添加子部门
                        </el-button>
                        <el-button
                            link
                            type="primary"
                            size="small"
                            @click="handleEdit(row)"
                        >
                            编辑
                        </el-button>
                        <el-button
                            link
                            type="danger"
                            size="small"
                            @click="handleDelete(row)"
                        >
                            删除
                        </el-button>
                    </template>
                </el-table-column>
            </el-table>
        </el-card>

        <!-- 新增/编辑部门对话框 -->
        <el-dialog
            v-model="dialog.visible"
            :title="dialog.title"
            width="600px"
            :close-on-click-modal="false"
            @close="handleDialogClose"
        >
            <el-form
                ref="deptFormRef"
                :model="dialog.form"
                :rules="dialog.rules"
                label-width="100px"
                status-icon
                :key="dialog.form.id || 'add'"
            >
                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="部门" prop="name">
                            <el-input
                                v-model="dialog.form.name"
                                placeholder="请输入部门"
                                :disabled="dialog.isView"
                            />
                        </el-form-item>
                    </el-col>
                </el-row>

                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="父级部门" prop="parentId">
                            <el-tree-select
                                v-model="dialog.form.parentId"
                                :data="deptList"
                                :props="{ label: 'name', value: 'id', children: 'children' }"
                                placeholder="请选择父级部门（留空为顶级）"
                                clearable
                                filterable
                                style="width: 100%"
                                :disabled="dialog.isView"
                            />
                        </el-form-item>
                    </el-col>
                </el-row>

                <el-col :span="12">
                    <el-form-item label="状态" prop="status">
                        <el-select
                            v-model="dialog.form.status"
                            placeholder="请选择状态"
                            style="width: 100%"
                            :disabled="dialog.isView"
                        >
                            <el-option label="启用" :value="1" />
                            <el-option label="禁用" :value="0" />
                        </el-select>
                    </el-form-item>
                </el-col>

                <el-form-item label="部门简介" prop="intro">
                    <el-input
                        v-model="dialog.form.intro"
                        type="textarea"
                        placeholder="请输入部门简介"
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
                        @click="submitDept"
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
import {Plus, Refresh, Search} from "@element-plus/icons-vue";
import request from "../../utils/request";
import router from "../../router/index.js";

// 搜索表单
const searchForm = reactive({
    name: "",
});

// 搜索
const handleSearch = () => {
    pagination.pageNum = 1;
    getDeptList();
};

// 重置搜索
const resetSearch = () => {
    Object.keys(searchForm).forEach((key) => {
        searchForm[key] = "";
    });
    handleSearch();
};

// 部门列表数据（树形）
const deptList = ref([]);
const loading = ref(false);

// 新增/编辑对话框
const deptFormRef = ref();
const dialog = reactive({
    visible: false,
    title: "",
    isAdd: false,
    isView: false,
    loading: false,
    form: {
        id: null,
        parentId: null,
        name: "",
        intro: "",
        status: 1,
    },
    rules: {
        name: [
            { required: true, message: "请输入部门", trigger: "blur" },
            {
                min: 2,
                max: 20,
                message: "长度在 2 到 20 个字符",
                trigger: "blur",
            },
        ],
    },
});

// 所有部门平面列表（用于父部门选择）
const allDepts = ref([]);

const flatDepts = (depts, result = []) => {
    for (const m of depts) {
        result.push(m);
        if (m.children && m.children.length) {
            flatDepts(m.children, result);
        }
    }
    return result;
};

// 获取部门树
const getDeptList = async () => {
    loading.value = true;
    try {
        const params = {};
        if (searchForm.name) {
            params.name = searchForm.name;
        }
        const res = await request.get("/dept/list", { params });
        if (res.code === "200") {
            const data = Array.isArray(res.data) ? res.data : (res.data.records || []);
            deptList.value = data;
            allDepts.value = flatDepts(data);
        } else {
            ElMessage.error(res.msg || "获取部门列表失败");
        }
    } catch (error) {
        ElMessage.error("获取部门列表失败");
    } finally {
        loading.value = false;
    }
};

// 查看部门详情
const handleCheck=(row) =>{
    router.push({ path: '/dept/detail', query: { id: row.id } });
}

// 新增部门
const handleAdd = (row) => {
    dialog.title = row ? "新增子部门" : "新增部门";
    dialog.isAdd = true;
    dialog.isView = false;
    dialog.form = {
        id: null,
        parentId: row ? row.id : null,
        name: "",
        status: 1,
        intro: "",
    };
    dialog.visible = true;
};

// 编辑部门
const handleEdit = (row) => {
    dialog.title = "编辑部门";
    dialog.isAdd = false;
    dialog.isView = false;
    dialog.form = {
        id: row.id || null,
        parentId: row.parentId || null,
        name: row.name || "",
        status: row.status ?? 1,
        intro: row.intro || "",
    };
    dialog.visible = true;
};

// 提交部门
const submitDept = async () => {
    if (!deptFormRef.value) return;
    await deptFormRef.value.validate(async (valid) => {
        if (valid) {
            dialog.loading = true;
            try {
                const submitData = { ...dialog.form };
                if (dialog.isAdd) {
                    const res = await request.post("/dept/add", submitData);
                    if (res.code === "200") {
                        ElMessage.success("新增部门成功");
                        dialog.visible = false;
                        getDeptList();
                    } else {
                        ElMessage.error(res.msg || "新增部门失败");
                    }
                } else {
                    const res = await request.post(
                        "/dept/updateInfo",
                        submitData,
                    );
                    if (res.code === "200") {
                        ElMessage.success("更新部门成功");
                        dialog.visible = false;
                        getDeptList();
                    } else {
                        ElMessage.error(res.msg || "更新部门失败");
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

// // 修改状态
const handleStatusChange = async (row) => {
    try {
        const res = await request.post(`/dept/updateStatus`, row);
        if (res.code !== "200") {
            ElMessage.error("状态修改失败");
            // 回滚状态
            row.status = row.status === 1 ? 0 : 1;
        }
    } catch (error) {
        ElMessage.error("状态修改失败");
        row.status = row.status === 1 ? 0 : 1;
    }
};

// 删除部门
const handleDelete = (row) => {
    ElMessageBox.confirm(`确定要删除部门"${row.name}"吗？`, "提示", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning",
    })
        .then(async () => {
            try {
                const res = await request.post(`/dept/delete`, row);
                if (res.code === "200") {
                    ElMessage.success("删除成功");
                    getDeptList();
                } else {
                    ElMessage.error(res.msg || "删除失败");
                }
            } catch (error) {
                ElMessage.error("删除失败");
            }
        })
        .catch(() => {});
};

const handleImport = (res, file, fileList) => {
    if (res.code === "200") {
        ElMessage.success("数据导入成功");
    } else {
        ElMessage.error(res.msg);
    }
    getDeptList();
};

const handleDialogClose = () => {
    deptFormRef.value?.clearValidate();
};

const exportData = async () => {
    window.open("/dept/exportData");
};

onMounted(() => {
    getDeptList();
});
</script>

<style src="@/assets/css/manager.css" scoped></style>
