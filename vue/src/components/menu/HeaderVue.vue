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
                ref="messagePopoverRef"
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

                    <!--
                        底部「查看更多」入口：
                        原实现调用 loadMore() 在弹窗内分页加载，现改为跳转到消息中心页面
                        （/message → components/Message.vue），分页 / 筛选 / 批量操作都在那里完成。
                        只要当前用户存在消息就展示该入口，保证任何时候都能进入消息中心。
                    -->
                    <div
                        class="message-footer"
                        v-if="messageList.length > 0"
                    >
                        <el-button type="primary" link @click="goToMessageCenter"
                        >查看更多（共 {{ total }} 条）
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
    Money,
    Setting,
    SuccessFilled,
    SwitchButton,
    Tickets,
    User,
    Warning,
} from "@element-plus/icons-vue";
import {getUserById} from "@/api/user";
import {getUnreadCount} from "@/api/notice";
// 消息中心接口（与 components/Message.vue 共用同一套后端接口）：
//   getMessageList        分页查询当前用户消息（响应里附带未读总数，用于铃铛角标）
//   getMessageUnreadCount 只查询未读数（页面初次加载时用，避免拉整页数据）
//   markMessageRead       单条消息标记已读
//   markAllMessageRead    当前用户全部标记已读
import {
    getMessageList,
    getMessageUnreadCount,
    markAllMessageRead,
    markMessageRead,
} from "@/api/message";
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
    "/ai/partner": "AI助手",
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

// ============================ 消息通知（已对接「消息中心」模块） ============================
// 说明：
//   1. 顶部铃铛弹窗的数据全部来自后端消息中心接口（MessageController，/message/**），
//      与「消息中心」页面 components/Message.vue 共用同一套接口和同一张 message 表；
//   2. 原实现使用组件内的 mockMessages 假数据 + 定时器伪造实时推送，已全部移除；
//   3. 弹窗只展示最近 POPUP_PAGE_SIZE 条，完整列表通过底部「查看更多」跳转到消息中心页面。

/** 弹窗一次展示的消息条数（完整列表请点击「查看更多」进入消息中心） */
const POPUP_PAGE_SIZE = 5;

/** 当前用户未读消息数：用于顶部铃铛角标 */
const unreadCount = ref(0);
/** 公告未读数：用于公告图标角标（属于公告模块，与消息中心无关） */
const noticeUnreadCount = ref(0);
/** 弹窗内展示的消息列表（后端实体已通过 mapMessage 映射为组件展示结构） */
const messageList = ref([]);
/** 弹窗列表加载状态 */
const loading = ref(false);
/** 当前用户消息总数：仅用于「查看更多（共 N 条）」提示 */
const total = ref(0);
/** 消息弹窗（el-popover）实例引用：跳转消息中心前需要主动关闭它 */
const messagePopoverRef = ref(null);

/**
 * 将后端消息实体（message 表记录）映射为弹窗展示所需的字段结构。
 *
 * 后端字段 → 组件字段：
 *   msgId       → id        消息唯一标识（标记已读时回传后端）
 *   title       → title     消息标题
 *   summary     → content   消息摘要（没有摘要时退化为正文前 60 个字符）
 *   type        → type      消息类型：system / approval / todo / finance / hr
 *   isRead      → isRead    是否已读（后端为 tinyint 0/1，这里转为布尔值）
 *   publishDate → createTime 发布时间（字符串 "yyyy-MM-dd HH:mm:ss"）
 *
 * @param {Object} item 后端返回的单条消息
 * @returns {Object} 组件内部使用的消息对象
 */
const mapMessage = (item) => ({
    id: item.msgId,
    title: item.title || "无标题消息",
    // 摘要为空时用正文兜底，并截断，避免弹窗里换行撑高
    content: item.summary || (item.content ? String(item.content).slice(0, 60) : ""),
    type: item.type || "system",
    // 后端用 tinyint(0/1) 表示已读，这里统一转成布尔值方便模板判断
    isRead: item.isRead === 1 || item.isRead === true,
    createTime: item.publishDate,
});

/**
 * 根据消息类型返回弹窗中展示的图标组件。
 *
 * 类型取值与后端 message.type 保持一致（与 components/Message.vue 中的映射一致）：
 *   system   系统通知 → 信息图标
 *   approval 审批消息 → 勾选图标
 *   todo     待办提醒 → 工单图标
 *   finance  财务通知 → 金额图标
 *   hr       人事通知 → 人员图标
 *
 * 同时保留旧类型（task / approve / comment / reminder / file / warning）的兼容映射，
 * 避免历史数据或其它调用方传入旧类型时图标丢失。
 */
