<template>
    <div class="dashboard">
        <!-- 欢迎区域 -->
        <el-row :gutter="20" class="welcome-section">
            <el-col :span="24">
                <div class="welcome-banner">
                    <h2>欢迎回来，{{ userName }}</h2>
                    <p>{{ greetingMessage }}</p>
                </div>
            </el-col>
        </el-row>

        <!-- 统计卡片 -->
        <el-row :gutter="20" class="stats-section">
            <el-col
                :xs="24"
                :sm="12"
                :md="6"
                v-for="stat in statsCards"
                :key="stat.title"
            >
                <el-card shadow="hover" class="stat-card">
                    <div class="stat-content">
                        <div
                            class="stat-icon"
                            :style="{ backgroundColor: stat.color }"
                        >
                            <el-icon :size="24"
                                ><component :is="stat.icon"
                            /></el-icon>
                        </div>
                        <div class="stat-info">
                            <div class="stat-value">{{ stat.value }}</div>
                            <div class="stat-title">{{ stat.title }}</div>
                        </div>
                    </div>
                </el-card>
            </el-col>
        </el-row>

        <el-row :gutter="20">
            <!-- 左侧内容区 -->
            <el-col :xs="24" :md="16">
                <!-- 快捷入口 -->
                <el-card class="quick-access-card" shadow="never">
                    <template #header>
                        <div class="card-header">
                            <span>快捷入口</span>
                        </div>
                    </template>
                    <div class="quick-access">
                        <div
                            v-for="item in quickAccessItems"
                            :key="item.name"
                            class="quick-item"
                            @click="handleQuickAccess(item)"
                        >
                            <div
                                class="quick-icon"
                                :style="{ backgroundColor: item.color }"
                            >
                                <el-icon :size="20"
                                    ><component :is="item.icon"
                                /></el-icon>
                            </div>
                            <span class="quick-name">{{ item.name }}</span>
                        </div>
                    </div>
                </el-card>

                <!-- 最新公告 -->
                <el-card
                    class="notices-card"
                    shadow="never"
                    style="margin-top: 20px"
                >
                    <template #header>
                        <div class="card-header">
                            <span>最新公告</span>
                            <el-button type="primary" link @click="goToNotices"
                                >查看更多</el-button
                            >
                        </div>
                    </template>
                    <div class="notice-list">
                        <div
                            v-for="notice in recentNotices"
                            :key="notice.nid"
                            class="notice-item"
                            @click="viewNotice(notice)"
                        >
                            <el-tag
                                :type="getNoticeTagType(notice.type)"
                                size="small"
                                >{{ notice.type }}</el-tag
                            >
                            <span class="notice-title">{{ notice.title }}</span>
                            <span class="notice-date">{{
                                formatDateTime(notice.publishDate)
                            }}</span>
                        </div>
                        <el-empty
                            v-if="recentNotices.length === 0"
                            description="暂无公告"
                            :image-size="60"
                        />
                    </div>
                </el-card>
            </el-col>

            <!-- 详情公告内容框 -->
            <el-dialog
                v-model="dialogVisible"
                :title="selectedAnnouncement?.title"
                width="1200px"
                class="detail-dialog"
            >
                <div v-if="selectedAnnouncement" class="detail-content">
                    <div class="detail-meta">
                        <el-tag
                            :type="getTagType(selectedAnnouncement.type)"
                            size="small"
                        >
                            {{ selectedAnnouncement.type }}
                        </el-tag>
                        <span class="date">{{
                            formatDateTime(selectedAnnouncement.publishDate)
                        }}</span>
                        <span class="author"
                            >发布人：{{ selectedAnnouncement.author }}</span
                        >
                    </div>
                    <div
                        class="detail-body"
                        v-html="selectedAnnouncement.content"
                    ></div>
                    <!-- 附件列表 -->
                    <div
                        v-if="
                            selectedAnnouncement.attachments &&
                            selectedAnnouncement.attachments.length > 0
                        "
                        class="attachment-section"
                    >
                        <h4 class="attachment-title">
                            <el-icon><Document /></el-icon> 附件下载
                        </h4>
                        <div class="attachment-list">
                            <div
                                v-for="(
                                    file, index
                                ) in selectedAnnouncement.attachments"
                                :key="index"
                                class="attachment-item"
                            >
                                <el-icon class="attachment-icon"
                                    ><Document
                                /></el-icon>
                                <span class="attachment-name">{{
                                    file.name
                                }}</span>
                                <span class="attachment-size">{{
                                    formatFileSize(file.size)
                                }}</span>
                                <el-button
                                    type="primary"
                                    link
                                    size="small"
                                    @click="handleDownloadFile(file)"
                                >
                                    <el-icon><Download /></el-icon> 下载
                                </el-button>
                            </div>
                        </div>
                    </div>
                    <div class="detail-footer">
                        <span>阅读次数：{{ selectedAnnouncement.views }}</span>
                    </div>
                </div>
                <template #footer>
                    <el-button @click="dialogVisible = false">关闭</el-button>
                    <el-button type="primary" @click="markAsRead"
                        >我知道了</el-button
                    >
                </template>
            </el-dialog>

            <!-- 右侧打卡模块 -->
            <el-col :xs="24" :md="8">
                <el-card class="clock-card" shadow="never">
                    <template #header>
                        <div class="card-header">
                            <span>打卡签到</span>
                        </div>
                    </template>
                    <div class="clock-content">
                        <div class="date">{{ currentDate }}</div>
                        <div class="time">{{ currentTime }}</div>
                        <div class="clock-buttons">
                            <el-button
                                type="primary"
                                @click="serverSign"
                                :loading="signing"
                                size="small"
                                >打卡</el-button
                            >
                            <el-button
                                type="warning"
                                @click="serverSignOut"
                                :loading="signing"
                                size="small"
                                >签退</el-button
                            >
                        </div>
                        <div class="last-sign">
                            最近打卡：{{ lastSignTime || "暂无" }}
                        </div>
                    </div>
                </el-card>

                <!-- 待办事项 -->
                <el-card
                    class="todo-card"
                    shadow="never"
                    style="margin-top: 20px"
                >
                    <template #header>
                        <div class="card-header">
                            <span>待办事项</span>
                        </div>
                    </template>
                    <div class="todo-list">
                        <div
                            v-for="todo in todoList"
                            :key="todo.id"
                            class="todo-item"
                        >
                            <el-checkbox
                                v-model="todo.completed"
                                @change="handleTodoChange(todo)"
                                >{{ todo.text }}</el-checkbox
                            >
                            <el-tag
                                :type="
                                    todo.priority === '高'
                                        ? 'danger'
                                        : todo.priority === '中'
                                          ? 'warning'
                                          : 'info'
                                "
                                size="small"
                                >{{ todo.priority }}</el-tag
                            >
                        </div>
                        <el-empty
                            v-if="todoList.length === 0"
                            description="暂无待办事项"
                            :image-size="60"
                        />
                    </div>
                </el-card>
            </el-col>
        </el-row>
    </div>
