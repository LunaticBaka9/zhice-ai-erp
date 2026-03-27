<script setup>

import AsideVue from "./components/menu/AsideVue.vue";
import HeaderVue from "./components/menu/HeaderVue.vue";
</script>

<template>
  <el-container>
    <el-aside width=200><AsideVue /></el-aside>
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
</style>
