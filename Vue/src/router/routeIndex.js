const routeIndex = [
  {
    path: "/index",
    name: "index",
    component: () => import("../components/index.vue"),
  },
  {
    path: "/signboard",
    name: "signboard",
    component: () => import("../components/SignBoard.vue"),
  },
  {
    path: "/message",
    name: "message",
    component: () => import("../components/Message.vue"),
  },
  {
    path: "/login",
    name: "login",
    component: () => import("../components/Login.vue"),
  },
  {
    path: "/register",
    name: "register",
    component: () => import("../components/Register.vue"),
  },
];

export default routeIndex;
