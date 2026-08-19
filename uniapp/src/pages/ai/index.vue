<template>
  <view class="page">
    <view class="sidebar-mask" v-if="sidebarVisible" @click="sidebarVisible = false"></view>
    <view class="sidebar" :class="{ 'sidebar-show': sidebarVisible }">
      <view class="sidebar-header">
        <text class="sidebar-title">AI 助手</text>
        <text class="sidebar-close" @click="sidebarVisible = false">✕</text>
      </view>
      <view class="new-chat-btn" @tap="createNewConversation">
        <text class="new-chat-icon">+</text>
        <text class="new-chat-text">新建对话</text>
      </view>
      <view class="search-wrapper">
        <input class="search-input" v-model="searchKeyword" placeholder="搜索对话" />
      </view>
      <scroll-view scroll-y class="conversation-list">
        <view v-for="(group, gIdx) in groupedConversations" :key="gIdx">
          <text class="group-label">{{ group.label }}</text>
          <view
            v-for="item in group.items"
            :key="item.id"
            class="conversation-item"
            :class="{ 'conversation-active': item.id === currentConversationId }"
            @tap="switchConversation(item.id)"
            @longpress="onConversationLongPress(item)"
          >
            <text class="conversation-title">{{ item.title }}</text>
            <text class="conversation-time">{{ formatTime(item.timestamp) }}</text>
          </view>
        </view>
        <view v-if="filteredConversations.length === 0 && !listLoading" class="empty-conversations">
          <text class="empty-text">暂无对话</text>
        </view>
      </scroll-view>
    </view>

    <view class="chat-main">
      <view class="chat-header">
        <view class="header-left" @tap="sidebarVisible = !sidebarVisible">
          <text class="menu-icon">☰</text>
        </view>
        <text class="header-title">{{ currentTitle }}</text>
        <view class="header-right"></view>
      </view>

      <scroll-view
        scroll-y
        class="message-area"
        :scroll-into-view="scrollTarget"
        scroll-with-animation
      >
        <view v-if="messages.length === 0 && !loading" class="welcome-screen">
          <view class="welcome-avatar">
            <text class="welcome-avatar-text">AI</text>
          </view>
          <text class="welcome-title">你好，我是 AI 智能助手</text>
          <text class="welcome-desc">我可以帮你分析库存、优化销售、管理采购等</text>
          <view class="suggestion-cards">
            <view
              v-for="(s, idx) in suggestions"
              :key="idx"
              class="suggestion-card"
              @tap="sendSuggestion(s.prompt)"
            >
              <view class="suggestion-icon-wrap" :style="{ background: s.color + '15' }">
                <text class="suggestion-icon" :style="{ color: s.color }">{{ getSuggestionEmoji(idx) }}</text>
              </view>
              <text class="suggestion-title">{{ s.title }}</text>
              <text class="suggestion-desc">{{ s.desc }}</text>
            </view>
          </view>
        </view>

        <view v-for="(msg, idx) in messages" :key="idx" :id="'msg-' + idx" class="message-item" :class="msg.role === 'user' ? 'message-user' : 'message-ai'">
          <view v-if="msg.role === 'ai'" class="ai-avatar">
            <text class="avatar-text">AI</text>
          </view>
          <view class="message-bubble" :class="msg.role === 'user' ? 'bubble-user' : 'bubble-ai'">
            <view v-if="msg.role === 'ai'" class="markdown-body" v-html="renderMarkdown(msg.content)"></view>
            <text v-else class="message-text">{{ msg.content }}</text>
          </view>
          <view v-if="msg.role === 'ai'" class="message-actions">
            <text class="action-btn" @tap="copyMessage(msg.content)">复制</text>
          </view>
          <view v-if="msg.role === 'user'" class="user-avatar">
            <text class="avatar-text">我</text>
          </view>
        </view>

        <view v-if="loading" class="message-item message-ai" :id="'msg-' + messages.length">
          <view class="ai-avatar">
            <text class="avatar-text">AI</text>
          </view>
          <view class="message-bubble bubble-ai">
            <view class="typing-indicator">
              <view class="typing-dot"></view>
              <view class="typing-dot"></view>
              <view class="typing-dot"></view>
            </view>
          </view>
        </view>

        <view id="chat-bottom"></view>
      </scroll-view>

      <view class="input-area">
        <view class="input-wrapper">
          <textarea
            class="chat-textarea"
            v-model="inputText"
            placeholder="输入你的问题..."
            :auto-height="true"
            :maxlength="2000"
            @confirm="sendMessage"
            confirm-type="send"
          />
          <view
            class="send-btn"
            :class="{ 'send-btn-disabled': !canSend }"
            @tap="sendMessage"
          >
            <text class="send-btn-text">发送</text>
          </view>
        </view>
      </view>
    </view>

    <view v-if="renameDialogVisible" class="modal-mask" @tap="renameDialogVisible = false">
      <view class="modal-box" @tap.stop>
        <text class="modal-title">重命名对话</text>
        <view class="modal-body">
          <input class="rename-input" v-model="renameTitle" placeholder="请输入新名称" />
        </view>
        <view class="modal-btns">
          <view class="modal-btn cancel" @tap="renameDialogVisible = false">
            <text class="btn-text">取消</text>
          </view>
          <view class="modal-btn confirm" @tap="confirmRename">
            <text class="btn-text btn-confirm-text">确定</text>
          </view>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref, computed, nextTick, onMounted } from 'vue'
