<template>
    <el-aside :width="isCollapse ? '64px' : '240px'">
        <!-- Logo区域 -->
        <div class="logo-container">
            <img
                src="https://element-plus.org/images/element-plus-logo.svg"
                alt="logo"
                class="logo"
            />
            <span v-show="!isCollapse" class="logo-text">ERP System</span>
        </div>

        <!-- 菜单区域 -->
        <el-menu
            class="aside-container"
            :default-active="activeMenu"
            :collapse="isCollapse"
            :collapse-transition="false"
            router
            background-color="#304156"
            text-color="#bfcbd9"
            active-text-color="#409EFF"
            :unique-opened="true"
        >
            <el-menu-item index="/index">
                <el-icon><House /></el-icon>
                <span>首页</span>
            </el-menu-item>

            <!-- 签到打卡 -->
            <el-menu-item index="/signboard">
                <el-icon><Grid /></el-icon>
                <span>签到打卡</span>
            </el-menu-item>

            <!-- 系统公告 -->
            <el-sub-menu>
                <template #title>
                    <el-icon><Notification /></el-icon>
                    <span>系统公告</span>
                </template>
                <el-menu-item index="/notice/index">
                    <span>公告详情</span>
                </el-menu-item>
                <el-menu-item index="/notice/post">
                    <span>公告发布</span>
                </el-menu-item>
                <el-menu-item index="/notice/manager" v-if="isAdmin">
                    <span>公告管理</span>
                </el-menu-item>
            </el-sub-menu>

            <!-- 技术部 -->
            <el-sub-menu v-if="isTech || isAdmin" index="/technology">
                <template #title>
                    <el-icon><Monitor /></el-icon>
                    <span>技术部</span>
                </template>
                <el-menu-item index="/technology/development">
                    <span>开发管理</span>
                </el-menu-item>
                <el-menu-item index="/technology/projects">
                    <span>技术项目</span>
                </el-menu-item>
                <el-menu-item index="/technology/code-review">
                    <span>代码审查</span>
                </el-menu-item>
                <el-menu-item index="/technology/version">
                    <span>版本发布</span>
                </el-menu-item>
            </el-sub-menu>

            <!-- 产品部 -->
            <el-sub-menu v-if="isProdect || isAdmin" index="/product">
                <template #title>
                    <el-icon><Grid /></el-icon>
                    <span>产品部</span>
                </template>
                <el-menu-item index="/product/management">
                    <span>产品管理</span>
                </el-menu-item>
                <el-menu-item index="/product/requirements">
                    <span>需求管理</span>
                </el-menu-item>
                <el-menu-item index="/product/design">
                    <span>原型设计</span>
                </el-menu-item>
                <el-menu-item index="/product/iteration">
                    <span>迭代计划</span>
                </el-menu-item>
            </el-sub-menu>

            <!-- 市场部 -->
            <el-sub-menu v-if="isMarket || isAdmin" index="/marketing">
                <template #title>
                    <el-icon><TrendCharts /></el-icon>
                    <span>市场部</span>
                </template>
                <el-menu-item index="/marketing/campaign">
                    <span>营销活动</span>
                </el-menu-item>
                <el-menu-item index="/marketing/brand">
                    <span>品牌管理</span>
                </el-menu-item>
                <el-menu-item index="/marketing/channel">
                    <span>渠道管理</span>
                </el-menu-item>
                <el-menu-item index="/marketing/analysis">
                    <span>市场分析</span>
                </el-menu-item>
            </el-sub-menu>

            <!-- 行政部 -->
            <el-sub-menu v-if="isAD || isAdmin" index="/administration">
                <template #title>
                    <el-icon><OfficeBuilding /></el-icon>
                    <span>行政部</span>
                </template>
                <el-menu-item index="/administration/office">
                    <span>办公管理</span>
                </el-menu-item>
                <el-menu-item index="/administration/assets">
                    <span>资产管理</span>
                </el-menu-item>
                <el-menu-item index="/administration/attendance">
                    <span>考勤管理</span>
                </el-menu-item>
                <el-menu-item index="/administration/document">
                    <span>文件归档</span>
                </el-menu-item>
            </el-sub-menu>

            <!-- 项目管理 -->
            <el-menu-item v-if="isTech || isAdmin" index="/project">
                <el-icon><Folder /></el-icon>
                <span>项目管理</span>
            </el-menu-item>

            <!-- 系统管理 -->
            <el-sub-menu v-if="isAdmin" index="/system">
                <template #title>
                    <el-icon><Setting /></el-icon>
                    <span>系统管理</span>
                </template>
                <el-menu-item index="/system/user">
                    <span>用户管理</span>
                </el-menu-item>
                <el-menu-item index="/system/role">
                    <span>角色管理</span>
                </el-menu-item>
                <el-menu-item index="/system/menu">
                    <span>菜单管理</span>
                </el-menu-item>
                <el-menu-item index="/system/sign">
                    <span>签到管理</span>
                </el-menu-item>
            </el-sub-menu>

            <!-- 系统监控 -->
            <el-sub-menu v-if="isTech || isAdmin" index="/monitor">
                <template #title>
                    <el-icon><Monitor /></el-icon>
                    <span>系统监控</span>
                </template>
                <el-menu-item index="/monitor/online">
                    <span>在线用户</span>
                </el-menu-item>
                <el-menu-item index="/monitor/log">
                    <span>操作日志</span>
                </el-menu-item>
            </el-sub-menu>

            <!-- 消息管理 -->
            <el-menu-item index="/message">
                <el-icon><Message /></el-icon>
                <span>消息中心</span>
            </el-menu-item>

            <!-- 个人主页 -->
            <el-menu-item index="/userInfo">
                <el-icon><Avatar /></el-icon>
                <span>个人主页</span>
            </el-menu-item>
        </el-menu>
    </el-aside>
