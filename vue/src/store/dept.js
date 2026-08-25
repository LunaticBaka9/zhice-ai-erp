import { defineStore } from "pinia";
import { ref } from "vue";
import { getDeptList } from "@/api/dept";

export const useDeptStore = defineStore("dept", () => {
    const deptTree = ref([]);
    const deptList = ref([]);
    const loading = ref(false);
    const loaded = ref(false);

    function flattenTree(tree, result = []) {
        for (const node of tree) {
            result.push(node);
            if (node.children?.length) flattenTree(node.children, result);
        }
        return result;
    }

    async function fetchDeptList(force = false) {
        if (loaded.value && !force) return;
        loading.value = true;
        try {
            const res = await getDeptList();
            if (res.code === "200") {
                const data = Array.isArray(res.data) ? res.data : (res.data.records || []);
                deptTree.value = data;
                deptList.value = flattenTree(data);
                loaded.value = true;
            }
        } finally {
            loading.value = false;
        }
    }

    function clear() {
        deptTree.value = [];
        deptList.value = [];
        loaded.value = false;
    }

    return { deptTree, deptList, loading, loaded, fetchDeptList, clear };
});
