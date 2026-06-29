<template>
    <div class="dept-detail">
        <div style="margin-bottom: 16px">
            <el-button @click="goBack">
                <el-icon>
                    <ArrowLeft/>
                </el-icon>
                返回部门列表
            </el-button>
        </div>

        <el-card shadow="never" class="detail-card" v-loading="loading">
            <template #header>
                <div class="card-header">
                    <div class="card-header-left">
                        <el-tag v-if="dept.status === 1" type="success" effect="dark" size="small">启用</el-tag>
                        <el-tag v-else type="danger" effect="dark" size="small">禁用</el-tag>
                        <span class="dept-title">{{ dept.name }}</span>
                    </div>
                    <div>
                        <el-button type="primary" @click="handleEdit">
                            <el-icon>
                                <Edit/>
                            </el-icon>
                            编辑部门
                        </el-button>
                    </div>
                </div>
            </template>
            <el-descriptions :column="2" border>
                <el-descriptions-item label="部门名称">{{ dept.name }}</el-descriptions-item>
                <el-descriptions-item label="部门编码">{{ dept.code }}</el-descriptions-item>
                <el-descriptions-item label="上级部门">
                    <el-link v-if="dept.parentId" type="primary" @click="viewParentDept">
                        {{ dept.parentName || '暂无' }}
                    </el-link>
                    <span v-else>无（顶级部门）</span>
                </el-descriptions-item>
                <el-descriptions-item label="部门负责人">{{ dept.userName || '暂无' }}</el-descriptions-item>
                <el-descriptions-item label="联系电话">{{ dept.phone || '暂无' }}</el-descriptions-item>
                <el-descriptions-item label="办公地点">{{ dept.address || '暂无' }}</el-descriptions-item>
                <el-descriptions-item label="成立时间">{{ dept.createTime || '暂无' }}</el-descriptions-item>
                <el-descriptions-item label="部门状态">
                    <el-tag :type="dept.status === 1 ? 'success' : 'danger'" size="small">
                        {{ dept.status === 1 ? '正常运营' : '停用' }}
                    </el-tag>
                </el-descriptions-item>
                <el-descriptions-item label="部门简介" :span="2">{{ dept.intro || '暂无' }}</el-descriptions-item>
            </el-descriptions>
        </el-card>

        <el-card shadow="never" class="detail-card">
            <template #header>
                <div class="card-header">
                    <span>子部门列表（{{ subDeptList.length }}个）</span>
                </div>
            </template>
            <el-table :data="subDeptList" stripe border v-loading="subDeptLoading" row-key="id">
                <el-table-column type="index" label="序号" width="60"/>
                <el-table-column prop="code" label="部门编码"/>
                <el-table-column prop="name" label="部门名称"/>
                <el-table-column prop="userName" label="部门经理"/>
                <el-table-column prop="address" label="办公地点"/>
                <el-table-column prop="phone" label="联系电话"/>
                <el-table-column label="操作" width="160" fixed="right">
                    <template #default="{ row }">
                        <el-button link type="primary" size="small" @click="viewDept(row.id)">查看</el-button>
                        <el-button link type="danger" size="small" @click="deleteSubDept(row)">删除</el-button>
                    </template>
                </el-table-column>
            </el-table>
        </el-card>

        <el-card shadow="never" class="detail-card">
            <template #header>
                <div class="card-header">
                    <span>部门员工（{{ userList.length }}人）</span>
                    <div class="card-header-right">
                        <el-input
                            v-model="searchQuery"
                            placeholder="搜索员工姓名、职位..."
                            :prefix-icon="Search"
                            clearable
                            style="width: 240px; margin-right: 12px"
                            @input="handleSearch"
                        />
                    </div>
                </div>
            </template>
            <el-table :data="userList" stripe border v-loading="userLoading">
                <el-table-column prop="name" label="姓名"/>
                <el-table-column prop="role" label="职位"/>
                <el-table-column prop="department" label="所属部门"/>
                <el-table-column prop="phone" label="联系电话"/>
                <el-table-column prop="email" label="邮箱"/>
                <el-table-column prop="employed" label="在职状态" width="100">
                    <template #default="{ row }">
                        <el-tag :type="employedType(row.employed)" size="small">
                            {{ employedLabel(row.employed) }}
                        </el-tag>
                    </template>
                </el-table-column>
                <el-table-column prop="status" label="用户状态" width="100" />
                <el-table-column label="操作" width="160" fixed="right">
                    <template #default="{ row }">
                        <el-button link type="primary" size="small" @click="viewEmployee(row)">查看</el-button>
                        <el-button link type="warning" size="small" @click="handleTransfer(row)">调岗</el-button>
                    </template>
                </el-table-column>
            </el-table>
        </el-card>

        <el-dialog v-model="editDialog.visible" title="编辑部门" width="650px" :close-on-click-modal="false"
                   @close="editFormRef.value?.clearValidate()">
            <el-form ref="editFormRef" :model="editDialog.form" :rules="editDialog.rules" label-width="120px">
                <el-form-item label="上级部门" prop="parentId">
                    <el-tree-select
                        v-model="editDialog.form.parentId"
                        :data="allDeptTree"
                        :props="{ label: 'name', value: 'id', children: 'children' }"
                        placeholder="请选择上级部门（留空为顶级）"
                        clearable filterable style="width: 100%"
                    />
                </el-form-item>
                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="部门名称" prop="name">
                            <el-input v-model="editDialog.form.name"/>
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="部门编码" prop="code">
                            <el-input v-model="editDialog.form.code"/>
                        </el-form-item>
                    </el-col>
                </el-row>
                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="部门状态" prop="status">
                            <el-select v-model="editDialog.form.status" style="width: 100%">
                                <el-option label="正常运营" :value="1"/>
                                <el-option label="停用" :value="0"/>
                            </el-select>
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="部门负责人" prop="userId">
                            <el-select v-model="editDialog.form.userId" placeholder="请选择负责人" clearable filterable
                                       style="width: 100%">
                                <el-option v-for="u in allUsers" :key="u.uid" :label="u.name + ' - ' + (u.role || '')"
                                           :value="u.uid"/>
                            </el-select>
                        </el-form-item>
                    </el-col>
                </el-row>
                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="联系电话" prop="phone">
                            <el-input v-model="editDialog.form.phone"/>
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="办公地点" prop="address">
                            <el-input v-model="editDialog.form.address"/>
                        </el-form-item>
                    </el-col>
                </el-row>
                <el-form-item label="部门简介" prop="intro">
                    <el-input v-model="editDialog.form.intro" type="textarea" :rows="3" maxlength="200"
                              show-word-limit/>
                </el-form-item>
            </el-form>
            <template #footer>
                <el-button @click="editDialog.visible = false">取消</el-button>
                <el-button type="primary" :loading="editDialog.loading" @click="submitEdit">确认</el-button>
            </template>
        </el-dialog>

        <el-dialog v-model="transferDialog.visible" title="员工调岗" width="500px" :close-on-click-modal="false">
            <el-form ref="transferFormRef" :model="transferDialog.form" label-width="120px">
                <el-form-item label="当前员工">
                    <el-tag type="info">{{ transferDialog.form.userName }}</el-tag>
                </el-form-item>
                <el-form-item label="目标部门" prop="targetDeptId">
                    <el-tree-select
                        v-model="transferDialog.form.targetDeptId"
                        :data="allDeptTree"
                        :props="{ label: 'name', value: 'id', children: 'children' }"
                        placeholder="请选择目标部门"
                        clearable filterable style="width: 100%"
                    />
                </el-form-item>
                <el-form-item label="职位" prop="role">
                    <el-input v-model="transferDialog.form.role" placeholder="请输入职位"/>
                </el-form-item>
                <el-form-item label="在职状态" prop="empolyed">
                    <el-select v-model="transferDialog.form.empolyed" placeholder="请选择在职状态" style="width: 100%">
                        <el-option label="实习" value="0"/>
                        <el-option label="试用" value="1"/>
                        <el-option label="转正" value="2"/>
                        <el-option label="离职" value="3"/>
                    </el-select>
                </el-form-item>
            </el-form>
            <template #footer>
                <el-button @click="transferDialog.visible = false">取消</el-button>
                <el-button type="primary" :loading="transferDialog.loading" @click="submitTransfer">确认</el-button>
            </template>
        </el-dialog>
    </div>
