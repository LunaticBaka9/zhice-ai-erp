const routeManager = [
  {
    path: "/system/user",
    name: "userManager",
    component: () => import("../components/system/UserManager.vue"),
  },
  {
    path: "/system/sign",
    name: "signManager",
    component: () => import("../components/system/SignManager.vue"),
  },
];

export default routeManager;
