<template>
    <div class="announcement-container">
        <!-- 页面标题 -->
        <div class="page-header">
            <h2>系统公告</h2>
            <p>查看最新的系统动态和重要通知</p>
        </div>

        <!-- 筛选栏 -->
        <div class="filter-bar">
            <el-input
                v-model="searchKeyword"
                placeholder="搜索公告标题"
                clearable
                style="width: 240px"
                @clear="handleSearch"
                @keyup.enter="handleSearch"
            >
                <template #prefix>
                    <el-icon><Search /></el-icon>
                </template>
            </el-input>

            <el-select
                v-model="selectedType"
                placeholder="公告类型"
                clearable
                style="width: 140px"
                @change="handleSearch"
            >
                <el-option label="全部" value="" />
                <el-option label="系统更新" value="系统更新" />
                <el-option label="维护通知" value="维护通知" />
                <el-option label="功能上线" value="功能上线" />
                <el-option label="其他公告" value="其他公告" />
            </el-select>

            <el-input
                v-model="searchAuthor"
                placeholder="搜索发布者"
                clearable
                style="width: 180px"
                @clear="handleSearch"
                @keyup.enter="handleSearch"
            />

            <el-button type="primary" @click="handleSearch">
                <el-icon><Search /></el-icon>
                搜索
            </el-button>
        </div>

        <!-- 公告列表 -->
        <div class="announcement-list">
            <el-timeline>
                <el-timeline-item
                    v-for="item in paginatedList"
                    :key="item.id"
                    :timestamp="formatDateTime(item.publishDate)"
                    placement="top"
                    :type="getTimelineType(item.type)"
                    :hollow="true"
                >
                    <el-card
                        class="announcement-card"
                        shadow="hover"
                        @click="viewDetail(item)"
                    >
                        <template #header>
                            <div class="card-header">
                                <div class="title-section">
                                    <span class="title">{{ item.title }}</span>
                                    <el-tag
                                        :type="getTagType(item.type)"
                                        size="small"
                                        effect="plain"
                                    >
                                        {{ item.type }}
                                    </el-tag>
                                </div>
                                <el-button
                                    text
                                    type="primary"
                                    @click="viewDetail(item)"
                                >
                                    查看详情
                                </el-button>
                            </div>
                        </template>
                        <div class="card-content">
                            <p class="summary">{{ item.summary }}</p>
                            <div class="meta-info">
                                <span>
                                    <el-icon><User /></el-icon>
                                    {{ item.author }}
                                </span>
                                <span>
                                    <el-icon><View /></el-icon>
                                    {{ item.views }} 次阅读
                                </span>
                            </div>
                        </div>
                    </el-card>
                </el-timeline-item>
            </el-timeline>

            <!-- 空状态 -->
            <el-empty
                v-if="filteredList.length === 0"
                description="暂无公告"
                :image-size="120"
            />
        </div>

        <!-- 分页 -->
        <div class="pagination-wrapper" v-if="filteredList.length > 0">
            <el-pagination
                v-model:current-page="currentPage"
                v-model:page-size="pageSize"
                :page-sizes="[5, 10, 20]"
                :total="filteredList.length"
                layout="total, sizes, prev, pager, next, jumper"
                @size-change="handleSizeChange"
                @current-change="handleCurrentChange"
            />
        </div>

        <!-- 详情公告内容框 -->
        <el-dialog
            v-model="dialogVisible"
            :title="selectedAnnouncement?.title"
            width="1200px"
            class="detail-dialog"
        >
            <div v-if="selectedAnnouncement" class="detail-content">
                <div class="detail-meta">
                    <el-tag
                        :type="getTagType(selectedAnnouncement.type)"
                        size="small"
                    >
                        {{ selectedAnnouncement.type }}
                    </el-tag>
                    <span class="date">{{
                        formatDateTime(selectedAnnouncement.publishDate)
                    }}</span>
                    <span class="author"
                        >发布人：{{ selectedAnnouncement.author }}</span
                    >
                </div>
                <div
                    class="detail-body"
                    v-html="selectedAnnouncement.content"
                ></div>
                <!-- 附件列表 -->
                <div
                    v-if="
                        selectedAnnouncement.attachments &&
                        selectedAnnouncement.attachments.length > 0
                    "
                    class="attachment-section"
                >
                    <h4 class="attachment-title">
                        <el-icon><Document /></el-icon> 附件下载
                    </h4>
                    <div class="attachment-list">
                        <div
                            v-for="(
                                file, index
                            ) in selectedAnnouncement.attachments"
                            :key="index"
                            class="attachment-item"
                        >
                            <el-icon class="attachment-icon"
                                ><Document
                            /></el-icon>
                            <span class="attachment-name">{{ file.name }}</span>
                            <span class="attachment-size">{{
                                formatFileSize(file.size)
                            }}</span>
                            <el-button
                                type="primary"
                                link
                                size="small"
                                @click="handleDownloadFile(file)"
                            >
                                <el-icon><Download /></el-icon> 下载
                            </el-button>
                        </div>
                    </div>
                </div>
                <div class="detail-footer">
                    <span>阅读次数：{{ selectedAnnouncement.views }}</span>
                </div>
            </div>
            <template #footer>
                <el-button @click="dialogVisible = false">关闭</el-button>
                <el-button type="primary" @click="markAsRead"
                    >我知道了</el-button
                >
            </template>
        </el-dialog>
    </div>