import { sendChatMessage } from '@/api/ai'

const STORAGE_KEY = 'ai_conversations'

const sidebarVisible = ref(true)
const searchKeyword = ref('')
const inputText = ref('')
const loading = ref(false)
const listLoading = ref(false)
const messages = ref([])
const conversations = ref([])
const currentConversationId = ref('')
const renameDialogVisible = ref(false)
const renameTitle = ref('')
const renameTarget = ref(null)
const scrollTarget = ref('')

const suggestions = [
  { title: '库存分析', desc: '帮我分析当前库存预警情况', prompt: '帮我分析一下当前的库存预警情况，哪些商品需要补货？', color: '#409EFF' },
  { title: '销售建议', desc: '如何提升本月销售业绩', prompt: '根据近期的销售数据，给我一些提升销售业绩的建议。', color: '#67C23A' },
  { title: '采购优化', desc: '优化采购流程和成本', prompt: '如何优化采购流程，降低采购成本？', color: '#E6A23C' },
  { title: '数据报表', desc: '生成本月经营分析报告', prompt: '请帮我生成一份本月的经营分析报告，包括销售、库存、采购等维度。', color: '#F56C6C' },
]

const canSend = computed(() => inputText.value.trim().length > 0 && !loading.value)

const currentTitle = computed(() => {
  const conv = conversations.value.find(c => c.id === currentConversationId.value)
  return conv ? conv.title : '新对话'
})

const filteredConversations = computed(() => {
  if (!searchKeyword.value) return conversations.value
  const kw = searchKeyword.value.toLowerCase()
  return conversations.value.filter(c => c.title.toLowerCase().includes(kw))
})

const groupedConversations = computed(() => {
  const now = new Date()
  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate()).getTime()
  const yesterday = today - 86400000
  const weekAgo = today - 7 * 86400000

  const groups = { '今天': [], '昨天': [], '本周': [], '更早': [] }
  filteredConversations.value.forEach(c => {
    const t = c.timestamp
    if (t >= today) groups['今天'].push(c)
    else if (t >= yesterday) groups['昨天'].push(c)
    else if (t >= weekAgo) groups['本周'].push(c)
    else groups['更早'].push(c)
  })

  const labels = ['今天', '昨天', '本周', '更早']
  const result = []
  for (const label of labels) {
    if (groups[label].length > 0) {
      result.push({ label, items: groups[label].sort((a, b) => b.timestamp - a.timestamp) })
    }
  }
  return result
})

