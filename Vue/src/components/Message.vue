<template>
  <div class="erp-message-center">
    <!-- 头部操作栏 - ERP风格 -->
    <div class="message-header">
      <div class="header-left">
        <div class="title-section">
          <span class="title">消息中心</span>
          <span class="subtitle">企业通知 · 待办提醒 · 审批动态</span>
        </div>
        <div class="stats-section">
          <div class="stat-item">
            <span class="stat-label">未读</span>
            <span class="stat-value danger">{{ unreadCount }}</span>
          </div>
          <div class="stat-item">
            <span class="stat-label">待审批</span>
            <span class="stat-value warning">{{ pendingApprovalCount }}</span>
          </div>
          <div class="stat-item">
            <span class="stat-label">总消息</span>
            <span class="stat-value">{{ messageList.length }}</span>
          </div>
        </div>
      </div>
      <div class="header-right">
        <el-dropdown
          trigger="click"
          @command="handleBatchCommand"
          :disabled="selectedMessages.length === 0"
        >
          <el-button type="default">
            批量操作 <el-icon><ArrowDown /></el-icon>
          </el-button>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item command="markRead"
                >批量标记已读</el-dropdown-item
              >
              <el-dropdown-item command="delete" divided
                >批量删除</el-dropdown-item
              >
            </el-dropdown-menu>
          </template>
        </el-dropdown>
        <el-button
          type="primary"
          plain
          @click="markAllAsRead"
          :disabled="unreadCount === 0"
        >
          <el-icon><Check /></el-icon>
          全部已读
        </el-button>
        <el-button
          type="danger"
          plain
          @click="clearAllMessages"
          :disabled="messageList.length === 0"
        >
          <el-icon><Delete /></el-icon>
          清空消息
        </el-button>
      </div>
    </div>

    <!-- 高级筛选栏 -->
    <div class="filter-bar">
      <el-input
        v-model="searchKeyword"
        placeholder="搜索消息标题或内容"
        prefix-icon="Search"
        clearable
        size="default"
        class="search-input"
      />
      <el-select
        v-model="filterType"
        placeholder="消息类型"
        clearable
        size="default"
        class="filter-select"
      >
        <el-option label="系统通知" value="system" />
        <el-option label="审批消息" value="approval" />
        <el-option label="待办提醒" value="todo" />
        <el-option label="财务通知" value="finance" />
        <el-option label="人事通知" value="hr" />
      </el-select>
      <el-select
        v-model="filterPriority"
        placeholder="优先级"
        clearable
        size="default"
        class="filter-select"
      >
        <el-option label="高优先级" value="high">
          <span class="priority-high">🔴 高优先级</span>
        </el-option>
        <el-option label="中优先级" value="medium">
          <span class="priority-medium">🟡 中优先级</span>
        </el-option>
        <el-option label="低优先级" value="low">
          <span class="priority-low">🟢 低优先级</span>
        </el-option>
      </el-select>
      <el-date-picker
        v-model="dateRange"
        type="daterange"
        range-separator="至"
        start-placeholder="开始日期"
        end-placeholder="结束日期"
        size="default"
        class="date-picker"
      />
      <el-button type="primary" @click="handleSearch" :icon="Search"
        >查询</el-button
      >
      <el-button @click="resetFilters">重置</el-button>
    </div>

    <!-- 左右分栏布局：左侧消息列表，右侧详情 -->
    <div class="message-layout">
      <!-- 左侧消息列表 -->
      <div
        class="message-list-panel"
        :class="{ collapsed: !showDetailPanel && isMobile }"
      >
        <div class="list-header">
          <span class="list-title">消息列表</span>
          <span class="list-count">共 {{ filteredMessages.length }} 条</span>
        </div>
        <div class="message-list" v-loading="loading">
          <template v-if="filteredMessages.length > 0">
            <div
              v-for="message in paginatedMessages"
              :key="message.id"
              class="message-item"
              :class="{
                'message-read': message.isRead,
                'message-high': message.priority === 'high',
                'message-selected': selectedMessage?.id === message.id,
                'message-unread': !message.isRead,
              }"
              @click="handleMessageClick(message)"
            >
              <div class="message-select" @click.stop>
                <el-checkbox
                  :model-value="selectedMessages.includes(message.id)"
                  @change="toggleSelect(message.id)"
                />
              </div>
              <div class="message-icon" :class="`icon-${message.type}`">
                <el-icon :size="20">
                  <component :is="getIconComponent(message.type)" />
                </el-icon>
                <span v-if="message.priority === 'high'" class="priority-badge"
                  >!</span
                >
              </div>
              <div class="message-info">
                <div class="message-title">
                  <span class="title-text">{{ message.title }}</span>
                  <el-tag
                    :type="getTagType(message.type)"
                    size="small"
                    effect="light"
                    class="message-type-tag"
                  >
                    {{ getTypeLabel(message.type) }}
                  </el-tag>
                  <span v-if="!message.isRead" class="unread-dot"></span>
                  <span v-if="message.needAction" class="action-badge"
                    >待处理</span
                  >
                </div>
                <div class="message-summary">{{ message.summary }}</div>
                <div class="message-meta">
                  <span class="message-sender">{{
                    message.sender || "系统管理员"
                  }}</span>
                  <span class="message-time">{{
                    formatTime(message.time)
                  }}</span>
                  <span
                    v-if="message.deadline"
                    class="message-deadline"
                    :class="{
                      'deadline-urgent': isDeadlineUrgent(message.deadline),
                    }"
                  >
                    <el-icon><Clock /></el-icon>
                    截止: {{ formatDate(message.deadline) }}
                  </span>
                </div>
              </div>
              <div class="message-actions" @click.stop>
                <el-tooltip
                  content="标记已读"
                  placement="top"
                  v-if="!message.isRead"
                >
                  <el-button
                    type="primary"
                    :icon="Check"
                    circle
                    size="small"
                    @click.stop="markAsRead(message)"
                  />
                </el-tooltip>
                <el-tooltip
                  v-if="message.type === 'approval' && !message.isProcessed"
                  content="去审批"
                  placement="top"
                >
                  <el-button
                    type="warning"
                    :icon="Edit"
                    circle
                    size="small"
                    @click.stop="handleApproval(message)"
                  />
                </el-tooltip>
                <el-tooltip content="删除" placement="top">
                  <el-button
                    type="danger"
                    :icon="Delete"
                    circle
                    size="small"
                    @click.stop="deleteMessage(message)"
                  />
                </el-tooltip>
              </div>
            </div>
          </template>
          <el-empty v-else description="暂无消息" :image-size="100" />
        </div>

        <!-- 分页组件 -->
        <div class="pagination-wrapper" v-if="filteredMessages.length > 0">
          <el-pagination
            v-model:current-page="currentPage"
            v-model:page-size="pageSize"
            :page-sizes="[10, 20, 50]"
            :total="filteredMessages.length"
            layout="total, prev, pager, next"
            small
            @size-change="handleSizeChange"
            @current-change="handleCurrentChange"
          />
        </div>
      </div>

      <!-- 右侧详情面板 -->
      <div
        class="detail-panel"
        :class="{ show: showDetailPanel, 'mobile-detail': isMobile }"
      >
        <div class="detail-header">
          <div class="detail-header-left">
            <el-button
              v-if="isMobile && showDetailPanel"
              :icon="ArrowLeft"
              text
              @click="closeDetailPanel"
              class="back-btn"
            >
              返回列表
            </el-button>
            <span class="detail-title">消息详情</span>
          </div>
          <div class="detail-actions" v-if="selectedMessage">
            <el-tooltip
              content="标记已读"
              placement="top"
              v-if="!selectedMessage.isRead"
            >
              <el-button
                :icon="Check"
                circle
                size="small"
                @click="markAsRead(selectedMessage)"
              />
            </el-tooltip>
            <el-tooltip content="删除" placement="top">
              <el-button
                :icon="Delete"
                circle
                size="small"
                type="danger"
                @click="deleteMessage(selectedMessage)"
              />
            </el-tooltip>
          </div>
        </div>
        <div class="detail-content" v-if="selectedMessage">
          <div class="detail-meta">
            <div class="detail-tags">
              <el-tag :type="getTagType(selectedMessage.type)" size="small">
                {{ getTypeLabel(selectedMessage.type) }}
              </el-tag>
              <el-tag
                v-if="selectedMessage.priority === 'high'"
                type="danger"
                size="small"
                effect="dark"
              >
                高优先级
              </el-tag>
              <el-tag
                v-if="selectedMessage.needAction"
                type="warning"
                size="small"
              >
                需处理
              </el-tag>
              <el-tag
                v-if="!selectedMessage.isRead"
                type="info"
                size="small"
                effect="plain"
              >
                未读
              </el-tag>
            </div>
            <div class="detail-time">
              <el-icon><Clock /></el-icon>
              {{ formatDateTime(selectedMessage.time) }}
            </div>
          </div>

          <h3 class="detail-title-text">{{ selectedMessage.title }}</h3>

          <div class="detail-info">
            <div class="info-row">
              <span class="info-label">发送方：</span>
              <span class="info-value">{{
                selectedMessage.sender || "系统管理员"
              }}</span>
            </div>
            <div class="info-row" v-if="selectedMessage.deadline">
              <span class="info-label">截止时间：</span>
              <span
                class="info-value"
                :class="{
                  'deadline-urgent-text': isDeadlineUrgent(
                    selectedMessage.deadline,
                  ),
                }"
              >
                {{ formatDateTime(selectedMessage.deadline) }}
              </span>
            </div>
            <div class="info-row" v-if="selectedMessage.relatedId">
              <span class="info-label">关联单号：</span>
              <span
                class="info-value link"
                @click="viewRelatedDoc(selectedMessage.relatedId)"
              >
                {{ selectedMessage.relatedId }}
                <el-icon><TopRight /></el-icon>
              </span>
            </div>
          </div>

          <div class="detail-body">
            <div class="body-label">消息内容</div>
            <div class="body-text">
              {{ selectedMessage.content || selectedMessage.summary }}
            </div>
          </div>

          <div
            v-if="
              selectedMessage.attachments && selectedMessage.attachments.length
            "
            class="detail-attachments"
          >
            <div class="attachments-title">
              <el-icon><Paperclip /></el-icon>
              附件 ({{ selectedMessage.attachments.length }})
            </div>
            <div class="attachments-list">
              <div
                v-for="(file, idx) in selectedMessage.attachments"
                :key="idx"
                class="attachment-item"
                @click="downloadAttachment(file)"
              >
                <el-icon><Document /></el-icon>
                <span class="file-name">{{ file.name }}</span>
                <span class="file-size">{{ file.size }}</span>
                <el-icon class="download-icon"><Download /></el-icon>
              </div>
            </div>
          </div>

          <div
            class="detail-footer-actions"
            v-if="
              selectedMessage.type === 'approval' &&
              !selectedMessage.isProcessed
            "
          >
            <el-button
              type="primary"
              size="large"
              @click="handleApprovalFromDetail"
              style="width: 100%"
            >
              <el-icon><Edit /></el-icon>
              去审批
            </el-button>
          </div>
        </div>
        <div class="detail-empty" v-else>
          <el-empty description="请选择一条消息查看详情" :image-size="120">
            <template #image>
              <el-icon :size="80" color="#c0c4cc"><Message /></el-icon>
            </template>
          </el-empty>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from "vue";
