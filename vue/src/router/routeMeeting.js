const routeMeeting = [
    {
        path: "/meeting/index",
        name: "meetingIndex",
        component: () => import("../components/meeting/index.vue"),
    },
    {
        path: "/meeting/create",
        name: "meetingCreate",
        component: ()=>import("../components/meeting/create.vue"),
    },
    {
        path: "/meeting/detail",
        name: "meetingDetail",
        component:()=>import("../components/meeting/detail.vue")
    },
];

export default routeMeeting;