</template>

<script setup>
import { ref, onMounted, computed } from "vue";
import { useRouter } from "vue-router";
import request from "../utils/request";
import { ElMessage } from "element-plus";
import {
    formatDateTime,
    formatTime as fmtTime,
    parseDate,
} from "../utils/date";
import {
    Document,
    Bell,
    Calendar,
    User,
    EditPen,
    List,
    Clock,
    TrendCharts,
    ChatDotRound,
    Setting,
    Download,
} from "@element-plus/icons-vue";

const router = useRouter();

// 时钟相关
const currentDate = ref("");
const currentTime = ref("");
const lastSignTime = ref("");
const signing = ref(false);

// 用户信息
const userName = computed(() => {
    try {
        const s = localStorage.getItem("local_user");
        if (!s) return "用户";
        const u = JSON.parse(s);
        return u.name || u.username || "用户";
    } catch (e) {
        return "用户";
    }
});

const greetingMessage = computed(() => {
    const hour = new Date().getHours();
    if (hour < 6) return "夜深了，注意休息";
    if (hour < 9) return "早上好，新的一天开始了";
    if (hour < 12) return "上午好，工作顺利";
    if (hour < 14) return "中午好，记得午休";
    if (hour < 18) return "下午好，继续加油";
    if (hour < 22) return "晚上好，辛苦了";
    return "夜深了，早点休息";
});

// 统计卡片数据
const statsCards = ref([
    { title: "待办事项", value: 5, icon: "List", color: "#409EFF" },
    { title: "未读公告", value: 3, icon: "Bell", color: "#E6A23C" },
    { title: "本月打卡", value: 22, icon: "Clock", color: "#67C23A" },
    { title: "连续打卡", value: 15, icon: "TrendCharts", color: "#F56C6C" },
]);