import {
  Bell,
  Setting,
  ChatDotRound,
  Present,
  Check,
  Delete,
  ArrowDown,
  Search,
  Clock,
  Edit,
  Paperclip,
  Document,
  Money,
  User,
  Tickets,
  ArrowLeft,
  TopRight,
  Download,
  Message,
} from "@element-plus/icons-vue";
import { ElMessage, ElMessageBox } from "element-plus";

// 模拟ERP系统消息数据
const generateMockMessages = () => {
  const now = new Date();
  const types = ["system", "approval", "todo", "finance", "hr"];
  const messages = [];

  const templates = {
    system: {
      title: [
        "系统维护通知",
        "安全策略更新",
        "新模块上线通知",
        "数据库升级预告",
      ],
      summary: [
        "ERP系统将于本周末进行升级维护，届时将暂停服务2小时",
        "系统安全策略已更新，请及时修改密码",
        "采购管理模块已上线，欢迎使用",
        "数据库将于明日凌晨进行优化升级",
      ],
      sender: "系统运维部",
    },
    approval: {
      title: [
        "采购申请待审批",
        "费用报销申请",
        "合同审批提醒",
        "请假申请待审批",
      ],
      summary: [
        "张三提交的采购申请单号PO-2024001，金额¥12,800",
        "李四提交的费用报销单，金额¥3,200",
        "销售合同SALE-2024005待您审批",
        "王五提交的年假申请，共3天",
      ],
      sender: "审批中心",
    },
    todo: {
      title: [
        "待处理工单提醒",
        "库存盘点任务",
        "月度报表待提交",
        "供应商对账提醒",
      ],
      summary: [
        "您有3个工单待处理，请及时响应",
        "仓库A区库存盘点任务已分配给您",
        "10月份销售报表请于今日下班前提交",
        "本月供应商对账单已生成，请及时核对",
      ],
      sender: "任务中心",
    },
    finance: {
      title: ["付款审批提醒", "发票到期通知", "预算超支预警", "工资条已生成"],
      summary: [
        "供应商付款申请单号PAY-2024032待审批",
        "发票号INV-20241023即将到期，请及时处理",
        "部门预算使用率已达85%，请注意控制",
        "本月工资条已生成，请登录查看",
      ],
      sender: "财务部",
    },
    hr: {
      title: ["入职手续提醒", "绩效考核通知", "培训报名确认", "生日祝福"],
      summary: [
        "新员工王五今日入职，请完成相关手续",
        "季度绩效考核已开启，请于本周完成自评",
        '您已成功报名"领导力培训"课程',
        "祝您生日快乐，公司为您准备了惊喜礼品",
      ],
      sender: "人力资源部",
    },
  };

  const priorities = ["high", "medium", "low"];

  for (let i = 1; i <= 28; i++) {
    const type = types[Math.floor(Math.random() * types.length)];
    const template = templates[type];
    const titleIndex = Math.floor(Math.random() * template.title.length);
    const isRead = Math.random() > 0.55;
    const priority = priorities[Math.floor(Math.random() * priorities.length)];
    const needAction =
      type === "approval" || type === "todo" ? Math.random() > 0.6 : false;
    const time = new Date(
      now.getTime() - Math.random() * 30 * 24 * 60 * 60 * 1000,
    );

    let deadline = null;
    if (needAction && Math.random() > 0.5) {
      deadline = new Date(
        now.getTime() + Math.random() * 7 * 24 * 60 * 60 * 1000,
      );
    }

    messages.push({
      id: i,
      type: type,
      title: template.title[titleIndex],
      summary: template.summary[titleIndex],
      content: `${template.summary[titleIndex]}。\n\n详细信息：请登录ERP系统查看完整内容，如有疑问请联系相关部门。\n\n这是一条来自ERP系统的企业级消息通知，请及时处理相关事务。`,
      time: time,
      isRead: isRead,
      priority: priority,
      needAction: needAction,
      isProcessed: needAction ? Math.random() > 0.7 : false,
      sender: template.sender,
      deadline: deadline,
      relatedId:
        type === "approval"
          ? `APP-${2024000 + i}`
          : type === "finance"
            ? `FIN-${2024000 + i}`
            : null,
      attachments:
        Math.random() > 0.85
          ? [
              { name: `附件_${i}.pdf`, size: "128 KB" },
              { name: `相关文档_${i}.docx`, size: "256 KB" },
            ]
          : [],
    });
  }
  return messages.sort((a, b) => b.time - a.time);
};

