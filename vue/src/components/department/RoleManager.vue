<!-- 用户角色表 -->
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
            <el-button v-if="menuStore.hasPermission('role:add')" type="primary" @click="handleAdd">
                <el-icon><Plus /></el-icon>
                新增用户角色
            </el-button>
            <el-button type="primary" @click="exportData"> 导出表格 </el-button>
            <el-upload
                action="/api/role/importData"
                :headers="uploadHeaders"
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
                <el-table-column prop="code" label="编码" width="160" />
                <el-table-column prop="sort" label="排序" width="80" />
                <el-table-column prop="bio" label="简介" />
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
                <el-table-column label="操作" fixed="right" width="360">
                    <template #default="{ row }">
                        <el-button
                            v-if="menuStore.hasPermission('role:edit')"
                            link
                            type="primary"
                            size="small"
                            @click="handleEdit(row)"
                        >
                            <el-icon><Edit /></el-icon>
                            编辑
                        </el-button>
                        <el-button
                            v-if="menuStore.hasPermission('role:assignMenu')"
                            link
                            type="primary"
                            size="small"
                            @click="openMenuDialog(row)"
                        >
                            分配菜单
                        </el-button>
                        <el-button
                            v-if="menuStore.hasPermission('role:assignPermission')"
                            link
                            type="primary"
                            size="small"
                            @click="openPermDialog(row)"
                        >
                            分配权限
                        </el-button>
                        <el-button
                            v-if="menuStore.hasPermission('role:delete')"
                            link
                            type="danger"
                            size="small"
                            :disabled="row.isSystem === 1"
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
                    <el-col :span="12">
                        <el-form-item label="角色编码" prop="code">
                            <el-input
                                v-model="dialog.form.code"
                                placeholder="请输入角色编码"
                                :disabled="dialog.isView || dialog.form.isSystem === 1"
                            />
                        </el-form-item>
                    </el-col>
                </el-row>

                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="排序" prop="sort">
                            <el-input-number
                                v-model="dialog.form.sort"
                                :min="0"
                                :max="9999"
                                style="width: 100%"
                                :disabled="dialog.isView"
                            />
                        </el-form-item>
                    </el-col>
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

        <!-- 分配菜单 -->
        <el-dialog
            v-model="menuDialog.visible"
            :title="menuDialog.title"
            width="520px"
            :close-on-click-modal="false"
        >
            <el-tree
                ref="menuTreeRef"
                :data="menuTree"
                show-checkbox
                node-key="id"
                :props="{ label: 'name', children: 'children' }"
                default-expand-all
                :check-strictly="false"
            />
            <template #footer>
                <el-button @click="menuDialog.visible = false">取消</el-button>
                <el-button type="primary" :loading="menuDialog.loading" @click="submitMenus">确认</el-button>
            </template>
        </el-dialog>

        <!-- 分配权限 -->
        <el-dialog
            v-model="permDialog.visible"
            :title="permDialog.title"
            width="520px"
            :close-on-click-modal="false"
        >
            <el-tree
                ref="permTreeRef"
                :data="permTree"
                show-checkbox
                node-key="id"
                :props="{ label: 'name', children: 'children' }"
                default-expand-all
                :check-strictly="false"
            />
            <template #footer>
                <el-button @click="permDialog.visible = false">取消</el-button>
                <el-button type="primary" :loading="permDialog.loading" @click="submitPerms">确认</el-button>
            </template>
        </el-dialog>
    </div>
</template>

<script setup>
import { nextTick, onMounted, reactive, ref } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import { Delete, Edit, Plus, Refresh, Search } from "@element-plus/icons-vue";
import {
    addRole,
    assignRoleMenus,
    assignRolePermissions,
    deleteRole,
    exportRoles,
    getMenuList,
    getPermissionTree,
    getRoleList as apiGetRoleList,
    getRoleMenus,
    getRolePermissions,
    updateRole,
    updateRoleStatus,
} from "@/api";
import { useMenuStore } from "@/store/menu.ts";

