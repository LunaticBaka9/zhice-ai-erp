import { defineStore } from "pinia";
import { ref } from "vue";
import { getAllCustomers } from "@/api/customer";

export const useCustomerStore = defineStore("customer", () => {
    const allCustomers = ref([]);
    const loaded = ref(false);

    async function fetchAllCustomers(force = false) {
        if (loaded.value && !force) return;
        try {
            const res = await getAllCustomers();
            if (res.code === "200") {
                allCustomers.value = Array.isArray(res.data) ? res.data : [];
                loaded.value = true;
            }
        } catch (e) {
            console.error("获取客户列表失败", e);
        }
    }

    function clear() {
        allCustomers.value = [];
        loaded.value = false;
    }

    return { allCustomers, loaded, fetchAllCustomers, clear };
});