// 状态
const messageList = ref([]);
const searchKeyword = ref("");
const filterType = ref("");
const filterPriority = ref("");
const dateRange = ref(null);
const loading = ref(false);
const selectedMessage = ref(null);
const selectedMessages = ref([]);
const currentPage = ref(1);
const pageSize = ref(15);
const showDetailPanel = ref(true);
const isMobile = ref(false);

// 检测屏幕宽度
const checkMobile = () => {
  isMobile.value = window.innerWidth < 768;
  if (isMobile.value) {
    showDetailPanel.value = false;
  } else {
    showDetailPanel.value = true;
  }
};

// 计算属性
const unreadCount = computed(
  () => messageList.value.filter((msg) => !msg.isRead).length,
);
const pendingApprovalCount = computed(
  () =>
    messageList.value.filter(
      (msg) => msg.type === "approval" && !msg.isProcessed,
    ).length,
);

// 综合筛选
const filteredMessages = computed(() => {
  let result = [...messageList.value];

  if (searchKeyword.value) {
    const keyword = searchKeyword.value.toLowerCase();
    result = result.filter(
      (msg) =>
        msg.title.toLowerCase().includes(keyword) ||
        msg.summary.toLowerCase().includes(keyword) ||
        (msg.content && msg.content.toLowerCase().includes(keyword)),
    );
  }

  if (filterType.value) {
    result = result.filter((msg) => msg.type === filterType.value);
  }

  if (filterPriority.value) {
    result = result.filter((msg) => msg.priority === filterPriority.value);
  }

  if (dateRange.value && dateRange.value.length === 2) {
    const [startDate, endDate] = dateRange.value;
    result = result.filter((msg) => {
      const msgDate = new Date(msg.time);
      return msgDate >= startDate && msgDate <= endDate;
    });
  }

  return result;
});

