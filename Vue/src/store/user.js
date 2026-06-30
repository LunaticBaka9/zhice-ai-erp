import { defineStore } from "pinia";
import { ref } from "vue";
import { getAllUsers } from "@/api/user";

export const useUserStore = defineStore("user", () => {
    const allUsers = ref([]);
    const loaded = ref(false);

    async function fetchAllUsers(force = false) {
        if (loaded.value && !force) return;
        try {
            const res = await getAllUsers();
            if (res.code === "200") {
                allUsers.value = Array.isArray(res.data) ? res.data : [];
                loaded.value = true;
            }
        } catch (e) {
            console.error("获取用户列表失败", e);
        }
    }

    function clear() {
        allUsers.value = [];
        loaded.value = false;
    }

    return { allUsers, loaded, fetchAllUsers, clear };
});
