import { defineStore } from "pinia";
import { ref } from "vue";
import { getAllGoods } from "@/api/goods";

export const useGoodsStore = defineStore("goods", () => {
    const allGoods = ref([]);
    const loaded = ref(false);

    async function fetchAllGoods(force = false) {
        if (loaded.value && !force) return;
        try {
            const res = await getAllGoods();
            if (res.code === "200") {
                allGoods.value = Array.isArray(res.data) ? res.data : [];
                loaded.value = true;
            }
        } catch (e) {
            console.error("获取商品列表失败", e);
        }
    }

    function clear() {
        allGoods.value = [];
        loaded.value = false;
    }

    return { allGoods, loaded, fetchAllGoods, clear };
});
