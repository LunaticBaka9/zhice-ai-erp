
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
        path: "/notice/edit",
        name: "noticeEdit",
        component: () => import("../components/notice/NoticeEdit.vue"),
    },
    {
        path: "/notice/manager",
        name: "noticeManager",
        component: () => import("../components/notice/NoticeManager.vue"),
    }
]

export default routeNotice;