const mockReplies = [
  '根据系统数据分析，当前库存中有 **12 个 SKU** 的库存量低于安全库存线，建议及时补货。\n\n### 需要补货的商品\n1. 商品A - 当前库存 5，建议补货 50\n2. 商品B - 当前库存 3，建议补货 30\n3. 商品C - 当前库存 8，建议补货 40\n\n### 建议\n- 优先补货库存为0的商品\n- 联系供应商确认交期',
  '根据近 30 天的销售数据分析，给您以下建议：\n\n### 提升销售业绩的方法\n- **增加高毛利商品曝光**：将高毛利商品放在推荐位\n- **促销活动**：针对滞销商品开展限时折扣\n- **客户维护**：对老客户发送新品推荐\n\n### 数据概览\n| 指标 | 本月 | 上月 | 变化 |\n|------|------|------|------|\n| 销售额 | 12.8万 | 11.2万 | +14.3% |\n| 订单数 | 256 | 231 | +10.8% |',
  '关于采购流程优化，我有以下建议：\n\n### 流程优化\n1. **集中采购**：合并同类商品的采购需求，降低单次采购成本\n2. **供应商比价**：建立供应商评分体系，定期比价\n3. **库存联动**：设置自动补货阈值，减少人工干预\n\n### 成本控制\n- 批量采购可降低 **5%-15%** 的采购成本\n- 建立长期合作关系可获得更优惠的价格\n- 优化物流路线，降低运输成本\n\n> 建议定期复盘采购数据，持续优化采购策略。',
]

let mockIndex = 0

function getSuggestionEmoji(idx) {
  return ['📊', '💡', '🛒', '📈'][idx] || '💬'
}

function formatTime(ts) {
  const d = new Date(ts)
  const m = (d.getMonth() + 1).toString().padStart(2, '0')
  const day = d.getDate().toString().padStart(2, '0')
  const h = d.getHours().toString().padStart(2, '0')
  const min = d.getMinutes().toString().padStart(2, '0')
  return `${m}-${day} ${h}:${min}`
}

