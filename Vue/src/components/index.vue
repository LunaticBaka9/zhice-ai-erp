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
            <el-col :xs="24" :sm="12" :md="6" v-for="stat in statsCards" :key="stat.title">
                <el-card shadow="hover" class="stat-card">
                    <div class="stat-content">
                        <div class="stat-icon" :style="{ backgroundColor: stat.color }">
                            <el-icon :size="24">
                                <component :is="stat.icon" />
                            </el-icon>
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
                            <div class="quick-icon" :style="{ backgroundColor: item.color }">
                                <el-icon :size="20">
                                    <component :is="item.icon" />
                                </el-icon>
                            </div>
                            <span class="quick-name">{{ item.name }}</span>
                        </div>
                    </div>
                </el-card>

                <!-- 库存预警 -->
                <el-card class="notices-card" shadow="never" style="margin-top: 20px">
                    <template #header>
                        <div class="card-header">
                            <span>库存预警 Top 5</span>
                            <el-button type="primary" link @click="goToInventoryWarning"> 查看更多 </el-button>
                        </div>
                    </template>
                    <div class="notice-list">
                        <div
                            v-for="item in inventoryWarnings"
                            :key="item.skuCode"
                            class="notice-item"
                            @click="handleWarningClick(item)"
                        >
                            <el-tag :type="item.warningType === '缺货' ? 'danger' : 'warning'" size="small">
                                {{ item.warningType }}
                            </el-tag>
                            <span class="notice-title"> {{ item.skuName }} ({{ item.skuCode }}) </span>
                            <span class="notice-stock">
                                当前库存: {{ item.currentStock }} / {{ item.warningType === "缺货" ? "下限" : "上限" }}:
                                {{ item.threshold }}
                            </span>
                        </div>
                        <el-empty v-if="inventoryWarnings.length === 0" description="暂无库存预警" :image-size="60" />
                    </div>
                </el-card>

                <!-- 销售趋势简图（简易） -->
                <el-card class="chart-card" shadow="never" style="margin-top: 20px">
                    <template #header>
                        <div class="card-header">
                            <span>近7天销售趋势</span>
                            <el-button type="primary" link @click="goToSalesReport"> 详细报表 </el-button>
                        </div>
                    </template>
                    <div class="chart-placeholder">
                        <div v-for="(day, idx) in weekSales" :key="idx" class="chart-bar-container">
                            <div class="chart-bar-label">{{ day.label }}</div>
                            <div class="chart-bar-wrapper">
                                <div class="chart-bar" :style="{ height: day.height + 'px' }"></div>
                            </div>
                            <div class="chart-bar-value">¥{{ day.amount }}</div>
                        </div>
                    </div>
                </el-card>
            </el-col>

            <!-- 右侧模块 -->
            <el-col :xs="24" :md="8">
                <!-- 最新公告（保留原公告功能） -->
                <el-card class="notices-card" shadow="never" style="margin-top: 20px">
                    <template #header>
                        <div class="card-header">
                            <span>最新公告</span>
                            <el-button type="primary" link @click="goToNotices"> 查看更多 </el-button>
                        </div>
                    </template>
                    <div class="notice-list">
                        <div
                            v-for="notice in recentNotices"
                            :key="notice.nid"
                            class="notice-item"
                            @click="viewNotice(notice)"
                        >
                            <el-tag :type="getNoticeTagType(notice.type)" size="small">
                                {{ notice.type }}
                            </el-tag>
                            <span class="notice-title">
                                <span v-if="!isNoticeRead(notice.nid)" class="unread-badge"></span>
                                {{ notice.title }}
                            </span>
                            <span class="notice-date">
                                {{ formatDateTime(notice.publishDate) }}
                            </span>
                        </div>
                        <el-empty v-if="recentNotices.length === 0" description="暂无公告" :image-size="60" />
                    </div>
                </el-card>

                <!-- 最新消息模块 -->
                <el-card class="notices-card" shadow="never" style="margin-top: 20px">
                    <template #header>
                        <div class="card-header">
                            <span>最新消息</span>
                            <el-button type="primary" link @click="goToMessages"> 查看更多 </el-button>
                        </div>
                    </template>
                    <div class="notice-list">
                        <div
                            v-for="msg in recentMessages"
                            :key="msg.id"
                            class="notice-item"
                            @click="viewMessage(msg)"
                        >
                            <el-tag :type="getMessageTagType(msg.type)" size="small">
                                {{ getMessageTypeText(msg.type) }}
                            </el-tag>
                            <span class="notice-title">
                                <span v-if="!isMessageRead(msg.id)" class="unread-badge"></span>
                                {{ msg.content }}
                            </span>
                            <span class="notice-date">
                                {{ formatDateTime(msg.createTime) }}
                            </span>
                        </div>
                        <el-empty v-if="recentMessages.length === 0" description="暂无消息" :image-size="60" />
                    </div>
                </el-card>
            </el-col>
        </el-row>

        <!-- 公告详情弹窗（原代码保留） -->
        <el-dialog v-model="dialogVisible" :title="selectedAnnouncement?.title" width="1200px" class="detail-dialog">
            <div v-if="selectedAnnouncement" class="detail-content">
                <div class="detail-meta">
                    <el-tag :type="getTagType(selectedAnnouncement.type)" size="small">
                        {{ selectedAnnouncement.type }}
                    </el-tag>
                    <span class="date">{{ formatDateTime(selectedAnnouncement.publishDate) }}</span>
                    <span class="author">发布人：{{ selectedAnnouncement.author }}</span>
                </div>
                <div class="detail-body" v-html="selectedAnnouncement.content"></div>
                <div
                    v-if="selectedAnnouncement.attachments && selectedAnnouncement.attachments.length > 0"
                    class="attachment-section"
                >
                    <h4 class="attachment-title">
                        <el-icon><Document /></el-icon> 附件下载
                    </h4>
                    <div class="attachment-list">
                        <div
                            v-for="(file, index) in selectedAnnouncement.attachments"
                            :key="index"
                            class="attachment-item"
                        >
                            <el-icon class="attachment-icon"><Document /></el-icon>
                            <span class="attachment-name">{{ file.name }}</span>
                            <span class="attachment-size">{{ formatFileSize(file.size) }}</span>
                            <el-button type="primary" link size="small" @click="handleDownloadFile(file)">
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
                <el-button type="primary" @click="markAsRead">我知道了</el-button>
            </template>
        </el-dialog>
    </div>
