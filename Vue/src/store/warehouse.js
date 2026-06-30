import { defineStore } from "pinia";
import { ref } from "vue";
import { getAllWarehouses } from "@/api/warehouse";

export const useWarehouseStore = defineStore("warehouse", () => {
    const allWarehouses = ref([]);
    const loaded = ref(false);

    async function fetchAllWarehouses(force = false) {
        if (loaded.value && !force) return;
        try {
            const res = await getAllWarehouses();
            if (res.code === "200") {
                allWarehouses.value = Array.isArray(res.data) ? res.data : [];
                loaded.value = true;
            }
        } catch (e) {
            console.error("获取仓库列表失败", e);
        }
    }

    function clear() {
        allWarehouses.value = [];
        loaded.value = false;
    }

    return { allWarehouses, loaded, fetchAllWarehouses, clear };
});
