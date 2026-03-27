<template>
  <!-- 主要内容区域 -->
  <el-main class="main-content">
    <div class="profile-container">
      <!-- 页面标题 -->
      <div class="page-header">
        <h2 class="page-title">个人主页</h2>
        <el-button type="primary" @click="handleEdit">编辑资料</el-button>
      </div>

      <!-- 主要内容区域：两列布局 -->
      <el-row :gutter="20">
        <!-- 左侧：用户信息卡片 + 统计卡片 -->
        <el-col :xs="24" :md="8">
          <!-- 用户信息卡片 -->
          <el-card class="profile-card" shadow="hover">
            <div class="user-info">
              <h3 class="user-name">{{ data.userInfo.name }}</h3>
              <p class="user-role">{{ data.userInfo.role }}</p>
              <p class="user-department">{{ data.userInfo.department }}</p>
              <div class="user-contact">
                <el-icon><Message /></el-icon>
                <span>{{ data.userInfo.email }}</span>
              </div>
              <div class="user-contact">
                <el-icon><Phone /></el-icon>
                <span>{{ data.userInfo.phone }}</span>
              </div>
            </div>
          </el-card>

          <!-- 统计卡片 -->
          <el-card class="stats-card" shadow="hover">
            <template #header>
              <div class="card-header">
                <span>数据统计</span>
              </div>
            </template>
            <div class="stats-grid">
              <div class="stat-item">
                <div class="stat-label">项目数</div>
                <div class="stat-value">{{ stats.projects }}</div>
              </div>
              <div class="stat-item">
                <div class="stat-label">任务数</div>
                <div class="stat-value">{{ stats.tasks }}</div>
              </div>
              <div class="stat-item">
                <div class="stat-label">团队成员</div>
                <div class="stat-value">{{ stats.team }}</div>
              </div>
              <div class="stat-item">
                <div class="stat-label">动态</div>
                <div class="stat-value">{{ stats.activities }}</div>
              </div>
            </div>
          </el-card>
        </el-col>

        <!-- 右侧：标签页内容 -->
        <el-col :xs="24" :md="16">
          <el-card class="tab-card" shadow="hover">
            <el-tabs v-model="activeTab">
              <!-- 最近活动 -->
              <el-tab-pane label="最近活动" name="activity">
                <div v-for="item in activities" :key="item.id" class="activity-item">
                  <el-tag :type="item.type" size="small" class="activity-tag">
                    {{ item.tag }}
                  </el-tag>
                  <div class="activity-content">
                    <p class="activity-title">{{ item.title }}</p>
                    <span class="activity-time">{{ item.time }}</span>
                  </div>
                </div>
              </el-tab-pane>

              <!-- 安全设置 -->
              <el-tab-pane label="安全设置" name="security">
                <div class="security-item">
                  <div class="security-info">
                    <h4>账户密码</h4>
                    <p>当前密码强度：强</p>
                  </div>
                  <el-button link type="primary" @click="openPasswordDialog">修改</el-button>
                </div>
                <el-divider />
                <div class="security-item">
                  <div class="security-info">
                    <h4>绑定手机</h4>
                    <p v-if="data.userInfo.phone" class="table-text-center">已绑定：{{ data.userInfo.phone }}</p>
                    <p v-else class="table-text-center">未绑定</p>
                  </div>
                  <el-button link type="primary" @click="openPhoneDialog">修改</el-button>
                </div>
                <el-divider />
                <div class="security-item">
                  <div class="security-info">
                    <h4>绑定邮箱</h4>
                    <p v-if="data.userInfo.email" class="table-text-center">已绑定：{{ data.userInfo.email }}</p>
                    <p v-else class="table-text-center">未绑定</p>
                  </div>
                  <el-button link type="primary" @click="openEmailDialog">修改</el-button>
                </div>
                <el-divider />
                <div class="security-item">
                  <div class="security-info">
                    <h4>两步验证</h4>
                    <p>未开启两步验证</p>
                  </div>
                  <el-button link type="primary" @click="handleEnable2FA">开启</el-button>
                </div>
              </el-tab-pane>

              <!-- 个人资料 -->
              <el-tab-pane label="个人资料" name="profile">
                <el-descriptions :column="1" border>
                  <el-descriptions-item label="姓名">{{ data.userInfo.name }}</el-descriptions-item>
                  <el-descriptions-item label="角色">{{ data.userInfo.role }}</el-descriptions-item>
                  <el-descriptions-item label="部门">{{ data.userInfo.department }}</el-descriptions-item>
                  <el-descriptions-item label="入职时间">{{ data.userInfo.joinDate }}</el-descriptions-item>
                  <el-descriptions-item label="个人简介">{{ data.userInfo.bio }}</el-descriptions-item>
                </el-descriptions>
              </el-tab-pane>
            </el-tabs>
          </el-card>
        </el-col>
      </el-row>
    </div>
  </el-main>

  <!-- 修改密码对话框 -->
  <el-dialog
      v-model="passwordDialog.visible"
      title="修改密码"
      width="400px"
      :close-on-click-modal="false"
  >
    <el-form
        ref="passwordFormRef"
        :model="passwordDialog.form"
        :rules="passwordDialog.rules"
        label-width="100px"
    >
      <el-form-item label="当前密码" prop="oldPassword">
        <el-input
            v-model="passwordDialog.form.oldPassword"
            type="password"
            placeholder="请输入当前密码"
            show-password
        />
      </el-form-item>
      <el-form-item label="新密码" prop="newPassword">
        <el-input
            v-model="passwordDialog.form.newPassword"
            type="password"
            placeholder="请输入新密码"
            show-password
        />
      </el-form-item>
      <el-form-item label="确认密码" prop="confirmPassword">
        <el-input
            v-model="passwordDialog.form.confirmPassword"
            type="password"
            placeholder="请再次输入新密码"
            show-password
        />
      </el-form-item>
    </el-form>
    <template #footer>
      <span class="dialog-footer">
        <el-button @click="passwordDialog.visible = false">取消</el-button>
        <el-button type="primary" @click="submitPassword" :loading="passwordDialog.loading">
          确认修改
        </el-button>
      </span>
    </template>
  </el-dialog>

  <!-- 修改手机对话框 -->
  <el-dialog
      v-model="phoneDialog.visible"
      title="修改手机"
      width="400px"
      :close-on-click-modal="false"
  >
    <el-form
        ref="phoneFormRef"
        :model="phoneDialog.form"
        :rules="phoneDialog.rules"
        label-width="100px"
    >
      <el-form-item label="当前手机" prop="oldPhone">
        <el-input
            v-model="phoneDialog.form.oldPhone"
            placeholder="请输入当前手机号"
            :disabled="true"
            :value="data.userInfo.phone"
        />
      </el-form-item>
      <el-form-item label="新手机号" prop="newPhone">
        <el-input
            v-model="phoneDialog.form.newPhone"
            placeholder="请输入新手机号"
        />
      </el-form-item>
      <el-form-item label="验证码" prop="code">
        <div class="code-input-wrapper">
          <el-input v-model="phoneDialog.form.code" placeholder="请输入验证码" />
          <el-button
              type="primary"
              :disabled="phoneDialog.codeSending || phoneDialog.countdown > 0"
              @click="sendPhoneCode"
          >
            {{ phoneDialog.countdown > 0 ? `${phoneDialog.countdown}秒后重试` : '获取验证码' }}
          </el-button>
        </div>
      </el-form-item>
    </el-form>
    <template #footer>
      <span class="dialog-footer">
        <el-button @click="phoneDialog.visible = false">取消</el-button>
        <el-button type="primary" @click="submitPhone" :loading="phoneDialog.loading">
          确认修改
        </el-button>
      </span>
    </template>
  </el-dialog>

  <!-- 修改邮箱对话框 -->
  <el-dialog
      v-model="emailDialog.visible"
      title="修改邮箱"
      width="400px"
      :close-on-click-modal="false"
  >
    <el-form
        ref="emailFormRef"
        :model="emailDialog.form"
        :rules="emailDialog.rules"
        label-width="100px"
    >
      <el-form-item label="当前邮箱" prop="oldEmail">
        <el-input
            v-model="emailDialog.form.oldEmail"
            placeholder="请输入当前邮箱"
            :disabled="true"
            :value="data.userInfo.email"
        />
      </el-form-item>
      <el-form-item label="新邮箱" prop="newEmail">
        <el-input
            v-model="emailDialog.form.newEmail"
            placeholder="请输入新邮箱"
        />
      </el-form-item>
      <el-form-item label="验证码" prop="code">
        <div class="code-input-wrapper">
          <el-input v-model="emailDialog.form.code" placeholder="请输入验证码" />
          <el-button
              type="primary"
              :disabled="emailDialog.codeSending || emailDialog.countdown > 0"
              @click="sendEmailCode"
          >
            {{ emailDialog.countdown > 0 ? `${emailDialog.countdown}秒后重试` : '获取验证码' }}
          </el-button>
        </div>
      </el-form-item>
    </el-form>
    <template #footer>
      <span class="dialog-footer">
        <el-button @click="emailDialog.visible = false">取消</el-button>
        <el-button type="primary" @click="submitEmail" :loading="emailDialog.loading">
          确认修改
        </el-button>
      </span>
    </template>
  </el-dialog>

  <!-- 编辑资料对话框 -->
  <el-dialog
      v-model="profileDialog.visible"
      title="编辑个人资料"
      width="500px"
      :close-on-click-modal="false"
      @close="handleProfileDialogClose"
  >
    <el-form
        ref="profileFormRef"
        :model="profileDialog.form"
        :rules="profileDialog.rules"
        label-width="100px"
        status-icon
    >
      <!--      <el-form-item label="头像" prop="avatar">-->
      <!--        <div class="avatar-uploader" @click="triggerAvatarUpload">-->
      <!--          <img v-if="profileDialog.form.avatar" :src="profileDialog.form.avatar" class="avatar" />-->
      <!--          <el-icon v-else class="avatar-uploader-icon"><Plus /></el-icon>-->
      <!--        </div>-->
      <!--        <input-->
      <!--            ref="avatarInputRef"-->
      <!--            type="file"-->
      <!--            accept="image/*"-->
      <!--            style="display: none"-->
      <!--            @change="handleAvatarChange"-->
      <!--        />-->
      <!--        <div class="avatar-tip">点击上传头像，支持jpg、png格式</div>-->
      <!--      </el-form-item>-->

      <el-form-item label="姓名" prop="name">
        <el-input
            v-model="profileDialog.form.name"
            placeholder="请输入姓名"
            maxlength="20"
            show-word-limit
        />
      </el-form-item>

      <el-form-item label="角色" prop="role">
        <el-select
            v-model="profileDialog.form.role"
            placeholder="请选择角色"
            style="width: 100%"
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
            v-model="profileDialog.form.department"
            :options="departmentOptions"
            :props="{
            value: 'id',
            label: 'name',
            children: 'children',
            checkStrictly: true
          }"
            placeholder="请选择部门"
            style="width: 100%"
            clearable
        />
      </el-form-item>

      <el-form-item label="入职时间" prop="joinDate">
        <el-date-picker
            v-model="profileDialog.form.joinDate"
            type="date"
            placeholder="选择入职时间"
            style="width: 100%"
            format="YYYY-MM-DD"
            value-format="YYYY-MM-DD"
        />
      </el-form-item>

      <el-form-item label="个人简介" prop="bio">
        <el-input
            v-model="profileDialog.form.bio"
            type="textarea"
            placeholder="请输入个人简介"
            :rows="4"
            maxlength="200"
            show-word-limit
        />
      </el-form-item>
    </el-form>

    <template #footer>
      <span class="dialog-footer">
        <el-button @click="profileDialog.visible = false">取消</el-button>
        <el-button type="primary" @click="submitProfile" :loading="profileDialog.loading">
          保存修改
        </el-button>
      </span>
    </template>
  </el-dialog>
