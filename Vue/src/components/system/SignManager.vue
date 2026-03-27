<template>
  <div class="user-management">
    <!-- 页面标题 -->
    <!--    <div class="page-header">-->
    <!--      <h2 class="page-title">用户管理</h2>-->
    <!--    </div>-->

    <!-- 搜索栏 -->
    <el-card class="search-card" shadow="never" style="margin-bottom: 5px;">
        <el-form-item label="用户名">
          <el-input
              v-model="data.username"
              placeholder="请输入用户名"
              clearable
              @clear="load"
              @keyup.enter="load"
          />
        </el-form-item>
        <el-form-item label="姓名">
          <el-input
              v-model="data.name"
              placeholder="请输入姓名"
              clearable
              @clear="load"
              @keyup.enter="load"
          />
        </el-form-item>

        <el-form-item label="签到状态">
          <el-select
              v-model="data.signInStatus"
              placeholder="选择签到状态"
              clearable
              @clear="load"
          >
            <el-option label="准时" value="准时" />
            <el-option label="迟到" value="迟到" />
          </el-select>
        </el-form-item>

        <el-form-item label="签退状态">
          <el-select
              v-model="data.signOutStatus"
              placeholder="选择签退状态"
              clearable
              @clear="load"
          >
            <el-option label="准时" value="准时" />
            <el-option label="早退" value="早退" />
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
    </el-card>

    <!-- 签到信息表格 -->
    <el-card class="table-card" shadow="never">
      <el-table
          :data="data.tableData"
          stripe
          border
          style="width: 100%"
          @selection-change="handleSelectionChange"
      >
        <el-table-column type="selection" width="55" />
        <el-table-column prop="uid" label="ID" width="80" />
        <el-table-column prop="username" label="用户名" width="120" />
        <el-table-column prop="name" label="姓名" width="120" />
        <el-table-column prop="signInTime" label="签到时间" width="200" />
        <el-table-column prop="signOutTime" label="签退时间" width="200" />
        <el-table-column prop="signInStatus" label="签到状态" width="90"></el-table-column>
        <el-table-column prop="signOutStatus" label="签退状态" width="90"></el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="scope">
            <el-button link type="primary" size="small" @click="handleEdit(scope.row)">
              <el-icon><Edit /></el-icon>
              编辑
            </el-button>
            <el-button link type="danger" size="small" @click="handleDelete(scope.row)">
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
            :page-sizes="[5,10, 20, 50, 100]"
            :total="data.total"
            layout="total, sizes, prev, pager, next, jumper"
            @current-change="load"
            @size-change="load"
        />
      </div>
    </el-card>

<!--    修改表格 -->
    <el-dialog
        v-model="data.formVisible"
        title="修改签到"
        width="600px"
        :close-on-click-modal="false"
        @close="handleDialogClose"
    >
      <el-form ref="formRef" :model="data.form">
          <el-form-item label="签到时间" prop="sign_in_time" >
            <el-input v-model="data.form.signInTime" autocomplete="off" />
          </el-form-item>
          <el-form-item label="签到状态" prop="sign_in_status">
            <el-select v-model="data.form.signInStatus" placeholder="签到状态">
              <el-option label="准时" value="准时" />
              <el-option label="迟到" value="迟到" />
            </el-select>
          </el-form-item>
          <el-form-item label="签退时间" prop="sign_in_time">
            <el-input v-model="data.form.signOutTime" autocomplete="off" />
          </el-form-item>
          <el-form-item label="签退状态" prop="sign_out_status">
            <el-select v-model="data.form.signOutStatus" placeholder="签退状态">
              <el-option label="准时" value="准时" />
              <el-option label="早退" value="早退" />
            </el-select>
          </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="data.formVisible = false">取消</el-button>
          <el-button type="primary" @click="update">更新</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Plus, Search, Refresh, View, Edit, Delete, Key
} from '@element-plus/icons-vue'
import request from "../../utils/request"

const data = reactive({
  username:null,
  name:null,
  signInStatus:null,
  signOutStatus:null,
  pageNum:1,
  pageSize:10,
  total:6,
  tableData: [],
  formVisible: false,
  form: {},
  rows: [],
})

const formRef = ref();

const load = () =>{
  request.get("/sign/selectPage",{
    params:{
      pageNum:data.pageNum,
      pageSize:data.pageSize,
      username:data.username,
      name:data.name,
    },
  }).then(res=>{
    if(res.code === "200"){
      data.tableData = res.data.list;
      data.total = res.data.total;
      console.log(data)
    } else{
      ElMessage.error(res.msg)
    }
  })
}
load();

const resetSearch = () =>{
  data.username = null;
  data.name = null;
  data.signInStatus = null;
  data.signOutStatus = null;
  load();
}

// 编辑用户
const handleEdit = (row) => {
  data.form = JSON.parse(JSON.stringify(row));
  data.formVisible = true;
}

const handleSelectionChange = (row) => {
  data.rows = rows;
}

// // 修改状态
const update = (row) => {
  formRef.value.validate((valid) => {
    if (valid) {
      requset.post("/sign/update", data.form).then((res)=>{
        if(res.code === "200"){
          data.formVisible = false;
          ElMessage.success("修改成功");
          load();
        }
      })
    } else{
      ElMessage.error(res.msg)
    }
  });
}
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