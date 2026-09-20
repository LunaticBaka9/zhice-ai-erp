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
                        <span class="stat-label">待处理</span>
                        <span class="stat-value warning">{{ pendingCount }}</span>
                    </div>
                    <div class="stat-item">
                        <span class="stat-label">总消息</span>
                        <span class="stat-value">{{ total }}</span>
                    </div>
                </div>
            </div>
            <div class="header-right">
                <el-dropdown trigger="click" @command="handleBatchCommand" :disabled="selectedMessages.length === 0">
                    <el-button type="default">
                        批量操作
                        <span v-if="selectedMessages.length" class="batch-count">({{ selectedMessages.length }})</span>
                        <el-icon>
                            <ArrowDown/>
                        </el-icon>
                    </el-button>
                    <template #dropdown>
                        <el-dropdown-menu>
                            <el-dropdown-item command="markRead">批量标记已读</el-dropdown-item>
                            <el-dropdown-item command="delete" divided>批量删除</el-dropdown-item>
                        </el-dropdown-menu>
                    </template>
                </el-dropdown>
                <el-button type="primary" plain @click="markAllAsRead" :disabled="unreadCount === 0">
                    <el-icon>
                        <Check/>
                    </el-icon>
                    全部已读
                </el-button>
                <el-button type="danger" plain @click="clearAllMessages" :disabled="total === 0">
                    <el-icon>
                        <Delete/>
                    </el-icon>
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
                @keyup.enter="handleSearch"
                @clear="handleSearch"
            />
            <el-select v-model="filterType" placeholder="消息类型" clearable size="default" class="filter-select">
                <el-option label="系统通知" value="system"/>
                <el-option label="审批消息" value="approval"/>
                <el-option label="待办提醒" value="todo"/>
                <el-option label="财务通知" value="finance"/>
                <el-option label="人事通知" value="hr"/>
            </el-select>
            <el-select v-model="filterPriority" placeholder="优先级" clearable size="default" class="filter-select">
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
            <el-select v-model="filterReadStatus" placeholder="阅读状态" clearable size="default" class="filter-select">
                <el-option label="未读" :value="0"/>
                <el-option label="已读" :value="1"/>
            </el-select>
            <el-date-picker
                v-model="dateRange"
                type="daterange"
                range-separator="至"
                start-placeholder="开始日期"
                end-placeholder="结束日期"
                value-format="YYYY-MM-DD"
                size="default"
                class="date-picker"
            />
            <el-button type="primary" @click="handleSearch" :icon="Search">查询</el-button>
            <el-button @click="resetFilters">重置</el-button>
        </div>

        <!-- 左右分栏布局：左侧消息列表，右侧详情 -->
        <div class="message-layout">
            <!-- 左侧消息列表 -->
            <div class="message-list-panel" :class="{ collapsed: !showDetailPanel && isMobile }">
                <div class="list-header">
                    <div style="display: flex; align-items: center; gap: 8px;">
                        <el-checkbox
                            :model-value="isAllCurrentSelected"
                            :indeterminate="isCurrentIndeterminate"
                            :disabled="messageList.length === 0"
                            @change="toggleSelectAll"
                        />
                        <span class="list-title">消息列表</span>
                    </div>
                    <span class="list-count">共 {{ total }} 条</span>
                </div>
                <div class="message-list" v-loading="loading">
                    <template v-if="messageList.length > 0">
                        <div
                            v-for="message in messageList"
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
                                    <component :is="getIconComponent(message.type)"/>
                                </el-icon>
                                <span v-if="message.priority === 'high'" class="priority-badge">!</span>
                            </div>
                            <div class="message-info">
                                <div class="message-title">
                                    <span class="title-text">{{ message.title || "无标题消息" }}</span>
                                    <el-tag
                                        :type="getTagType(message.type)"
                                        size="small"
                                        effect="light"
                                        class="message-type-tag"
                                    >
                                        {{ getTypeLabel(message.type) }}
                                    </el-tag>
                                    <span v-if="!message.isRead" class="unread-dot"></span>
                                    <span v-if="message.needAction && !message.isProcessed" class="action-badge">待处理</span>
                                    <span v-else-if="message.needAction && message.isProcessed" class="action-badge processed">
                                        已处理
                                    </span>
                                </div>
                                <div class="message-summary">{{ message.summary }}</div>
                                <div class="message-meta">
                                    <span class="message-sender">{{ message.sender || "系统管理员" }}</span>
                                    <span class="message-time">{{ formatTime(message.time) }}</span>
                                    <span
                                        v-if="message.deadline"
                                        class="message-deadline"
                                        :class="{
                                            'deadline-urgent': isDeadlineUrgent(message.deadline),
                                        }"
                                    >
                                        <el-icon><Clock/></el-icon>
                                        截止: {{ formatDate(message.deadline) }}
                                    </span>
                                </div>
                            </div>
                            <div class="message-actions" @click.stop>
                                <el-tooltip content="标记已读" placement="top" v-if="!message.isRead">
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
                    <el-empty v-else description="暂无消息" :image-size="100"/>
                </div>

                <!-- 分页组件 -->
                <div class="pagination-wrapper" v-if="total > 0">
                    <el-pagination
                        v-model:current-page="currentPage"
                        v-model:page-size="pageSize"
                        :page-sizes="[10, 20, 50]"
                        :total="total"
                        layout="total, sizes, prev, pager, next"
                        small
                        @size-change="handleSizeChange"
                        @current-change="handleCurrentChange"
                    />
                </div>
            </div>

            <!-- 右侧详情面板 -->
            <div class="detail-panel" :class="{ show: showDetailPanel, 'mobile-detail': isMobile }">
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
                        <el-tooltip content="标记已读" placement="top" v-if="!selectedMessage.isRead">
                            <el-button :icon="Check" circle size="small" @click="markAsRead(selectedMessage)"/>
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
                            <el-tag v-if="selectedMessage.priority === 'high'" type="danger" size="small" effect="dark">
                                高优先级
                            </el-tag>
                            <el-tag v-if="selectedMessage.priority === 'medium'" type="warning" size="small" effect="plain">
                                中优先级
                            </el-tag>
                            <el-tag v-if="selectedMessage.needAction" type="warning" size="small">
                                {{ selectedMessage.isProcessed ? "已处理" : "需处理" }}
                            </el-tag>
                            <el-tag v-if="!selectedMessage.isRead" type="info" size="small" effect="plain">
                                未读
                            </el-tag>
                        </div>
                        <div class="detail-time">
                            <el-icon>
                                <Clock/>
                            </el-icon>
                            {{ formatDateTime(selectedMessage.time) }}
                        </div>
                    </div>

                    <h3 class="detail-title-text">{{ selectedMessage.title || "无标题消息" }}</h3>

                    <div class="detail-info">
                        <div class="info-row">
                            <span class="info-label">发送方：</span>
                            <span class="info-value">{{ selectedMessage.sender || "系统管理员" }}</span>
                        </div>
                        <div class="info-row" v-if="selectedMessage.deadline">
                            <span class="info-label">截止时间：</span>
                            <span
                                class="info-value"
                                :class="{
                                    'deadline-urgent-text': isDeadlineUrgent(selectedMessage.deadline),
                                }"
                            >
                                {{ formatDateTime(selectedMessage.deadline) }}
                            </span>
                        </div>
                        <div class="info-row" v-if="selectedMessage.relatedId">
                            <span class="info-label">关联单号：</span>
                            <span class="info-value link" @click="viewRelatedDoc(selectedMessage.relatedId)">
                                {{ selectedMessage.relatedId }}
                                <el-icon><TopRight/></el-icon>
                            </span>
                        </div>
                    </div>

                    <div class="detail-body">
                        <div class="body-label">消息内容</div>
                        <div class="body-text">
                            {{ selectedMessage.content || selectedMessage.summary || "暂无内容" }}
                        </div>
                    </div>

                    <div
                        v-if="selectedMessage.attachments && selectedMessage.attachments.length"
                        class="detail-attachments"
                    >
                        <div class="attachments-title">
                            <el-icon>
                                <Paperclip/>
                            </el-icon>
                            附件 ({{ selectedMessage.attachments.length }})
                        </div>
                        <div class="attachments-list">
                            <div
                                v-for="(file, idx) in selectedMessage.attachments"
                                :key="idx"
                                class="attachment-item"
                                @click="downloadAttachment(file)"
                            >
                                <el-icon>
                                    <Document/>
                                </el-icon>
                                <span class="file-name">{{ file.name }}</span>
                                <span class="file-size">{{ file.size }}</span>
                                <el-icon class="download-icon">
                                    <Download/>
                                </el-icon>
                            </div>
                        </div>
                    </div>

                    <div
                        class="detail-footer-actions"
                        v-if="selectedMessage.type === 'approval' && !selectedMessage.isProcessed"
                    >
                        <el-button type="primary" size="large" @click="handleApprovalFromDetail" style="width: 100%">
                            <el-icon>
                                <Edit/>
                            </el-icon>
                            去审批
                        </el-button>
                    </div>
                </div>
                <div class="detail-empty" v-else>
                    <el-empty description="请选择一条消息查看详情" :image-size="120">
                        <template #image>
                            <el-icon :size="80" color="#c0c4cc">
                                <Message/>
                            </el-icon>
                        </template>
                    </el-empty>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup>