const menuStore = useMenuStore();

const uploadHeaders = {
    token: localStorage.getItem("token") || "",
};

const searchForm = reactive({
    name: "",
    status: "",
});

const roleList = ref([]);
const loading = ref(false);

const pagination = reactive({
    pageNum: 1,
    pageSize: 10,
    total: 0,
});

const selectedRows = ref([]);

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
        code: "",
        sort: 0,
        bio: "",
        status: 1,
        isSystem: 0,
    },
    rules: {
        name: [
            { required: true, message: "请输入用户角色", trigger: "blur" },
            { min: 2, max: 20, message: "长度在 2 到 20 个字符", trigger: "blur" },
        ],
        code: [
            { required: true, message: "请输入角色编码", trigger: "blur" },
            { min: 2, max: 50, message: "长度在 2 到 50 个字符", trigger: "blur" },
        ],
    },
});

const menuTreeRef = ref();
const menuTree = ref([]);
const menuDialog = reactive({
    visible: false,
    title: "",
    loading: false,
    roleId: null,
});

const permTreeRef = ref();
const permTree = ref([]);
const permDialog = reactive({
    visible: false,
    title: "",
    loading: false,
    roleId: null,
});

const getRoleList = async () => {
    loading.value = true;
    try {
        const params = {
            pageNum: pagination.pageNum,
            pageSize: pagination.pageSize,
        };
        Object.entries(searchForm).forEach(([key, value]) => {
            if (value !== "") {
                params[key] = value;
            }
        });
        const res = await apiGetRoleList(params);
        if (res.code === "200") {
            roleList.value = res.data.records;
            pagination.total = res.data.total;
        } else {
            ElMessage.error(res.msg || "获取用户角色列表失败");
        }
    } catch (error) {
        ElMessage.error("获取用户角色列表失败");
    } finally {
        loading.value = false;
    }
};

const handleSearch = () => {
    pagination.pageNum = 1;
    getRoleList();
};

const resetSearch = () => {
    Object.keys(searchForm).forEach((key) => {
        searchForm[key] = "";
    });
    handleSearch();
};

const handleSizeChange = (val) => {
    pagination.pageSize = val;
    getRoleList();
};

const handleCurrentChange = (val) => {
    pagination.pageNum = val;
    getRoleList();
};

const handleSelectionChange = (val) => {
    selectedRows.value = val;
};

const handleAdd = () => {
    dialog.title = "新增用户角色";
    dialog.isAdd = true;
    dialog.isView = false;
    dialog.form = {
        id: null,
        name: "",
        code: "",
        sort: 0,
        status: 1,
        bio: "",
        isSystem: 0,
    };
    dialog.visible = true;
};

const handleEdit = (row) => {
    dialog.title = "编辑用户角色";
    dialog.isAdd = false;
    dialog.isView = false;
    dialog.form = {
        id: row.id || null,
        name: row.name || "",
        code: row.code || "",
        sort: row.sort ?? 0,
        status: row.status ?? 1,
        bio: row.bio || "",
        isSystem: row.isSystem ?? 0,
    };
    dialog.visible = true;
};