</template>

<script setup>
import { ref, reactive, onBeforeMount } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Grid, Setting, User, Lock, Menu, Monitor, UserFilled, Document,
  Avatar, Fold, Expand, Bell, ArrowDown, SwitchButton, Message, Phone
} from '@element-plus/icons-vue'
import request from '../utils/request'

onBeforeMount(() => {
  const userStr = localStorage.getItem("local_user");
  if (userStr) {
    const user = JSON.parse(userStr);
    if (!user.uid) {
      location.href = "/login";
    }
  } else {
    location.href = "/login";
  }
});

const data = reactive({
  user: JSON.parse(localStorage.getItem("local_user")),
  userInfo:[]
})
console.log(data.user)

const load = () =>{
  request.get("user/selectById/" + data.user.uid).then((res)=>{
    if(res.code == "200"){
      data.userInfo = res.data;
    } else{
      ElMessage.error(res.msg);
    }
  })
}
load();

const logout = () => {
  localStorage.removeItem("local_user");
  location.href = "/login";
};

// 统计数据
const stats = reactive({
  projects: 12,
  tasks: 38,
  team: 8,
  activities: 156
})

// 当前激活的标签页
const activeTab = ref('security')

// 最近活动数据
const activities = ref([
  {
    id: 1,
    title: '完成了项目Alpha的代码审查',
    time: '10分钟前',
    tag: '更新',
    type: 'success'
  },
  {
    id: 2,
    title: '提交了用户管理模块的PR',
    time: '2小时前',
    tag: '提交',
    type: 'info'
  },
  {
    id: 3,
    title: '参加了产品需求评审会议',
    time: '昨天',
    tag: '会议',
    type: 'warning'
  },
  {
    id: 4,
    title: '修复了登录页面的样式问题',
    time: '昨天',
    tag: '修复',
    type: 'danger'
  }
])