import {computed, onMounted, onUnmounted, ref} from "vue";
import {
    ArrowDown,
    ArrowLeft,
    Bell,
    Check,
    Clock,
    Delete,
    Document,
    Download,
    Edit,
    Message,
    Money,
    Paperclip,
    Search,
    Setting,
    Tickets,
    TopRight,
    User,
} from "@element-plus/icons-vue";
import {ElMessage, ElMessageBox} from "element-plus";
import {
    clearAllMessage,
    getMessageList,
    markAllMessageRead,
    markBatchMessageRead,
    markMessageRead,
    removeBatchMessage,
    removeMessage,
} from "@/api/message";

// ------------------------------------------------------------------ 状态
const loading = ref(false);
const messageList = ref([]);
const total = ref(0);
const unreadCount = ref(0);
const pendingCount = ref(0);

const searchKeyword = ref("");
const filterType = ref("");
const filterPriority = ref("");
const filterReadStatus = ref("");
const dateRange = ref([]);

const currentPage = ref(1);
const pageSize = ref(10);

const selectedMessage = ref(null);
const selectedMessages = ref([]);
const showDetailPanel = ref(true);
const isMobile = ref(false);

// ------------------------------------------------------------------ 工具方法
const parseDate = (value) => {
    if (!value && value !== 0) return null;
    if (value instanceof Date) return value;
    const date = new Date(typeof value === "string" ? value.replace(/-/g, "/") : value);
    return Number.isNaN(date.getTime()) ? null : date;
};