// 快捷入口
const quickAccessItems = [
    {
        name: "发布公告",
        icon: "EditPen",
        color: "#409EFF",
        route: "/notice/post",
    },
    {
        name: "公告管理",
        icon: "Document",
        color: "#67C23A",
        route: "/notice/manager",
    },
    {
        name: "打卡记录",
        icon: "Calendar",
        color: "#E6A23C",
        route: "/sign/manager",
    },
    {
        name: "用户管理",
        icon: "User",
        color: "#F56C6C",
        route: "/user/manager",
    },
    {
        name: "消息中心",
        icon: "List",
        color: "#909399",
        route: "/message",
    },
    {
        name: "系统设置",
        icon: "Setting",
        color: "#909399",
        route: "/system/role",
    },
];

// 最近公告
const recentNotices = ref([]);
// 详情公告弹窗
const dialogVisible = ref(false);
const selectedAnnouncement = ref(null);

// 待办事项
const todoList = ref([
    { id: 1, text: "查看最新公告", completed: false, priority: "高" },
    { id: 2, text: "完成今日打卡", completed: false, priority: "高" },
    { id: 3, text: "更新个人资料", completed: true, priority: "中" },
    { id: 4, text: "查看打卡记录", completed: false, priority: "低" },
    { id: 5, text: "提交周报", completed: false, priority: "中" },
]);

// 时钟更新
function updateClock() {
    const now = new Date();
    currentDate.value = now.toLocaleDateString("zh-CN", {
        year: "numeric",
        month: "long",
        day: "numeric",
        weekday: "long",
    });
    currentTime.value = now.toLocaleTimeString();
}
setInterval(updateClock, 1000);
updateClock();

// 获取本地用户ID
function getLocalUserId() {
    try {
        const s = localStorage.getItem("local_user");
        if (!s) return null;
        const u = JSON.parse(s);
        return u.uid || u.id || null;
    } catch (e) {
        return null;
    }
}

// 打卡功能
async function serverSign() {
    signing.value = true;
    const uid = getLocalUserId();
    if (!uid) {
        ElMessage.warning("未检测到登录用户，请先登录");
        signing.value = false;
        return;
    }
    try {
        // 先检查今日是否已经打卡
        const checkRes = await request.get("/sign/today", { params: { uid } });
        if (checkRes && (checkRes.code === "200" || checkRes.code === 200)) {
            if (checkRes.data) {
                ElMessage.warning("今天已经打卡了");
                signing.value = false;
                return;
            }
        }

        const payload = { uid };
        const res = await request.post("/sign/add", payload);
        if (res && res.code === "200") {
            const r = res.data || {};
            lastSignTime.value = formatDateTime(r.signInTime || r.createTime);
            ElMessage.success("打卡成功");
            // 更新统计
            statsCards.value[2].value += 1;
            statsCards.value[3].value += 1;
        } else {
            ElMessage.error((res && res.msg) || "后端打卡失败");
        }
    } catch (err) {
        console.error(err);
        ElMessage.error("后端请求失败");
    } finally {
        signing.value = false;
    }
}

async function serverSignOut() {
    signing.value = true;
    const uid = getLocalUserId();
    if (!uid) {
        ElMessage.warning("未检测到登录用户，请先登录");
        signing.value = false;
        return;
    }
    try {
        const payload = { uid };
        const res = await request.post("/sign/signOut", payload);
        if (res && res.code === "200") {
            ElMessage.success("签退成功");
        } else {
            ElMessage.error((res && res.msg) || "后端签退失败");
        }
    } catch (err) {
        console.error(err);
        ElMessage.error("后端签退请求失败");
    } finally {
        signing.value = false;
    }
}

async function fetchLastSignTime() {
    const uid = getLocalUserId();
    if (!uid) return;
    try {
        const res = await request.get("/sign/latest", { params: { uid } });
        if (res && (res.code === "200" || res.code === 200)) {
            const d = res.data || null;
            if (d) {
                lastSignTime.value = formatDateTime(
                    d.signInTime || d.createTime,
                );
            }
        }
    } catch (e) {
        console.error("fetchLastSignTime error", e);
    }
}

// 获取最近公告
async function fetchRecentNotices() {
    try {
        const res = await request.get("/notice/list", {
            params: { pageNum: 1, pageSize: 5 },
        });
        if (res && (res.code === "200" || res.code === 200)) {
            recentNotices.value = res.data?.list || [];
            // 更新未读公告统计
            statsCards.value[1].value = recentNotices.value.length;
        }
    } catch (e) {
        console.error("fetchRecentNotices error", e);
    }
}

// 快捷入口跳转
function handleQuickAccess(item) {
    if (item.route) {
        router.push(item.route);
    }
}

// 公告类型标签
function getNoticeTagType(type) {
    const typeMap = {
        系统更新: "primary",
        维护通知: "warning",
        功能上线: "success",
        其他公告: "info",
    };
    return typeMap[type] || "info";
}