</template>

<script setup>
import { ref, onMounted, computed } from "vue";
import { useRouter } from "vue-router";
import { ElMessage } from "element-plus";
import {
    Document,
    Download,
    List,
    Bell,
    Clock,
    TrendCharts,
    EditPen,
    User,
    Setting,
    ShoppingCart,
    Box,
    Plus,
    Search,
} from "@element-plus/icons-vue";
import request from "../utils/request";
import { formatDateTime, parseDate } from "../utils/date";

const router = useRouter();

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

// ---------- 统计卡片数据 ----------
const statsCards = ref([
    {
        title: "今日销售额",
        value: "¥12,800",
        icon: "TrendCharts",
        color: "#409EFF",
    },
    {
        title: "今日订单数",
        value: "42",
        icon: "ShoppingCart",
        color: "#67C23A",
    },
    {
        title: "待采购入库",
        value: "8",
        icon: "Box",
        color: "#E6A23C",
    },
    {
        title: "库存预警",
        value: "5",
        icon: "Bell",
        color: "#F56C6C",
    },
]);

// ---------- 快捷入口（进销存核心操作） ----------
const quickAccessItems = [
    {
        name: "销售开单",
        icon: "ShoppingCart",
        color: "#409EFF",
        route: "/sale/order",
    },
    {
        name: "采购入库",
        icon: "Box",
        color: "#67C23A",
        route: "/purchase/inbound",
    },
    {
        name: "库存查询",
        icon: "Search",
        color: "#E6A23C",
        route: "/inventory/query",
    },
    {
        name: "新增客户",
        icon: "Plus",
        color: "#909399",
        route: "/base/customer",
    },
    {
        name: "个人中心",
        icon: "User",
        color: "#F56C6C",
        route: "/userInfo",
    },
    {
        name: "系统设置",
        icon: "Setting",
        color: "#909399",
        route: "/system/user",
    },
];

// ---------- 库存预警数据 ----------
const inventoryWarnings = ref([]);

// 获取库存预警数据
async function fetchInventoryWarnings() {
    try {
        const res = await request.get("/inventoryAlert/list", {
            params: { pageNum: 1, pageSize: 5 },
        });
        if (res && (res.code === "200" || res.code === 200)) {
            const list = res.data?.list || res.data?.records || [];
            inventoryWarnings.value = list.map((item) => {
                const stock = item.stockQuantity || 0;
                const low = item.stockLow || 0;
                const high = item.stockHigh || 0;
                let warningType = "正常";
                if (stock <= 0) {
                    warningType = "缺货";
                } else if (stock < low) {
                    warningType = "库存不足";
                } else if (stock > high) {
                    warningType = "积压";
                }
                return {
                    skuCode: item.skuCode,
                    skuName: item.goodsName,
                    currentStock: stock,
                    threshold: stock <= 0 ? low : high,
                    warningType: warningType,
                    id: item.id,
                };
            });
        }
    } catch (e) {
        console.error("fetchInventoryWarnings error", e);
    }
}

