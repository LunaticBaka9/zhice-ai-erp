<template>
    <div class="meeting-create">
        <div class="page-header">
            <div class="page-header-left">
                <h2 class="page-title">发布会议</h2>
                <p class="page-subtitle">创建新的会议，并通知相关人员参与</p>
            </div>
            <el-button @click="goBack">
                <el-icon><ArrowLeft /></el-icon>
                返回列表
            </el-button>
        </div>

        <el-card class="form-card" shadow="never">
            <el-form
                ref="formRef"
                :model="formData"
                :rules="formRules"
                label-width="120px"
                label-position="right"
            >
                <!-- 基本信息 -->
                <el-divider content-position="left">
                    <el-icon><InfoFilled /></el-icon>
                    基本信息
                </el-divider>

                <el-form-item label="会议标题" prop="title">
                    <el-input
                        v-model="formData.title"
                        placeholder="请输入会议标题"
                        maxlength="50"
                        show-word-limit
                        clearable
                    />
                    <div class="form-tip">建议使用简洁明了的标题，不超过50个字符</div>
                </el-form-item>

                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="所属部门" prop="deptId">
                            <el-select
                                v-model="formData.deptId"
                                placeholder="请选择部门"
                                filterable
                                style="width: 100%"
                            >
                                <el-option
                                    v-for="dept in deptStore.deptList"
                                    :key="dept.id"
                                    :label="dept.name"
                                    :value="dept.id"
                                />
                            </el-select>
                            <div class="form-tip">选择会议所属的部门</div>
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="会议地点" prop="address">
                            <el-input
                                v-model="formData.address"
                                placeholder="请输入会议地点"
                            />
                            <div class="form-tip">格式: A栋3楼Java会议室</div>
                        </el-form-item>
                    </el-col>
                </el-row>

                <el-form-item label="抄送人员">
                    <el-select
                        v-model="formData.ccUserIds"
                        placeholder="请选择抄送人员"
                        multiple
                        filterable
                        style="width: 100%"
                    >
                        <el-option
                            v-for="user in userStore.allUsers"
                            :key="user.id"
                            :label="`${user.realName} - ${user.job} - ${user.deptName}`"
                            :value="user.id"
                        />
                    </el-select>
                    <div class="form-tip">选择需要抄送的相关人员，可多选</div>
                </el-form-item>

                <!-- 时间设置 -->
                <el-divider content-position="left">
                    <el-icon><Clock /></el-icon>
                    时间设置
                </el-divider>

                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="开始时间" prop="startTime">
                            <el-date-picker
                                v-model="formData.startTime"
                                type="datetime"
                                placeholder="选择开始时间"
                                style="width: 100%"
                                value-format="YYYY-MM-DD HH:mm:ss"
                            />
                            <div class="form-tip">会议开始的日期和时间</div>
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="结束时间" prop="endTime">
                            <el-date-picker
                                v-model="formData.endTime"
                                type="datetime"
                                placeholder="选择结束时间"
                                style="width: 100%"
                                value-format="YYYY-MM-DD HH:mm:ss"
                            />
                            <div class="form-tip">会议结束的日期和时间</div>
                        </el-form-item>
                    </el-col>
                </el-row>

                <!-- 会议内容 -->
                <el-divider content-position="left">
                    <el-icon><Document /></el-icon>
                    会议内容
                </el-divider>

                <el-form-item label="内容描述" prop="content">
                    <div class="editor-wrapper">
                        <div style="border: 1px solid #dcdfe6; border-radius: 4px; z-index: 100">
                            <Toolbar
                                :editor="editor"
                                :defaultConfig="toolbarConfig"
                                mode="default"
                                style="border-bottom: 1px solid #dcdfe6"
                            />
                            <Editor
                                :defaultConfig="editorConfig"
                                v-model="formData.content"
                                style="height: 400px; overflow-y: hidden"
                                @onCreated="handleEditorCreated"
                            />
                        </div>
                    </div>
                    <div class="form-tip">详细描述会议的主要内容和议题</div>
                </el-form-item>

                <!-- 表单操作 -->
                <el-divider />
                <el-form-item>
                    <el-button @click="resetForm">
                        <el-icon><Refresh /></el-icon>
                        重置表单
                    </el-button>
                    <el-button type="primary" @click="submitForm" :loading="submitting">
                        <el-icon><Promotion /></el-icon>
                        发布会议
                    </el-button>
                </el-form-item>
            </el-form>
        </el-card>
    </div>
</template>