</template>

<script setup>
import { onMounted, reactive, ref } from "vue";
import { useRoute, useRouter } from "vue-router";
import { ElMessage, ElMessageBox } from "element-plus";
import { ArrowLeft, Edit, Search } from "@element-plus/icons-vue";
import request from "../../utils/request";

const route = useRoute();
const router = useRouter();

const loading = ref(false);
const subDeptLoading = ref(false);
const userLoading = ref(false);
const searchQuery = ref("");

const dept = ref({});
const subDeptList = ref([]);
const userList = ref([]);
const allDeptTree = ref([]);
const allUsers = ref([]);

const findDeptInTree = (nodes, id) => {
    for (const node of nodes) {
        if (node.id === id) return node;
        if (node.children) {
            const found = findDeptInTree(node.children, id);
            if (found) return found;
        }
    }
    return null;
};

const findDeptName = (nodes, id) => {
    const node = findDeptInTree(nodes, id);
    return node ? node.name : "";
};

const loadDeptDetail = async () => {
    const id = route.query.id;
    if (!id) {
        ElMessage.error("部门ID不存在");
        router.push("/dept/list");
        return;
    }
    loading.value = true;
    try {
        const res = await request.get(`/dept/detail/${id}`);
        if (res.code === "200") {
            dept.value = res.data || {};
        } else {
            ElMessage.error(res.msg || "获取部门详情失败");
        }
    } catch (error) {
        ElMessage.error("获取部门详情失败");
    } finally {
        loading.value = false;
    }
};

