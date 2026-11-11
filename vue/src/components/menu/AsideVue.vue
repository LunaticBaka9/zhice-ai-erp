<template>
    <el-aside :width="isCollapse ? '64px' : '240px'" class="aside-transition">
        <!-- Logo区域 -->
        <div class="logo-container">
            <img src="/xianglian_logo.png" alt="logo" class="logo" />
            <transition name="logo-fade">
                <span v-show="!isCollapse" class="logo-text">进销存系统</span>
            </transition>
        </div>

        <!-- 菜单区域：按当前角色已分配的 path 过滤，布局保持不变 -->
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
            <el-menu-item v-if="canShow('/')" index="/">
                <el-icon><House /></el-icon>
                <span>工作台</span>
            </el-menu-item>

            <el-sub-menu v-if="showNotice" index="notice">
                <template #title>
                    <el-icon><Notification /></el-icon>
                    <span>系统公告</span>
                </template>
                <el-menu-item v-if="canShow('/notice/index')" index="/notice/index">
                    <span>公告详情</span>
                </el-menu-item>
                <el-menu-item v-if="canShow('/notice/post')" index="/notice/post">
                    <span>公告发布</span>
                </el-menu-item>
                <el-menu-item v-if="canShow('/notice/manager')" index="/notice/manager">
                    <span>公告管理</span>
                </el-menu-item>
            </el-sub-menu>

            <el-sub-menu v-if="showBase" index="base">
                <template #title>
                    <el-icon><Goods /></el-icon>
                    <span>基础资料</span>
                </template>
                <el-menu-item v-if="canShow('/base/goodsInfo')" index="/base/goodsInfo">
                    <span>商品管理</span>
                </el-menu-item>
                <el-menu-item v-if="canShow('/base/supplier')" index="/base/supplier">
                    <span>供应商管理</span>
                </el-menu-item>
                <el-menu-item v-if="canShow('/base/customer')" index="/base/customer">
                    <span>客户管理</span>
                </el-menu-item>
                <el-menu-item v-if="canShow('/base/warehouse')" index="/base/warehouse">
                    <span>仓库管理</span>
                </el-menu-item>
            </el-sub-menu>

            <el-sub-menu v-if="showSale" index="sale">
                <template #title>
                    <el-icon><ShoppingBag /></el-icon>
                    <span>销售管理</span>
                </template>
                <el-menu-item v-if="canShow('/sale/order')" index="/sale/order">
                    <span>销售订单</span>
                </el-menu-item>
                <el-menu-item v-if="canShow('/sale/delivery')" index="/sale/delivery">
                    <span>销售发货</span>
                </el-menu-item>
            </el-sub-menu>

            <el-sub-menu v-if="showPurchase" index="purchase">
                <template #title>
                    <el-icon><ShoppingCart /></el-icon>
                    <span>采购管理</span>
                </template>
                <el-menu-item v-if="canShow('/purchase/order')" index="/purchase/order">
                    <span>采购订单</span>
                </el-menu-item>
                <el-menu-item v-if="canShow('/purchase/inbound')" index="/purchase/inbound">
                    <span>采购入库</span>
                </el-menu-item>
                <el-menu-item v-if="canShow('/purchase/query')" index="/purchase/query">
                    <span>采购单据查询</span>
                </el-menu-item>
            </el-sub-menu>

            <el-sub-menu v-if="showInventory" index="inventory">
                <template #title>
                    <el-icon><Box /></el-icon>
                    <span>库存管理</span>
                </template>
                <el-menu-item v-if="canShow('/inventory/query')" index="/inventory/query">
                    <span>库存查询</span>
                </el-menu-item>
                <el-menu-item v-if="canShow('/inventory/operation')" index="/inventory/operation">
                    <span>仓库作业</span>
                </el-menu-item>
                <el-menu-item v-if="canShow('/inventory/warning')" index="/inventory/warning">
                    <span>库存预警</span>
                </el-menu-item>
            </el-sub-menu>

            <el-sub-menu v-if="showMeeting" index="meeting">
              <template #title>
                <el-icon><ChatSquare /></el-icon>
                <span>会议管理</span>
              </template>
              <el-menu-item v-if="canShow('/meeting/create')" index="/meeting/create">
                <span>发起会议</span>
              </el-menu-item>
              <el-menu-item v-if="canShow('/meeting/index')" index="/meeting/index">
                <span>会议列表</span>
              </el-menu-item>
            </el-sub-menu>

            <el-sub-menu v-if="showReport" index="report">
                <template #title>
                    <el-icon><PieChart /></el-icon>
                    <span>报表分析</span>
                </template>
                <el-menu-item v-if="canShow('/report/core')" index="/report/core">
                    <span>核心报表</span>
                </el-menu-item>
                <el-menu-item v-if="canShow('/report/sales')" index="/report/sales">
                    <span>销售分析</span>
                </el-menu-item>
                <el-menu-item v-if="canShow('/report/inventory')" index="/report/inventory">
                    <span>库存分析</span>
                </el-menu-item>
            </el-sub-menu>

            <el-sub-menu v-if="showDept" index="/dept">
                <template #title>
                    <el-icon><OfficeBuilding /></el-icon>
                    <span>部门管理</span>
                </template>
                <el-menu-item v-if="canShow('/dept/list')" index="/dept/list">
                    <span>部门列表</span>
                </el-menu-item>
                <el-menu-item v-if="canShow('/system/user')" index="/system/user">
                    <span>用户列表</span>
                </el-menu-item>
                <el-menu-item v-if="canShow('/system/post')" index="/system/post">
                    <span>职位列表</span>
                </el-menu-item>
                <el-menu-item v-if="canShow('/system/role')" index="/system/role">
                    <span>角色列表</span>
                </el-menu-item>
            </el-sub-menu>

            <el-sub-menu v-if="showSystem" index="/system">
                <template #title>
                    <el-icon><Setting /></el-icon>
                    <span>系统管理</span>
                </template>
                <el-menu-item v-if="canShow('/system/menu')" index="/system/menu">
                    <span>菜单管理</span>
                </el-menu-item>
                <el-menu-item v-if="canShow('/monitor/operationLog')" index="/monitor/operationLog">
                    <span>操作日志</span>
                </el-menu-item>
            </el-sub-menu>

            <el-menu-item v-if="canShow('/message')" index="/message">
                <el-icon><Message /></el-icon>
                <span>消息中心</span>
            </el-menu-item>

            <el-menu-item v-if="canShow('/ai/partner')" index="/ai/partner">
                <el-icon><ChatLineSquare /></el-icon>
                <span>AI 助手</span>
            </el-menu-item>

            <el-menu-item v-if="canShow('/userInfo')" index="/userInfo">
                <el-icon><Avatar /></el-icon>
                <span>个人主页</span>
            </el-menu-item>
        </el-menu>
    </el-aside>