// 获取预警统计数量
async function fetchAlertStatistics() {
    try {
        const res = await request.get("/inventoryAlert/statistics");
        if (res && (res.code === "200" || res.code === 200)) {
            const total = res.data?.totalAlerts || 0;
            // 更新统计卡片中的库存预警数量
            const alertCard = statsCards.value.find((s) => s.title === "库存预警");
            if (alertCard) {
                alertCard.value = total;
            }
        }
    } catch (e) {
        console.error("fetchAlertStatistics error", e);
    }
}

// ---------- 最新消息数据 ----------
const recentMessages = ref([]);

// 生成模拟消息数据
function generateMockMessages() {
    const types = ["system", "approval", "todo", "finance", "hr"];
    const contents = [
        "您有待审批的采购申请单，请及时处理",
        "库存预警：农夫山泉矿泉水库存不足",
        "本月销售报表已生成，请查阅",
        "系统将于今晚22:00进行维护升级",
        "您有新的待办任务需要处理",
    ];
    const now = new Date();
    return contents.map((content, index) => ({
        id: index + 1,
        type: types[index % types.length],
        content: content,
        createTime: new Date(now.getTime() - index * 3600000),
    }));
}

// 获取最新消息（使用模拟数据）
function fetchRecentMessages() {
    recentMessages.value = generateMockMessages();
}

// 消息类型标签
function getMessageTagType(type) {
    const typeMap = {
        system: "primary",
        approval: "warning",
        todo: "info",
        finance: "success",
        hr: "danger",
    };
    return typeMap[type] || "info";
}

// 消息类型文本
function getMessageTypeText(type) {
    const typeMap = {
        system: "系统",
        approval: "审批",
        todo: "待办",
        finance: "财务",
        hr: "人事",
    };
    return typeMap[type] || "消息";
}

// 消息已读状态
function isMessageRead(msgId) {
    const key = "read_messages_" + (getLocalUserId() || "guest");
    try {
        const data = localStorage.getItem(key);
        return data ? JSON.parse(data).includes(msgId) : false;
    } catch (e) {
        return false;
    }
}

// 查看消息
function viewMessage(msg) {
    router.push("/message");
}

// ---------- 销售趋势简图数据 ----------
const weekSales = ref([
    { label: "周一", amount: 3200, height: 40 },
    { label: "周二", amount: 4500, height: 56 },
    { label: "周三", amount: 3800, height: 48 },
    { label: "周四", amount: 5100, height: 64 },
    { label: "周五", amount: 6200, height: 78 },
    { label: "周六", amount: 7800, height: 98 },
    { label: "周日", amount: 5300, height: 66 },
]);

// ---------- 公告相关（保留原逻辑） ----------
const recentNotices = ref([]);
const dialogVisible = ref(false);
const selectedAnnouncement = ref(null);

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

// 已读公告管理
function getReadNoticeIds() {
    try {
        const userId = getLocalUserId();
        if (!userId) return [];
        const key = `read_notices_${userId}`;
        const data = localStorage.getItem(key);
        return data ? JSON.parse(data) : [];
    } catch (e) {
        return [];
    }
}

function saveReadNoticeId(noticeId) {
    try {
        const userId = getLocalUserId();
        if (!userId) return;
        const key = `read_notices_${userId}`;
        const ids = getReadNoticeIds();
        if (!ids.includes(noticeId)) {
            ids.push(noticeId);
            localStorage.setItem(key, JSON.stringify(ids));
        }
    } catch (e) {
        console.error("保存已读公告ID失败", e);
    }
}

function isNoticeRead(noticeId) {
    const ids = getReadNoticeIds();
    return ids.includes(noticeId);
}

