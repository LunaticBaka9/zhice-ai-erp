<template>
    <el-header class="header-container">
        <!-- 左侧区域 -->
        <div class="header-left">
            <el-icon class="collapse-icon" @click="handleToggle()">
                <Fold v-if="!isCollapse" />
                <Expand v-else />
            </el-icon>
            <!-- 面包屑导航 -->
            <el-breadcrumb separator="/">
                <el-breadcrumb-item :to="{ path: '/' }">首页</el-breadcrumb-item>
                <el-breadcrumb-item v-for="(item, index) in breadcrumbs" :key="index">
                    <template v-if="item.path && index !== breadcrumbs.length - 1">
                        <el-link type="primary" @click="handleNavigate(item.path)">
                            {{ item.name }}
                        </el-link>
                    </template>
                    <template v-else>
                        <span>{{ item.name }}</span>
                    </template>
                </el-breadcrumb-item>
            </el-breadcrumb>
        </div>

        <!-- 右侧区域 -->
        <div class="header-right">
            <!-- 消息通知 -->
            <el-popover
                placement="bottom-end"
                :width="360"
                trigger="click"
                popper-class="message-popover"
                @show="handleMessagePopoverShow"
            >
                <template #reference>
                    <el-badge :value="unreadCount" :hidden="unreadCount === 0" :max="99">
                        <div class="action-icon message-icon" @click="fetchMessages">
                            <el-icon :size="20"><Bell /></el-icon>
                        </div>
                    </el-badge>
                </template>

                <div class="message-panel">
                    <div class="message-header">
                        <span class="title">消息通知</span>
                        <el-button v-if="unreadCount > 0" type="primary" link size="small" @click="markAllAsRead">
                            全部已读
                        </el-button>
                    </div>

                    <div class="message-list" v-loading="loading">
                        <template v-if="messageList.length > 0">
                            <div
                                v-for="item in messageList"
                                :key="item.id"
                                class="message-item"
                                :class="{ unread: !item.isRead }"
                                @click="handleMessageClick(item)"
                            >
                                <div class="message-icon-wrapper">
                                    <el-icon :size="20" :color="getMessageIconColor(item.type)">
                                        <component :is="getMessageIcon(item.type)" />
                                    </el-icon>
                                </div>
                                <div class="message-content">
                                    <div class="message-title">{{ item.title }}</div>
                                    <div class="message-desc">{{ item.content }}</div>
                                    <div class="message-time">
                                        {{ formatTime(item.createTime) }}
                                    </div>
                                </div>
                                <div v-if="!item.isRead" class="unread-dot"></div>
                            </div>
                        </template>
                        <el-empty v-else description="暂无消息" :image-size="80" />
                    </div>

                    <div class="message-footer" v-if="messageList.length > 0 && total > messageList.length">
                        <el-button type="primary" link @click="loadMore">查看更多</el-button>
                    </div>
                </div>
            </el-popover>

            <el-icon class="header-icon" @click="toggleFullscreen">
                <FullScreen v-if="!isFullscreen" />
                <Aim v-else />
            </el-icon>
            <el-dropdown @command="handleCommand" trigger="click" v-if="data.user">
                <div class="user-dropdown">
                    <el-avatar :src="data.userInfo.avatar || defaultAvatar" :size="32" />
                    <span class="username">{{ data.userInfo.name }}</span>
                    <el-icon class="arrow-down"><ArrowDown /></el-icon>
                </div>
                <template #dropdown>
                    <el-dropdown-menu>
                        <el-dropdown-item command="profile">
                            <el-icon><Avatar /></el-icon>
                            个人中心
                        </el-dropdown-item>
                        <el-dropdown-item command="settings">
                            <el-icon><Setting /></el-icon>
                            系统设置
                        </el-dropdown-item>
                        <el-dropdown-item divided command="logout">
                            <el-icon><SwitchButton /></el-icon>
                            退出登录
                        </el-dropdown-item>
                    </el-dropdown-menu>
                </template>
            </el-dropdown>
            <el-button v-else @click="login">登录</el-button>
        </div>
    </el-header>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, reactive } from "vue";
