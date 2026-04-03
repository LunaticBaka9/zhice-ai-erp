
const routeNotice = [
    {
        path: "/notice/index",
        name: "noticeIndex",
        component: () => import("../components/notice/NoticeIndex.vue"),
    },
    {
        path: "/notice/post",
        name: "noticePost",
        component: () => import("../components/notice/NoticePost.vue"),
    },
    {
        path: "/notice/manager",
        name: "noticeManager",
        component: () => import("../components/notice/NoticeManager.vue"),
    }
]

export default routeNotice;