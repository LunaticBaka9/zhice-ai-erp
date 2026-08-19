<template>
    <div class="ai-partner">
        <!-- 左侧会话栏 -->
        <transition name="slide-sidebar">
            <div v-show="sidebarVisible" class="ai-sidebar">
                <!-- 顶部：新建对话 -->
                <div class="sidebar-header">
                    <el-button class="new-chat-btn" type="primary" :icon="Plus" @click="handleNewConversation">
                        新建对话
                    </el-button>
                    <el-icon class="collapse-btn" @click="toggleSidebar">
                        <Fold />
                    </el-icon>
                </div>

                <!-- 搜索框 -->
                <div class="sidebar-search">
                    <el-input
                        v-model="searchKeyword"
                        placeholder="搜索对话"
                        prefix-icon="Search"
                        clearable
                        size="default"
                    />
                </div>

                <!-- 会话列表 -->
                <div class="conversation-list" v-loading="listLoading">
                    <template v-if="filteredConversations.length > 0">
                        <div v-for="group in groupedConversations" :key="group.label" class="conversation-group">
                            <div class="group-label">{{ group.label }}</div>
                            <div
                                v-for="conv in group.items"
                                :key="conv.id"
                                class="conversation-item"
                                :class="{ active: conv.id === currentConversationId }"
                                @click="handleSelectConversation(conv)"
                            >
                                <el-icon class="conv-icon"><ChatDotRound /></el-icon>
                                <span class="conv-title">{{ conv.title }}</span>
                                <el-dropdown
                                    class="conv-actions"
                                    trigger="click"
                                    @command="(cmd) => handleConversationCommand(cmd, conv)"
                                >
                                    <el-icon class="more-icon"><MoreFilled /></el-icon>
                                    <template #dropdown>
                                        <el-dropdown-menu>
                                            <el-dropdown-item command="rename">重命名</el-dropdown-item>
                                            <el-dropdown-item command="delete" divided>删除</el-dropdown-item>
                                        </el-dropdown-menu>
                                    </template>
                                </el-dropdown>
                            </div>
                        </div>
                    </template>
                    <el-empty v-else description="暂无对话记录" :image-size="60" />
                </div>
            </div>
        </transition>

        <!-- 折叠时的展开按钮 -->
        <div v-show="!sidebarVisible" class="sidebar-toggle" @click="toggleSidebar">
            <el-icon><Expand /></el-icon>
        </div>

        <!-- 右侧主区域 -->
        <div class="ai-main">
            <!-- 顶部标题栏 -->
            <div class="chat-header">
                <div class="header-left">
                    <el-icon class="menu-toggle" @click="toggleSidebar" v-if="!sidebarVisible">
                        <Expand />
                    </el-icon>
                    <span class="chat-title">{{ currentConversationTitle || "AI 助手" }}</span>
                </div>
                <div class="header-right">
                    <el-tooltip content="清空当前对话" placement="bottom">
                        <el-icon class="header-icon" @click="handleClearMessages">
                            <Delete />
                        </el-icon>
                    </el-tooltip>
                </div>
            </div>

            <!-- 消息区域 -->
            <div ref="messageAreaRef" class="message-area">
                <!-- 空状态欢迎页 -->
                <div v-if="messages.length === 0" class="welcome-screen">
                    <div class="welcome-logo">
                        <el-icon :size="56" color="#667eea"><ChatLineSquare /></el-icon>
                    </div>
                    <h2 class="welcome-title">你好，我是 AI 助手</h2>
                    <p class="welcome-desc">基于 DeepSeek 大模型，随时为你解答进销存业务问题</p>
                    <div class="suggestion-cards">
                        <div
                            v-for="card in suggestionCards"
                            :key="card.title"
                            class="suggestion-card"
                            @click="handleSendSuggestion(card.prompt)"
                        >
                            <el-icon class="card-icon" :color="card.color">
                                <component :is="card.icon" />
                            </el-icon>
                            <div class="card-content">
                                <div class="card-title">{{ card.title }}</div>
                                <div class="card-desc">{{ card.desc }}</div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- 消息列表 -->
                <template v-else>
                    <div
                        v-for="(msg, idx) in messages"
                        :key="idx"
                        class="message-row"
                        :class="msg.role"
                    >
                        <!-- AI 消息 -->
                        <div v-if="msg.role === 'assistant'" class="message-item ai-message">
                            <div class="avatar ai-avatar">
                                <el-icon :size="20"><ChatLineSquare /></el-icon>
                            </div>
                            <div class="message-body">
                                <div class="message-content" v-html="renderMarkdown(msg.content)"></div>
                                <div class="message-actions">
                                    <el-tooltip content="复制" placement="top">
                                        <el-icon class="action-icon" @click="handleCopy(msg.content)">
                                            <CopyDocument />
                                        </el-icon>
                                    </el-tooltip>
                                </div>
                            </div>
                        </div>

                        <!-- 用户消息 -->
                        <div v-else class="message-item user-message">
                            <div class="message-body">
                                <div class="message-content">{{ msg.content }}</div>
                            </div>
                            <div class="avatar user-avatar">
                                <el-icon :size="20"><User /></el-icon>
                            </div>
                        </div>
                    </div>

                    <!-- 加载指示器 -->
                    <div v-if="loading" class="message-row assistant">
                        <div class="message-item ai-message">
                            <div class="avatar ai-avatar">
                                <el-icon :size="20"><ChatLineSquare /></el-icon>
                            </div>
                            <div class="message-body">
                                <div class="typing-indicator">
                                    <span></span>
                                    <span></span>
                                    <span></span>
                                </div>
                            </div>
                        </div>
                    </div>
                </template>
            </div>

            <!-- 输入区域 -->
            <div class="input-area">
                <div class="input-wrapper">
                    <el-input
                        ref="inputRef"
                        v-model="inputText"
                        type="textarea"
                        :autosize="{ minRows: 1, maxRows: 6 }"
                        placeholder="输入消息，按 Enter 发送，Shift+Enter 换行"
                        resize="none"
                        @keydown.enter="handleKeyDown"
                        :disabled="loading"
                    />
                    <div class="input-actions">
                        <el-button
                            type="primary"
                            :icon="Promotion"
                            circle
                            :loading="loading"
                            :disabled="!inputText.trim()"
                            @click="handleSendMessage"
                        />
                    </div>
                </div>
                <div class="input-tip">
                    <span>AI 生成内容仅供参考，请注意核实重要信息</span>
                </div>
            </div>
        </div>

        <!-- 重命名弹窗 -->
        <el-dialog v-model="renameDialogVisible" title="重命名对话" width="420px">
            <el-input v-model="renameTitle" placeholder="请输入对话标题" maxlength="50" show-word-limit />
            <template #footer>
                <el-button @click="renameDialogVisible = false">取消</el-button>
                <el-button type="primary" @click="handleRenameConfirm">确定</el-button>
            </template>
        </el-dialog>
    </div>
