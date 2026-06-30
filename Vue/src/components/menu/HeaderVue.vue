<template>
    <el-header class="header-container">
        <!-- 左侧区域 -->
        <div class="header-left">
            <el-icon class="collapse-icon" @click="handleToggle()">
                <Fold v-if="!isCollapse"/>
                <Expand v-else/>
            </el-icon>
            <!-- 面包屑导航 -->
            <el-breadcrumb separator="/">
                <el-breadcrumb-item :to="{ path: '/' }"
                >首页
                </el-breadcrumb-item
                >
                <el-breadcrumb-item
                    v-for="(item, index) in breadcrumbs"
                    :key="index"
                >
                    <template
                        v-if="item.path && index !== breadcrumbs.length - 1"
                    >
                        <el-link
                            type="primary"
                            @click="handleNavigate(item.path)"
                        >
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
                    <el-badge
                        :value="unreadCount"
                        :hidden="unreadCount === 0"
                        :max="99"
                    >
                        <div
                            class="action-icon message-icon"
                            @click="fetchMessages"
                        >
                            <el-icon :size="20">
                                <Bell/>
                            </el-icon>
                        </div>
                    </el-badge>
                </template>

                <div class="message-panel">
                    <div class="message-header">
                        <span class="title">消息通知</span>
                        <el-button
                            v-if="unreadCount > 0"
                            type="primary"
                            link
                            size="small"
                            @click="markAllAsRead"
                        >
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
                                    <el-icon
                                        :size="20"
                                        :color="getMessageIconColor(item.type)"
                                    >
                                        <component
                                            :is="getMessageIcon(item.type)"
                                        />
                                    </el-icon>
                                </div>
                                <div class="message-content">
                                    <div class="message-title">
                                        {{ item.title }}
                                    </div>
                                    <div class="message-desc">
                                        {{ item.content }}
                                    </div>
                                    <div class="message-time">
                                        {{ formatTime(item.createTime) }}
                                    </div>
                                </div>
                                <div
                                    v-if="!item.isRead"
                                    class="unread-dot"
                                ></div>
                            </div>
                        </template>
                        <el-empty
                            v-else
                            description="暂无消息"
                            :image-size="80"
                        />
                    </div>

                    <div
                        class="message-footer"
                        v-if="
                            messageList.length > 0 && total > messageList.length
                        "
                    >
                        <el-button type="primary" link @click="loadMore"
                        >查看更多
                        </el-button
                        >
                    </div>
                </div>
            </el-popover>

            <!-- 公告未读角标 -->
            <el-badge
                :value="noticeUnreadCount"
                :hidden="noticeUnreadCount === 0"
                :max="99"
                class="notice-badge"
            >
                <el-icon class="header-icon" @click="goToNotices" title="公告">
                    <Document/>
                </el-icon>
            </el-badge>

            <el-icon class="header-icon" @click="toggleFullscreen">
                <FullScreen v-if="!isFullscreen"/>
                <Aim v-else/>
            </el-icon>
            <el-dropdown
                @command="handleCommand"
                trigger="click"
                v-if="data.user"
            >
                <div class="user-dropdown">
                    <el-avatar
                        :src="data.userInfo.avatar || defaultAvatar"
                        :size="32"
                    />
                    <span class="username">{{ data.userInfo.name }}</span>
                    <el-icon class="arrow-down">
                        <ArrowDown/>
                    </el-icon>
                </div>
                <template #dropdown>
                    <el-dropdown-menu>
                        <el-dropdown-item command="profile">
                            <el-icon>
                                <Avatar/>
                            </el-icon>
                            个人中心
                        </el-dropdown-item>
                        <el-dropdown-item command="settings">
                            <el-icon>
                                <Setting/>
                            </el-icon>
                            系统设置
                        </el-dropdown-item>
                        <el-dropdown-item divided command="logout">
                            <el-icon>
                                <SwitchButton/>
                            </el-icon>
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
import {computed, onMounted, onUnmounted, reactive, ref} from "vue";
import {useRoute, useRouter} from "vue-router";
import {ElMessage, ElMessageBox, ElNotification} from "element-plus";
import {
    Aim,
    ArrowDown,
    Avatar,
    Bell,
    ChatDotRound,
    Document,
    Expand,
    Fold,
    FullScreen,
    InfoFilled,
    Setting,
    SuccessFilled,
    SwitchButton,
    Tickets,
    Warning,
} from "@element-plus/icons-vue";
import {getUserById} from "@/api/user";
import {getUnreadCount} from "@/api/notice";
import {useMenuStore} from "../../store/menu";

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
    "/base/goodsInfo": "商品管理",
    "/base/supplier": "供应商管理",
    "/base/customer": "客户管理",
    "/base/warehouse": "仓库管理",
    "/sale/order": "销售订单",
    "/sale/delivery": "销售发货",
    "/purchase/order": "采购订单",
    "/purchase/inbound": "采购入库",
    "/purchase/query": "采购单据查询",
    "/dept/list": "部门列表",
    "/dept/detail": "部门详情",
    "/system/user": "用户管理",
    "/system/role": "角色管理",
    "/monitor/operationLog": "操作日志",
    "/user/list": "用户列表",
    "/user/detail": "用户详情",
    "/order": "订单管理",
    "/order/list": "订单列表",
    "/order/detail": "订单详情",
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
const defaultAvatar =
    "https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png";

// 搜索关键词
const searchKeyword = ref("");

// 全屏状态
const isFullscreen = ref(false);

// 主题模式
const theme = ref(localStorage.getItem("theme") || "light");

// 消息相关状态
const unreadCount = ref(0);
const noticeUnreadCount = ref(0);
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

// 获取公告未读数量
const fetchNoticeUnreadCount = async () => {
    try {
        const user = JSON.parse(localStorage.getItem("local_user"));
        if (!user || !user.uid) return;
        const res = await getUnreadCount();
        if (res && (res.code === "200" || res.code === 200)) {
            noticeUnreadCount.value = res.data || 0;
        }
    } catch (e) {
        console.error("获取公告未读数失败", e);
    }
};

// 跳转到公告页
const goToNotices = () => {
    router.push("/notice/index");
};

onMounted(() => {
    updateUnreadCount();
    fetchNoticeUnreadCount();
    // 模拟实时消息
    simulateRealTimeMessage();
    // 加载用户详细信息，确保头像和名称可用
    if (data.user && data.user.uid) {
        getUserById(data.user.uid).then((res) => {
            if (res && res.code === "200") {
                data.userInfo = res.data || {};
                // 若 local_user 中缺少 avatar，则同步
                const localUserStr = localStorage.getItem("local_user");
                if (localUserStr) {
                    try {
                        const localUser = JSON.parse(localUserStr);
                        if (!localUser.avatar && data.userInfo.avatar) {
                            localUser.avatar = data.userInfo.avatar;
                            localStorage.setItem(
                                "local_user",
                                JSON.stringify(localUser),
                            );
                        }
                    } catch (e) {
                    }
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
        .catch(() => {
        });
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
    document.removeEventListener("fullscreenchange", () => {
    });
});
</script>

<style src="@/assets/css/menu/header.css"/>