// 分页后的消息
const paginatedMessages = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value;
  const end = start + pageSize.value;
  return filteredMessages.value.slice(start, end);
});

// 获取图标组件
const getIconComponent = (type) => {
  const icons = {
    system: Setting,
    approval: Tickets,
    todo: Document,
    finance: Money,
    hr: User,
  };
  return icons[type] || Bell;
};

// 获取标签类型
const getTagType = (type) => {
  const types = {
    system: "info",
    approval: "warning",
    todo: "danger",
    finance: "success",
    hr: "primary",
  };
  return types[type] || "";
};

// 获取类型显示文本
const getTypeLabel = (type) => {
  const map = {
    system: "系统通知",
    approval: "审批消息",
    todo: "待办提醒",
    finance: "财务通知",
    hr: "人事通知",
  };
  return map[type] || type;
};

// 格式化时间
const formatTime = (time) => {
  const date = new Date(time);
  const now = new Date();
  const diff = now - date;

  if (diff < 60 * 1000) return "刚刚";
  if (diff < 60 * 60 * 1000) return `${Math.floor(diff / (60 * 1000))}分钟前`;
  if (diff < 24 * 60 * 60 * 1000)
    return `${Math.floor(diff / (60 * 60 * 1000))}小时前`;
  if (diff < 7 * 24 * 60 * 60 * 1000)
    return `${Math.floor(diff / (24 * 60 * 60 * 1000))}天前`;
  return `${date.getMonth() + 1}月${date.getDate()}日`;
};