// 将后端 Notice 映射到组件展示结构
const mapNoticeToAnnouncement = (notice) => {
    const stripHtml = (html) => {
        if (!html) return "";
        return html.replace(/<[^>]*>/g, "");
    };

    // 解析附件数据
    let attachments = [];
    if (notice.attachments) {
        try {
            attachments =
                typeof notice.attachments === "string"
                    ? JSON.parse(notice.attachments)
                    : notice.attachments;
        } catch (e) {
            console.warn("解析附件数据失败", e);
            attachments = [];
        }
    }

    const content = notice.content || "";
    return {
        id: notice.nid,
        title: notice.title || "未命名公告",
        status: notice.status || "",
        type: notice.type,
        summary: notice.summary || stripHtml(content).slice(0, 140),
        content: content,
        publishDate: notice.publishDate ? parseDate(notice.publishDate) : null,
        uid: notice.uid,
        author: notice.author
            ? notice.author
            : notice.uid
              ? String(notice.uid)
              : "系统管理员",
        views: notice.views ? notice.views : 0,
        isRead: false,
        attachments: attachments,
    };
};

// 查看公告
const viewNotice = async (item) => {
    // 优先从后端获取完整详情
    try {
        if (item && item.nid) {
            const res = await request.get(`/notice/selectByNid/${item.nid}`);
            if (res && (res.code === "200" || res.code === 200)) {
                const n = res.data || {};
                selectedAnnouncement.value = mapNoticeToAnnouncement(n);
            } else {
                // 回退到传入项
                selectedAnnouncement.value = item;
                ElMessage.warning(res.msg || "获取详情失败，显示简略信息");
            }
        } else {
            selectedAnnouncement.value = item;
        }
    } catch (e) {
        selectedAnnouncement.value = item;
        ElMessage.error("请求公告详情失败");
    }

    dialogVisible.value = true;
    // 本地标记为已读并增加阅读数
    if (selectedAnnouncement.value && !selectedAnnouncement.value.isRead) {
        selectedAnnouncement.value.isRead = true;
        selectedAnnouncement.value.views =
            (selectedAnnouncement.value.views || 0) + 1;
    }
    try {
        const payload = {
            nid: item.nid,
            views: selectedAnnouncement.value.views,
        };
        const res = await request.post(`/notice/updateViews`, payload);
        if (res && (res.code === "200" || res.code === 200)) {
            // 同步更新本地列表中的阅读数
            const idx = recentNotices.value.findIndex(
                (a) => a.nid === item.nid,
            );
            if (idx !== -1) {
                recentNotices.value[idx].views =
                    selectedAnnouncement.value.views;
            }
        } else {
            ElMessage.warning(res.msg || "更新阅读数失败");
        }
    } catch (e) {
        ElMessage.error("更新阅读数请求失败");
    }
};

// 公告类型标签
const getTagType = (type) => {
    const typeMap = {
        系统更新: "primary",
        维护通知: "warning",
        功能上线: "success",
        其他公告: "info",
    };
    return typeMap[type] || "info";
};

// 下载文件
const handleDownloadFile = (file) => {
    if (!file.url) {
        ElMessage.warning("文件路径不存在");
        return;
    }
    // 后端返回的路径已经包含 /api 前缀
    const downloadUrl = file.url.startsWith("http") ? file.url : file.url;

    // 创建隐藏的 a 标签进行下载
    const link = document.createElement("a");
    link.href = downloadUrl;
    link.download = file.name;
    link.target = "_blank";
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
};

// 格式化文件大小
const formatFileSize = (bytes) => {
    if (!bytes || bytes === 0) return "0 B";
    const k = 1024;
    const sizes = ["B", "KB", "MB", "GB"];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return (bytes / Math.pow(k, i)).toFixed(2) + " " + sizes[i];
};

// 关闭公告弹窗
const markAsRead = () => {
    dialogVisible.value = false;
    ElMessage.success("感谢您的阅读");
};

// 跳转到公告列表
function goToNotices() {
    router.push("/notice/index");
}

// 待办事项状态变化
function handleTodoChange(todo) {
    console.log("待办事项状态变化:", todo);
}

// 初始化
onMounted(() => {
    fetchLastSignTime();
    fetchRecentNotices();
});
</script>

<style scoped>
.dashboard {
    padding: 20px;
    background-color: #f5f7fa;
    min-height: calc(100vh - 60px);
}

/* 欢迎区域 */
.welcome-section {
    margin-bottom: 20px;
}

.welcome-banner {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    padding: 30px;
    border-radius: 8px;
}