const loadDeptTree = async () => {
    try {
        const res = await request.get("/dept/list");
        if (res.code === "200") {
            const tree = Array.isArray(res.data) ? res.data : (res.data.records || []);
            allDeptTree.value = tree;
            const id = route.query.id;
            if (id) {
                const node = findDeptInTree(tree, Number(id));
                if (node) {
                    subDeptList.value = node.children || [];
                }
            }
        }
    } catch (error) {
        console.error("获取部门树失败");
    }
};

const loadMembers = async () => {
    const id = route.query.id;
    if (!id) return;
    userLoading.value = true;
    try {
        const params = {};
        if (searchQuery.value) {
            params.searchQuery = searchQuery.value;
        }
        const res = await request.get(`/dept/members/${id}`, { params });
        if (res.code === "200") {
            const data = Array.isArray(res.data) ? res.data : (res.data.records || []);
            userList.value = data.map(u => ({
                ...u,
                department: u.deptName || "",
            }));
        } else {
            ElMessage.error(res.msg || "获取部门成员失败");
        }
    } catch (error) {
        ElMessage.error("获取部门成员失败");
    } finally {
        userLoading.value = false;
    }
};

const loadAllUsers = async () => {
    try {
        const res = await request.get("/user/selectAllUsers");
        if (res.code === "200") {
            allUsers.value = Array.isArray(res.data) ? res.data : [];
        }
    } catch (error) {
        console.error("获取用户列表失败");
    }
};

const goBack = () => {
    router.push("/dept/list");
};

const viewParentDept = () => {
    if (dept.value.parentId) {
        router.push({ path: "/dept/detail", query: { id: dept.value.parentId } });
    }
};

const viewDept = (id) => {
    router.push({ path: "/dept/detail", query: { id } });
};

const deleteSubDept = (row) => {
    ElMessageBox.confirm(`确定要删除部门"${row.name}"吗？`, "提示", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning",
    })
        .then(async () => {
            try {
                const res = await request.post("/dept/delete", row);
                if (res.code === "200") {
                    ElMessage.success("删除成功");
                    loadDeptTree();
                } else {
                    ElMessage.error(res.msg || "删除失败");
                }
            } catch (error) {
                ElMessage.error("删除失败");
            }
        })
        .catch(() => {});
};