const formatDateTime = (date) => {
  const d = new Date(date);
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")} ${String(d.getHours()).padStart(2, "0")}:${String(d.getMinutes()).padStart(2, "0")}`;
};

const formatDate = (date) => {
  const d = new Date(date);
  return `${d.getMonth() + 1}/${d.getDate()}`;
};

const isDeadlineUrgent = (deadline) => {
  if (!deadline) return false;
  const now = new Date();
  const diff = new Date(deadline) - now;
  return diff < 24 * 60 * 60 * 1000 && diff > 0;
};

// 消息操作
const markAsRead = (message) => {
  if (!message.isRead) {
    message.isRead = true;
    ElMessage.success("已标记为已读");
  }
};

const deleteMessage = async (message) => {
  try {
    await ElMessageBox.confirm("确定要删除这条消息吗？", "删除确认", {
      confirmButtonText: "确定",
      cancelButtonText: "取消",
      type: "warning",
    });
    const index = messageList.value.findIndex((m) => m.id === message.id);
    if (index !== -1) {
      messageList.value.splice(index, 1);
      if (selectedMessage.value?.id === message.id) {
        selectedMessage.value = filteredMessages.value[0] || null;
      }
      selectedMessages.value = selectedMessages.value.filter(
        (id) => id !== message.id,
      );
      ElMessage.success("删除成功");
    }
  } catch {}
};

const markAllAsRead = () => {
  messageList.value.forEach((msg) => {
    msg.isRead = true;
  });
  if (selectedMessage.value) {
    selectedMessage.value.isRead = true;
  }
  ElMessage.success("已全部标记为已读");
};

const clearAllMessages = async () => {
  try {
    await ElMessageBox.confirm(
      "清空后将无法恢复，确定要清空所有消息吗？",
      "清空确认",
      {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning",
      },
    );
    messageList.value = [];
    selectedMessage.value = null;
    selectedMessages.value = [];
    ElMessage.success("已清空所有消息");
  } catch {}
};

// 批量操作
const toggleSelect = (id) => {
  const index = selectedMessages.value.indexOf(id);
  if (index === -1) {
    selectedMessages.value.push(id);
  } else {
    selectedMessages.value.splice(index, 1);
  }
};