.welcome-banner h2 {
    margin: 0 0 8px 0;
    font-size: 24px;
}

.welcome-banner p {
    margin: 0;
    opacity: 0.9;
}

/* 统计卡片 */
.stats-section {
    margin-bottom: 20px;
}

.stat-card {
    margin-bottom: 16px;
}

.stat-content {
    display: flex;
    align-items: center;
    gap: 16px;
}

.stat-icon {
    width: 48px;
    height: 48px;
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
}

.stat-info {
    flex: 1;
}

.stat-value {
    font-size: 24px;
    font-weight: bold;
    color: #303133;
}

.stat-title {
    font-size: 14px;
    color: #909399;
}

/* 卡片头部 */
.card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

/* 快捷入口 */
.quick-access {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 16px;
}

.quick-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 16px;
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.3s;
    background-color: #f5f7fa;
}

.quick-item:hover {
    background-color: #e8eef5;
    transform: translateY(-2px);
}

.quick-icon {
    width: 40px;
    height: 40px;
    border-radius: 10px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    margin-bottom: 8px;
}

.quick-name {
    font-size: 13px;
    color: #606266;
}

/* 公告列表 */
.notice-list {
    display: flex;
    flex-direction: column;
    gap: 12px;
}

.notice-item {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 10px;
    border-radius: 6px;
    cursor: pointer;
    transition: background-color 0.2s;
}

.notice-item:hover {
    background-color: #f5f7fa;
}

.notice-item .notice-title {
    flex: 1;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    color: #303133;
}

.notice-item .notice-date {
    font-size: 12px;
    color: #909399;
}

/* 打卡模块 */
.clock-card {
    text-align: center;
}

.clock-content {
    padding: 10px 0;
}

.clock-content .date {
    font-size: 14px;
    color: #909399;
}

.clock-content .time {
    font-size: 32px;
    font-weight: bold;
    color: #303133;
    margin: 10px 0;
}

.clock-buttons {
    display: flex;
    justify-content: center;
    gap: 10px;
    margin-bottom: 12px;
}

.last-sign {
    font-size: 12px;
    color: #909399;
}

/* 待办事项 */
.todo-list {
    display: flex;
    flex-direction: column;
    gap: 10px;
}

.todo-item {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 8px 0;
    border-bottom: 1px solid #ebeef5;
}

.todo-item:last-child {
    border-bottom: none;
}

/* 公告详情对话框 */
.detail-dialog :deep(.el-dialog__body) {
    padding: 20px;
    max-height: 500px;
    overflow-y: auto;
}

.detail-content {
    display: flex;
    flex-direction: column;
    gap: 16px;
}

.detail-meta {
    display: flex;
    align-items: center;
    gap: 16px;
    flex-wrap: wrap;
    padding-bottom: 12px;
    border-bottom: 1px solid #ebeef5;
    font-size: 13px;
    color: #909399;
}

.detail-body {
    line-height: 1.8;
    color: #303133;
}

.detail-body :deep(p) {
    margin: 0 0 12px 0;
}

.detail-body :deep(ul) {
    margin: 8px 0;
    padding-left: 20px;
}

.detail-body :deep(li) {
    margin: 4px 0;
}

.detail-body :deep(strong) {
    color: #409eff;
}

.detail-footer {
    padding-top: 12px;
    border-top: 1px solid #ebeef5;
    font-size: 12px;
    color: #909399;
    text-align: right;
}

/* 附件样式 */
.attachment-section {
    margin-top: 20px;
    padding-top: 15px;
    border-top: 1px solid #ebeef5;
}

.attachment-title {
    margin: 0 0 12px 0;
    font-size: 14px;
    color: #303133;
    display: flex;
    align-items: center;
    gap: 6px;
}

.attachment-list {
    display: flex;
    flex-direction: column;
    gap: 8px;
}

.attachment-item {
    display: flex;
    align-items: center;
    padding: 10px 12px;
    background-color: #f5f7fa;
    border-radius: 4px;
    transition: background-color 0.2s;
}

.attachment-item:hover {
    background-color: #e8eef5;
}

.attachment-icon {
    color: #909399;
    margin-right: 8px;
}

.attachment-name {
    flex: 1;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    color: #606266;
}

.attachment-size {
    color: #909399;
    font-size: 12px;
    margin: 0 10px;
}

/* 响应式 */
@media (max-width: 768px) {
    .dashboard {
        padding: 12px;
    }

    .welcome-banner {
        padding: 20px;
    }

    .welcome-banner h2 {
        font-size: 20px;
    }

    .quick-access {
        grid-template-columns: repeat(2, 1fr);
    }
}
</style>
