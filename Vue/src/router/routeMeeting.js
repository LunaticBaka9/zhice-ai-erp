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
];

export default routeMeeting;
