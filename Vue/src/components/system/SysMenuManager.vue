<template>
    <el-table :data="menuList" row-key="id" border :tree-props="{children: 'children'}">
    <el-table-column prop="name" label="菜单名称" />
    <el-table-column prop="icon" label="图标" />
    <el-table-column prop="sort" label="排序" />
    <el-table-column label="类型">
        <template #default="{row}">
        <el-tag v-if="row.type === 'M'">目录</el-tag>
        <el-tag v-else-if="row.type === 'C'" type="success">菜单</el-tag>
        <el-tag v-else type="info">按钮</el-tag>
        </template>
    </el-table-column>
    <el-table-column label="操作" width="200">
        <!-- 编辑、新增子级、删除 -->
    </el-table-column>
    </el-table>
</template>

<script setup>
// 将后端返回的组件字符串转为实际组件
const loadView = (viewPath) => {
  // 注意：vite 不支持完全动态字符串，需用 import.meta.glob
  const modules = import.meta.glob('../views/**/*.vue');
  return modules[`../views/${viewPath}.vue`];
};

// 递归转换菜单树为 Vue Router 格式
function generateRoutes(menuTree) {
  return menuTree.map(item => {
    const route = {
      path: item.path,
      name: item.name,
      component: item.component ? loadView(item.component) : null,
      meta: { title: item.name, icon: item.icon },
      children: []
    };
    if (item.children && item.children.length) {
      route.children = generateRoutes(item.children);
    }
    return route;
  });
}
</script>

<style scoped></style>