const handleBatchCommand = async (command) => {
  if (selectedMessages.value.length === 0) return;

  if (command === "markRead") {
    selectedMessages.value.forEach((id) => {
      const msg = messageList.value.find((m) => m.id === id);
      if (msg) msg.isRead = true;
    });
    ElMessage.success(`已标记 ${selectedMessages.value.length} 条消息为已读`);
    selectedMessages.value = [];
  } else if (command === "delete") {
    try {
      await ElMessageBox.confirm(
        `确定要删除选中的 ${selectedMessages.value.length} 条消息吗？`,
        "批量删除确认",
        {
          confirmButtonText: "确定",
          cancelButtonText: "取消",
          type: "warning",
        },
      );
      messageList.value = messageList.value.filter(
        (m) => !selectedMessages.value.includes(m.id),
      );
      if (
        selectedMessage.value &&
        selectedMessages.value.includes(selectedMessage.value.id)
      ) {
        selectedMessage.value = filteredMessages.value[0] || null;
      }
      selectedMessages.value = [];
      ElMessage.success("批量删除成功");
    } catch {}
  }
};

// 审批操作
const handleApproval = (message) => {
  ElMessage.info(
    `跳转到审批页面，审批单号：${message.relatedId || message.id}`,
  );
};

const handleApprovalFromDetail = () => {
  if (selectedMessage.value) {
    handleApproval(selectedMessage.value);
  }
};

// 查看关联文档
const viewRelatedDoc = (relatedId) => {
  ElMessage.info(`查看关联单据：${relatedId}`);
};

// 下载附件
const downloadAttachment = (file) => {
  ElMessage.info(`下载附件：${file.name}`);
};

// 搜索与筛选
const handleSearch = () => {
  currentPage.value = 1;
  if (
    filteredMessages.value.length > 0 &&
    selectedMessage.value &&
    !filteredMessages.value.find((m) => m.id === selectedMessage.value.id)
  ) {
    selectedMessage.value = filteredMessages.value[0];
  }
};

const resetFilters = () => {
  searchKeyword.value = "";
  filterType.value = "";
  filterPriority.value = "";
  dateRange.value = null;
  currentPage.value = 1;
  if (filteredMessages.value.length > 0 && !selectedMessage.value) {
    selectedMessage.value = filteredMessages.value[0];
  }
};

// 分页处理
const handleSizeChange = (val) => {
  pageSize.value = val;
  currentPage.value = 1;
};

const handleCurrentChange = (val) => {
  currentPage.value = val;
};

// 点击消息
const handleMessageClick = (message) => {
  selectedMessage.value = message;
  if (isMobile.value) {
    showDetailPanel.value = true;
  }
  if (!message.isRead) {
    message.isRead = true;
  }
};

// 关闭详情面板（移动端）
const closeDetailPanel = () => {
  showDetailPanel.value = false;
};

// 初始化
const initData = () => {
  loading.value = true;
  setTimeout(() => {
    messageList.value = generateMockMessages();
    if (messageList.value.length > 0) {
      selectedMessage.value = messageList.value[0];
    }
    loading.value = false;
  }, 300);
};

onMounted(() => {
  initData();
  checkMobile();
  window.addEventListener("resize", checkMobile);
});

onUnmounted(() => {
  window.removeEventListener("resize", checkMobile);
});
</script>

<style scoped lang="scss">
.erp-message-center {
  //height: 100%;
  //min-height: 100vh;
  background-color: #f5f7fa;
  font-family:
    -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue",
    Arial, sans-serif;
}

.message-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 24px;
  background: #fff;
  border-bottom: 1px solid #e9ecef;
  flex-wrap: wrap;
  gap: 12px;

  .header-left {
    display: flex;
    align-items: baseline;
    gap: 32px;
    flex-wrap: wrap;

    .title-section {
      .title {
        font-size: 18px;
        font-weight: 600;
        color: #1e2a3a;
      }
      .subtitle {
        font-size: 12px;
        color: #8a99aa;
        margin-left: 12px;
      }
    }

    .stats-section {
      display: flex;
      gap: 24px;

      .stat-item {
        display: flex;
        align-items: baseline;
        gap: 6px;

        .stat-label {
          font-size: 13px;
          color: #6c757d;
        }

        .stat-value {
          font-size: 20px;
          font-weight: 600;

          &.danger {
            color: #dc3545;
          }
          &.warning {
            color: #fd7e14;
          }
        }
      }
    }
  }

  .header-right {
    display: flex;
    gap: 12px;
  }
}

.filter-bar {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 12px;
  padding: 12px 24px;
  background: #fff;
  border-bottom: 1px solid #e9ecef;

  .search-input {
    width: 240px;
  }

  .filter-select {
    width: 130px;
  }

  .date-picker {
    width: 260px;
  }

  .priority-high {
    color: #dc3545;
  }
  .priority-medium {
    color: #fd7e14;
  }
  .priority-low {
    color: #28a745;
  }
}