</template>

<script setup>
import { computed, ref, watch } from "vue";
import { useRoute } from "vue-router";
import {
    Avatar,
    Box,
    ChatSquare,
    ChatLineSquare,
    Goods,
    House,
    Message,
    Notification,
    OfficeBuilding,
    PieChart,
    Setting,
    ShoppingBag,
    ShoppingCart,
} from "@element-plus/icons-vue";
import { useMenuStore } from "../../store/menu.ts";
import { storeToRefs } from "pinia";

const menuStore = useMenuStore();
const { isCollapse } = storeToRefs(menuStore);
const canShow = (path) => menuStore.canShow(path);

const showNotice = computed(
    () => canShow("/notice/index") || canShow("/notice/post") || canShow("/notice/manager"),
);
const showBase = computed(
    () =>
        canShow("/base/goodsInfo") ||
        canShow("/base/supplier") ||
        canShow("/base/customer") ||
        canShow("/base/warehouse"),
);
const showSale = computed(() => canShow("/sale/order") || canShow("/sale/delivery"));
const showPurchase = computed(
    () => canShow("/purchase/order") || canShow("/purchase/inbound") || canShow("/purchase/query"),
);
const showInventory = computed(
    () => canShow("/inventory/query") || canShow("/inventory/operation") || canShow("/inventory/warning"),
);
const showMeeting = computed(() => canShow("/meeting/create") || canShow("/meeting/index"));
const showReport = computed(
    () => canShow("/report/core") || canShow("/report/sales") || canShow("/report/inventory"),
);
const showDept = computed(
    () =>
        canShow("/dept/list") ||
        canShow("/system/user") ||
        canShow("/system/post") ||
        canShow("/system/role"),
);
const showSystem = computed(() => canShow("/system/menu") || canShow("/monitor/operationLog"));

const route = useRoute();
const activeMenu = ref("/");

watch(
    () => route.path,
    (newPath) => {
        activeMenu.value = newPath;
    },
    { immediate: true },
);
</script>

<style src="@/assets/css/menu/aside.css" />
