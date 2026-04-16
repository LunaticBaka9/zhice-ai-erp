<script setup>
import { computed } from "vue";
import { useRoute } from "vue-router";
import AsideVue from "./components/menu/AsideVue.vue";
import HeaderVue from "./components/menu/HeaderVue.vue";

const route = useRoute();

// 判断是否为登录/注册页面
const isAuthPage = computed(() => {
    return route.path === "/login" || route.path === "/register";
});
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