</template>

<script setup>
import { ref, computed, onMounted } from "vue";
import {
    Search,
    User,
    View,
    Document,
    Download,
} from "@element-plus/icons-vue";
import { ElMessage } from "element-plus";
import request from "../../utils/request.js";
import { formatDateTime, parseDate } from "../../utils/date.js";
import router from "../../router/index.js";

const user = JSON.parse(localStorage.getItem("local_user"));

// 公告数据（从后端加载）
const announcements = ref([]);

// 将后端 Notice 映射到组件展示结构
const mapNoticeToAnnouncement = (notice) => {
    const stripHtml = (html) => {
        if (!html) return "";
        return html.replace(/<[^>]*>/g, "");
    };

    // 解析附件数据
    let attachments = [];
    if (notice.attachments) {
        try {
            attachments =
                typeof notice.attachments === "string"
                    ? JSON.parse(notice.attachments)
                    : notice.attachments;
        } catch (e) {
            console.warn("解析附件数据失败", e);
            attachments = [];
        }
    }

    const content = notice.content || "";
    return {
        id: notice.nid,
        title: notice.title || "未命名公告",
        status: notice.status || "",
        type: notice.type,
        summary: notice.summary || stripHtml(content).slice(0, 140),
        content: content,
        publishDate: notice.publishDate ? parseDate(notice.publishDate) : null,
        uid: notice.uid,
        author: notice.author
            ? notice.author
            : notice.uid
              ? String(notice.uid)
              : "系统管理员",
        views: notice.views ? notice.views : 0,
        isRead: false,
        attachments: attachments,
    };
};

const loadNotices = async () => {
    try {
        const res = await request.get("/notice/selectAllNotice");
        if (res && (res.code === "200" || res.code === 200)) {
            const arr = Array.isArray(res.data) ? res.data : [];
            announcements.value = arr.map(mapNoticeToAnnouncement);
        } else {
            ElMessage.error(res.msg || "获取公告失败");
        }
    } catch (e) {
        ElMessage.error("请求公告接口失败");
    }
};

// 筛选相关
const searchKeyword = ref("");
const selectedType = ref("");
const searchAuthor = ref("");
const filteredList = computed(() => {
    let list = announcements.value;
    //按照输入的值进行筛选
    if (searchKeyword.value) {
        list = list.filter((item) =>
            item.title
                .toLowerCase()
                .includes(searchKeyword.value.toLowerCase()),
        );
    }
    if (selectedType.value) {
        list = list.filter((item) => item.type === selectedType.value);
    }
    if (searchAuthor.value) {
        list = list.filter((item) =>
            item.author
                .toLowerCase()
                .includes(searchAuthor.value.toLowerCase()),
        );
    }
    // 排除草稿状态的公告
    list = list.filter(
        (item) => item.status !== "草稿" && item.status !== "定时发布",
    );
    return list;
});