const getMessageIcon = (type) => {
    const iconMap = {
        // —— 与消息中心一致的 5 种类型 ——
        system: InfoFilled,
        approval: SuccessFilled,
        todo: Tickets,
        finance: Money,
        hr: User,
        // —— 兼容旧类型 ——
        task: Tickets,
        approve: SuccessFilled,
        comment: ChatDotRound,
        reminder: Bell,
        file: Document,
        warning: Warning,
    };
    return iconMap[type] || InfoFilled;
};

/**
 * 根据消息类型返回图标颜色，配色与 components/Message.vue 保持一致，
 * 使顶栏弹窗与消息中心页面的视觉语言统一。
 */
const getMessageIconColor = (type) => {
    const colorMap = {
        // —— 与消息中心一致的 5 种类型 ——
        system: "#409EFF",   // 系统通知：蓝色
        approval: "#E6A23C", // 审批消息：橙色
        todo: "#F56C6C",     // 待办提醒：红色
        finance: "#67C23A",  // 财务通知：绿色
        hr: "#909399",       // 人事通知：灰色
        // —— 兼容旧类型 ——
        task: "#E6A23C",
        approve: "#67C23A",
        comment: "#909399",
        reminder: "#F56C6C",
        file: "#909399",
    };
    return colorMap[type] || "#909399";
};

/**
 * 将后端返回的发布时间格式化为「相对时间」。
 *
 * 后端 publishDate 为 "yyyy-MM-dd HH:mm:ss" 字符串，这里统一做兼容处理：
 *   - 把 "-" 替换成 "/"，避免部分浏览器（如 Safari）解析该格式失败；
 *   - 解析失败时直接返回原字符串，保证界面不会出现 Invalid Date；
 *   - 未来时间（例如定时发布的消息）直接展示完整时间，避免出现「-1分钟前」。
 *
 * @param {string|Date} time 发布时间
 * @returns {string} 例如「刚刚 / 5分钟前 / 3小时前 / 2天前 / 2026-09-20 07:53」
 */
const formatTime = (time) => {
    if (!time) return "";
    const date =
        time instanceof Date ? time : new Date(String(time).replace(/-/g, "/"));
    if (Number.isNaN(date.getTime())) return String(time);

    const pad = (n) => String(n).padStart(2, "0");
    const absolute = `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(
        date.getDate(),
    )} ${pad(date.getHours())}:${pad(date.getMinutes())}`;

    const diff = Date.now() - date.getTime();
    if (diff < 0) return absolute; // 未来时间：直接展示绝对时间
    if (diff < 60 * 1000) return "刚刚";
    if (diff < 3600 * 1000) return `${Math.floor(diff / 60000)}分钟前`;
    if (diff < 86400 * 1000) return `${Math.floor(diff / 3600000)}小时前`;
    if (diff < 7 * 86400 * 1000) return `${Math.floor(diff / 86400000)}天前`;
    return absolute;
};

/**
 * 拉取顶部弹窗的消息列表（真实接口版本）。
 *
 * 调用消息中心分页接口 GET /message/list：
 *   - 只取第 1 页的 POPUP_PAGE_SIZE 条，按发布时间倒序（后端已按 publish_date 排序）；
 *   - 响应体同时携带 unreadCount（未读总数），这里直接同步到铃铛角标，
 *     因此打开弹窗后角标会自动刷新，无需额外发起一次未读数请求。
 *
 * 说明：原实现基于组件内 mockMessages 做前端分页，并用 setTimeout 伪造网络延迟，
 *      现已全部替换为真实后端数据。
 */
const fetchMessages = async () => {
    loading.value = true;
    try {
        const res = await getMessageList({
            pageNum: 1,
            pageSize: POPUP_PAGE_SIZE,
        });
        if (res && res.code === "200" && res.data) {
            const records = Array.isArray(res.data.records)
                ? res.data.records
                : [];
            // 后端实体 → 组件展示结构
            messageList.value = records.map(mapMessage);
            total.value = Number(res.data.total || 0);
            // 接口顺带返回未读总数，直接同步到角标，保持与消息中心页面一致
            unreadCount.value = Number(res.data.unreadCount || 0);
        } else {
            messageList.value = [];
            total.value = 0;
            ElMessage.error(res?.msg || "获取消息失败");
        }
    } catch (e) {
        // request 响应拦截器已统一弹出错误提示，这里只做数据兜底
        messageList.value = [];
        total.value = 0;
    } finally {
        loading.value = false;
    }
};