import { useRoute, useRouter } from "vue-router";
import { ElMessage, ElMessageBox, ElNotification } from "element-plus";
import {
    Fold,
    Expand,
    Bell,
    ArrowDown,
    SwitchButton,
    Avatar,
    Setting,
    FullScreen,
    Aim,
    Warning,
    InfoFilled,
    Tickets,
    SuccessFilled,
    ChatDotRound,
    Document,
} from "@element-plus/icons-vue";
import request from "../../utils/request";
import { useMenuStore } from "../../store/menu";
const menuStore = useMenuStore();
const isCollapse = menuStore.isCollapse;
const handleToggle = menuStore.handleToggle;

const data = reactive({
    user: JSON.parse(localStorage.getItem("local_user")),
    userInfo: {},
});

// 定义事件
const emit = defineEmits(["update:isCollapse", "search", "logout"]);

// 路由
const route = useRoute();
const router = useRouter();

const breadcrumbMap = {
    "/userInfo": "个人中心",
    "/message": "消息中心",
    "/notice/index": "公告详情",
    "/notice/post": "公告发布",
    "/notice/manager": "公告管理",
    "/system/user": "用户管理",
    "/system/sign": "打卡管理",
    "/user/list": "用户列表",
    "/user/detail": "用户详情",
    "/order": "订单管理",
    "/order/list": "订单列表",
    "/order/detail": "订单详情",
    "/product": "商品管理",
    "/product/list": "商品列表",
    "/product/detail": "商品详情",
};

// 生成面包屑数据
const breadcrumbs = computed(() => {
    const matched = route.matched.filter((item) => item.path !== "");
    const crumbs = [];

    matched.forEach((route) => {
        // 优先使用路由meta中配置的面包屑名称
        let name = route.meta?.breadcrumb || route.meta?.title;
        if (!name) {
            // 如果meta中没有配置，则从映射表中获取
            name = breadcrumbMap[route.path];
        }
        if (!name && route.name) {
            // 最后尝试使用路由名称
            name = route.name;
        }

        if (name) {
            crumbs.push({
                name,
                path: route.path,
            });
        }
    });

    return crumbs;
});
// 导航处理
const handleNavigate = (path) => {
    router.push(path);
};

// 默认头像
const defaultAvatar = "https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png";

// 搜索关键词
const searchKeyword = ref("");

// 全屏状态
const isFullscreen = ref(false);

// 主题模式
const theme = ref(localStorage.getItem("theme") || "light");

// 消息相关状态
const unreadCount = ref(0);
const messageList = ref([]);
const loading = ref(false);
const currentPage = ref(1);
const pageSize = ref(5);
const total = ref(0);

// 模拟消息数据
const mockMessages = [
    {
        id: 1,
        title: "系统升级通知",
        content: "系统将于今晚22:00进行升级维护，预计持续2小时",
        type: "system",
        isRead: false,
        createTime: "2024-01-15 10:30:00",
    },
    {
        id: 2,
        title: "新任务分配",
        content: "您有一个新的任务需要处理，请及时查看",
        type: "task",
        isRead: false,
        createTime: "2024-01-15 09:15:00",
    },
    {
        id: 3,
        title: "审批通过",
        content: "您提交的请假申请已通过审批",
        type: "approve",
        isRead: true,
        createTime: "2024-01-14 16:20:00",
    },
    {
        id: 4,
        title: "新评论",
        content: "您的项目文档有新的评论",
        type: "comment",
        isRead: false,
        createTime: "2024-01-14 14:45:00",
    },
    {
        id: 5,
        title: "会议提醒",
        content: "下午3点召开项目进度会议，请准时参加",
        type: "reminder",
        isRead: true,
        createTime: "2024-01-14 10:00:00",
    },
    {
        id: 6,
        title: "文件更新",
        content: "项目需求文档已更新，请查看最新版本",
        type: "file",
        isRead: false,
        createTime: "2024-01-13 17:30:00",
    },
];

// 获取消息图标
const getMessageIcon = (type) => {
    const iconMap = {
        system: InfoFilled,
        task: Tickets,
        approve: SuccessFilled,
        comment: ChatDotRound,
        reminder: Bell,
        file: Document,
        warning: Warning,
    };
    return iconMap[type] || InfoFilled;
};

