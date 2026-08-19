import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useMenuStore = defineStore('menu', () => {
    const isCollapse = ref(false)

    function handleToggle() {
        isCollapse.value = !isCollapse.value
    }

    return { isCollapse, handleToggle }
})