// 表单引用
const passwordFormRef = ref()
const phoneFormRef = ref()
const emailFormRef = ref()

// 密码修改对话框
const passwordDialog = reactive({
  visible: false,
  loading: false,
  form: {
    oldPassword: '',
    newPassword: '',
    confirmPassword: ''
  },
  rules: {
    oldPassword: [
      { required: true, message: '请输入当前密码', trigger: 'blur' },
      { min: 6, max: 20, message: '密码长度在6-20个字符', trigger: 'blur' }
    ],
    newPassword: [
      { required: true, message: '请输入新密码', trigger: 'blur' },
      { min: 6, max: 20, message: '密码长度在6-20个字符', trigger: 'blur' },
      {
        validator: (rule, value, callback) => {
          if (value === passwordDialog.form.oldPassword) {
            callback(new Error('新密码不能与当前密码相同'))
          } else {
            callback()
          }
        },
        trigger: 'blur'
      }
    ],
    confirmPassword: [
      { required: true, message: '请确认新密码', trigger: 'blur' },
      {
        validator: (rule, value, callback) => {
          if (value !== passwordDialog.form.newPassword) {
            callback(new Error('两次输入的密码不一致'))
          } else {
            callback()
          }
        },
        trigger: 'blur'
      }
    ]
  }
})