const submitRole = async () => {
    if (!roleFormRef.value) return;
    await roleFormRef.value.validate(async (valid) => {
        if (valid) {
            dialog.loading = true;
            try {
                const submitData = { ...dialog.form };
                if (dialog.isAdd) {
                    const res = await addRole(submitData);
                    if (res.code === "200") {
                        ElMessage.success("新增用户角色成功");
                        dialog.visible = false;
                        getRoleList();
                    } else {
                        ElMessage.error(res.msg || "新增用户角色失败");
                    }
                } else {
                    const res = await updateRole(submitData);
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

const handleDelete = (row) => {
    if (row.isSystem === 1) {
        ElMessage.warning("系统角色不可删除");
        return;
    }
    ElMessageBox.confirm(`确定要删除用户角色"${row.name}"吗？`, "提示", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning",
    })
        .then(async () => {
            try {
                const res = await deleteRole(row);
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
        const res = await updateRoleStatus({ id: row.id, status: row.status });
        if (res.code !== "200") {
            ElMessage.error("状态修改失败");
            row.status = row.status === 1 ? 0 : 1;
        }
    } catch (error) {
        ElMessage.error("状态修改失败");
        row.status = row.status === 1 ? 0 : 1;
    }
};

const handleImport = (res) => {
    if (res.code === "200") {
        ElMessage.success("数据导入成功");
    } else {
        ElMessage.error(res.msg);
    }
    getRoleList();
};

const handleDialogClose = () => {
    roleFormRef.value?.clearValidate();
};

const exportData = async () => {
    try {
        const res = await exportRoles();
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

/** 收集树节点 ID，用于回显时只勾叶子、父级由 el-tree 自动半选 */
const collectLeafIds = (nodes, idSet, result) => {
    (nodes || []).forEach((node) => {
        if (node.children && node.children.length) {
            collectLeafIds(node.children, idSet, result);
        } else if (idSet.has(node.id)) {
            result.push(node.id);
        }
    });
};

const openMenuDialog = async (row) => {
    menuDialog.title = `分配菜单 - ${row.name}`;
    menuDialog.roleId = row.id;
    menuDialog.visible = true;
    try {
        const [treeRes, idsRes] = await Promise.all([getMenuList(), getRoleMenus(row.id)]);
        if (treeRes.code === "200") {
            menuTree.value = treeRes.data || [];
        }
        const ids = idsRes.code === "200" ? idsRes.data || [] : [];
        const idSet = new Set(ids);
        const leaves = [];
        collectLeafIds(menuTree.value, idSet, leaves);
        await nextTick();
        menuTreeRef.value?.setCheckedKeys(leaves);
    } catch (e) {
        ElMessage.error("加载菜单失败");
    }
};

const submitMenus = async () => {
    menuDialog.loading = true;
    try {
        const checked = menuTreeRef.value?.getCheckedKeys(false) || [];
        const half = menuTreeRef.value?.getHalfCheckedKeys() || [];
        const res = await assignRoleMenus({
            roleId: menuDialog.roleId,
            menuIds: [...checked, ...half],
        });
        if (res.code === "200") {
            ElMessage.success("菜单分配成功");
            menuDialog.visible = false;
        } else {
            ElMessage.error(res.msg || "菜单分配失败");
        }
    } catch (e) {
        ElMessage.error("菜单分配失败");
    } finally {
        menuDialog.loading = false;
    }
};

const openPermDialog = async (row) => {
    permDialog.title = `分配权限 - ${row.name}`;
    permDialog.roleId = row.id;
    permDialog.visible = true;
    try {
        const [treeRes, idsRes] = await Promise.all([getPermissionTree(), getRolePermissions(row.id)]);
        if (treeRes.code === "200") {
            permTree.value = treeRes.data || [];
        }
        const ids = idsRes.code === "200" ? idsRes.data || [] : [];
        const idSet = new Set(ids);
        const leaves = [];
        collectLeafIds(permTree.value, idSet, leaves);
        await nextTick();
        permTreeRef.value?.setCheckedKeys(leaves);
    } catch (e) {
        ElMessage.error("加载权限失败");
    }
};

const submitPerms = async () => {
    permDialog.loading = true;
    try {
        const checked = permTreeRef.value?.getCheckedKeys(false) || [];
        const half = permTreeRef.value?.getHalfCheckedKeys() || [];
        const res = await assignRolePermissions({
            roleId: permDialog.roleId,
            permissionIds: [...checked, ...half],
        });
        if (res.code === "200") {
            ElMessage.success("权限分配成功");
            permDialog.visible = false;
        } else {
            ElMessage.error(res.msg || "权限分配失败");
        }
    } catch (e) {
        ElMessage.error("权限分配失败");
    } finally {
        permDialog.loading = false;
    }
};

onMounted(() => {
    getRoleList();
});
</script>

<style src="@/assets/css/manager.css" scoped></style>