.message-layout {
  display: flex;
  height: calc(100vh - 200px);
  min-height: 500px;
  gap: 1px;
  background: #e9ecef;
}

.message-list-panel {
  width: 420px;
  background: #fff;
  display: flex;
  flex-direction: column;
  flex-shrink: 0;
  transition: all 0.3s ease;

  .list-header {
    padding: 16px 20px;
    border-bottom: 1px solid #e9ecef;
    display: flex;
    justify-content: space-between;
    align-items: center;

    .list-title {
      font-size: 15px;
      font-weight: 600;
      color: #1e2a3a;
    }

    .list-count {
      font-size: 12px;
      color: #8a99aa;
    }
  }

  .message-list {
    flex: 1;
    overflow-y: auto;
    padding: 0;
  }

  .pagination-wrapper {
    padding: 12px 16px;
    border-top: 1px solid #e9ecef;
    display: flex;
    justify-content: center;
  }

  &.collapsed {
    width: 100%;
  }
}

.message-item {
  display: flex;
  align-items: flex-start;
  padding: 14px 16px;
  cursor: pointer;
  transition: all 0.2s;
  border-bottom: 1px solid #f0f2f5;
  position: relative;

  &:hover {
    background-color: #f8f9fa;

    .message-actions {
      opacity: 1;
    }
  }

  &.message-read {
    background-color: #fff;

    .message-title .title-text {
      color: #8a99aa;
      font-weight: normal;
    }

    .message-summary {
      color: #adb5bd;
    }
  }

  &.message-unread {
    background-color: #fef9e6;

    .message-title .title-text {
      font-weight: 600;
      color: #1e2a3a;
    }
  }

  &.message-high {
    border-left: 3px solid #dc3545;
  }

  &.message-selected {
    background-color: #ecf5ff;
    border-left: 3px solid #409eff;
  }
}

.message-select {
  margin-right: 12px;
  padding-top: 2px;
}

.message-icon {
  flex-shrink: 0;
  width: 36px;
  height: 36px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 12px;
  position: relative;

  &.icon-system {
    background: #e9ecef;
    color: #495057;
  }
  &.icon-approval {
    background: #fff3e0;
    color: #fd7e14;
  }
  &.icon-todo {
    background: #ffe6e6;
    color: #dc3545;
  }
  &.icon-finance {
    background: #e0f7e8;
    color: #28a745;
  }
  &.icon-hr {
    background: #e0e7ff;
    color: #4f46e5;
  }

  .priority-badge {
    position: absolute;
    top: -4px;
    right: -6px;
    width: 16px;
    height: 16px;
    background: #dc3545;
    color: #fff;
    border-radius: 50%;
    font-size: 10px;
    font-weight: bold;
    display: flex;
    align-items: center;
    justify-content: center;
  }
}

.message-info {
  flex: 1;
  min-width: 0;

  .message-title {
    display: flex;
    align-items: center;
    gap: 6px;
    flex-wrap: wrap;
    margin-bottom: 6px;

    .title-text {
      font-size: 14px;
      font-weight: 500;
      color: #1e2a3a;
    }

    .message-type-tag {
      transform: scale(0.85);
    }

    .unread-dot {
      width: 6px;
      height: 6px;
      background-color: #409eff;
      border-radius: 50%;
    }

    .action-badge {
      font-size: 10px;
      background: #fd7e14;
      color: #fff;
      padding: 2px 6px;
      border-radius: 10px;
    }
  }

  .message-summary {
    font-size: 12px;
    color: #6c757d;
    line-height: 1.4;
    margin-bottom: 6px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .message-meta {
    display: flex;
    align-items: center;
    gap: 12px;
    font-size: 11px;
    color: #adb5bd;

    .message-deadline {
      display: flex;
      align-items: center;
      gap: 4px;

      &.deadline-urgent {
        color: #dc3545;
      }
    }
  }
}

.message-actions {
  display: flex;
  gap: 4px;
  margin-left: 8px;
  opacity: 0;
  transition: opacity 0.2s;

  @media (max-width: 768px) {
    opacity: 1;
  }
}

// 右侧详情面板
.detail-panel {
  flex: 1;
  background: #fff;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  transition: all 0.3s ease;

  .detail-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 16px 24px;
    border-bottom: 1px solid #e9ecef;

    .detail-header-left {
      display: flex;
      align-items: center;
      gap: 12px;

      .back-btn {
        padding: 0;
        font-size: 14px;
      }

      .detail-title {
        font-size: 16px;
        font-weight: 600;
        color: #1e2a3a;
      }
    }

    .detail-actions {
      display: flex;
      gap: 8px;
    }
  }

  .detail-content {
    flex: 1;
    overflow-y: auto;
    padding: 20px 24px;
  }

  .detail-empty {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  &.mobile-detail {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    z-index: 1000;
    background: #fff;
    transform: translateX(100%);
    transition: transform 0.3s ease;

    &.show {
      transform: translateX(0);
    }
  }
}

.detail-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  flex-wrap: wrap;
  gap: 12px;

  .detail-tags {
    display: flex;
    gap: 8px;
    flex-wrap: wrap;
  }

  .detail-time {
    font-size: 13px;
    color: #8a99aa;
    display: flex;
    align-items: center;
    gap: 4px;
  }
}