</template>

<script setup>
import { computed, nextTick, onMounted, ref } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import {
    ChatDotRound,
    ChatLineSquare,
    CopyDocument,
    Delete,
    Expand,
    Fold,
    MoreFilled,
    Plus,
    Promotion,
    User,
} from "@element-plus/icons-vue";

// ======================== 状态 ========================
const sidebarVisible = ref(true);
const searchKeyword = ref("");
const inputText = ref("");
const loading = ref(false);
const listLoading = ref(false);
const messages = ref([]);
const conversations = ref([]);
const currentConversationId = ref(null);
const messageAreaRef = ref(null);
const inputRef = ref(null);
const renameDialogVisible = ref(false);
const renameTitle = ref("");
const renameTarget = ref(null);

// ======================== 计算属性 ========================
const currentConversationTitle = computed(() => {
    const conv = conversations.value.find((c) => c.id === currentConversationId.value);
    return conv?.title || "";
});

const filteredConversations = computed(() => {
    if (!searchKeyword.value) return conversations.value;
    const kw = searchKeyword.value.toLowerCase();
    return conversations.value.filter((c) => c.title.toLowerCase().includes(kw));
});

// 按日期分组
const groupedConversations = computed(() => {
    const groups = { today: [], yesterday: [], week: [], earlier: [] };
    const now = new Date();
    const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate()).getTime();
    const yesterdayStart = todayStart - 86400000;
    const weekStart = todayStart - 7 * 86400000;

    filteredConversations.value.forEach((conv) => {
        const t = conv.timestamp || 0;
        if (t >= todayStart) groups.today.push(conv);
        else if (t >= yesterdayStart) groups.yesterday.push(conv);
        else if (t >= weekStart) groups.week.push(conv);
        else groups.earlier.push(conv);
    });

    const result = [];
    if (groups.today.length) result.push({ label: "今天", items: groups.today });
    if (groups.yesterday.length) result.push({ label: "昨天", items: groups.yesterday });
    if (groups.week.length) result.push({ label: "本周", items: groups.week });
    if (groups.earlier.length) result.push({ label: "更早", items: groups.earlier });
    return result;
});