// 获取消息图标颜色
const getMessageIconColor = (type) => {
    const colorMap = {
        system: "#409EFF",
        task: "#E6A23C",
        approve: "#67C23A",
        comment: "#909399",
        reminder: "#F56C6C",
        file: "#909399",
    };
    return colorMap[type] || "#909399";
};

// 格式化时间
const formatTime = (time) => {
    const date = new Date(time);
    const now = new Date();
    const diff = now - date;

    if (diff < 3600000) {
        return `${Math.floor(diff / 60000)}分钟前`;
    } else if (diff < 86400000) {
        return `${Math.floor(diff / 3600000)}小时前`;
    } else if (diff < 604800000) {
        return `${Math.floor(diff / 86400000)}天前`;
    }
    return time.slice(0, 16);
};

// 获取消息列表
const fetchMessages = async () => {
    loading.value = true;
    try {
        // 模拟API请求
        await new Promise((resolve) => setTimeout(resolve, 500));

        const start = (currentPage.value - 1) * pageSize.value;
        const end = start + pageSize.value;
        const list = mockMessages.slice(start, end);
        const totalMessages = mockMessages.length;

        messageList.value = list;
        total.value = totalMessages;

        // 计算未读数量（实际项目中应从接口获取）
        updateUnreadCount();
    } catch (error) {
        ElMessage.error("获取消息失败");
    } finally {
        loading.value = false;
    }
};

// 更新未读数量
const updateUnreadCount = () => {
    const unread = mockMessages.filter((item) => !item.isRead).length;
    unreadCount.value = unread;
};

// 处理消息点击
const handleMessageClick = (item) => {
    if (!item.isRead) {
        item.isRead = true;
        updateUnreadCount();
        // 可以在这里调用标记已读的接口
        ElNotification({
            title: item.title,
            message: item.content,
            type: "info",
            duration: 3000,
        });
    } else {
        ElNotification({
            title: item.title,
            message: item.content,
            type: "info",
            duration: 3000,
        });
    }
};

// 全部标记为已读
const markAllAsRead = () => {
    mockMessages.forEach((item) => {
        item.isRead = true;
    });
    messageList.value.forEach((item) => {
        item.isRead = true;
    });
    updateUnreadCount();
    ElMessage.success("已全部标记为已读");
};

// 模拟实时消息推送
const simulateRealTimeMessage = () => {
    setTimeout(() => {
        const newMessage = {
            id: Date.now(),
            title: "实时消息",
            content: "您有一条新的实时消息",
            type: "system",
            isRead: false,
            createTime: new Date().toLocaleString(),
        };
        mockMessages.unshift(newMessage);
        updateUnreadCount();

        // 如果消息弹窗未打开，显示通知
        ElNotification({
            title: "新消息",
            message: newMessage.title,
            type: "info",
            duration: 5000,
        });
    }, 10000);
};

onMounted(() => {
    updateUnreadCount();
    // 模拟实时消息
    simulateRealTimeMessage();
    // 加载用户详细信息，确保头像和名称可用
    if (data.user && data.user.uid) {
        request.get("user/selectById/" + data.user.uid).then((res) => {
            if (res && res.code === "200") {
                data.userInfo = res.data || {};
                // 若 local_user 中缺少 avatar，则同步
                const localUserStr = localStorage.getItem("local_user");
                if (localUserStr) {
                    try {
                        const localUser = JSON.parse(localUserStr);
                        if (!localUser.avatar && data.userInfo.avatar) {
                            localUser.avatar = data.userInfo.avatar;
                            localStorage.setItem("local_user", JSON.stringify(localUser));
                        }
                    } catch (e) {}
                }
            }
        });
    }
});

// 加载更多
const loadMore = () => {
    currentPage.value++;
    fetchMessages();
};

// 消息弹窗显示时的处理
const handleMessagePopoverShow = () => {
    if (currentPage.value === 1 && messageList.value.length === 0) {
        fetchMessages();
    }
};

// 处理搜索
const handleSearch = () => {
    if (searchKeyword.value.trim()) {
        emit("search", searchKeyword.value);
    }
};