// 分页相关
const currentPage = ref(1);
const pageSize = ref(5);
const paginatedList = computed(() => {
    const start = (currentPage.value - 1) * pageSize.value;
    const end = start + pageSize.value;
    return filteredList.value.slice(start, end);
});

// 详情弹窗
const dialogVisible = ref(false);
const selectedAnnouncement = ref(null);

// 方法
const getTagType = (type) => {
    const typeMap = {
        系统更新: "primary",
        维护通知: "warning",
        功能上线: "success",
        其他公告: "info",
    };
    return typeMap[type] || "info";
};

const getTimelineType = (type) => {
    const typeMap = {
        系统更新: "primary",
        维护通知: "warning",
        功能上线: "success",
        其他公告: "info",
    };
    return typeMap[type] || "info";
};

const handleSearch = () => {
    currentPage.value = 1;
};

const handleSizeChange = (val) => {
    pageSize.value = val;
    currentPage.value = 1;
};

const handleCurrentChange = (val) => {
    currentPage.value = val;
};

const viewDetail = async (item) => {
    // 优先从后端获取完整详情
    try {
        if (item && item.id) {
            const res = await request.get(`/notice/selectByNid/${item.id}`);
            if (res && (res.code === "200" || res.code === 200)) {
                const n = res.data || {};
                selectedAnnouncement.value = mapNoticeToAnnouncement(n);
            } else {
                // 回退到传入项
                selectedAnnouncement.value = item;
                ElMessage.warning(res.msg || "获取详情失败，显示简略信息");
            }
        } else {
            selectedAnnouncement.value = item;
        }
    } catch (e) {
        selectedAnnouncement.value = item;
        ElMessage.error("请求公告详情失败");
    }

    dialogVisible.value = true;
    // 本地标记为已读并增加阅读数
    if (selectedAnnouncement.value && !selectedAnnouncement.value.isRead) {
        selectedAnnouncement.value.isRead = true;
        selectedAnnouncement.value.views =
            (selectedAnnouncement.value.views || 0) + 1;
    }
    try {
        const payload = {
            nid: item.id,
            views: selectedAnnouncement.value.views,
        };
        const res = await request.post(`/notice/updateViews`, payload);
        if (res && (res.code === "200" || res.code === 200)) {
            // 同步更新本地列表中的阅读数
            const idx = announcements.value.findIndex((a) => a.id === item.id);
            if (idx !== -1) {
                announcements.value[idx].views =
                    selectedAnnouncement.value.views;
            }
        } else {
            ElMessage.warning(res.msg || "更新阅读数失败");
        }
    } catch (e) {
        ElMessage.error("更新阅读数请求失败");
    }
};

// 下载文件
const handleDownloadFile = (file) => {
    if (!file.url) {
        ElMessage.warning("文件路径不存在");
        return;
    }
    // 后端返回的路径已经包含 /api 前缀
    const downloadUrl = file.url.startsWith("http") ? file.url : file.url;

    // 创建隐藏的 a 标签进行下载
    const link = document.createElement("a");
    link.href = downloadUrl;
    link.download = file.name;
    link.target = "_blank";
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
};

// 格式化文件大小
const formatFileSize = (bytes) => {
    if (!bytes || bytes === 0) return "0 B";
    const k = 1024;
    const sizes = ["B", "KB", "MB", "GB"];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return (bytes / Math.pow(k, i)).toFixed(2) + " " + sizes[i];
};

const markAsRead = () => {
    dialogVisible.value = false;
    ElMessage.success("感谢您的阅读");
};

onMounted(() => {
    loadNotices();
});
</script>

<style scoped>
.announcement-container {
    padding: 24px 20px;
    background-color: #f5f7fa;
    min-height: calc(100vh - 60px);
}

.page-header {
    margin-bottom: 28px;
}