// ======================== 建议卡片 ========================
const suggestionCards = [
    {
        title: "库存分析",
        desc: "帮我分析当前库存预警情况",
        prompt: "帮我分析一下当前的库存预警情况，哪些商品需要补货？",
        icon: "Box",
        color: "#409EFF",
    },
    {
        title: "销售建议",
        desc: "如何提升本月销售业绩",
        prompt: "根据近期的销售数据，给我一些提升销售业绩的建议。",
        icon: "TrendCharts",
        color: "#67C23A",
    },
    {
        title: "采购优化",
        desc: "优化采购流程和成本",
        prompt: "如何优化采购流程，降低采购成本？",
        icon: "ShoppingCart",
        color: "#E6A23C",
    },
    {
        title: "数据报表",
        desc: "生成本月经营分析报告",
        prompt: "请帮我生成一份本月的经营分析报告，包括销售、库存、采购等维度。",
        icon: "PieChart",
        color: "#F56C6C",
    },
];

// ======================== 方法 ========================

// 切换侧边栏
function toggleSidebar() {
    sidebarVisible.value = !sidebarVisible.value;
}

// 新建对话
function handleNewConversation() {
    currentConversationId.value = null;
    messages.value = [];
    nextTick(() => inputRef.value?.focus());
}

// 选择历史对话
function handleSelectConversation(conv) {
    if (conv.id === currentConversationId.value) return;
    currentConversationId.value = conv.id;
    messages.value = conv.messages || [];
    nextTick(() => scrollToBottom());
}

// 对话操作菜单
function handleConversationCommand(cmd, conv) {
    if (cmd === "rename") {
        renameTarget.value = conv;
        renameTitle.value = conv.title;
        renameDialogVisible.value = true;
    } else if (cmd === "delete") {
        handleDeleteConversation(conv);
    }
}

// 重命名确认
function handleRenameConfirm() {
    if (!renameTitle.value.trim()) {
        ElMessage.warning("请输入对话标题");
        return;
    }
    if (renameTarget.value) {
        renameTarget.value.title = renameTitle.value.trim();
        saveConversationsToStorage();
    }
    renameDialogVisible.value = false;
    renameTarget.value = null;
}

// 删除对话
async function handleDeleteConversation(conv) {
    try {
        await ElMessageBox.confirm("确定删除该对话吗？删除后不可恢复。", "删除确认", {
            confirmButtonText: "删除",
            cancelButtonText: "取消",
            type: "warning",
        });
        const idx = conversations.value.findIndex((c) => c.id === conv.id);
        if (idx !== -1) conversations.value.splice(idx, 1);
        if (currentConversationId.value === conv.id) {
            handleNewConversation();
        }
        saveConversationsToStorage();
        ElMessage.success("对话已删除");
    } catch {
        // 用户取消
    }
}

// 清空当前对话消息
async function handleClearMessages() {
    if (messages.value.length === 0) return;
    try {
        await ElMessageBox.confirm("确定清空当前对话的所有消息吗？", "清空确认", {
            confirmButtonText: "清空",
            cancelButtonText: "取消",
            type: "warning",
        });
        messages.value = [];
        if (currentConversationId.value) {
            const conv = conversations.value.find((c) => c.id === currentConversationId.value);
            if (conv) conv.messages = [];
        }
        saveConversationsToStorage();
        ElMessage.success("已清空对话");
    } catch {
        // 用户取消
    }
}

