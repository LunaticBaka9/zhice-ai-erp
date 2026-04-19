<template>
    <el-aside :width="isCollapse ? '64px' : '240px'">
        <!-- Logo区域 -->
        <div class="logo-container">
            <img src="/xianglian_logo.png" alt="logo" class="logo" />
            <span v-show="!isCollapse" class="logo-text">进销存系统</span>
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
            <el-menu-item index="/">
                <el-icon><House /></el-icon>
                <span>工作台</span>
            </el-menu-item>

            <!-- 系统公告 -->
            <el-sub-menu index="notice">
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
                <el-menu-item index="/notice/manager">
                    <span>公告管理</span>
                </el-menu-item>
            </el-sub-menu>

            <!-- 基础资料 -->
            <el-sub-menu v-if="showBaseMenu" index="base">
                <template #title>
                    <el-icon><Goods /></el-icon>
                    <span>基础资料</span>
                </template>
                <el-menu-item index="/base/goodsInfo">
                    <span>商品管理</span>
                </el-menu-item>
                <el-menu-item index="/base/supplier">
                    <span>供应商管理</span>
                </el-menu-item>
                <el-menu-item index="/base/customer">
                    <span>客户管理</span>
                </el-menu-item>
                <el-menu-item index="/base/warehouse">
                    <span>仓库管理</span>
                </el-menu-item>
            </el-sub-menu>

            <!-- 销售管理 -->
            <el-sub-menu v-if="showSaleMenu" index="sale">
                <template #title>
                    <el-icon><ShoppingBag /></el-icon>
                    <span>销售管理</span>
                </template>
                <el-menu-item index="/sale/order">
                    <span>销售订单</span>
                </el-menu-item>
                <el-menu-item index="/sale/delivery">
                    <span>销售发货</span>
                </el-menu-item>
            </el-sub-menu>

            <!-- 采购管理 -->
            <el-sub-menu v-if="showPurchaseMenu" index="purchase">
                <template #title>
                    <el-icon><ShoppingCart /></el-icon>
                    <span>采购管理</span>
                </template>
                <el-menu-item index="/purchase/order">
                    <span>采购订单</span>
                </el-menu-item>
                <el-menu-item index="/purchase/inbound">
                    <span>采购入库</span>
                </el-menu-item>
                <el-menu-item index="/purchase/query">
                    <span>采购单据查询</span>
                </el-menu-item>
            </el-sub-menu>

            <!-- 库存管理 -->
            <el-sub-menu v-if="showInventoryMenu" index="inventory">
                <template #title>
                    <el-icon><Box /></el-icon>
                    <span>库存管理</span>
                </template>
                <el-menu-item index="/inventory/query">
                    <span>库存查询</span>
                </el-menu-item>
                <el-menu-item index="/inventory/operation">
                    <span>仓库作业</span>
                </el-menu-item>
                <el-menu-item index="/inventory/warning">
                    <span>库存预警</span>
                </el-menu-item>
            </el-sub-menu>

            <!-- 报表分析 -->
            <el-sub-menu v-if="showReportMenu" index="report">
                <template #title>
                    <el-icon><PieChart /></el-icon>
                    <span>报表分析</span>
                </template>
                <el-menu-item index="/report/core">
                    <span>核心报表</span>
                </el-menu-item>
                <el-menu-item index="/report/sales">
                    <span>销售分析</span>
                </el-menu-item>
                <el-menu-item index="/report/inventory">
                    <span>库存分析</span>
                </el-menu-item>
            </el-sub-menu>

            <!-- 系统管理 -->
            <el-sub-menu v-if="isAdmin" index="/system">
                <template #title>
                    <el-icon><Setting /></el-icon>
                    <span>系统管理</span>
                </template>
                <el-menu-item index="/system/user">
                    <span>用户管理</span>
                </el-menu-item>
                <el-menu-item index="/monitor/operationLog">
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
    House,
    ShoppingCart,
    ShoppingBag,
    Box,
    Money,
    PieChart,
    Goods,
    Notification,
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

const isTech = computed(() => {
    return (
        data.user?.department === "研发组" || data.user?.department === "测试组" || data.user?.department === "运维组"
    );
});
const isAdmin = computed(() => {
    return data.user?.role.includes("管理员") === true;
});

// 菜单权限控制
const showPurchaseMenu = computed(() => {
    return isAdmin.value || data.user?.department === "采购组" || data.user?.department === "供应链组";
});

const showSaleMenu = computed(() => {
    return isAdmin.value || data.user?.department === "销售组" || data.user?.department === "运营组";
});

const showInventoryMenu = computed(() => {
    return isAdmin.value || data.user?.department === "仓库组" || data.user?.department === "物流组";
});

const showFinanceMenu = computed(() => {
    return isAdmin.value || data.user?.department === "财务组";
});

const showReportMenu = computed(() => {
    return true; // 所有用户可见
});

const showBaseMenu = computed(() => {
    return isAdmin.value || data.user?.department === "管理组";
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
    overflow-y: auto;
    overflow-x: hidden;
    background-color: #304156;
    transition: 0.6s ease-out;
    height: 100vh;
    box-shadow: 2px 0 8px rgba(0, 0, 0, 0.05);
}

/* 折叠状态下隐藏滚动条和滚动条轨道 */
.el-menu--collapse.aside-container {
    overflow: hidden;
}
.el-menu--collapse.aside-container::-webkit-scrollbar {
    display: none;
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

.aside-container .el-menu-item,
.aside-container .el-sub-menu__title {
    white-space: nowrap;
    font-size: 14px;
}

.aside-container .el-menu-item:hover,
.aside-container .el-sub-menu__title:hover {
    background-color: rgba(255, 255, 255, 0.08) !important;
}

/* 激活菜单项样式 */
.aside-container .el-menu-item.is-active {
    background-color: rgba(64, 158, 255, 0.15) !important;
    color: #409eff !important;
    border-right: 3px solid #409eff;
}

.aside-container .el-menu-item.is-active .el-icon {
    color: #409eff;
}

/* 子菜单激活状态 */
.aside-container .el-sub-menu.is-active .el-sub-menu__title {
    color: #409eff !important;
}

/* 菜单项之间的分隔线 */
.aside-container .el-menu-item:not(:last-child) {
    margin-bottom: 1px;
}

.aside-container .el-sub-menu:not(:last-child) {
    margin-bottom: 1px;
}

/* 自定义滚动条 */
.aside-container::-webkit-scrollbar {
    width: 6px;
}

.aside-container::-webkit-scrollbar-thumb {
    background-color: #263445;
    border-radius: 3px;
}

.aside-container::-webkit-scrollbar-thumb:hover {
    background-color: #1f2d3d;
}

.aside-container::-webkit-scrollbar-track {
    background-color: #1f2d3d;
}

/* 折叠时图标间距调整 */
.el-menu--collapse .el-menu-item .el-icon,
.el-menu--collapse .el-sub-menu__title .el-icon {
    margin: 0 auto;
    width: 24px;
    text-align: center;
}

/* 折叠时菜单项居中 */
.el-menu--collapse .el-menu-item,
.el-menu--collapse .el-sub-menu__title {
    justify-content: center;
    padding-left: 0 !important;
}

/* Logo区域悬停效果 */
.logo-container:hover {
    background-color: #1a2530;
    transition: background-color 0.3s;
}

/* 菜单展开/折叠过渡 */
.el-menu-vertical-demo:not(.el-menu--collapse) {
    width: 240px;
    transition: width 0.3s;
}
</style>
