const routeDept = [
    {
        path: "/system/user",
        name: "userManager",
        component: () => import("../components/department/UserManager.vue"),
    },
    {
        path: "/dept/list",
        name: "deptManager",
        component: () => import("../components/department/DeptManager.vue")
    },
    {
        path: "/dept/detail",
        name: "deptDetail",
        component:()=>import("../components/department/DeptDetail.vue")
    }
];

export default routeDept;