// 处理键盘事件
function handleKeyDown(e) {
    if (e.shiftKey) return; // Shift+Enter 换行
    e.preventDefault();
    handleSendMessage();
}

// 发送消息
async function handleSendMessage() {
    const text = inputText.value.trim();
    if (!text || loading.value) return;

    // 添加用户消息
    messages.value.push({ role: "user", content: text });
    inputText.value = "";
    loading.value = true;

    nextTick(() => scrollToBottom());

    try {
        // 调用后端 AI 接口
        const { sendChatMessage } = await import("@/api");
        const res = await sendChatMessage({
            conversationId: currentConversationId.value,
            message: text,
        });

        let reply = "";
        if (res && (res.code === "200" || res.code === 200)) {
            reply = res.data?.content || res.data?.reply || res.data || "";
            // 如果是新会话，后端返回了 conversationId
            if (res.data?.conversationId && !currentConversationId.value) {
                currentConversationId.value = res.data.conversationId;
            }
        } else {
            reply = res?.msg || "抱歉，服务暂时不可用，请稍后重试。";
        }

        // 如果后端未返回有效内容，使用模拟回复
        if (!reply || typeof reply !== "string") {
            reply = generateMockReply(text);
        }

        messages.value.push({ role: "assistant", content: reply });
    } catch (err) {
        // 后端不可用时使用模拟回复
        const mockReply = generateMockReply(text);
        messages.value.push({ role: "assistant", content: mockReply });
    } finally {
        loading.value = false;
        nextTick(() => scrollToBottom());
        // 保存或更新会话
        saveOrUpdateConversation(text);
    }
}

// 发送建议卡片
function handleSendSuggestion(prompt) {
    inputText.value = prompt;
    handleSendMessage();
}

// 复制消息
function handleCopy(text) {
    navigator.clipboard
        .writeText(text)
        .then(() => ElMessage.success("已复制到剪贴板"))
        .catch(() => ElMessage.error("复制失败"));
}

// 滚动到底部
function scrollToBottom() {
    if (messageAreaRef.value) {
        messageAreaRef.value.scrollTop = messageAreaRef.value.scrollHeight;
    }
}

