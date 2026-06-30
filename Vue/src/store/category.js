import { defineStore } from "pinia";
import { ref } from "vue";
import { getCategoryTree } from "@/api/category";

export const useCategoryStore = defineStore("category", () => {
    const categoryTree = ref([]);
    const loaded = ref(false);

    async function fetchCategoryTree(force = false) {
        if (loaded.value && !force) return;
        try {
            const res = await getCategoryTree();
            if (res.code === "200") {
                categoryTree.value = Array.isArray(res.data) ? res.data : [];
                loaded.value = true;
            }
        } catch (e) {
            console.error("获取分类树失败", e);
        }
    }

    function clear() {
        categoryTree.value = [];
        loaded.value = false;
    }

    return { categoryTree, loaded, fetchCategoryTree, clear };
});