</template>

<script setup>
import { computed, onBeforeMount, reactive, ref, watch } from "vue";
import { useRoute } from "vue-router";
import {
    Grid,
    Setting,
    Monitor,
    Avatar,
    Message,
} from "@element-plus/icons-vue";
import { useMenuStore } from "../../store/menu.ts";
import { storeToRefs } from "pinia";
const { isCollapse } = storeToRefs(useMenuStore());

const data = reactive({
    user: JSON.parse(localStorage.getItem("local_user")),
    userInfo: [],
});
console.log(data.user?.department);
console.log(data.user?.role);

const isTech = computed(() => {
    return (
        data.user?.department === "研发组" ||
        data.user?.department === "测试组" ||
        data.user?.department === "运维组"
    );
});
const isProdect = computed(() => {
    return (
        data.user?.department === "产品组" ||
        data.user?.department === "设计组" ||
        data.user?.department === "交互组"
    );
});
const isMarket = computed(() => {
    return (
        data.user?.department === "运营组" ||
        data.user?.department === "销售组" ||
        data.user?.department === "公关组"
    );
});
const isAD = computed(() => {
    return (
        data.user?.department === "人力资源" ||
        data.user?.department === "财务组" ||
        data.user?.department === "办公室"
    );
});
const isAdmin = computed(() => {
    return data.user?.role.includes("管理员") === true;
});

// 定义事件
const emit = defineEmits(["menu-click"]);

// 当前路由
const route = useRoute();

// 当前激活的菜单
const activeMenu = ref("/dashboard");

// 监听路由变化，更新激活菜单
watch(
    () => route.path,
    (newPath) => {
        activeMenu.value = newPath;
    },
    { immediate: true },
);

// 菜单点击事件
const handleMenuClick = (path) => {
    emit("menu-click", path);
};
</script>

<style scoped>
* {
    overflow: hidden;
}
.aside-container {
    overflow: hidden;
    background-color: #304156;
    transition: 0.6s ease-out;
    height: 100vh;
    box-shadow: 2px 0 8px rgba(0, 0, 0, 0.05);
}

/* Logo区域样式 */
.logo-container {
    height: 60px;
    display: flex;
    align-items: center;
    padding: 0 16px;
    background-color: #1f2d3d;
    overflow: hidden;
    white-space: nowrap;
    border-bottom: 1px solid rgba(255, 255, 255, 0.05);
}

.logo {
    width: 32px;
    height: 32px;
    margin-right: 8px;
    flex-shrink: 0;
    transition: all 0.3s;
}

.logo-text {
    color: #fff;
    font-size: 16px;
    font-weight: 600;
    transition: opacity 0.3s ease;
    letter-spacing: 1px;
}

.aside-menu .el-menu-item,
.aside-menu .el-sub-menu__title {
    white-space: nowrap;
    font-size: 14px;
}

.aside-menu .el-menu-item:hover,
.aside-menu .el-sub-menu__title:hover {
    background-color: rgba(255, 255, 255, 0.08) !important;
}

/* 自定义滚动条 */
.aside-menu::-webkit-scrollbar {
    width: 6px;
}

.aside-menu::-webkit-scrollbar-thumb {
    background-color: #263445;
    border-radius: 3px;
}

.aside-menu::-webkit-scrollbar-thumb:hover {
    background-color: #1f2d3d;
}

.aside-menu::-webkit-scrollbar-track {
    background-color: #1f2d3d;
}

/* 折叠时图标间距调整 */
.el-menu--collapse .el-menu-item .el-icon,
.el-menu--collapse .el-sub-menu__title .el-icon {
    margin: 0 auto;
    width: 24px;
    text-align: center;
}
</style>
