<template>
    <div class="user-management">
        <div class="card" style="margin-bottom: 10px; display: flex; align-items: center; gap: 10px">
            <el-button type="primary" @click="handleAdd">
                <el-icon><Plus /></el-icon>
                新增菜单
            </el-button>
            <el-button type="primary" @click="exportData"> 导出表格 </el-button>
            <el-upload
                action="/menu/importData"
                :on-success="handleImport"
                style="display: inline-block; margin-left: 10px"
                :show-file-list="false"
            >
                <el-button type="primary">导入表格</el-button>
            </el-upload>
        </div>

        <!-- 菜单表格（树形展示） -->
        <el-card class="table-card" shadow="never">
            <el-table
                :data="menuList"
                v-loading="loading"
                style="width: 100%"
                row-key="id"
                :tree-props="{ children: 'children' }"
            >
                <el-table-column prop="name" label="名称" />
                <el-table-column label="状态" width="120">
                    <template #default="{ row }">
                        <span :style="{ color: row.status ? '#67c23a' : '#f56c6c' }">
                            {{ row.status ? '启用' : '禁用' }}
                        </span>
                    </template>
                </el-table-column>
                <el-table-column label="操作" fixed="right" width="320">
                    <template #default="{ row }">
                        <el-button
                            link
                            type="primary"
                            size="small"
                            @click="handleAdd(row)"
                        >
                            添加子菜单
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

        <!-- 新增/编辑菜单对话框 -->
        <el-dialog
            v-model="dialog.visible"
            :title="dialog.title"
            width="600px"
            :close-on-click-modal="false"
            @close="handleDialogClose"
        >
            <el-form
                ref="menuFormRef"
                :model="dialog.form"
                :rules="dialog.rules"
                label-width="100px"
                status-icon
                :key="dialog.form.id || 'add'"
            >
                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="菜单" prop="name">
                            <el-input
                                v-model="dialog.form.name"
                                placeholder="请输入菜单"
                                :disabled="dialog.isView"
                            />
                        </el-form-item>
                    </el-col>
                </el-row>

                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="父级菜单" prop="pid">
                            <el-tree-select
                                v-model="dialog.form.pid"
                                :data="menuList"
                                :props="{ label: 'name', value: 'id', children: 'children' }"
                                placeholder="请选择父级菜单（留空为顶级）"
                                clearable
                                filterable
                                style="width: 100%"
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
                                <el-option :label="'启用'" :value="true" />
                                <el-option :label="'禁用'" :value="false" />
                            </el-select>
                        </el-form-item>
                    </el-col>
                </el-row>

                <el-form-item label="菜单简介" prop="bio">
                    <el-input
                        v-model="dialog.form.bio"
                        type="textarea"
                        placeholder="请输入菜单简介"
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
                        @click="submitmenu"
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
import {Plus} from "@element-plus/icons-vue";
import request from "../../utils/request";

// 搜索表单
const searchForm = reactive({
    name: "",
});

// 菜单列表数据（树形）
const menuList = ref([]);
const loading = ref(false);

// 新增/编辑对话框
const menuFormRef = ref();
const dialog = reactive({
    visible: false,
    title: "",
    isAdd: false,
    isView: false,
    loading: false,
    form: {
        id: null,
        pid: null,
        name: "",
        bio: "",
        status: true,
    },
    rules: {
        name: [
            { required: true, message: "请输入菜单", trigger: "blur" },
            {
                min: 2,
                max: 20,
                message: "长度在 2 到 20 个字符",
                trigger: "blur",
            },
        ],
    },
});

// 所有菜单平面列表（用于父菜单选择）
const allMenus = ref([]);

const flatMenus = (menus, result = []) => {
    for (const m of menus) {
        result.push(m);
        if (m.children && m.children.length) {
            flatMenus(m.children, result);
        }
    }
    return result;
};

// 获取菜单树
const getMenuList = async () => {
    loading.value = true;
    try {
        const params = {};
        if (searchForm.name) {
            params.name = searchForm.name;
        }
        const res = await request.get("/menu/list", { params });
        if (res.code === "200") {
            const data = Array.isArray(res.data) ? res.data : (res.data.records || []);
            menuList.value = data;
            allMenus.value = flatMenus(data);
        } else {
            ElMessage.error(res.msg || "获取菜单列表失败");
        }
    } catch (error) {
        ElMessage.error("获取菜单列表失败");
    } finally {
        loading.value = false;
    }
};

// 新增菜单
const handleAdd = (row) => {
    dialog.title = row ? "新增子菜单" : "新增菜单";
    dialog.isAdd = true;
    dialog.isView = false;
    dialog.form = {
        id: null,
        pid: row ? row.id : null,
        name: "",
        status: true,
        bio: "",
    };
    dialog.visible = true;
};

// 编辑菜单
const handleEdit = (row) => {
    dialog.title = "编辑菜单";
    dialog.isAdd = false;
    dialog.isView = false;
    dialog.form = {
        id: row.id || null,
        pid: row.pid || null,
        name: row.name || "",
        status: row.status ?? true,
        bio: row.bio || "",
    };
    dialog.visible = true;
};

// 提交菜单
const submitmenu = async () => {
    if (!menuFormRef.value) return;
    await menuFormRef.value.validate(async (valid) => {
        if (valid) {
            dialog.loading = true;
            try {
                const submitData = { ...dialog.form };
                if (dialog.isAdd) {
                    const res = await request.post("/menu/add", submitData);
                    if (res.code === "200") {
                        ElMessage.success("新增菜单成功");
                        dialog.visible = false;
                        getMenuList();
                    } else {
                        ElMessage.error(res.msg || "新增菜单失败");
                    }
                } else {
                    const res = await request.post(
                        "/menu/updateInfo",
                        submitData,
                    );
                    if (res.code === "200") {
                        ElMessage.success("更新菜单成功");
                        dialog.visible = false;
                        getMenuList();
                    } else {
                        ElMessage.error(res.msg || "更新菜单失败");
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

// 删除菜单
const handleDelete = (row) => {
    ElMessageBox.confirm(`确定要删除菜单"${row.name}"吗？`, "提示", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning",
    })
        .then(async () => {
            try {
                const res = await request.post(`/menu/delete`, row);
                if (res.code === "200") {
                    ElMessage.success("删除成功");
                    getMenuList();
                } else {
                    ElMessage.error(res.msg || "删除失败");
                }
            } catch (error) {
                ElMessage.error("删除失败");
            }
        })
        .catch(() => {});
};

const handleImport = (res, file, filelist) => {
    if (res.code === "200") {
        ElMessage.success("数据导入成功");
    } else {
        ElMessage.error(res.msg);
    }
    getMenuList();
};

const handleDialogClose = () => {
    menuFormRef.value?.clearValidate();
};

const exportData = async () => {
    window.open("/menu/exportData");
};

onMounted(() => {
    getMenuList();
});
</script>

<style src="@/assets/css/manager.css" scoped></style>
