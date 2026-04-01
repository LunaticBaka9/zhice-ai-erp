<template>
    <div class="dashboard">
        <el-row :gutter="20">
            <el-col :span="8" style="margin: 20px">
                <el-card>
                    <div class="clock-card">
                        <div class="date">{{ currentDate }}</div>
                        <div class="time">{{ currentTime }}</div>
                        <div style="margin-top: 12px">
                            <el-button
                                type="primary"
                                @click="serverSign"
                                :loading="signing"
                                >打卡</el-button
                            >
                            <el-button
                                type="warning"
                                @click="serverSignOut"
                                :loading="signing"
                                style="margin-left: 8px"
                                >签退</el-button
                            >
                            <el-button
                                plain
                                @click="fetchRecords"
                                style="margin-left: 8px"
                                >刷新记录</el-button
                            >
                        </div>
                        <div class="last">最近打卡：{{ lastSignTime }}</div>
                    </div>
                </el-card>
            </el-col>
        </el-row>
    </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import request from "../utils/request";
import { ElMessage } from "element-plus";
import { formatDateTime, formatTime as fmtTime } from "../utils/date";
const currentDate = ref("");
const currentTime = ref("");
const lastSignTime = ref("");
const records = ref([]);
const total = ref(0);
const signing = ref(false);

function updateClock() {
    const now = new Date();
    currentDate.value = now.toLocaleDateString();
    currentTime.value = now.toLocaleTimeString();
}
setInterval(updateClock, 1000);
updateClock();

onMounted(() => {
    fetchLastSignTime();
});

function formatTime(v) {
    return fmtTime(v);
}

function getLocalUserName() {
    try {
        const s = localStorage.getItem("local_user");
        if (!s) return "我";
        const u = JSON.parse(s);
        return u.username || u.name || u.nick || "我";
    } catch (e) {
        return "我";
    }
}

function getLocalUserId() {
    try {
        const s = localStorage.getItem("local_user");
        if (!s) return null;
        const u = JSON.parse(s);
        return u.uid || u.id || null;
    } catch (e) {
        return null;
    }
}

function localSign() {
    signing.value = true;
    setTimeout(() => {
        const now = new Date();
        const rec = {
            sid: `local-${now.getTime()}`,
            username: getLocalUserName(),
            signInStatus: "本地",
            signOutStatus: "",
            signInTime: now.toLocaleTimeString(),
            source: "本地",
            remark: "本地临时打卡",
        };
        records.value = [rec, ...records.value];
        total.value = (total.value || 0) + 1;
        lastSignTime.value = rec.signInTime;
        signing.value = false;
        ElMessage.success("打卡成功（本地）");
    }, 500);
}

async function serverSign() {
    signing.value = true;
    const uid = getLocalUserId();
    if (!uid) {
        ElMessage.warning("未检测到登录用户，请先登录");
        signing.value = false;
        return;
    }
    try {
        const payload = { uid };
        const res = await request.post("/sign/add", payload);
        if (res && res.code === "200") {
            const r = res.data || {};
            const rec = {
                sid: r.sid ?? r.id ?? "",
                username: getLocalUserName(),
                signInStatus: r.signInStatus ?? "准时",
                signOutStatus: r.signOutStatus ?? "",
                signInTime: formatDateTime(r.signInTime || r.createTime),
                signOutTime: formatDateTime(r.signOutTime || r.createTime),
                source: "服务端",
                remark: r.remark ?? "正常",
            };
            records.value = [rec, ...records.value];
            total.value = (total.value || 0) + 1;
            lastSignTime.value = rec.signInTime;
            fetchLastSignTime();
            ElMessage.success("打卡成功");
        } else {
            ElMessage.error((res && res.msg) || "后端打卡失败");
        }
    } catch (err) {
        console.error(err);
        ElMessage.error("后端请求失败，已回退到本地打卡");
        localSign();
    } finally {
        signing.value = false;
    }
}

async function serverSignOut() {
    signing.value = true;
    const uid = getLocalUserId();
    if (!uid) {
        ElMessage.warning("未检测到登录用户，请先登录");
        signing.value = false;
        return;
    }
    try {
        const payload = { uid };
        const res = await request.post("/sign/signOut", payload);
        if (res && res.code === "200") {
            ElMessage.success("签退成功");
            fetchLastSignTime();
        } else {
            ElMessage.error((res && res.msg) || "后端签退失败");
        }
    } catch (err) {
        console.error(err);
        ElMessage.error("后端签退请求失败");
    } finally {
        signing.value = false;
    }
}

async function fetchLastSignTime() {
    const uid = getLocalUserId();
    if (!uid) return;
    try {
        const res = await request.get("/sign/latest", { params: { uid } });
        if (res && (res.code === "200" || res.code === 200)) {
            const d = res.data || null;
            if (d) {
                lastSignTime.value = formatDateTime(d.signInTime || d.createTime);
            }
        }
    } catch (e) {
        console.error("fetchLastSignTime error", e);
    }
}

</script>

<style scoped>
.clock-card {
    text-align: center;
    padding: 12px 0;
}
.clock-card .date {
    font-size: 18px;
    color: #666;
}
.clock-card .time {
    font-size: 28px;
    margin-top: 6px;
}
.clock-card .last {
    margin-top: 12px;
    color: #999;
}
</style>