.detail-title-text {
  font-size: 20px;
  font-weight: 600;
  color: #1e2a3a;
  margin: 0 0 16px 0;
  line-height: 1.4;
}

.detail-info {
  background: #f8f9fa;
  padding: 12px 16px;
  border-radius: 8px;
  margin-bottom: 24px;

  .info-row {
    font-size: 13px;
    margin-bottom: 8px;

    &:last-child {
      margin-bottom: 0;
    }

    .info-label {
      color: #6c757d;
      width: 80px;
      display: inline-block;
    }

    .info-value {
      color: #1e2a3a;

      &.link {
        color: #409eff;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        gap: 4px;

        &:hover {
          text-decoration: underline;
        }
      }

      &.deadline-urgent-text {
        color: #dc3545;
        font-weight: 500;
      }
    }
  }
}

.detail-body {
  margin-bottom: 24px;

  .body-label {
    font-size: 14px;
    font-weight: 500;
    color: #495057;
    margin-bottom: 12px;
  }

  .body-text {
    font-size: 14px;
    line-height: 1.6;
    color: #2c3e50;
    white-space: pre-wrap;
    word-break: break-word;
  }
}

.detail-attachments {
  margin-bottom: 24px;

  .attachments-title {
    font-size: 14px;
    font-weight: 500;
    color: #495057;
    margin-bottom: 12px;
    display: flex;
    align-items: center;
    gap: 6px;
  }

  .attachments-list {
    .attachment-item {
      display: flex;
      align-items: center;
      gap: 8px;
      padding: 10px 12px;
      background: #f8f9fa;
      border-radius: 6px;
      margin-bottom: 8px;
      cursor: pointer;
      transition: all 0.2s;

      &:hover {
        background: #e9ecef;
      }

      .file-name {
        flex: 1;
        font-size: 13px;
        color: #409eff;
      }

      .file-size {
        font-size: 11px;
        color: #8a99aa;
      }

      .download-icon {
        color: #8a99aa;
        opacity: 0;
        transition: opacity 0.2s;
      }

      &:hover .download-icon {
        opacity: 1;
      }
    }
  }
}

.detail-footer-actions {
  margin-top: 24px;
  padding-top: 16px;
  border-top: 1px solid #e9ecef;
}

// 滚动条样式
.message-list::-webkit-scrollbar,
.detail-content::-webkit-scrollbar {
  width: 5px;
}

.message-list::-webkit-scrollbar-track,
.detail-content::-webkit-scrollbar-track {
  background: #f1f1f1;
}

.message-list::-webkit-scrollbar-thumb,
.detail-content::-webkit-scrollbar-thumb {
  background: #cbd5e0;
  border-radius: 3px;
}

// 响应式
@media (max-width: 768px) {
  .message-header {
    padding: 12px 16px;

    .header-left {
      gap: 16px;

      .title-section .subtitle {
        display: none;
      }

      .stats-section {
        gap: 12px;

        .stat-value {
          font-size: 16px;
        }
      }
    }
  }

  .filter-bar {
    padding: 12px 16px;

    .search-input {
      width: 100%;
    }

    .filter-select {
      flex: 1;
      min-width: 100px;
    }

    .date-picker {
      width: 100%;
    }
  }

  .message-layout {
    height: calc(100vh - 160px);
  }

  .message-list-panel {
    width: 100%;
  }

  .detail-panel:not(.mobile-detail) {
    display: none;
  }
}
</style>