function renderMarkdown(text) {
  if (!text) return ''
  let html = text
  html = html.replace(/```(\w*)\n([\s\S]*?)```/g, '<pre class="code-block"><code>$2</code></pre>')
  html = html.replace(/`([^`]+)`/g, '<code class="inline-code">$1</code>')
  html = html.replace(/^### (.+)$/gm, '<h3 class="md-h3">$1</h3>')
  html = html.replace(/^## (.+)$/gm, '<h2 class="md-h2">$1</h2>')
  html = html.replace(/^# (.+)$/gm, '<h1 class="md-h1">$1</h1>')
  html = html.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
  html = html.replace(/\*(.+?)\*/g, '<em>$1</em>')
  html = html.replace(/^> (.+)$/gm, '<blockquote class="md-quote">$1</blockquote>')
  html = html.replace(/^- (.+)$/gm, '<view class="md-list-item"><text class="md-list-dot">•</text><text>$1</text></view>')
  html = html.replace(/^(\d+)\. (.+)$/gm, '<view class="md-list-item"><text class="md-list-num">$1.</text><text>$2</text></view>')
  html = html.replace(/\|(.+)\|/g, (match) => {
    const cells = match.split('|').filter(c => c.trim())
    if (cells.every(c => /^[\s\-:]+$/.test(c))) return '<view class="md-table-divider"></view>'
    return '<view class="md-table-row">' + cells.map(c => '<text class="md-table-cell">' + c.trim() + '</text>').join('') + '</view>'
  })
  html = html.replace(/\n/g, '<br/>')
  return html
}

function scrollToBottom() {
  nextTick(() => {
    scrollTarget.value = ''
    nextTick(() => {
      scrollTarget.value = messages.value.length > 0 ? 'msg-' + (messages.value.length - 1) : 'chat-bottom'
    })
  })
}

function loadConversations() {
  try {
    const data = uni.getStorageSync(STORAGE_KEY)
    if (data) {
      conversations.value = JSON.parse(data)
    }
  } catch (e) {
    conversations.value = []
  }
}

function saveConversations() {
  try {
    uni.setStorageSync(STORAGE_KEY, JSON.stringify(conversations.value))
  } catch (e) {
    console.error('save conversations error', e)
  }
}

function createNewConversation() {
  const id = 'conv_' + Date.now()
  const conv = { id, title: '新对话', timestamp: Date.now(), messages: [] }
  conversations.value.unshift(conv)
  currentConversationId.value = id
  messages.value = []
  saveConversations()
  sidebarVisible.value = false
}

function switchConversation(id) {
  currentConversationId.value = id
  const conv = conversations.value.find(c => c.id === id)
  messages.value = conv ? [...conv.messages] : []
  sidebarVisible.value = false
  scrollToBottom()
}

function onConversationLongPress(item) {
  uni.showActionSheet({
    itemList: ['重命名', '删除'],
    success: (res) => {
      if (res.tapIndex === 0) {
        renameTarget.value = item
        renameTitle.value = item.title
        renameDialogVisible.value = true
      } else if (res.tapIndex === 1) {
        uni.showModal({
          title: '提示',
          content: '确定要删除这个对话吗？',
          success: (r) => {
            if (r.confirm) {
              conversations.value = conversations.value.filter(c => c.id !== item.id)
              if (currentConversationId.value === item.id) {
                if (conversations.value.length > 0) {
                  switchConversation(conversations.value[0].id)
                } else {
                  createNewConversation()
                }
              }
              saveConversations()
            }
          }
        })
      }
    }
  })
}

function confirmRename() {
  if (!renameTitle.value.trim()) {
    uni.showToast({ title: '请输入名称', icon: 'none' })
    return
  }
  if (renameTarget.value) {
    renameTarget.value.title = renameTitle.value.trim()
    saveConversations()
  }
  renameDialogVisible.value = false
}

function copyMessage(content) {
  uni.setClipboardData({
    data: content,
    success: () => {
      uni.showToast({ title: '已复制', icon: 'success' })
    }
  })
}

async function sendMessage() {
  if (!canSend.value) return
  const text = inputText.value.trim()
  if (!text) return

  if (!currentConversationId.value) {
    createNewConversation()
  }

  messages.value.push({ role: 'user', content: text })
  inputText.value = ''
  scrollToBottom()

  const conv = conversations.value.find(c => c.id === currentConversationId.value)
  if (conv && conv.messages.length === 0) {
    conv.title = text.substring(0, 20) + (text.length > 20 ? '...' : '')
  }

  loading.value = true
  scrollToBottom()

  try {
    const res = await sendChatMessage({
      message: text,
      conversationId: currentConversationId.value,
    })
    if (res.code === '200' && res.data) {
      const reply = typeof res.data === 'string' ? res.data : (res.data.reply || res.data.content || '抱歉，我无法理解你的问题。')
      messages.value.push({ role: 'ai', content: reply })
    } else {
      throw new Error('api error')
    }
  } catch (e) {
    const reply = mockReplies[mockIndex % mockReplies.length]
    mockIndex++
    messages.value.push({ role: 'ai', content: reply })
  } finally {
    loading.value = false
    if (conv) {
      conv.messages = [...messages.value]
      saveConversations()
    }
    scrollToBottom()
  }
}

function sendSuggestion(prompt) {
  inputText.value = prompt
  sendMessage()
}

onMounted(() => {
  loadConversations()
  if (conversations.value.length === 0) {
    createNewConversation()
  } else if (!currentConversationId.value) {
    switchConversation(conversations.value[0].id)
  }
})
</script>

<style scoped>
.page {
  display: flex;
  height: 100vh;
  background: #F5F7FA;
  position: relative;
  overflow: hidden;
}

.sidebar-mask {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.4);
  z-index: 99;
}

.sidebar {
  position: fixed;
  top: 0;
  left: 0;
  bottom: 0;
  width: 280px;
  background: #FFFFFF;
  z-index: 100;
  display: flex;
  flex-direction: column;
  transform: translateX(-100%);
  transition: transform 0.3s ease;
  box-shadow: 2px 0 12px rgba(0, 0, 0, 0.1);
}

.sidebar-show {
  transform: translateX(0);
}

.sidebar-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  border-bottom: 1px solid #F2F6FC;
}

.sidebar-title {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
}

.sidebar-close {
  font-size: 18px;
  color: #909399;
  padding: 4px;
}

.new-chat-btn {
  display: flex;
  align-items: center;
  margin: 12px 16px;
  padding: 12px;
  background: #ECF5FF;
  border-radius: 10px;
}

.new-chat-icon {
  font-size: 18px;
  color: #409EFF;
  margin-right: 8px;
  font-weight: bold;
}

.new-chat-text {
  font-size: 14px;
  color: #409EFF;
  font-weight: 500;
}

.search-wrapper {
  padding: 0 16px 12px;
}

.search-input {
  width: 100%;
  height: 36px;
  padding: 0 12px;
  border: 1px solid #DCDFE6;
  border-radius: 8px;
  font-size: 13px;
  background: #F5F7FA;
}

.conversation-list {
  flex: 1;
  overflow: hidden;
}

.group-label {
  display: block;
  font-size: 12px;
  color: #909399;
  padding: 8px 16px 4px;
}

.conversation-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;
  border-bottom: 1px solid #F8F8F8;
}

.conversation-item:active {
  background: #F5F7FA;
}

.conversation-active {
  background: #ECF5FF;
  border-right: 3px solid #409EFF;
}

.conversation-title {
  font-size: 14px;
  color: #303133;
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.conversation-time {
  font-size: 11px;
  color: #C0C4CC;
  flex-shrink: 0;
  margin-left: 8px;
}

.empty-conversations {
  padding: 40px 0;
  text-align: center;
}

.empty-text {
  font-size: 13px;
  color: #909399;
}

.chat-main {
  flex: 1;
  display: flex;
  flex-direction: column;
  height: 100vh;
}

.chat-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 48px;
  padding: 0 12px;
  background: #FFFFFF;
  border-bottom: 1px solid #F2F6FC;
  flex-shrink: 0;
}

.header-left {
  padding: 8px;
}

.menu-icon {
  font-size: 20px;
  color: #303133;
}

.header-title {
  font-size: 16px;
  font-weight: 500;
  color: #303133;
  flex: 1;
  text-align: center;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.header-right {
  width: 36px;
}

.message-area {
  flex: 1;
  overflow: hidden;
  padding: 12px;
}

.welcome-screen {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 40px 16px;
}

.welcome-avatar {
  width: 64px;
  height: 64px;
  border-radius: 50%;
  background: linear-gradient(135deg, #409EFF, #66B1FF);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 16px;
}

.welcome-avatar-text {
  font-size: 24px;
  font-weight: bold;
  color: #FFFFFF;
}

.welcome-title {
  font-size: 20px;
  font-weight: 600;
  color: #303133;
  margin-bottom: 8px;
}

.welcome-desc {
  font-size: 14px;
  color: #909399;
  margin-bottom: 32px;
}

.suggestion-cards {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  width: 100%;
}

.suggestion-card {
  width: calc(50% - 6px);
  background: #FFFFFF;
  border-radius: 12px;
  padding: 16px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.suggestion-card:active {
  transform: scale(0.98);
}

.suggestion-icon-wrap {
  width: 40px;
  height: 40px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 10px;
}

.suggestion-icon {
  font-size: 20px;
}

.suggestion-title {
  font-size: 15px;
  font-weight: 600;
  color: #303133;
  display: block;
  margin-bottom: 4px;
}

.suggestion-desc {
  font-size: 12px;
  color: #909399;
  display: block;
}

.message-item {
  display: flex;
  align-items: flex-start;
  margin-bottom: 16px;
  gap: 10px;
}

.message-user {
  justify-content: flex-end;
}

.message-ai {
  justify-content: flex-start;
}

.ai-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: linear-gradient(135deg, #409EFF, #66B1FF);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.user-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: linear-gradient(135deg, #67C23A, #85CE61);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.avatar-text {
  font-size: 14px;
  font-weight: bold;
  color: #FFFFFF;
}

.message-bubble {
  max-width: 75%;
  padding: 12px 16px;
  border-radius: 16px;
  word-break: break-word;
}

.bubble-user {
  background: #409EFF;
  border-bottom-right-radius: 4px;
}

.bubble-ai {
  background: #FFFFFF;
  border-bottom-left-radius: 4px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
}

.message-text {
  font-size: 14px;
  color: #FFFFFF;
  line-height: 1.6;
}

.message-actions {
  display: flex;
  margin-top: 4px;
}

.action-btn {
  font-size: 12px;
  color: #909399;
  padding: 2px 8px;
}

.action-btn:active {
  color: #409EFF;
}

.markdown-body {
  font-size: 14px;
  color: #303133;
  line-height: 1.7;
}

.markdown-body :deep(.code-block) {
  background: #F5F7FA;
  border-radius: 8px;
  padding: 12px;
  overflow-x: auto;
  margin: 8px 0;
}

.markdown-body :deep(.code-block code) {
  font-size: 13px;
  color: #E6A23C;
  font-family: monospace;
}

.markdown-body :deep(.inline-code) {
  background: #F0F2F5;
  padding: 2px 6px;
  border-radius: 4px;
  font-size: 13px;
  color: #E6A23C;
  font-family: monospace;
}

.markdown-body :deep(.md-h1) {
  font-size: 18px;
  font-weight: 600;
  margin: 12px 0 8px;
}

.markdown-body :deep(.md-h2) {
  font-size: 16px;
  font-weight: 600;
  margin: 10px 0 6px;
}

.markdown-body :deep(.md-h3) {
  font-size: 15px;
  font-weight: 600;
  margin: 8px 0 4px;
}

.markdown-body :deep(.md-quote) {
  border-left: 3px solid #409EFF;
  padding-left: 12px;
  color: #909399;
  margin: 8px 0;
}

.markdown-body :deep(.md-list-item) {
  display: flex;
  align-items: flex-start;
  margin: 4px 0;
}

.markdown-body :deep(.md-list-dot),
.markdown-body :deep(.md-list-num) {
  margin-right: 8px;
  color: #409EFF;
}

.markdown-body :deep(.md-table-row) {
  display: flex;
  border: 1px solid #EBEEF5;
  border-radius: 4px;
  margin: 4px 0;
  overflow: hidden;
}

.markdown-body :deep(.md-table-cell) {
  flex: 1;
  padding: 6px 10px;
  font-size: 13px;
  border-right: 1px solid #EBEEF5;
}

.markdown-body :deep(.md-table-cell:last-child) {
  border-right: none;
}

.markdown-body :deep(.md-table-divider) {
  height: 2px;
  background: #EBEEF5;
}

.typing-indicator {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 4px 0;
}

.typing-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #C0C4CC;
  animation: typingBounce 1.4s infinite ease-in-out;
}

.typing-dot:nth-child(2) {
  animation-delay: 0.2s;
}

.typing-dot:nth-child(3) {
  animation-delay: 0.4s;
}

@keyframes typingBounce {
  0%, 80%, 100% { transform: translateY(0); opacity: 0.4; }
  40% { transform: translateY(-6px); opacity: 1; }
}

.input-area {
  padding: 12px 16px;
  background: #FFFFFF;
  border-top: 1px solid #F2F6FC;
  flex-shrink: 0;
}

.input-wrapper {
  display: flex;
  align-items: flex-end;
  gap: 8px;
  background: #F5F7FA;
  border-radius: 12px;
  padding: 8px 12px;
}

.chat-textarea {
  flex: 1;
  min-height: 36px;
  max-height: 120px;
  font-size: 14px;
  line-height: 1.5;
  padding: 4px 0;
}

.send-btn {
  width: 56px;
  height: 36px;
  background: #409EFF;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.send-btn:active {
  opacity: 0.85;
}

.send-btn-disabled {
  background: #C0C4CC;
}

.send-btn-text {
  font-size: 14px;
  color: #FFFFFF;
  font-weight: 500;
}

.modal-mask {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  z-index: 1000;
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal-box {
  background: #FFFFFF;
  border-radius: 12px;
  width: 85%;
  overflow: hidden;
}

.modal-title {
  font-size: 17px;
  font-weight: 500;
  text-align: center;
  padding: 16px;
  border-bottom: 1px solid #F2F6FC;
}

.modal-body {
  padding: 20px 16px;
}

.rename-input {
  width: 100%;
  height: 42px;
  border: 1px solid #DCDFE6;
  border-radius: 8px;
  padding: 0 12px;
  font-size: 14px;
}

.modal-btns {
  display: flex;
  border-top: 1px solid #F2F6FC;
}

.modal-btn {
  flex: 1;
  height: 48px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.btn-text {
  font-size: 15px;
  color: #606266;
}

.cancel {
  border-right: 1px solid #F2F6FC;
}

.btn-confirm-text {
  color: #409EFF;
  font-weight: 500;
}
</style>