// 简易 Markdown 渲染
function renderMarkdown(text) {
    if (!text) return "";
    let html = text;
    // 代码块
    html = html.replace(/```(\w*)\n([\s\S]*?)```/g, (_, lang, code) => {
        return `<pre class="code-block"><code>${escapeHtml(code.trim())}</code></pre>`;
    });
    // 行内代码
    html = html.replace(/`([^`]+)`/g, '<code class="inline-code">$1</code>');
    // 加粗
    html = html.replace(/\*\*([^*]+)\*\*/g, "<strong>$1</strong>");
    // 标题
    html = html.replace(/^### (.+)$/gm, '<h4 class="md-h4">$1</h4>');
    html = html.replace(/^## (.+)$/gm, '<h3 class="md-h3">$1</h3>');
    html = html.replace(/^# (.+)$/gm, '<h2 class="md-h2">$1</h2>');
    // 列表
    html = html.replace(/^- (.+)$/gm, '<div class="md-li">$1</div>');
    // 段落（换行）
    html = html.replace(/\n/g, "<br>");
    return html;
}

function escapeHtml(str) {
    return str
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;");
}

// 生成模拟回复（后端不可用时的降级方案）
function generateMockReply(userText) {
    const replies = [
        `收到你的问题：「${userText}」\n\n这是一个很好的问题。作为进销存 ERP 系统的 AI 助手，我可以帮你：\n\n- 分析库存数据和预警情况\n- 提供销售和采购建议\n- 生成经营分析报告\n- 解答业务流程问题\n\n请告诉我你具体想了解哪方面的信息，我会为你详细解答。`,
        `关于「${userText}」，我的建议如下：\n\n1. **数据层面**：建议先查看相关模块的统计数据，了解当前状况\n2. **分析层面**：通过对比历史数据，找出趋势和异常\n3. **行动层面**：根据分析结果制定具体的行动计划\n\n如果你需要更详细的报表或数据，可以在左侧菜单中查看对应的报表分析模块。`,
        `我理解你想了解「${userText}」相关的内容。\n\n根据系统中的数据，我建议你关注以下几个方面：\n\n- 库存周转率是否健康\n- 供应商交货及时率\n- 客户满意度变化趋势\n- 采购成本控制情况\n\n你可以随时向我提出更具体的问题，我会尽力为你解答。`,
    ];
    return replies[Math.floor(Math.random() * replies.length)];
}

// 保存或更新会话
function saveOrUpdateConversation(firstMessage) {
    if (!currentConversationId.value) {
        // 新建会话
        const newConv = {
            id: "conv_" + Date.now(),
            title: firstMessage.slice(0, 30) + (firstMessage.length > 30 ? "..." : ""),
            timestamp: Date.now(),
            messages: [...messages.value],
        };
        conversations.value.unshift(newConv);
        currentConversationId.value = newConv.id;
    } else {
        // 更新现有会话
        const conv = conversations.value.find((c) => c.id === currentConversationId.value);
        if (conv) {
            conv.messages = [...messages.value];
            conv.timestamp = Date.now();
        }
    }
    saveConversationsToStorage();
}

// localStorage 持久化
function saveConversationsToStorage() {
    try {
        localStorage.setItem("ai_conversations", JSON.stringify(conversations.value));
    } catch (e) {
        console.error("保存对话失败", e);
    }
}

function loadConversationsFromStorage() {
    try {
        const data = localStorage.getItem("ai_conversations");
        if (data) conversations.value = JSON.parse(data);
    } catch (e) {
        console.error("加载对话失败", e);
    }
}

// ======================== 初始化 ========================
onMounted(() => {
    loadConversationsFromStorage();
    nextTick(() => inputRef.value?.focus());
});
</script>

<style scoped>
.ai-partner {
    display: flex;
    height: 100%;
    background-color: #f5f7fa;
    overflow: hidden;
}

/* ======================== 左侧会话栏 ======================== */
.ai-sidebar {
    width: 280px;
    min-width: 280px;
    background-color: #ffffff;
    border-right: 1px solid #e4e7ed;
    display: flex;
    flex-direction: column;
    box-shadow: 1px 0 4px rgba(0, 0, 0, 0.04);
}

.sidebar-header {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 16px;
    border-bottom: 1px solid #f0f0f0;
}

.new-chat-btn {
    flex: 1;
    justify-content: flex-start;
}

.collapse-btn {
    font-size: 20px;
    color: #909399;
    cursor: pointer;
    transition: color 0.2s;
}

.collapse-btn:hover {
    color: #409eff;
}

.sidebar-search {
    padding: 0 16px 12px;
}

.conversation-list {
    flex: 1;
    overflow-y: auto;
    padding: 8px 0;
}

.conversation-group {
    margin-bottom: 8px;
}

.group-label {
    font-size: 12px;
    color: #909399;
    padding: 8px 20px 4px;
    font-weight: 500;
}

.conversation-item {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 10px 16px;
    cursor: pointer;
    transition: background-color 0.2s;
    position: relative;
}

.conversation-item:hover {
    background-color: #f5f7fa;
}

.conversation-item.active {
    background-color: #ecf5ff;
}

.conversation-item.active .conv-title {
    color: #409eff;
    font-weight: 500;
}

.conv-icon {
    font-size: 16px;
    color: #909399;
    flex-shrink: 0;
}

.conversation-item.active .conv-icon {
    color: #409eff;
}

.conv-title {
    flex: 1;
    font-size: 14px;
    color: #606266;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.conv-actions {
    opacity: 0;
    transition: opacity 0.2s;
    flex-shrink: 0;
}

.conversation-item:hover .conv-actions {
    opacity: 1;
}

.more-icon {
    font-size: 16px;
    color: #909399;
    cursor: pointer;
}

.more-icon:hover {
    color: #409eff;
}

/* ======================== 展开按钮 ======================== */
.sidebar-toggle {
    width: 40px;
    display: flex;
    align-items: center;
    justify-content: center;
    background-color: #ffffff;
    border-right: 1px solid #e4e7ed;
    cursor: pointer;
    color: #909399;
    transition: color 0.2s;
}

.sidebar-toggle:hover {
    color: #409eff;
}

/* ======================== 主区域 ======================== */
.ai-main {
    flex: 1;
    display: flex;
    flex-direction: column;
    min-width: 0;
    background-color: #ffffff;
}

/* 顶部标题栏 */
.chat-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0 20px;
    height: 56px;
    border-bottom: 1px solid #f0f0f0;
    flex-shrink: 0;
}

.header-left {
    display: flex;
    align-items: center;
    gap: 12px;
}

.menu-toggle {
    font-size: 20px;
    color: #606266;
    cursor: pointer;
}

.chat-title {
    font-size: 16px;
    font-weight: 500;
    color: #303133;
}

.header-right {
    display: flex;
    align-items: center;
    gap: 8px;
}

.header-icon {
    font-size: 18px;
    color: #909399;
    cursor: pointer;
    transition: color 0.2s;
}

.header-icon:hover {
    color: #f56c6c;
}

/* ======================== 消息区域 ======================== */
.message-area {
    flex: 1;
    overflow-y: auto;
    padding: 20px 0;
}

/* 空状态欢迎页 */
.welcome-screen {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    height: 100%;
    padding: 40px;
    text-align: center;
}

.welcome-logo {
    width: 80px;
    height: 80px;
    border-radius: 50%;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    display: flex;
    align-items: center;
    justify-content: center;
    margin-bottom: 24px;
}

.welcome-title {
    font-size: 24px;
    color: #303133;
    margin: 0 0 8px 0;
}

.welcome-desc {
    font-size: 14px;
    color: #909399;
    margin: 0 0 32px 0;
}

.suggestion-cards {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 16px;
    max-width: 640px;
    width: 100%;
}

.suggestion-card {
    display: flex;
    align-items: flex-start;
    gap: 12px;
    padding: 20px;
    background-color: #f9fafc;
    border: 1px solid #ebeef5;
    border-radius: 12px;
    cursor: pointer;
    text-align: left;
    transition: all 0.3s;
}

.suggestion-card:hover {
    border-color: #409eff;
    box-shadow: 0 4px 12px rgba(64, 158, 255, 0.12);
    transform: translateY(-2px);
}

.card-icon {
    font-size: 24px;
    flex-shrink: 0;
}

.card-content {
    flex: 1;
}

.card-title {
    font-size: 15px;
    font-weight: 500;
    color: #303133;
    margin-bottom: 4px;
}

.card-desc {
    font-size: 13px;
    color: #909399;
}

/* ======================== 消息项 ======================== */
.message-row {
    display: flex;
    margin-bottom: 24px;
    padding: 0 20px;
}

.message-row.assistant {
    justify-content: flex-start;
}

.message-row.user {
    justify-content: flex-end;
}

.message-item {
    display: flex;
    gap: 12px;
    max-width: 80%;
}

.ai-message {
    flex-direction: row;
}

.user-message {
    flex-direction: row-reverse;
}

.avatar {
    width: 36px;
    height: 36px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
    color: #fff;
}

.ai-avatar {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.user-avatar {
    background: linear-gradient(135deg, #409eff 0%, #337ecc 100%);
}

.message-body {
    display: flex;
    flex-direction: column;
    gap: 6px;
}

.user-message .message-body {
    align-items: flex-end;
}

.message-content {
    padding: 12px 16px;
    border-radius: 12px;
    font-size: 14px;
    line-height: 1.7;
    word-break: break-word;
}

.ai-message .message-content {
    background-color: #f5f7fa;
    color: #303133;
    border-top-left-radius: 4px;
}

.user-message .message-content {
    background-color: #409eff;
    color: #fff;
    border-top-right-radius: 4px;
}

.message-actions {
    display: flex;
    gap: 8px;
}

.action-icon {
    font-size: 14px;
    color: #c0c4cc;
    cursor: pointer;
    transition: color 0.2s;
}

.action-icon:hover {
    color: #409eff;
}

/* ======================== Markdown 样式 ======================== */
.message-content :deep(.code-block) {
    background-color: #1e1e1e;
    color: #d4d4d4;
    padding: 12px 16px;
    border-radius: 8px;
    overflow-x: auto;
    margin: 8px 0;
    font-family: "Consolas", "Monaco", monospace;
    font-size: 13px;
}

.message-content :deep(.inline-code) {
    background-color: rgba(0, 0, 0, 0.06);
    padding: 2px 6px;
    border-radius: 4px;
    font-family: "Consolas", "Monaco", monospace;
    font-size: 13px;
}

.user-message .message-content :deep(.inline-code) {
    background-color: rgba(255, 255, 255, 0.2);
}

.message-content :deep(.md-h2),
.message-content :deep(.md-h3),
.message-content :deep(.md-h4) {
    margin: 12px 0 6px;
    font-weight: 600;
}

.message-content :deep(.md-h2) {
    font-size: 16px;
}

.message-content :deep(.md-h3) {
    font-size: 15px;
}

.message-content :deep(.md-h4) {
    font-size: 14px;
}

.message-content :deep(.md-li) {
    padding-left: 16px;
    position: relative;
    margin: 4px 0;
}

.message-content :deep(.md-li)::before {
    content: "•";
    position: absolute;
    left: 4px;
}

/* ======================== 打字指示器 ======================== */
.typing-indicator {
    display: flex;
    gap: 4px;
    padding: 14px 16px;
    background-color: #f5f7fa;
    border-radius: 12px;
    border-top-left-radius: 4px;
}

.typing-indicator span {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background-color: #c0c4cc;
    animation: typing-bounce 1.4s infinite ease-in-out;
}

.typing-indicator span:nth-child(2) {
    animation-delay: 0.2s;
}

.typing-indicator span:nth-child(3) {
    animation-delay: 0.4s;
}

@keyframes typing-bounce {
    0%, 60%, 100% {
        transform: translateY(0);
        opacity: 0.4;
    }
    30% {
        transform: translateY(-6px);
        opacity: 1;
    }
}

/* ======================== 输入区域 ======================== */
.input-area {
    padding: 12px 20px 16px;
    border-top: 1px solid #f0f0f0;
    flex-shrink: 0;
}

.input-wrapper {
    display: flex;
    align-items: flex-end;
    gap: 12px;
    background-color: #f5f7fa;
    border: 1px solid #e4e7ed;
    border-radius: 12px;
    padding: 8px 8px 8px 16px;
    transition: border-color 0.2s;
}

.input-wrapper:focus-within {
    border-color: #409eff;
}

.input-wrapper :deep(.el-textarea__inner) {
    border: none;
    background: transparent;
    box-shadow: none;
    padding: 4px 0;
    resize: none;
    font-size: 14px;
    line-height: 1.6;
}

.input-actions {
    flex-shrink: 0;
}

.input-tip {
    text-align: center;
    font-size: 12px;
    color: #c0c4cc;
    margin-top: 8px;
}

/* ======================== 侧边栏动画 ======================== */
.slide-sidebar-enter-active,
.slide-sidebar-leave-active {
    transition: all 0.3s ease;
}

.slide-sidebar-enter-from,
.slide-sidebar-leave-to {
    margin-left: -280px;
    opacity: 0;
}

/* ======================== 滚动条 ======================== */
.message-area::-webkit-scrollbar,
.conversation-list::-webkit-scrollbar {
    width: 6px;
}

.message-area::-webkit-scrollbar-thumb,
.conversation-list::-webkit-scrollbar-thumb {
    background-color: #dcdfe6;
    border-radius: 3px;
}

.message-area::-webkit-scrollbar-track,
.conversation-list::-webkit-scrollbar-track {
    background: transparent;
}

/* ======================== 响应式 ======================== */
@media (max-width: 768px) {
    .ai-sidebar {
        position: absolute;
        z-index: 10;
        height: 100%;
        box-shadow: 2px 0 8px rgba(0, 0, 0, 0.15);
    }

    .suggestion-cards {
        grid-template-columns: 1fr;
    }

    .message-item {
        max-width: 90%;
    }
}
</style>