const handleSearch = () => {
    loadMembers();
};

const viewEmployee = (row) => {
    router.push({ path: "/system/user", query: { uid: row.uid } });
};

const employedType = (val) => {
    const map = { "0": "info", "1": "warning", "2": "success", "3": "danger" };
    return map[val] || "info";
};

const employedLabel = (val) => {
    const map = { "0": "实习", "1": "试用", "2": "转正", "3": "离职" };
    return map[val] || "未知";
};

const editFormRef = ref();
const editDialog = reactive({
    visible: false,
    loading: false,
    form: {
        id: null,
        parentId: null,
        name: "",
        code: "",
        status: 1,
        userId: null,
        phone: "",
        address: "",
        intro: "",
    },
    rules: {
        name: [
            { required: true, message: "请输入部门名称", trigger: "blur" },
            { min: 2, max: 20, message: "长度在 2 到 20 个字符", trigger: "blur" },
        ],
        code: [
            { required: true, message: "请输入部门编码", trigger: "blur" },
        ],
    },
});

const handleEdit = () => {
    editDialog.form = {
        id: dept.value.id || null,
        parentId: dept.value.parentId || null,
        name: dept.value.name || "",
        code: dept.value.code || "",
        status: dept.value.status ?? 1,
        userId: dept.value.userId || null,
        phone: dept.value.phone || "",
        address: dept.value.address || "",
        intro: dept.value.intro || "",
    };
    editDialog.visible = true;
};

const submitEdit = async () => {
    if (!editFormRef.value) return;
    await editFormRef.value.validate(async (valid) => {
        if (valid) {
            editDialog.loading = true;
            try {
                const res = await request.post("/dept/updateInfo", editDialog.form);
                if (res.code === "200") {
                    ElMessage.success("更新部门成功");
                    editDialog.visible = false;
                    loadDeptDetail();
                    loadDeptTree();
                } else {
                    ElMessage.error(res.msg || "更新部门失败");
                }
            } catch (error) {
                ElMessage.error("操作失败");
            } finally {
                editDialog.loading = false;
            }
        }
    });
};

const transferFormRef = ref();
const transferDialog = reactive({
    visible: false,
    loading: false,
    form: {
        uid: null,
        userName: "",
        targetDeptId: null,
        role: "",
        empolyed: "",
    },
});

const handleTransfer = (row) => {
    transferDialog.form = {
        uid: row.uid || null,
        userName: row.name || "",
        targetDeptId: null,
        role: row.role || "",
        empolyed: row.employed || "",
    };
    transferDialog.visible = true;
};

const submitTransfer = async () => {
    const targetDeptName = findDeptName(allDeptTree.value, transferDialog.form.targetDeptId);
    if (!targetDeptName) {
        ElMessage.error("请选择目标部门");
        return;
    }
    transferDialog.loading = true;
    try {
        const submitData = {
            uid: transferDialog.form.uid,
            role: transferDialog.form.role,
            deptName: targetDeptName,
            bio: "",
            joinDate: "",
        };
        const res = await request.post("/user/updateInfo", submitData);
        if (res.code === "200") {
            ElMessage.success("调岗成功");
            transferDialog.visible = false;
            loadMembers();
        } else {
            ElMessage.error(res.msg || "调岗失败");
        }
    } catch (error) {
        ElMessage.error("操作失败");
    } finally {
        transferDialog.loading = false;
    }
};

onMounted(() => {
    loadDeptDetail();
    loadDeptTree();
    loadMembers();
    loadAllUsers();
});
</script>

<style scoped>
.dept-detail {
    padding: 16px;
    background-color: #f5f7fa;
}

.detail-card {
    margin-bottom: 16px;
}

.card-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    flex-wrap: wrap;
    gap: 12px;
}

.card-header-left {
    display: flex;
    align-items: center;
    gap: 8px;
}

.card-header-right {
    display: flex;
    align-items: center;
}

.dept-title {
    font-size: 18px;
    font-weight: bold;
}
</style>