// 获取最近公告
async function fetchRecentNotices() {
    try {
        const res = await request.get("/notice/list", {
            params: { pageNum: 1, pageSize: 5 },
        });
        if (res && (res.code === "200" || res.code === 200)) {
            recentNotices.value = res.data?.list || [];
        }
    } catch (e) {
        console.error("fetchRecentNotices error", e);
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

const mapNoticeToAnnouncement = (notice) => {
    const stripHtml = (html) => {
        if (!html) return "";
        return html.replace(/<[^>]*>/g, "");
    };

    let attachments = [];
    if (notice.attachments) {
        try {
            attachments = typeof notice.attachments === "string" ? JSON.parse(notice.attachments) : notice.attachments;
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
        author: notice.author ? notice.author : notice.uid ? String(notice.uid) : "系统管理员",
        views: notice.views ? notice.views : 0,
        isRead: false,
        attachments: attachments,
    };
};

const viewNotice = async (item) => {
    try {
        if (item && item.nid) {
            const res = await request.get(`/notice/selectByNid/${item.nid}`);
            if (res && (res.code === "200" || res.code === 200)) {
                const n = res.data || {};
                selectedAnnouncement.value = mapNoticeToAnnouncement(n);
            } else {
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
    saveReadNoticeId(item.nid);

    if (selectedAnnouncement.value && !selectedAnnouncement.value.isRead) {
        selectedAnnouncement.value.isRead = true;
        selectedAnnouncement.value.views = (selectedAnnouncement.value.views || 0) + 1;
    }

    try {
        const payload = { nid: item.nid, views: selectedAnnouncement.value.views };
        await request.post(`/notice/updateViews`, payload);
        const userId = getLocalUserId();
        if (userId) {
            await request.post("/notice/markAsRead", {
                noticeId: item.nid,
                userId: userId,
            });
        }
    } catch (e) {
        // 静默失败
    }
};

const getTagType = (type) => {
    const typeMap = {
        系统更新: "primary",
        维护通知: "warning",
        功能上线: "success",
        其他公告: "info",
    };
    return typeMap[type] || "info";
};

const handleDownloadFile = (file) => {
    if (!file.url) {
        ElMessage.warning("文件路径不存在");
        return;
    }
    const downloadUrl = file.url.startsWith("http") ? file.url : file.url;
    const link = document.createElement("a");
    link.href = downloadUrl;
    link.download = file.name;
    link.target = "_blank";
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
};

const formatFileSize = (bytes) => {
    if (!bytes || bytes === 0) return "0 B";
    const k = 1024;
    const sizes = ["B", "KB", "MB", "GB"];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return (bytes / Math.pow(k, i)).toFixed(2) + " " + sizes[i];
};

const markAsRead = () => {
    dialogVisible.value = false;
    ElMessage.success("感谢您的阅读");
};

// ---------- 路由跳转方法 ----------
function handleQuickAccess(item) {
    if (item.route) router.push(item.route);
}

function goToInventoryWarning() {
    router.push("/inventory/warning");
}

function goToSalesReport() {
    router.push("/report/sales");
}

function goToNotices() {
    router.push("/notice/index");
}

function goToMessages() {
    router.push("/message");
}

function handleWarningClick(item) {
    // 跳转到库存预警页面
    router.push("/inventory/warning");
}

function handleTodoClick(todo) {
    if (todo.route) router.push(todo.route);
}

// ---------- 初始化 ----------
onMounted(() => {
    fetchRecentNotices();
    fetchRecentMessages();
    fetchInventoryWarnings();
    fetchAlertStatistics();
});
</script>

<style scoped>
.dashboard {
    padding: 20px;
    background-color: #f5f7fa;
    min-height: calc(100vh - 60px);
}

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

/* 库存预警列表 */
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

.notice-title {
    flex: 1;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    color: #303133;
    display: flex;
    align-items: center;
    gap: 6px;
}

.notice-stock {
    font-size: 12px;
    color: #909399;
    white-space: nowrap;
}

.unread-badge {
    display: inline-block;
    width: 8px;
    height: 8px;
    background-color: #f56c6c;
    border-radius: 50%;
    flex-shrink: 0;
    animation: pulse 1.5s infinite;
}

@keyframes pulse {
    0%,
    100% {
        opacity: 1;
        transform: scale(1);
    }
    50% {
        opacity: 0.6;
        transform: scale(1.2);
    }
}

.notice-date {
    font-size: 12px;
    color: #909399;
}

/* 图表占位 */
.chart-placeholder {
    display: flex;
    justify-content: space-around;
    align-items: flex-end;
    height: 160px;
    padding: 10px 0;
}

.chart-bar-container {
    display: flex;
    flex-direction: column;
    align-items: center;
    width: 12%;
}

.chart-bar-label {
    font-size: 12px;
    color: #909399;
    margin-bottom: 5px;
}

.chart-bar-wrapper {
    height: 100px;
    width: 100%;
    display: flex;
    align-items: flex-end;
    justify-content: center;
}

.chart-bar {
    width: 30px;
    background: linear-gradient(180deg, #409eff 0%, #66b1ff 100%);
    border-radius: 4px 4px 0 0;
    transition: height 0.3s;
    min-height: 4px;
}

.chart-bar-value {
    font-size: 12px;
    color: #303133;
    margin-top: 5px;
    font-weight: 500;
}

.todo-item {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 8px 0;
    border-bottom: 1px solid #ebeef5;
    cursor: pointer;
}

.todo-item:last-child {
    border-bottom: none;
}

.todo-item:hover {
    background-color: #f5f7fa;
}

.todo-content {
    display: flex;
    align-items: center;
    gap: 8px;
}

.todo-text {
    color: #303133;
}

.todo-count {
    background-color: #f0f2f5;
    padding: 2px 8px;
    border-radius: 10px;
    font-size: 12px;
    color: #606266;
}

/* 公告详情对话框（保留原样式） */
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

.detail-footer {
    padding-top: 12px;
    border-top: 1px solid #ebeef5;
    font-size: 12px;
    color: #909399;
    text-align: right;
}

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
