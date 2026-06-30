const routeDept = [
    {
        path: "/dept/list",
        name: "deptManager",
        component: () => import("../components/department/DeptManager.vue")
    },
    {
        path: "/dept/detail",
        name: "deptDetail",
        component:()=>import("../components/department/DeptDetail.vue")
    },
    {
        path: "/system/user",
        name: "userManager",
        component: () => import("../components/department/UserManager.vue"),
    },
    {
        path: "/system/role",
        name: "roleManager",
        component: ()=> import("../components/department/RoleManager.vue")
    },
    {
        path: "/system/post",
        name: "postManager",
        component:()=>import("../components/department/PostManager.vue")
    },
];

export default routeDept;
