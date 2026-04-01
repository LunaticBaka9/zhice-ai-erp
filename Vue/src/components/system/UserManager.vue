<template>
  <div class="user-management">
    <!-- 页面标题 -->
    <!--    <div class="page-header">-->
    <!--      <h2 class="page-title">用户管理</h2>-->
    <!--    </div>-->

    <!-- 搜索栏 -->
    <el-card class="search-card" shadow="never">
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="用户名">
          <el-input
            v-model="searchForm.username"
            placeholder="请输入用户名"
            clearable
            @clear="handleSearch"
            @keyup.enter="handleSearch"
          />
        </el-form-item>
        <el-form-item label="姓名">
          <el-input
            v-model="searchForm.name"
            placeholder="请输入姓名"
            clearable
            @clear="handleSearch"
            @keyup.enter="handleSearch"
          />
        </el-form-item>
        <el-form-item label="手机号">
          <el-input
            v-model="searchForm.phone"
            placeholder="请输入手机号"
            clearable
            @clear="handleSearch"
            @keyup.enter="handleSearch"
          />
        </el-form-item>
        <el-form-item label="邮箱">
          <el-input
            v-model="searchForm.email"
            placeholder="请输入邮箱"
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

    <div class="card" style="margin-bottom: 10px">
      <el-button type="primary" @click="handleAdd">
        <el-icon><Plus /></el-icon>
        新增用户
      </el-button>
      <el-button type="primary" @click="exportData"> 导出表格 </el-button>
      <el-upload
        action="/api/user/importData"
        :on-success="handleImport"
        style="display: inline-block; margin-left: 10px"
        :show-file-list="false"
      >
        <el-button type="primary">导入表格</el-button>
      </el-upload>
    </div>

    <!-- 用户表格 -->
    <el-card class="table-card" shadow="never">
      <el-table
        :data="userList"
        v-loading="loading"
        stripe
        border
        style="width: 100%"
        :table-layout="fixed"
        @selection-change="handleSelectionChange"
      >
        <el-table-column type="selection" width="55" />
        <el-table-column prop="uid" label="ID" width="80" />
        <el-table-column prop="avatar" label="头像" width="80">
          <template #default="{ row }">
            <el-avatar :src="resolveAvatar(row.avatar)" :size="40" />
          </template>
        </el-table-column>
        <el-table-column prop="username" label="用户名" width="120" />
        <el-table-column prop="name" label="姓名" width="120" />
        <el-table-column prop="role" label="角色" width="120">
          <template #default="{ row }">
            <el-tag :type="getRoleType(row.role)" size="small">
              {{ row.role }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="department" label="部门" width="150" />
        <el-table-column prop="phone" label="手机号" width="130" />
        <el-table-column
          prop="email"
          label="邮箱"
          width="200"
          show-overflow-tooltip
        />
        <el-table-column
          prop="joinDate"
          label="入职时间"
          sortable
        />
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-switch
              v-model="row.status"
              active-value="启用"
              inactive-value="禁用"
              @change="handleStatusChange(row)"
            />
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button
              link
              type="primary"
              size="small"
              @click="handleView(row)"
            >
              <el-icon><View /></el-icon>
              查看
            </el-button>
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
            <el-button
              link
              type="primary"
              size="small"
              @click="handleResetPassword(row)"
            >
              <el-icon><Key /></el-icon>
              修改密码
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

    <!-- 新增/编辑用户对话框 -->
    <el-dialog
      v-model="dialog.visible"
      :title="dialog.title"
      width="600px"
      :close-on-click-modal="false"
      @close="handleDialogClose"
    >
      <el-form
        ref="userFormRef"
        :model="dialog.form"
        :rules="dialog.rules"
        label-width="100px"
        status-icon
      >
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="用户名" prop="username">
              <el-input
                v-model="dialog.form.username"
                placeholder="请输入用户名"
                :disabled="dialog.isView"
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="姓名" prop="name">
              <el-input
                v-model="dialog.form.name"
                placeholder="请输入姓名"
                :disabled="dialog.isView"
              />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="密码" prop="password" v-if="dialog.isAdd">
              <el-input
                v-model="dialog.form.password"
                type="password"
                placeholder="请输入密码"
                show-password
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item
              label="确认密码"
              prop="confirmPassword"
              v-if="dialog.isAdd"
            >
              <el-input
                v-model="dialog.form.confirmPassword"
                type="password"
                placeholder="请确认密码"
                show-password
              />
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item label="角色" prop="role">
          <el-select
            v-model="dialog.form.role"
            placeholder="请选择角色"
            style="width: 100%"
            :disabled="dialog.isView"
          >
            <el-option label="超级管理员" value="超级管理员" />
            <el-option label="高级管理员" value="高级管理员" />
            <el-option label="普通管理员" value="普通管理员" />
            <el-option label="开发工程师" value="开发工程师" />
            <el-option label="测试工程师" value="测试工程师" />
            <el-option label="产品经理" value="产品经理" />
          </el-select>
        </el-form-item>

        <el-form-item label="部门" prop="department">
          <el-cascader
            v-model="dialog.form.department"
            :options="departmentOptions"
            :props="{
              value: 'id',
              label: 'name',
              children: 'children',
              checkStrictly: true,
            }"
            placeholder="请选择部门"
            style="width: 100%"
            clearable
          />
        </el-form-item>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="手机号" prop="phone">
              <el-input
                v-model="dialog.form.phone"
                placeholder="请输入手机号"
                :disabled="dialog.isView"
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="邮箱" prop="email">
              <el-input
                v-model="dialog.form.email"
                placeholder="请输入邮箱"
                :disabled="dialog.isView"
              />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="入职时间" prop="joinDate">
              <el-date-picker
                v-model="dialog.form.joinDate"
                type="date"
                placeholder="选择入职时间"
                style="width: 100%"
                format="YYYY-MM-DD"
                value-format="YYYY-MM-DD"
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
                <el-option label="启用" value="启用" />
                <el-option label="禁用" value="禁用" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item label="个人简介" prop="bio">
          <el-input
            v-model="dialog.form.bio"
            type="textarea"
            placeholder="请输入个人简介"
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
            @click="submitUser"
            :loading="dialog.loading"
          >
            确认
          </el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 查看用户详情对话框 -->
    <el-dialog v-model="viewDialog.visible" title="用户详情" width="500px">
      <el-descriptions :column="1" border>
        <el-descriptions-item label="用户名">{{
          viewDialog.data.username
        }}</el-descriptions-item>
        <el-descriptions-item label="姓名">{{
          viewDialog.data.name
        }}</el-descriptions-item>
        <el-descriptions-item label="角色">{{
          viewDialog.data.role
        }}</el-descriptions-item>
        <el-descriptions-item label="部门">{{
          viewDialog.data.department
        }}</el-descriptions-item>
        <el-descriptions-item label="手机号">{{
          viewDialog.data.phone
        }}</el-descriptions-item>
        <el-descriptions-item label="邮箱">{{
          viewDialog.data.email
        }}</el-descriptions-item>
        <el-descriptions-item label="入职时间">{{
          viewDialog.data.joinDate
        }}</el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag
            :type="viewDialog.data.status === '启用' ? 'success' : 'danger'"
          >
            {{ viewDialog.data.status }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="个人简介">{{
          viewDialog.data.bio || "暂无"
        }}</el-descriptions-item>
        <el-descriptions-item label="创建时间">{{
          viewDialog.data.createTime
        }}</el-descriptions-item>
        <el-descriptions-item label="更新时间">{{
          viewDialog.data.updateTime
        }}</el-descriptions-item>
      </el-descriptions>
    </el-dialog>

    <!-- 修改密码对话框 -->
    <el-dialog
      v-model="resetPasswordDialog.visible"
      title="修改密码"
      width="400px"
    >
      <el-form
        ref="resetPasswordFormRef"
        :model="resetPasswordDialog.form"
        :rules="resetPasswordDialog.rules"
        label-width="100px"
      >
        <el-form-item label="新密码" prop="newPassword">
          <el-input
            v-model="resetPasswordDialog.form.newPassword"
            type="password"
            placeholder="请输入新密码"
            show-password
          />
        </el-form-item>
        <el-form-item label="确认密码" prop="confirmPassword">
          <el-input
            v-model="resetPasswordDialog.form.confirmPassword"
            type="password"
            placeholder="请确认新密码"
            show-password
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="resetPasswordDialog.visible = false"
            >取消</el-button
          >
          <el-button
            type="primary"
            @click="submitResetPassword"
            :loading="resetPasswordDialog.loading"
          >
            确认重置
          </el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import {
  Plus,
  Search,
  Refresh,
  View,
  Edit,
  Delete,
  Key,
} from "@element-plus/icons-vue";
import request from "../../utils/request";

// 默认头像
const defaultAvatar =
  "https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png";

// 解析头像 URL，支持空值、完整 URL、以 / 开头的绝对路径和相对路径
const resolveAvatar = (avatar) => {
  if (!avatar) return defaultAvatar;
  if (/^https?:\/\//.test(avatar)) return avatar;
  if (avatar.startsWith("/")) return avatar;
  try {
    // 相对路径，拼接当前站点 origin
    return new URL(avatar, window.location.origin).toString();
  } catch (e) {
    return defaultAvatar;
  }
};

// 搜索表单
const searchForm = reactive({
  username: "",
  name: "",
  phone: "",
  email: "",
  role: "",
});

// 用户列表数据
const userList = ref([]);
const loading = ref(false);

// 分页参数
const pagination = reactive({
  pageNum: 1,
  pageSize: 10,
  total: 0,
});

// 选中的行
const selectedRows = ref([]);

// 部门选项
const departmentOptions = ref([
  {
    id: "技术部",
    name: "技术部",
    children: [
      { id: "研发组", name: "研发组" },
      { id: "测试组", name: "测试组" },
      { id: "运维组", name: "运维组" },
    ],
  },
  {
    id: "产品部t",
    name: "产品部",
    children: [
      { id: "产品组", name: "产品组" },
      { id: "设计组", name: "设计组" },
      { id: "交互组", name: "交互组" },
    ],
  },
  {
    id: "市场部",
    name: "市场部",
    children: [
      { id: "运营组", name: "运营组" },
      { id: "销售组", name: "销售组" },
      { id: "公关组", name: "公关组" },
    ],
  },
  {
    id: "admin",
    name: "行政部",
    children: [
      { id: "admin-hr", name: "人力资源" },
      { id: "admin-finance", name: "财务组" },
      { id: "admin-office", name: "办公室" },
    ],
  },
]);

// 新增/编辑对话框
const userFormRef = ref();
const dialog = reactive({
  visible: false,
  title: "",
  isAdd: false,
  isView: false,
  loading: false,
  form: {
    id: null,
    avatar: "",
    username: "",
    name: "",
    password: "",
    confirmPassword: "",
    role: "",
    department: [],
    phone: "",
    email: "",
    joinDate: "",
    status: "启用",
    bio: "",
  },
  rules: {
    username: [
      { required: true, message: "请输入用户名", trigger: "blur" },
      { min: 3, max: 20, message: "长度在 3 到 20 个字符", trigger: "blur" },
    ],
    name: [
      { required: true, message: "请输入姓名", trigger: "blur" },
      { min: 2, max: 20, message: "长度在 2 到 20 个字符", trigger: "blur" },
    ],
    password: [
      { required: true, message: "请输入密码", trigger: "blur" },
      { min: 6, max: 20, message: "长度在 6 到 20 个字符", trigger: "blur" },
    ],
    confirmPassword: [
      { required: true, message: "请确认密码", trigger: "blur" },
      {
        validator: (rule, value, callback) => {
          if (value !== dialog.form.password) {
            callback(new Error("两次输入的密码不一致"));
          } else {
            callback();
          }
        },
        trigger: "blur",
      },
    ],
    role: [{ required: true, message: "请选择角色", trigger: "change" }],
    department: [{ required: true, message: "请选择部门", trigger: "change" }],
    phone: [
      { required: true, message: "请输入手机号", trigger: "blur" },
      {
        pattern: /^1[3-9]\d{9}$/,
        message: "请输入正确的手机号",
        trigger: "blur",
      },
    ],
    email: [
      { required: true, message: "请输入邮箱", trigger: "blur" },
      { type: "email", message: "请输入正确的邮箱地址", trigger: "blur" },
    ],
    joinDate: [
      { required: true, message: "请选择入职时间", trigger: "change" },
    ],
  },
});

// 查看详情对话框
const viewDialog = reactive({
  visible: false,
  data: {},
});

// 修改密码对话框
const resetPasswordFormRef = ref();
const resetPasswordDialog = reactive({
  visible: false,
  loading: false,
  userId: null,
  form: {
    newPassword: "",
    confirmPassword: "",
  },
  rules: {
    newPassword: [
      { required: true, message: "请输入新密码", trigger: "blur" },
      { min: 6, max: 20, message: "长度在 6 到 20 个字符", trigger: "blur" },
    ],
    confirmPassword: [
      { required: true, message: "请确认密码", trigger: "blur" },
      {
        validator: (rule, value, callback) => {
          if (value !== resetPasswordDialog.form.newPassword) {
            callback(new Error("两次输入的密码不一致"));
          } else {
            callback();
          }
        },
        trigger: "blur",
      },
    ],
  },
});

// 获取角色标签类型
const getRoleType = (role) => {
  const typeMap = {
    超级管理员: "danger",
    高级管理员: "warning",
    普通管理员: "info",
    开发工程师: "primary",
    测试工程师: "success",
    产品经理: "",
  };
  return typeMap[role] || "info";
};

// 获取用户列表
const getUserList = async () => {
  loading.value = true;
  try {
    const params = {
      pageNum: pagination.pageNum,
      pageSize: pagination.pageSize,
      ...searchForm,
    };
    const res = await request.get("/user/list", { params });
    if (res.code === "200") {
      userList.value = res.data.records || res.data.list || [];
      pagination.total = res.data.total || 0;
      console.log(res.data);
    } else {
      ElMessage.error(res.msg || "获取用户列表失败");
    }
  } catch (error) {
    ElMessage.error("获取用户列表失败");
  } finally {
    loading.value = false;
  }
};

// 搜索
const handleSearch = () => {
  pagination.pageNum = 1;
  getUserList();
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
  getUserList();
};

const handleCurrentChange = (val) => {
  pagination.pageNum = val;
  getUserList();
};

// 表格选择变化
const handleSelectionChange = (val) => {
  selectedRows.value = val;
};

// 新增用户
const handleAdd = () => {
  dialog.title = "新增用户";
  dialog.isAdd = true;
  dialog.isView = false;
  dialog.form = {
    id: null,
    avatar: "",
    username: "",
    name: "",
    password: "",
    confirmPassword: "",
    role: "",
    department: "",
    phone: "",
    email: "",
    joinDate: "",
    status: "启用",
    bio: "",
  };
  dialog.visible = true;
};

// 编辑用户
const handleEdit = (row) => {
  dialog.title = "编辑用户";
  dialog.isAdd = false;
  dialog.isView = false;
  const formData = { ...row };
  if (formData.department && typeof formData.department === "string") {
    formData.department = formData.department.split("/");
  } else if (!formData.department) {
    formData.department = [];
  }

  dialog.form = {
    ...row,
    password: "",
    confirmPassword: "",
  };
  dialog.visible = true;
};

// 查看用户
const handleView = (row) => {
  viewDialog.data = { ...row };
  viewDialog.visible = true;
};

// 提交用户
const submitUser = async () => {
  if (!userFormRef.value) return;

  await userFormRef.value.validate(async (valid) => {
    if (valid) {
      dialog.loading = true;
      try {
        const submitData = { ...dialog.form };

        if (submitData.department && Array.isArray(submitData.department)) {
          submitData.department = submitData.department.join("/");
        }

        if (dialog.isAdd) {
          delete submitData.confirmPassword;
          const res = await request.post("/user/add", submitData);
          if (res.code === "200") {
            ElMessage.success("新增用户成功");
            dialog.visible = false;
            getUserList();
          } else {
            ElMessage.error(res.msg || "新增用户失败");
          }
        } else {
          delete submitData.password;
          delete submitData.confirmPassword;
          const res = await request.post("/user/updateInfo", submitData);
          if (res.code === "200") {
            ElMessage.success("更新用户成功");
            dialog.visible = false;
            getUserList();
          } else {
            ElMessage.error(res.msg || "更新用户失败");
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
  ElMessageBox.confirm(`确定要删除用户"${row.name}"吗？`, "提示", {
    confirmButtonText: "确定",
    cancelButtonText: "取消",
    type: "warning",
  })
    .then(async () => {
      try {
        const res = await request.post(`/user/delete`, row);
        if (res.code === "200") {
          ElMessage.success("删除成功");
          getUserList();
        } else {
          ElMessage.error(res.msg || "删除失败");
        }
      } catch (error) {
        ElMessage.error("删除失败");
      }
    })
    .catch(() => {});
};

// // 修改状态
const handleStatusChange = async (row) => {
  try {
    const res = await request.post(`/user/updateStatus`, row);
    if (res.code !== "200") {
      ElMessage.error("状态修改失败");
      // 回滚状态
      row.status = row.status === "启用" ? "禁用" : "启用";
    }
  } catch (error) {
    ElMessage.error("状态修改失败");
    row.status = row.status === "启用" ? "禁用" : "启用";
  }
};

// 修改密码
const handleResetPassword = (row) => {
  resetPasswordDialog.userId = row.id;
  resetPasswordDialog.form = {
    newPassword: "",
    confirmPassword: "",
  };
  resetPasswordDialog.visible = true;
};

// 提交修改密码
const submitResetPassword = async () => {
  if (!resetPasswordFormRef.value) return;

  await resetPasswordFormRef.value.validate(async (valid) => {
    if (valid) {
      resetPasswordDialog.loading = true;
      try {
        const res = await request.post("/user/updatePassword", {
          uid: resetPasswordDialog.userId,
          newPassword: resetPasswordDialog.form.newPassword,
        });
        if (res.code === "200") {
          ElMessage.success("密码修改成功");
          resetPasswordDialog.visible = false;
        } else {
          ElMessage.error(res.msg || "密码修改成功");
        }
      } catch (error) {
        ElMessage.error("密码修改成功");
      } finally {
        resetPasswordDialog.loading = false;
      }
    }
  });
};

const handleImport = (res, file, filelist) => {
  if (res.code === "200") {
    ElMessage.success("数据导入成功");
  } else {
    ElMessage.error(res.msg);
  }
  getUserList();
};

// 关闭对话框
const handleDialogClose = () => {
  userFormRef.value?.clearValidate();
};

const exportData = async () => {
  window.open("http://localhost:8080/user/exportData");
};

// 页面加载时获取数据
onMounted(() => {
  getUserList();
});
</script>

<style scoped>
.user-management {
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
::v-deep .el-table__row {
  height: 60px;
}

/* 或者设置单元格内边距 */
::v-deep .el-table__body td {
  padding: 15px 0;
}

/* 或者设置单元格的高度 */
::v-deep .el-table td,
::v-deep .el-table th {
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
