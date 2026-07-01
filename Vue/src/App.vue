<script setup>
import { computed, onMounted, provide, ref, watch } from "vue";
import { useRoute, useRouter } from "vue-router";
import { ElNotification } from "element-plus";
import AsideVue from "./components/menu/AsideVue.vue";
import HeaderVue from "./components/menu/HeaderVue.vue";
import { useNoticeWebSocket } from "./utils/useWebSocket.js";

const route = useRoute();
const router = useRouter();

const isAuthPage = computed(() => {
    return route.path === "/login" || route.path === "/register";
});

const noticeRefreshKey = ref(0)

const { connect, disconnect } = useNoticeWebSocket((data) => {
    if (data.action === "new") {
        noticeRefreshKey.value++
        ElNotification({
            title: "新公告",
            message: data.title || "有一条新公告",
            type: "success",
            duration: 5000,
            onClick: () => {
                router.push("/notice/index");
            },
        });
    }
});

onMounted(() => {
    const token = localStorage.getItem("token");
    if (token) {
        connect();
    }
});

watch(isAuthPage, (val) => {
    if (val) {
        disconnect();
    } else {
        const token = localStorage.getItem("token");
        if (token) connect();
    }
});

provide("noticeRefreshKey", noticeRefreshKey)
</script>

<template>
    <div v-if="isAuthPage" class="auth-page">
        <RouterView></RouterView>
    </div>
    <el-container v-else>
        <el-aside width="200"><AsideVue /></el-aside>
        <el-container>
            <el-header><HeaderVue /></el-header>
            <el-main>
                <RouterView></RouterView>
            </el-main>
        </el-container>
    </el-container>
</template>

<style scoped>
.el-aside {
    overflow: hidden;
    padding: 0;
    transition: width 0.3s ease-in-out;
}
.el-header {
    padding: 0;
}
.el-main {
    padding: 0;
}

.auth-page {
    height: 100vh;
    width: 100vw;
    overflow: hidden;
}
</style>