/**
 * 单独拉取未读消息数，用于页面初次加载时渲染铃铛角标。
 * （此时弹窗尚未打开，没有必要加载完整消息列表。）
 */
const fetchUnreadCount = async () => {
    try {
        const res = await getMessageUnreadCount();
        if (res && res.code === "200") {
            unreadCount.value = Number(res.data || 0);
        }
    } catch (e) {
        // 未读数获取失败不阻断页面其它逻辑，角标保持原值即可
    }
};

/**
 * 点击弹窗中的某条消息：
 *   1. 未读时先调用 POST /message/markRead 在服务端标记已读；
 *      —— 只有服务端成功后才更新本地状态，避免前后端数据不一致；
 *   2. 本地同步 isRead 并递减铃铛角标（无需再发一次未读数请求）；
 *   3. 用 ElNotification 弹出消息内容（保持原有交互习惯）。
 *
 * 说明：这里只处理「已读 + 提示」，不做页面跳转；
 *      查看完整消息列表请点击弹窗底部的「查看更多」进入消息中心页面。
 */
const handleMessageClick = async (item) => {
    if (!item.isRead) {
        try {
            const res = await markMessageRead(item.id);
            if (res && res.code !== "200") {
                ElMessage.error(res.msg || "标记已读失败");
                return;
            }
            // 服务端标记已读成功后再同步本地状态
            item.isRead = true;
            if (unreadCount.value > 0) unreadCount.value -= 1;
        } catch (e) {
            // request 响应拦截器已统一提示，这里直接返回，保证本地状态与后端一致
            return;
        }
    }
    ElNotification({
        title: item.title,
        message: item.content,
        type: "info",
        duration: 3000,
    });
};

/**
 * 全部标记为已读：调用 POST /message/markAllRead。
 * 成功后把弹窗内已加载的消息同步为已读，并将铃铛角标清零。
 * （接口本身会更新当前用户全部未读消息，无需前端逐条处理。）
 */
const markAllAsRead = async () => {
    try {
        const res = await markAllMessageRead();
        if (res && res.code !== "200") {
            ElMessage.error(res.msg || "操作失败");
            return;
        }
        messageList.value.forEach((item) => {
            item.isRead = true;
        });
        unreadCount.value = 0;
        ElMessage.success("已全部标记为已读");
    } catch (e) {
        // request 响应拦截器已统一提示
    }
};

// 已移除：原 simulateRealTimeMessage() 通过 setTimeout 每 10 秒向页面注入一条假消息，
// 属于纯前端模拟，会造成「角标数字」与后端真实数据不一致。
// 若后续需要真正的实时提醒，可参照公告模块的 WebSocket 方案（utils/useWebSocket.js），
// 订阅后端推送后调用 fetchMessages() / fetchUnreadCount() 刷新列表与角标即可。

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
    // 页面加载即拉取真实未读数，保证一进入系统铃铛角标就是准确的；
    // 弹窗消息列表则等到用户点击铃铛时再按需加载（见 handleMessagePopoverShow）。
    fetchUnreadCount();
    fetchNoticeUnreadCount();
    // 加载用户详细信息，确保头像和名称可用
    if (data.user && data.user.uid) {
        getUserById(data.user.uid).then((res) => {
            if (res && res.code === "200") {
                data.userInfo = res.data || {};
                if (data.userInfo.avatar) {
                    try {
                        const u = new URL(data.userInfo.avatar);
                        data.userInfo.avatar = u.pathname;
                    } catch {}
                }
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

/**
 * 「查看更多」：跳转到消息中心页面
 * （路由 /message → vue/src/components/Message.vue）。
 *
 * 原实现是弹窗内分页「加载更多」(loadMore)；
 * 现在弹窗只作为「最近消息预览」，分页 / 筛选 / 批量操作等完整能力
 * 统一在消息中心页面完成，避免两处重复实现同一套逻辑。
 */
const goToMessageCenter = () => {
    // 先主动关闭弹窗再跳转，避免弹窗残留悬浮在消息中心页面之上
    messagePopoverRef.value?.hide();
    router.push("/message");
};

/**
 * 弹窗展开时的处理：
 *   - 首次打开（列表为空）才请求消息列表，做一层缓存，避免每次展开都打接口；
 *   - 已有数据时只刷新未读数，保证角标与后端一致。
 */
const handleMessagePopoverShow = () => {
    if (messageList.value.length === 0) {
        fetchMessages();
    } else {
        fetchUnreadCount();
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