const parseAttachments = (raw) => {
    if (!raw) return [];
    if (Array.isArray(raw)) return raw;
    try {
        const parsed = typeof raw === "string" ? JSON.parse(raw) : raw;
        return Array.isArray(parsed) ? parsed : [];
    } catch (e) {
        return [];
    }
};

const toBooleanFlag = (value) => value === 1 || value === true || value === "1";

// 后端实体 -> 前端展示模型
const mapMessage = (item) => ({
    id: item.msgId,
    type: item.type || "system",
    title: item.title,
    summary: item.summary || "",
    content: item.content || "",
    time: parseDate(item.publishDate),
    isRead: toBooleanFlag(item.isRead),
    priority: item.priority || "medium",
    needAction: toBooleanFlag(item.needAction),
    isProcessed: toBooleanFlag(item.isProcessed),
    sender: item.senderName || "系统管理员",
    deadline: parseDate(item.deadline),
    relatedId: item.relatedId || null,
    attachments: parseAttachments(item.attachments),
    receiverId: item.receiverId,
});

const formatTime = (time) => {
    const date = parseDate(time);
    if (!date) return "";
    const now = new Date();
    const diff = now - date;

    if (diff < 0) return formatDateTime(date);
    if (diff < 60 * 1000) return "刚刚";
    if (diff < 60 * 60 * 1000) return `${Math.floor(diff / (60 * 1000))}分钟前`;
    if (diff < 24 * 60 * 60 * 1000) return `${Math.floor(diff / (60 * 60 * 1000))}小时前`;
    if (diff < 7 * 24 * 60 * 60 * 1000) return `${Math.floor(diff / (24 * 60 * 60 * 1000))}天前`;
    return `${date.getMonth() + 1}月${date.getDate()}日`;
};

const formatDateTime = (value) => {
    const d = parseDate(value);
    if (!d) return "";
    return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")} ${String(d.getHours()).padStart(2, "0")}:${String(d.getMinutes()).padStart(2, "0")}`;
};

const formatDate = (value) => {
    const d = parseDate(value);
    if (!d) return "";
    return `${d.getMonth() + 1}/${d.getDate()}`;
};

const isDeadlineUrgent = (deadline) => {
    const d = parseDate(deadline);
    if (!d) return false;
    const diff = d - new Date();
    return diff > 0 && diff < 24 * 60 * 60 * 1000;
};

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