.page-header h2 {
    font-size: 28px;
    font-weight: 600;
    color: #303133;
    margin: 0 0 8px 0;
}

.page-header p {
    color: #909399;
    font-size: 14px;
    margin: 0;
}

.filter-bar {
    display: flex;
    gap: 12px;
    margin-bottom: 28px;
    flex-wrap: wrap;
    background: white;
    padding: 16px 20px;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.announcement-list {
    margin-bottom: 24px;
}

.announcement-card {
    margin-bottom: 4px;
    transition: transform 0.2s;
}

.announcement-card:hover {
    transform: translateY(-2px);
}

.card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 12px;
}

.title-section {
    display: flex;
    align-items: center;
    gap: 12px;
    flex-wrap: wrap;
}

.title {
    font-size: 16px;
    font-weight: 500;
    color: #303133;
}

.badge-new {
    margin-left: 4px;
}

.card-content {
    color: #606266;
}

.summary {
    margin: 0 0 12px 0;
    line-height: 1.5;
    overflow: hidden;
    text-overflow: ellipsis;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
}

.meta-info {
    display: flex;
    gap: 20px;
    font-size: 12px;
    color: #909399;
}

.meta-info span {
    display: inline-flex;
    align-items: center;
    gap: 4px;
}

.pagination-wrapper {
    display: flex;
    justify-content: flex-end;
    margin-top: 20px;
    background: white;
    padding: 16px 20px;
    border-radius: 8px;
}

.detail-dialog :deep(.el-dialog__body) {
    padding: 20px;
    max-height: 500px;
    overflow-y: auto;
}

.detail-content {
    display: flex;
    flex-direction: column;
    gap: 16px;
}

.detail-meta {
    display: flex;
    align-items: center;
    gap: 16px;
    flex-wrap: wrap;
    padding-bottom: 12px;
    border-bottom: 1px solid #ebeef5;
    font-size: 13px;
    color: #909399;
}

.detail-body {
    line-height: 1.8;
    color: #303133;
}

/* 附件样式 */
.attachment-section {
    margin-top: 20px;
    padding-top: 15px;
    border-top: 1px solid #ebeef5;
}

.attachment-title {
    margin: 0 0 12px 0;
    font-size: 14px;
    color: #303133;
    display: flex;
    align-items: center;
    gap: 6px;
}

.attachment-list {
    display: flex;
    flex-direction: column;
    gap: 8px;
}

.attachment-item {
    display: flex;
    align-items: center;
    padding: 10px 12px;
    background-color: #f5f7fa;
    border-radius: 4px;
    transition: background-color 0.2s;
}

.attachment-item:hover {
    background-color: #e8eef5;
}

.attachment-icon {
    color: #909399;
    margin-right: 8px;
}

.attachment-name {
    flex: 1;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    color: #606266;
}

.attachment-size {
    color: #909399;
    font-size: 12px;
    margin: 0 10px;
}

.detail-body :deep(p) {
    margin: 0 0 12px 0;
}

/* 修复 blockquote 显示，适配 v-html 渲染的引用样式 */
.detail-body :deep(blockquote) {
    margin: 0 0 12px 0;
    padding: 12px 16px;
    border-left: 4px solid #e6e6e6;
    background: #fafafa;
    color: #606266;
    font-style: italic;
}
.detail-body :deep(blockquote p) {
    margin: 0;
}

.detail-body :deep(ul) {
    margin: 8px 0;
    padding-left: 20px;
}

.detail-body :deep(li) {
    margin: 4px 0;
}

.detail-body :deep(strong) {
    color: #409eff;
}

.detail-footer {
    padding-top: 12px;
    border-top: 1px solid #ebeef5;
    font-size: 12px;
    color: #909399;
    text-align: right;
}

/* 响应式调整 */
@media (max-width: 768px) {
    .announcement-container {
        padding: 16px;
    }

    .filter-bar {
        padding: 12px;
    }

    .card-header {
        flex-direction: column;
        align-items: flex-start;
    }

    .title-section {
        width: 100%;
    }
}
</style>