// 手机修改对话框
const phoneDialog = reactive({
  visible: false,
  loading: false,
  codeSending: false,
  countdown: 0,
  form: {
    oldPhone: '',
    newPhone: '',
    code: ''
  },
  rules: {
    newPhone: [
      { required: true, message: '请输入新手机号', trigger: 'blur' },
      { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' }
    ],
    code: [
      { required: true, message: '请输入验证码', trigger: 'blur' },
      { len: 6, message: '验证码长度为6位', trigger: 'blur' }
    ]
  }
})

// 邮箱修改对话框
const emailDialog = reactive({
  visible: false,
  loading: false,
  codeSending: false,
  countdown: 0,
  form: {
    oldEmail: '',
    newEmail: '',
    code: ''
  },
  rules: {
    newEmail: [
      { required: true, message: '请输入新邮箱', trigger: 'blur' },
      { type: 'email', message: '请输入正确的邮箱地址', trigger: 'blur' }
    ],
    code: [
      { required: true, message: '请输入验证码', trigger: 'blur' },
      { len: 6, message: '验证码长度为6位', trigger: 'blur' }
    ]
  }
})

// 切换侧边栏折叠
const toggleCollapse = () => {
  isCollapse.value = !isCollapse.value
}

// 处理下拉菜单命令
const handleCommand = (command) => {
  switch (command) {
    case 'profile':
      ElMessage.success('跳转到个人中心')
      break
    case 'settings':
      ElMessage.success('跳转到系统设置')
      break
    case 'logout':
      handleLogout()
      break
  }
}

// 退出登录
const handleLogout = () => {
  ElMessageBox.confirm('确认退出登录吗？', '提示', {
    confirmButtonText: '确认',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    logout()
  }).catch(() => {})
}

// 打开修改密码对话框
const openPasswordDialog = () => {
  passwordDialog.form = {
    oldPassword: '',
    newPassword: '',
    confirmPassword: ''
  }
  passwordDialog.visible = true
}

// 打开修改手机对话框
const openPhoneDialog = () => {
  phoneDialog.form = {
    oldPhone: data.userInfo.phone,
    newPhone: '',
    code: ''
  }
  phoneDialog.visible = true
}

// 打开修改邮箱对话框
const openEmailDialog = () => {
  emailDialog.form = {
    oldEmail: data.userInfo.email,
    newEmail: '',
    code: ''
  }
  emailDialog.visible = true
}

// 发送手机验证码
const sendPhoneCode = async () => {
  if (!phoneDialog.form.newPhone) {
    ElMessage.warning('请先输入新手机号')
    return
  }

  if (!/^1[3-9]\d{9}$/.test(phoneDialog.form.newPhone)) {
    ElMessage.warning('请输入正确的手机号')
    return
  }

  phoneDialog.codeSending = true
  try {
    // 这里调用发送验证码的API
    await request.post('/api/send-phone-code', {
      phone: phoneDialog.form.newPhone,
      type: 'change_phone'
    })
    ElMessage.success('验证码已发送')

    // 开始倒计时
    phoneDialog.countdown = 60
    const timer = setInterval(() => {
      if (phoneDialog.countdown > 0) {
        phoneDialog.countdown--
      } else {
        clearInterval(timer)
      }
    }, 1000)
  } catch (error) {
    ElMessage.error('验证码发送失败')
  } finally {
    phoneDialog.codeSending = false
  }
}

// 发送邮箱验证码
const sendEmailCode = async () => {
  if (!emailDialog.form.newEmail) {
    ElMessage.warning('请先输入新邮箱')
    return
  }

  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  if (!emailRegex.test(emailDialog.form.newEmail)) {
    ElMessage.warning('请输入正确的邮箱地址')
    return
  }

  emailDialog.codeSending = true
  try {
    // 这里调用发送验证码的API
    await request.post('/user/send-email-code', {
      email: emailDialog.form.newEmail,
      type: 'change_email'
    })
    ElMessage.success('验证码已发送，验证码为 12345')

    // 开始倒计时
    emailDialog.countdown = 60
    const timer = setInterval(() => {
      if (emailDialog.countdown > 0) {
        emailDialog.countdown--
      } else {
        clearInterval(timer)
      }
    }, 1000)
  } catch (error) {
    ElMessage.error('验证码发送失败')
  } finally {
    emailDialog.codeSending = false
  }
}

// 提交修改密码
const submitPassword = async () => {
  if (!passwordFormRef.value) return

  await passwordFormRef.value.validate(async (valid) => {
    if (valid) {
      passwordDialog.loading = true
      try {
        // 这里调用修改密码的API
        await request.post('/user/updatePassword', {
          userId: data.user.uid,
          oldPassword: passwordDialog.form.oldPassword,
          newPassword: passwordDialog.form.newPassword
        })
        ElMessage.success('密码修改成功')
        passwordDialog.visible = false
      } catch (error) {
        ElMessage.error('密码修改失败')
      } finally {
        passwordDialog.loading = false
      }
    }
  })
}

// 提交修改手机
const submitPhone = async () => {
  if (!phoneFormRef.value) return

  await phoneFormRef.value.validate(async (valid) => {
    if (valid) {
      phoneDialog.loading = true
      try {
        // 这里调用修改手机的API
        await request.post('/api/change-phone', {
          userId: data.user.uid,
          newPhone: phoneDialog.form.newPhone,
          code: phoneDialog.form.code
        })

        // 更新本地用户信息
        data.userInfo.phone = phoneDialog.form.newPhone
        ElMessage.success('手机号修改成功')
        phoneDialog.visible = false
      } catch (error) {
        ElMessage.error('手机号修改失败')
      } finally {
        phoneDialog.loading = false
      }
    }
  })
}

// 提交修改邮箱
const submitEmail = async () => {
  if (!emailFormRef.value) return

  await emailFormRef.value.validate(async (valid) => {
    if (valid) {
      emailDialog.loading = true
      try {
        // 这里调用修改邮箱的API
        await request.post('/user/changeEmail', {
          userId: data.user.uid,
          newEmail: emailDialog.form.newEmail,
          code: emailDialog.form.code
        })

        // 更新本地用户信息
        data.userInfo.email = emailDialog.form.newEmail
        ElMessage.success('邮箱修改成功')
        emailDialog.visible = false
      } catch (error) {
        ElMessage.error('邮箱修改失败')
      } finally {
        emailDialog.loading = false
      }
    }
  })
}

// 在 data 对象后面添加部门选项数据
const departmentOptions = ref([
  {
    id: '技术部',
    name: '技术部',
    children: [
      { id: '研发组', name: '研发组' },
      { id: '测试组', name: '测试组' },
      { id: '运维组', name: '运维组' }
    ]
  },
  {
    id: '产品部t',
    name: '产品部',
    children: [
      { id: '产品组', name: '产品组' },
      { id: '设计组', name: '设计组' },
      { id: '交互组', name: '交互组' }
    ]
  },
  {
    id: '市场部',
    name: '市场部',
    children: [
      { id: '运营组', name: '运营组' },
      { id: '销售组', name: '销售组' },
      { id: '公关组', name: '公关组' }
    ]
  },
  {
    id: '行政部',
    name: '行政部',
    children: [
      { id: '人力资源', name: '人力资源' },
      { id: '财务组', name: '财务组' },
      { id: '办公室', name: '办公室' }
    ]
  }
])

// 编辑资料对话框
const profileDialog = reactive({
  visible: false,
  loading: false,
  form: {
    avatar: '',
    name: '',
    role: '',
    department: [],
    email: '',
    phone: '',
    joinDate: '',
    bio: ''
  },
  rules: {
    name: [
      { required: true, message: '请输入姓名', trigger: 'blur' },
      { min: 2, max: 20, message: '长度在 2 到 20 个字符', trigger: 'blur' }
    ],
    role: [
      { required: true, message: '请选择角色', trigger: 'change' }
    ],
    department: [
      { required: true, message: '请选择部门', trigger: 'change' }
    ],
    email: [
      { required: true, message: '请输入邮箱', trigger: 'blur' },
      { type: 'email', message: '请输入正确的邮箱地址', trigger: 'blur' }
    ],
    phone: [
      { required: true, message: '请输入手机号', trigger: 'blur' },
      { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' }
    ],
    joinDate: [
      { required: true, message: '请选择入职时间', trigger: 'change' }
    ],
    bio: [
      { max: 200, message: '个人简介不能超过200个字符', trigger: 'blur' }
    ]
  }
})

// 表单引用
const profileFormRef = ref()
const avatarInputRef = ref()

// 打开编辑资料对话框
const handleEdit = () => {
  // 将当前用户信息填充到表单
  profileDialog.form = {
    // avatar: data.userInfo.avatar || 'https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png',
    name: data.userInfo.name || '',
    role: data.userInfo.role || '',
    department: data.userInfo.department ? [data.userInfo.department] : [],
    email: data.userInfo.email || '',
    phone: data.userInfo.phone || '',
    joinDate: data.userInfo.joinDate || '',
    bio: data.userInfo.bio || ''
  }
  profileDialog.visible = true
}

// 关闭对话框时的处理
const handleProfileDialogClose = () => {
  profileFormRef.value?.clearValidate()
}

// 触发头像上传
const triggerAvatarUpload = () => {
  avatarInputRef.value?.click()
}

// 处理头像变更
const handleAvatarChange = (event) => {
  const file = event.target.files[0]
  if (!file) return

  // 验证文件类型
  const isImage = file.type.startsWith('image/')
  const isLt2M = file.size / 1024 / 1024 < 2

  if (!isImage) {
    ElMessage.error('只能上传图片文件！')
    return
  }
  if (!isLt2M) {
    ElMessage.error('图片大小不能超过 2MB！')
    return
  }

  // 创建FormData对象
  const formData = new FormData()
  formData.append('file', file)
  formData.append('userId', data.user.uid)

  // 显示上传中状态
  const loading = ElMessage.loading('正在上传头像...')

  // 上传头像到服务器
  request.post('/api/upload-avatar', formData, {
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  }).then(res => {
    if (res.code === '200') {
      // 更新预览图
      const reader = new FileReader()
      reader.onload = (e) => {
        profileDialog.form.avatar = e.target.result
      }
      reader.readAsDataURL(file)

      ElMessage.success('头像上传成功')
    } else {
      ElMessage.error(res.msg || '头像上传失败')
    }
  }).catch(error => {
    ElMessage.error('头像上传失败')
  }).finally(() => {
    loading.close()
    // 清空input，允许重新选择同一文件
    event.target.value = ''
  })
}

// 提交编辑资料
const submitProfile = async () => {
  if (!profileFormRef.value) return

  await profileFormRef.value.validate(async (valid) => {
    if (valid) {
      profileDialog.loading = true

      // 准备提交的数据
      const submitData = {
        uid: data.user.uid,
        // avatar: profileDialog.form.avatar,
        name: profileDialog.form.name,
        role: profileDialog.form.role,
        department: Array.isArray(profileDialog.form.department)
            ? profileDialog.form.department[profileDialog.form.department.length - 1]
            : profileDialog.form.department,
        email: profileDialog.form.email,
        phone: profileDialog.form.phone,
        joinDate: profileDialog.form.joinDate,
        bio: profileDialog.form.bio
      }

      try {
        // 调用更新用户信息的API
        const res = await request.post('/user/updateInfo', submitData)
        if (res.code === '200') {
          ElMessage.success('资料更新成功')

          // 更新本地用户信息
          data.userInfo = {
            ...data.userInfo,
            ...submitData,
            department: submitData.department
          }

          profileDialog.visible = false
        } else {
          ElMessage.error(res.msg || '更新失败')
        }
      } catch (error) {
        ElMessage.error('更新失败，请稍后重试')
      } finally {
        profileDialog.loading = false
      }
    }
  })
}

const handleEnable2FA = () => {
  ElMessage.success('两步验证功能开发中')
}
</script>

<style scoped>
/* 原有样式保持不变，添加以下新样式 */

.code-input-wrapper {
  display: flex;
  gap: 8px;
}

.code-input-wrapper .el-input {
  flex: 1;
}

.code-input-wrapper .el-button {
  width: 120px;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

/* 其他样式保持不变 */
.layout-container {
  height: 100vh;
  width: 100vw;
  overflow: hidden;
}

/* 侧边栏样式 */
.aside {
  background-color: #304156;
  transition: width 0.3s ease;
  overflow: hidden;
  height: 100vh;
}

.logo-container {
  height: 60px;
  display: flex;
  align-items: center;
  padding: 0 16px;
  background-color: #1f2d3d;
  overflow: hidden;
  white-space: nowrap;
}

.logo {
  width: 32px;
  height: 32px;
  margin-right: 8px;
  flex-shrink: 0;
}

.logo-text {
  color: #fff;
  font-size: 16px;
  font-weight: 600;
  transition: opacity 0.3s ease;
}

.aside-menu {
  border-right: none;
  height: calc(100vh - 60px);
  overflow-y: auto;
  overflow-x: hidden;
}

.aside-menu:not(.el-menu--collapse) {
  width: 240px;
}

.aside-menu.el-menu--collapse {
  width: 64px;
}

.aside-menu .el-menu-item,
.aside-menu .el-sub-menu__title {
  white-space: nowrap;
}

/* 主容器样式 */
.main-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
  overflow: hidden;
}

/* Header样式 */
.header {
  background-color: #fff;
  border-bottom: 1px solid #e6e9f0;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 20px;
  height: 60px;
  flex-shrink: 0;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 16px;
}

.collapse-icon {
  font-size: 20px;
  cursor: pointer;
  color: #606266;
  transition: color 0.3s;
}

.collapse-icon:hover {
  color: #409eff;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 24px;
}

.notification-badge {
  cursor: pointer;
}

.header-icon {
  font-size: 20px;
  color: #606266;
  transition: color 0.3s;
}

.header-icon:hover {
  color: #409eff;
}

.user-dropdown {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  padding: 4px 8px;
  border-radius: 4px;
  transition: background-color 0.3s;
}

.user-dropdown:hover {
  background-color: #f5f7fa;
}

.username {
  color: #303133;
  font-size: 14px;
}

.arrow-down {
  font-size: 14px;
  color: #909399;
}

/* 主要内容区域样式 */
.main-content {
  background-color: #f5f7fa;
  padding: 0;
  overflow-y: auto;
  height: calc(100vh - 20px);
}

.profile-container {
  padding: 24px;
  max-width: 1400px;
  margin: 0 auto;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.page-title {
  margin: 0;
  font-size: 24px;
  font-weight: 500;
  color: #303133;
}

/* 左侧卡片样式 */
.profile-card,
.stats-card {
  margin-bottom: 20px;
}

.user-info {
  text-align: center;
  padding: 16px 0;
}

.user-avatar {
  margin-bottom: 16px;
  border: 4px solid #fff;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.user-name {
  margin: 8px 0 4px;
  font-size: 20px;
  font-weight: 500;
  color: #303133;
}

.user-role {
  margin: 4px 0;
  color: #409eff;
  font-size: 14px;
}

.user-department {
  margin: 4px 0 12px;
  color: #909399;
  font-size: 14px;
}

.user-contact {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  margin: 8px 0;
  color: #606266;
  font-size: 14px;
}

/* 统计卡片 */
.card-header {
  font-weight: 500;
  color: #303133;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px;
}

.stat-item {
  text-align: center;
  padding: 12px;
  background-color: #f5f7fa;
  border-radius: 8px;
}

.stat-label {
  color: #909399;
  font-size: 14px;
  margin-bottom: 4px;
}

.stat-value {
  color: #303133;
  font-size: 20px;
  font-weight: 600;
}

/* 右侧标签页内容 */
.tab-card {
  height: 100%;
}

.activity-item {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  padding: 16px 0;
  border-bottom: 1px solid #ebeef5;
}

.activity-item:last-child {
  border-bottom: none;
}

.activity-tag {
  min-width: 60px;
  text-align: center;
}

.activity-content {
  flex: 1;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.activity-title {
  margin: 0;
  color: #303133;
  font-size: 14px;
}

.activity-time {
  color: #909399;
  font-size: 12px;
}

/* 安全设置项 */
.security-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 0;
}

.security-info h4 {
  margin: 0 0 4px;
  font-size: 16px;
  font-weight: 500;
  color: #303133;
}

.security-info p {
  margin: 0;
  color: #909399;
  font-size: 14px;
}

/* 响应式调整 */
@media (max-width: 768px) {
  .profile-container {
    padding: 16px;
  }

  .activity-content {
    flex-direction: column;
    align-items: flex-start;
    gap: 4px;
  }

  .username {
    display: none;
  }

  .code-input-wrapper {
    flex-direction: column;
  }

  .code-input-wrapper .el-button {
    width: 100%;
  }
}

/* 滚动条样式 */
.aside-menu::-webkit-scrollbar {
  width: 6px;
}

.aside-menu::-webkit-scrollbar-thumb {
  background-color: #263445;
  border-radius: 3px;
}

.aside-menu::-webkit-scrollbar-track {
  background-color: #1f2d3d;
}

.main-content::-webkit-scrollbar {
  width: 8px;
  height: 8px;
}

.main-content::-webkit-scrollbar-thumb {
  background-color: #c0c4cc;
  border-radius: 4px;
}

.main-content::-webkit-scrollbar-track {
  background-color: #f5f7fa;
}

/* 头像上传样式 */
.avatar-uploader {
  width: 100px;
  height: 100px;
  border: 1px dashed #d9d9d9;
  border-radius: 6px;
  cursor: pointer;
  position: relative;
  overflow: hidden;
  transition: border-color 0.3s;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 8px;
}

.avatar-uploader:hover {
  border-color: #409eff;
}

.avatar-uploader-icon {
  font-size: 28px;
  color: #8c939d;
  width: 100px;
  height: 100px;
  text-align: center;
  line-height: 100px;
}

.avatar {
  width: 100%;
  height: 100%;
  display: block;
  object-fit: cover;
}

.avatar-tip {
  color: #909399;
  font-size: 12px;
  line-height: 1.5;
}

/* 对话框样式优化 */
:deep(.el-dialog__body) {
  padding-top: 20px;
  padding-bottom: 10px;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

/* 表单样式优化 */
:deep(.el-form-item:last-child) {
  margin-bottom: 0;
}

/* 输入框后缀按钮样式 */
:deep(.el-input-group__append) {
  background-color: transparent;
  padding: 0 10px;
}

:deep(.el-input-group__append .el-button) {
  padding: 0;
}

/* 响应式调整 */
@media (max-width: 768px) {
  :deep(.el-dialog) {
    width: 90% !important;
    margin-top: 10vh !important;
  }

  .avatar-uploader {
    width: 80px;
    height: 80px;
  }

  .avatar-uploader-icon {
    width: 80px;
    height: 80px;
    line-height: 80px;
    font-size: 24px;
  }
}
</style>