// ------------------------------------------------------------------ 数据加载
const buildQuery = () => {
    const query = {
        pageNum: currentPage.value,
        pageSize: pageSize.value,
    };
    if (searchKeyword.value && searchKeyword.value.trim()) {
        query.keyword = searchKeyword.value.trim();
    }
    if (filterType.value) query.type = filterType.value;
    if (filterPriority.value) query.priority = filterPriority.value;
    if (filterReadStatus.value !== "" && filterReadStatus.value !== null && filterReadStatus.value !== undefined) {
        query.isRead = filterReadStatus.value;
    }
    if (Array.isArray(dateRange.value) && dateRange.value.length === 2 && dateRange.value[0] && dateRange.value[1]) {
        query.startDate = dateRange.value[0];
        query.endDate = dateRange.value[1];
    }
    return query;
};

const loadMessages = async (options = {}) => {
    const {keepSelection = false} = options;
    loading.value = true;
    try {
        const res = await getMessageList(buildQuery());
        if (res && res.code === "200" && res.data) {
            const data = res.data;
            const records = Array.isArray(data.records) ? data.records.map(mapMessage) : [];

            // 当前页不足时回退一页（例如删除/筛选后）
            if (records.length === 0 && currentPage.value > 1 && Number(data.total || 0) > 0) {
                currentPage.value -= 1;
                loading.value = false;
                return loadMessages({keepSelection});
            }

            messageList.value = records;
            total.value = Number(data.total || 0);
            unreadCount.value = Number(data.unreadCount || 0);
            pendingCount.value = Number(data.pendingCount || 0);

            if (!keepSelection) {
                selectedMessages.value = [];
            }

            if (selectedMessage.value) {
                selectedMessage.value = records.find((m) => m.id === selectedMessage.value.id) || records[0] || null;
            } else {
                selectedMessage.value = records[0] || null;
            }
        } else {
            ElMessage.error(res?.msg || "获取消息列表失败");
        }
    } catch (e) {
        // 请求拦截器已统一提示
    } finally {
        loading.value = false;
    }
};

// ------------------------------------------------------------------ 计算属性
const isAllCurrentSelected = computed(
    () => messageList.value.length > 0 && messageList.value.every((m) => selectedMessages.value.includes(m.id)),
);
const isCurrentIndeterminate = computed(() => {
    if (!messageList.value.length) return false;
    const count = messageList.value.filter((m) => selectedMessages.value.includes(m.id)).length;
    return count > 0 && count < messageList.value.length;
});

// ------------------------------------------------------------------ 选择
const toggleSelect = (id) => {
    const index = selectedMessages.value.indexOf(id);
    if (index === -1) {
        selectedMessages.value.push(id);
    } else {
        selectedMessages.value.splice(index, 1);
    }
};

const toggleSelectAll = (checked) => {
    const ids = messageList.value.map((m) => m.id);
    if (checked) {
        ids.forEach((id) => {
            if (!selectedMessages.value.includes(id)) selectedMessages.value.push(id);
        });
    } else {
        selectedMessages.value = selectedMessages.value.filter((id) => !ids.includes(id));
    }
};

// ------------------------------------------------------------------ 消息操作
const markAsRead = async (message) => {
    if (!message || message.isRead) return;
    try {
        const res = await markMessageRead(message.id);
        if (res && res.code !== "200") {
            ElMessage.error(res.msg || "标记已读失败");
            return;
        }
        message.isRead = true;
        if (unreadCount.value > 0) unreadCount.value -= 1;
        ElMessage.success("已标记为已读");
        // 处于“未读”筛选时，标记后该条应从列表移除
        if (filterReadStatus.value === 0) {
            await loadMessages({keepSelection: true});
        }
    } catch (e) {
        // 请求拦截器已统一提示
    }
};

const markAllAsRead = async () => {
    try {
        const res = await markAllMessageRead();
        if (res && res.code !== "200") {
            ElMessage.error(res.msg || "操作失败");
            return;
        }
        ElMessage.success("已全部标记为已读");
        await loadMessages();
    } catch (e) {
        // 请求拦截器已统一提示
    }
};