// 全屏切换
const toggleFullscreen = () => {
    if (!document.fullscreenElement) {
        document.documentElement.requestFullscreen();
        isFullscreen.value = true;
    } else {
        document.exitFullscreen();
        isFullscreen.value = false;
    }
};

// 处理下拉菜单命令
const handleCommand = (command) => {
    switch (command) {
        case "profile":
            router.push("/userInfo");
            break;
        case "settings":
            router.push("/settings");
            break;
        case "logout":
            handleLogout();
            break;
    }
};

// 切换侧边栏 - 直接使用 store 的方法

const handleLogout = () => {
    ElMessageBox.confirm("确认退出登录吗？", "提示", {
        confirmButtonText: "确认",
        cancelButtonText: "取消",
        type: "warning",
    })
        .then(() => {
            logout();
        })
        .catch(() => {});
};

const login = () => {
    router.push("/login");
};

const logout = () => {
    localStorage.removeItem("local_user");
    router.push("/login");
};

onMounted(() => {
    document.addEventListener("fullscreenchange", () => {
        isFullscreen.value = !!document.fullscreenElement;
    });
    document.documentElement.setAttribute("data-theme", theme.value);
});

onUnmounted(() => {
    document.removeEventListener("fullscreenchange", () => {});
});
</script>

<style scoped>
.header-container {
    background-color: #fff;
    border-bottom: 1px solid #e6e9f0;
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0 20px;
    height: 60px;
    box-shadow: 0 1px 4px rgba(0, 21, 41, 0.08);
}

/* 左侧区域 */
.header-left {
    display: flex;
    align-items: center;
    gap: 20px;
}

.collapse-icon {
    font-size: 20px;
    cursor: pointer;
    color: #606266;
    transition: all 0.3s;
}

.collapse-icon:hover {
    color: #409eff;
    transform: scale(1.05);
}

/* 面包屑样式优化 */
:deep(.el-breadcrumb) {
    font-size: 14px;
}

:deep(.el-breadcrumb__inner) {
    color: #606266;
}

:deep(.el-breadcrumb__inner:hover) {
    color: #409eff;
}

/* 右侧区域 */
.header-right {
    display: flex;
    align-items: center;
    gap: 20px;
}

/* 搜索框 */
.search-box {
    margin-right: 8px;
}

.search-input {
    width: 200px;
}

.search-input :deep(.el-input__wrapper) {
    border-radius: 20px;
    transition: all 0.3s;
}

.search-input :deep(.el-input__wrapper:hover) {
    box-shadow: 0 0 0 1px #409eff inset;
}

.search-input :deep(.el-input__wrapper.is-focus) {
    box-shadow: 0 0 0 1px #409eff inset;
}

/* 图标样式 */
.header-icon {
    font-size: 20px;
    cursor: pointer;
    color: #606266;
    transition: all 0.3s;
}

.header-icon:hover {
    color: #409eff;
    transform: scale(1.05);
}

/* 通知徽章 */
.notification-badge {
    cursor: pointer;
}

.notification-badge :deep(.el-badge__content) {
    border: none;
    top: 8px;
    right: 8px;
}

/* 用户下拉菜单 */
.user-dropdown {
    display: flex;
    align-items: center;
    gap: 8px;
    cursor: pointer;
    padding: 4px 8px;
    border-radius: 20px;
    transition: all 0.3s;
}

.user-dropdown:hover {
    background-color: #f5f7fa;
    transform: translateY(-1px);
}

.username {
    color: #303133;
    font-size: 14px;
    font-weight: 500;
}

.arrow-down {
    font-size: 12px;
    color: #909399;
    transition: transform 0.3s;
}

.user-dropdown:hover .arrow-down {
    transform: translateY(2px);
}

/* 通知抽屉样式 */
.notification-list {
    padding: 0 12px;
}

.notification-item {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 16px 12px;
    border-bottom: 1px solid #ebeef5;
    transition: all 0.3s;
    position: relative;
}

.notification-item:hover {
    background-color: #f5f7fa;
}

.notification-icon {
    flex-shrink: 0;
}

.notification-content {
    flex: 1;
}