<script setup>
import { ref, reactive, onMounted, onBeforeUnmount } from "vue";
import { useRouter } from "vue-router";
import { ElMessage } from "element-plus";
import { ArrowLeft, InfoFilled, Clock, Document, Refresh, Promotion } from "@element-plus/icons-vue";
import { Editor, Toolbar } from "@wangeditor/editor-for-vue";
import "@wangeditor/editor/dist/css/style.css";
import { createMeeting } from "@/api";
import { useDeptStore } from "@/store/dept"
import { useUserStore } from "@/store/user"

const deptStore = useDeptStore();
const userStore = useUserStore();

const router = useRouter();

const formRef = ref();
const submitting = ref(false);

const formData = reactive({
    title: "",
    deptId: null,
    ccUserIds: [],
    address: "",
    startTime: "",
    endTime: "",
    content: "",
});

const formRules = {
    title: [
        { required: true, message: "请输入会议标题", trigger: "blur" },
        { max: 50, message: "标题不超过50个字符", trigger: "blur" },
    ],
    deptId: [{ required: true, message: "请选择所属部门", trigger: "change" }],
    address: [{ required: true, message: "请输入会议地点", trigger: "blur" }],
    startTime: [{ required: true, message: "请选择开始时间", trigger: "change" }],
    endTime: [{ required: true, message: "请选择结束时间", trigger: "change" }],
    content: [
        { required: true, message: "请输入会议内容", trigger: "blur" },
        {
            validator: (rule, value, callback) => {
                if (!value || value === "<p><br></p>" || value === "") {
                    callback(new Error("请输入会议内容"));
                } else {
                    callback();
                }
            },
            trigger: "blur",
        },
    ],
};



const editor = ref(null);
const toolbarConfig = {
    excludeKeys: ["group-video", "fullScreen"],
};
const editorConfig = {
    placeholder: "请输入会议内容...",
    MENU_CONF: {
        uploadImage: {
            server: "/file/upload",
            fieldName: "file",
            maxFileSize: 5 * 1024 * 1024,
            maxNumberOfFiles: 10,
            allowedFileTypes: ["image/*"],
        },
    },
};

const handleEditorCreated = (instance) => {
    editor.value = instance;
};

const fetchDeptList = async () => {
    try {
        await deptStore.fetchDeptList();
    } catch {
        ElMessage.error("获取部门列表失败");
    }
};

const fetchUserList = async () => {
    try {
        await userStore.fetchAllUsers();
    } catch {
        ElMessage.error("获取用户列表失败");
    }
};

const goBack = () => {
    router.push("/meeting/index");
};

const resetForm = () => {
    formData.title = "";
    formData.deptId = null;
    formData.ccUserIds = [];
    formData.address = "";
    formData.startTime = "";
    formData.endTime = "";
    formData.content = "";
    if (editor.value) {
        editor.value.setHtml("");
    }
};

const submitForm = async () => {
    if (!formRef.value) return;

    await formRef.value.validate(async (valid) => {
        if (valid) {
            if (!formData.content || formData.content === "<p><br></p>") {
                ElMessage.warning("请输入会议内容");
                return;
            }
            submitting.value = true;
            try {
                const res = await createMeeting(formData);
                if (res.code === "200") {
                    ElMessage.success("会议发布成功");
                    router.push("/meeting/index");
                } else {
                    ElMessage.error(res.msg || "发布失败");
                }
            } catch {
                ElMessage.error("发布失败");
            } finally {
                submitting.value = false;
            }
        }
    });
};

onMounted(() => {

});

onBeforeUnmount(() => {
    if (editor.value) {
        editor.value.destroy();
    }
});
</script>

<style scoped>
.meeting-create {
    padding: 24px 20px;
    background-color: #f5f7fa;
    min-height: calc(100vh - 60px);
}

.page-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 20px;
}

.page-header-left {
    flex: 1;
}

.page-title {
    font-size: 24px;
    font-weight: 600;
    color: #303133;
    margin: 0 0 8px 0;
}

.page-subtitle {
    color: #909399;
    font-size: 14px;
    margin: 0;
}

.form-card {
    max-width: 1000px;
    margin: 0 auto;
}

.form-tip {
    color: #909399;
    font-size: 12px;
    line-height: 1.4;
    margin-top: 4px;
}

.editor-wrapper {
    width: 100%;
}

:deep(.el-divider__text) {
    font-size: 16px;
    font-weight: 500;
    color: #303133;
    display: flex;
    align-items: center;
    gap: 6px;
}

:deep(.el-form-item__label) {
    font-weight: 500;
}

@media (max-width: 768px) {
    .meeting-create {
        padding: 12px;
    }

    .page-header {
        flex-direction: column;
        gap: 12px;
    }
}
</style>
