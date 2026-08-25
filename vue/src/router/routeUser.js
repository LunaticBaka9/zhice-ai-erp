const routeUser = [
    {
      path:"/",
      redirect:"userInfo",
    },
    {
        path:"/userInfo",
        name:"userInfo",
        component:()=>import("../components/UserInfo.vue")
    },

];

export default routeUser;