const deleteMessage = async (message) => {
    if (!message) return;
    try {
        await ElMessageBox.confirm("确定要删除这条消息吗？", "删除确认", {
            confirmButtonText: "确定",
            cancelButtonText: "取消",
            type: "warning",
        });
    } catch {
        return;
    }
    try {
        const res = await removeMessage(message.id);
        if (res && res.code !== "200") {
            ElMessage.error(res.msg || "删除失败");
            return;
        }
        selectedMessages.value = selectedMessages.value.filter((id) => id !== message.id);
        if (selectedMessage.value?.id === message.id) {
            selectedMessage.value = null;
        }
        ElMessage.success("删除成功");
        await loadMessages({keepSelection: true});
    } catch (e) {
        // 请求拦截器已统一提示
    }
};

const clearAllMessages = async () => {
    try {
        await ElMessageBox.confirm("清空后将无法恢复，确定要清空所有消息吗？", "清空确认", {
            confirmButtonText: "确定",
            cancelButtonText: "取消",
            type: "warning",
        });
    } catch {
        return;
    }
    try {
        const res = await clearAllMessage();
        if (res && res.code !== "200") {
            ElMessage.error(res.msg || "清空失败");
            return;
        }
        selectedMessage.value = null;
        selectedMessages.value = [];
        currentPage.value = 1;
        ElMessage.success("已清空所有消息");
        await loadMessages();
    } catch (e) {
        // 请求拦截器已统一提示
    }
};

const handleBatchCommand = async (command) => {
    if (selectedMessages.value.length === 0) return;
    const ids = [...selectedMessages.value];

    if (command === "markRead") {
        try {
            const res = await markBatchMessageRead(ids);
            if (res && res.code !== "200") {
                ElMessage.error(res.msg || "批量标记失败");
                return;
            }
            ElMessage.success(`已标记 ${ids.length} 条消息为已读`);
            await loadMessages();
        } catch (e) {
            // 请求拦截器已统一提示
        }
        return;
    }

    if (command === "delete") {
        try {
            await ElMessageBox.confirm(`确定要删除选中的 ${ids.length} 条消息吗？`, "批量删除确认", {
                confirmButtonText: "确定",
                cancelButtonText: "取消",
                type: "warning",
            });
        } catch {
            return;
        }
        try {
            const res = await removeBatchMessage(ids);
            if (res && res.code !== "200") {
                ElMessage.error(res.msg || "批量删除失败");
                return;
            }
            if (selectedMessage.value && ids.includes(selectedMessage.value.id)) {
                selectedMessage.value = null;
            }
            selectedMessages.value = [];
            ElMessage.success("批量删除成功");
            await loadMessages();
        } catch (e) {
            // 请求拦截器已统一提示
        }
    }
};

// ------------------------------------------------------------------ 其它交互
const handleApproval = (message) => {
    ElMessage.info(`跳转到审批页面，审批单号：${message.relatedId || message.id}`);
};

const handleApprovalFromDetail = () => {
    if (selectedMessage.value) {
        handleApproval(selectedMessage.value);
    }
};

const viewRelatedDoc = (relatedId) => {
    ElMessage.info(`查看关联单据：${relatedId}`);
};

const downloadAttachment = (file) => {
    ElMessage.info(`下载附件：${file.name}`);
};

// ------------------------------------------------------------------ 搜索 / 分页
const handleSearch = () => {
    currentPage.value = 1;
    loadMessages();
};

const resetFilters = () => {
    searchKeyword.value = "";
    filterType.value = "";
    filterPriority.value = "";
    filterReadStatus.value = "";
    dateRange.value = [];
    currentPage.value = 1;
    loadMessages();
};

const handleSizeChange = (val) => {
    pageSize.value = val;
    currentPage.value = 1;
    loadMessages();
};

const handleCurrentChange = (val) => {
    currentPage.value = val;
    loadMessages();
};

const handleMessageClick = (message) => {
    selectedMessage.value = message;
    if (isMobile.value) {
        showDetailPanel.value = true;
    }
    if (!message.isRead) {
        markAsRead(message);
    }
};

const closeDetailPanel = () => {
    showDetailPanel.value = false;
};

// ------------------------------------------------------------------ 生命周期
const checkMobile = () => {
    isMobile.value = window.innerWidth < 768;
    showDetailPanel.value = !isMobile.value;
};

onMounted(() => {
    checkMobile();
    loadMessages();
    window.addEventListener("resize", checkMobile);
});

onUnmounted(() => {
    window.removeEventListener("resize", checkMobile);
});
</script>


<style scoped lang="scss" src="../assets/css/message.css" />