.notification-title {
    color: #303133;
    font-size: 14px;
    margin-bottom: 4px;
    line-height: 1.4;
}

.notification-time {
    color: #909399;
    font-size: 12px;
}

.notification-close {
    cursor: pointer;
    color: #909399;
    opacity: 0;
    transition: opacity 0.3s;
}

.notification-item:hover .notification-close {
    opacity: 1;
}

.notification-close:hover {
    color: #f56c6c;
}

.empty-notification {
    padding: 40px 0;
}

/* 响应式调整 */
@media (max-width: 768px) {
    .header-container {
        padding: 0 12px;
    }

    .username {
        display: none;
    }

    .search-input {
        width: 120px;
    }

    .header-right {
        gap: 12px;
    }

    :deep(.el-breadcrumb) {
        display: none;
    }
}

/* 深色模式 */
:global([data-theme="dark"]) .header-container {
    background-color: #1f2d3d;
    border-bottom-color: #304156;
}

:global([data-theme="dark"]) .collapse-icon,
:global([data-theme="dark"]) .header-icon {
    color: #bfcbd9;
}

:global([data-theme="dark"]) .collapse-icon:hover,
:global([data-theme="dark"]) .header-icon:hover {
    color: #409eff;
}

:global([data-theme="dark"]) .username {
    color: #e5eaf3;
}

:global([data-theme="dark"]) .user-dropdown:hover {
    background-color: #304156;
}

:global([data-theme="dark"]) .search-input :deep(.el-input__wrapper) {
    background-color: #304156;
    box-shadow: 0 0 0 1px #40506a;
}

:global([data-theme="dark"]) .search-input :deep(.el-input__inner) {
    color: #e5eaf3;
}

/* 消息弹窗样式 */
:deep(.message-popover) {
    padding: 0 !important;
    border-radius: 12px;
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
}

.message-panel {
    display: flex;
    flex-direction: column;
    height: auto;
    max-height: 480px;
}

.message-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 16px 20px;
    border-bottom: 1px solid #f0f0f0;
    background: #fafafa;
    border-radius: 12px 12px 0 0;
}

.message-header .title {
    font-size: 16px;
    font-weight: 600;
    color: #1f2f3d;
}

.message-list {
    flex: 1;
    overflow-y: auto;
    max-height: 360px;
}

.message-item {
    display: flex;
    align-items: flex-start;
    gap: 12px;
    padding: 14px 20px;
    border-bottom: 1px solid #f5f5f5;
    cursor: pointer;
    transition: all 0.2s ease;
    position: relative;
}

.message-item:hover {
    background-color: #f5f7fa;
}

.message-item.unread {
    background-color: #ecf5ff;
}

.message-item.unread:hover {
    background-color: #e1eaf5;
}

.message-icon-wrapper {
    flex-shrink: 0;
    width: 36px;
    height: 36px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 50%;
    background-color: #f5f7fa;
}

.message-content {
    flex: 1;
    min-width: 0;
}

.message-title {
    font-size: 14px;
    font-weight: 600;
    color: #303133;
    margin-bottom: 4px;
    line-height: 1.4;
}

.message-desc {
    font-size: 13px;
    color: #606266;
    line-height: 1.4;
    margin-bottom: 6px;
    overflow: hidden;
    text-overflow: ellipsis;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
}

.message-time {
    font-size: 11px;
    color: #909399;
}

.unread-dot {
    position: absolute;
    right: 20px;
    top: 50%;
    transform: translateY(-50%);
    width: 8px;
    height: 8px;
    background-color: #f56c6c;
    border-radius: 50%;
}

.message-footer {
    padding: 12px 20px;
    text-align: center;
    border-top: 1px solid #f0f0f0;
    background: #fff;
    border-radius: 0 0 12px 12px;
}

/* 滚动条样式 */
.message-list::-webkit-scrollbar {
    width: 6px;
}

.message-list::-webkit-scrollbar-track {
    background: #f1f1f1;
    border-radius: 3px;
}

.message-list::-webkit-scrollbar-thumb {
    background: #c1c1c1;
    border-radius: 3px;
}

.message-list::-webkit-scrollbar-thumb:hover {
    background: #a8a8a8;
}
</style>
