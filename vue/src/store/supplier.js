import { defineStore } from "pinia";
import { ref } from "vue";
import { getAllSuppliers } from "@/api/supplier";

export const useSupplierStore = defineStore("supplier", () => {
    const allSuppliers = ref([]);
    const loaded = ref(false);

    async function fetchAllSuppliers(force = false) {
        if (loaded.value && !force) return;
        try {
            const res = await getAllSuppliers();
            if (res.code === "200") {
                allSuppliers.value = Array.isArray(res.data) ? res.data : [];
                loaded.value = true;
            }
        } catch (e) {
            console.error("获取供应商列表失败", e);
        }
    }

    function clear() {
        allSuppliers.value = [];
        loaded.value = false;
    }

    return { allSuppliers, loaded, fetchAllSuppliers, clear };
});
