import { createApp } from 'vue'
import App from './App.vue'
import ElementPlus from "element-plus"; // 引入 element-plus第三方UI组件库
import "element-plus/dist/index.css"; // 引入 element-plus 样式
import * as ElementPlusIconsVue from "@element-plus/icons-vue"; // 引入 element-plus 图标库
import router from "./router/index.js";
import Axios from "axios";
import {createPinia} from "pinia";
import './assets/css/global.css'

const app = createApp(App);
const pinia = createPinia();
app.use(pinia);
app.use(router);
app.use(Axios);
app.use(ElementPlus);
for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
    app.component(key, component);
}
app.mount("#app");
