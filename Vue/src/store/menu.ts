import {defineStore} from "pinia";
import {ref} from "vue";

export const useMenuStore = defineStore('menu',() => {
    let isCollapse =ref(false);

    function handleToggle(){
        isCollapse.value = !isCollapse.value;
    }
    return { isCollapse, handleToggle };
})