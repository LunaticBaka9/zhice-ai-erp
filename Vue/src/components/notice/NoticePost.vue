<template>
    <div class="announcement-container">
        <!-- 页面标题 -->
        <div class="page-header">
            <h2>公告发布</h2>
            <p>编辑公告和发布公告</p>
        </div>

        <!-- 公告表单 -->
        <el-card class="form-card" shadow="never">
            <el-form
                ref="formRef"
                :model="formData"
                :rules="formRules"
                label-width="100px"
                label-position="right"
            >
                <!-- 公告标题 -->
                <el-form-item label="公告标题" prop="title">
                    <el-input
                        v-model="formData.title"
                        placeholder="请输入公告标题"
                        maxlength="100"
                        show-word-limit
                        clearable
                        style="width: 90%"
                    />
                </el-form-item>

                <!-- 公告类型 -->
                <el-form-item label="公告类型" prop="type">
                    <el-radio-group v-model="formData.type">
                        <el-radio label="系统更新" value="系统更新" />
                        <el-radio label="维护通知" value="维护通知" />
                        <el-radio label="功能上线" value="功能上线" />
                        <el-radio label="其他公告" value="其他公告" />
                    </el-radio-group>
                </el-form-item>

                <!-- 公告状态 -->
                <el-form-item label="发布状态" prop="status">
                    <el-radio-group v-model="formData.status">
                        <el-radio label="已发布">立即发布</el-radio>
                        <el-radio label="定时发布">定时发布</el-radio>
                    </el-radio-group>
                </el-form-item>

                <!-- 定时发布时间（仅当状态为定时发布时显示） -->
                <el-form-item
                    v-if="formData.status === '定时发布'"
                    label="发布时间"
                    prop="publishDate"
                >
                    <el-date-picker
                        v-model="formData.publishDate"
                        type="datetime"
                        placeholder="选择发布时间"
                        :picker-options="pickerOptions"
                    />
                </el-form-item>

                <!-- 公告摘要 -->
                <el-form-item label="公告摘要" prop="summary">
                    <el-input
                        v-model="formData.summary"
                        type="textarea"
                        :rows="3"
                        placeholder="请输入公告摘要（选填）"
                        maxlength="200"
                        show-word-limit
                        style="width: 90%"
                    />
                </el-form-item>

                <!-- wangEditor 富文本编辑器 -->
                <el-form-item label="公告内容" prop="content" required>
                    <div class="editor-wrapper">
                        <div style="border: 1px solid #ccc; z-index: 100">
                            <!-- 工具栏 -->
                            <Toolbar
                                :editor="editor"
                                :defaultConfig="toolbarConfig"
                                mode="default"
                                style="border-bottom: 1px solid #ccc"
                            />
                            <!-- 编辑器 -->
                            <Editor
                                :defaultConfig="editorConfig"
                                v-model="formData.content"
                                style="height: 400px; overflow-y: hidden"
                                @onCreated="handleEditorCreated"
                                @onChange="handleEditorChange"
                            />
                        </div>
                    </div>
                </el-form-item>

                <!-- 附件上传 -->
                <el-form-item label="附件">
                    <el-upload
                        class="upload-demo"
                        action="/api/upload"
                        :on-success="handleUploadSuccess"
                        :on-remove="handleUploadRemove"
                        :file-list="fileList"
                        :limit="5"
                        :on-exceed="handleExceed"
                        multiple
                    >
                        <el-button type="primary">上传附件</el-button>
                        <template #tip>
                            <div class="el-upload__tip">
                                支持上传图片、文档、压缩包等，单个文件不超过
                                10MB
                            </div>
                        </template>
                    </el-upload>
                </el-form-item>

                <!-- 操作按钮 -->
                <el-form-item>
                    <el-button @click="handleCancel">取消</el-button>
                    <el-button
                        type="primary"
                        @click="handleSubmit"
                        :loading="submitting"
                        >发布公告</el-button
                    >
                    <el-button @click="handleSaveDraft">保存草稿</el-button>
                </el-form-item>
            </el-form>
        </el-card>

        <!-- 预览对话框 -->
        <el-dialog
            v-model="previewVisible"
            :title="formData.title"
            width="1200px"
            class="detail-dialog"
            :before-close="handleClosePreview"
        >
            <div class="detail-content">
                <div class="detail-meta">
                    <el-tag :type="getTagType(formData.type)" size="small">
                        {{ formData.type }}
                    </el-tag>
                    <span class="date">
                        {{ formatDateTime(formData.publishDate) || "待发布" }}
                    </span>
                    <span class="author">发布人：{{ formData.author }}</span>
                </div>
                <div class="detail-body" v-html="formData.content"></div>
            </div>
            <template #footer>
                <el-button @click="previewVisible = false">关闭</el-button>
                <el-button type="primary" @click="handleConfirmPublish">
                    确认发布
                </el-button>
            </template>
        </el-dialog>
    </div>
</template>

<script setup>
import { ref, reactive, onBeforeUnmount, onMounted, computed } from "vue";
import { formatDateTime } from "../../utils/date.js";
import { useRouter, useRoute } from "vue-router";
import { ElMessage, ElMessageBox } from "element-plus";
import { Editor, Toolbar } from "@wangeditor/editor-for-vue";
import "@wangeditor/editor/dist/css/style.css";
import request from "../../utils/request.js";

// 路由
const router = useRouter();
const route = useRoute();

const user = JSON.parse(localStorage.getItem("local_user"));
// 表单数据
const formData = reactive({
    nid: null,
    uid: user.uid,
    title: "",
    type: "",
    author: user.name,
    status: "已发布",
    publishDate: "",
    summary: "",
    content: "",
    attachments: [],
});
console.log(formData);
// 附件列表
const fileList = ref([]);

// 表单校验规则
const formRules = {
    title: [
        { required: true, message: "请输入公告标题", trigger: "blur" },
        {
            min: 2,
            max: 100,
            message: "长度在 2 到 100 个字符",
            trigger: "blur",
        },
    ],
    type: [{ required: true, message: "请选择公告类型", trigger: "change" }],
    content: [
        { required: true, message: "请输入公告内容", trigger: "blur" },
        {
            validator: (rule, value, callback) => {
                if (!value || value === "<p><br></p>" || value === "") {
                    callback(new Error("请输入公告内容"));
                } else {
                    callback();
                }
            },
            trigger: "blur",
        },
    ],
    publishDate: [
        { required: true, message: "请选择发布时间", trigger: "change" },
    ],
};

// 编辑器实例
const editor = ref(null);
const formRef = ref(null);
const submitting = ref(false);
const previewVisible = ref(false);
// 是否为编辑模式
const isEditor = ref(false);

// 时间选择器配置
const pickerOptions = {
    disabledDate(time) {
        // 不能选择过去的时间
        return time.getTime() < Date.now() - 8.64e7;
    },
};

// 工具栏配置
const toolbarConfig = {
    excludeKeys: [
        "group-video", // 排除视频
        "fullScreen", // 排除全屏（可选）
    ],
};

// 编辑器配置
const editorConfig = {
    placeholder: "请输入公告内容...",
    // 菜单配置
    MENU_CONF: {
        // 上传图片配置
        uploadImage: {
            server: "/api/upload/image",
            fieldName: "file",
            maxFileSize: 5 * 1024 * 1024, // 5MB
            maxNumberOfFiles: 10,
            allowedFileTypes: ["image/*"],
            onSuccess(file, res) {
                // 上传成功回调
                console.log("图片上传成功", res);
            },
            onFailed(file, res) {
                ElMessage.error("图片上传失败");
            },
            onError(file, err, res) {
                ElMessage.error("图片上传出错");
            },
        },
        // 上传视频配置
        uploadVideo: {
            server: "/api/upload/video",
            fieldName: "file",
            maxFileSize: 20 * 1024 * 1024, // 20MB
            allowedFileTypes: ["video/*"],
        },
    },
};

// 编辑器创建成功回调
const handleEditorCreated = (instance) => {
    editor.value = instance;
    console.log("编辑器创建成功", instance);
    // 如果是从管理页编辑过来，编辑器创建后需要将 HTML 内容显式设置到编辑器实例
    if (isEditor.value && formData.content) {
        const html =
            typeof formData.content === "string"
                ? formData.content
                : String(formData.content);
        try {
            // 尝试常见的 API：setHtml
            if (typeof instance.setHtml === "function") {
                instance.setHtml(html);
                return;
            }
        } catch (e) {
            console.warn("注入编辑器内容失败", e);
            formData.content = html;
        }
    }
};

// 编辑器内容变化回调
const handleEditorChange = (editor) => {
    // 可以在这里做实时保存等操作
    console.log("内容已变化");
};

// 提交表单
const handleSubmit = async () => {
    try {
        // 表单验证
        await formRef.value.validate();

        // 内容验证
        if (!formData.content || formData.content === "<p><br></p>") {
            ElMessage.warning("请输入公告内容");
            return;
        }

        // 定时发布需要验证发布时间
        if (formData.status === "定时发布" && !formData.publishDate) {
            ElMessage.warning("请选择发布时间");
            return;
        }

        // 预览确认
        previewVisible.value = true;
    } catch (error) {
        console.error("表单验证失败", error);
    }
};

// 确认发布
const handleConfirmPublish = async () => {
    previewVisible.value = false;
    submitting.value = true;
    if(!formData.status === "定时发布"){
      formData.publishDate = Date.now();
    }
    try {
        // 准备提交数据
        const submitData = {
            ...formData,
            attachments: fileList.value.map((file) => ({
                name: file.name,
                url: file.url,
                size: file.size,
            })),
        };

        if (isEditor.value) {
            request.post("/notice/update", submitData).then((res) => {
                if (res.code === "200") {
                    ElMessage.success("公告修改成功");
                } else {
                    ElMessage.error("修改失败");
                }
            });
        } else {
            request.post("/notice/postNotice", submitData).then((res) => {
                if (res.code === "200") {
                    ElMessage.success("公告发布成功");
                } else {
                    ElMessage.error("发布失败");
                }
            });
        }

        // 延迟跳转
        setTimeout(() => {
            router.push("/notice/index");
        }, 1500);
    } catch (error) {
        ElMessage.error("发布失败");
        console.error("提交失败", error);
    } finally {
        submitting.value = false;
    }
};

// 保存草稿
const handleSaveDraft = async () => {
    try {
        const draftData = {
            ...formData,
            status: "草稿", // 草稿状态
            attachments: fileList.value.map((file) => ({
                name: file.name,
                url: file.url,
                size: file.size,
            })),
        };
        formData.publishDate = Date.now();
        if (isEditor.value) {
            request.post("/notice/update", draftData).then((res) => {
                if (res.code === "200") {
                    ElMessage.success("草稿修改成功");
                } else {
                    ElMessage.error("保存草稿失败");
                }
            });
        } else {
            request.post("/notice/saveDraft", draftData).then((res) => {
                if (res.code === "200") {
                    ElMessage.success("草稿保存成功");
                } else {
                    ElMessage.error("保存草稿失败");
                }
            });
        }

        // 延迟跳转
        setTimeout(() => {
            router.push("/notice/index");
        }, 1500);
    } catch (error) {
        ElMessage.error("保存草稿失败");
    }
};

// 取消操作
const handleCancel = () => {
    ElMessageBox.confirm("确认离开吗？未保存的内容将会丢失", "提示", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning",
    })
        .then(() => {
            router.back();
        })
        .catch(() => {});
};

// 上传成功回调
const handleUploadSuccess = (response, file) => {
    file.url = response.data.url;
    ElMessage.success(`文件 ${file.name} 上传成功`);
};

// 移除附件
const handleUploadRemove = (file, fileList) => {
    console.log("移除附件", file);
};

// 超出文件数量限制
const handleExceed = (files, fileList) => {
    ElMessage.warning("最多只能上传 5 个附件");
};

// 关闭预览
const handleClosePreview = () => {
    previewVisible.value = false;
};

// 组件卸载前销毁编辑器
onBeforeUnmount(() => {
    if (editor.value) {
        editor.value.destroy();
    }
});

// 获取类型标签
const getTagType = (type) => {
    const typeMap = {
        系统更新: "primary",
        维护通知: "warning",
        功能上线: "success",
        其他公告: "info",
    };
    return typeMap[type] || "info";
};

// 初始化
onMounted(() => {
    try {
        const editRaw = sessionStorage.getItem("editNotice");
        if (editRaw) {
            const obj = JSON.parse(editRaw);
            isEditor.value = true;
            formData.nid = obj.nid || obj.id || formData.nid;
            formData.title = obj.title || formData.title;
            formData.type = obj.type || formData.type;
            formData.author = obj.author || formData.author;
            // 支持后端有字符串或时间戳
            if (obj.publishDate) {
                const d = new Date(obj.publishDate);
                formData.publishDate = isNaN(d.getTime()) ? obj.publishDate : d;
            }
            formData.summary = obj.summary || formData.summary;
            formData.content = obj.content || formData.content;
            if (obj.attachments) {
                fileList.value = obj.attachments;
            }
            sessionStorage.removeItem("editNotice");
        }
    } catch (e) {
        console.warn("读取编辑数据失败", e);
    }
});
</script>

<style scoped lang="scss">
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

.notice-editor-container {
    padding: 20px;
    background-color: #f5f7fa;
    min-height: 100vh;

    .form-card {
        max-width: 1200px;
        margin: 0 auto;

        :deep(.el-card__body) {
            padding: 30px;
        }
    }

    .editor-wrapper {
        width: 100%;

        // 编辑器样式调整
        :deep(.w-e-toolbar) {
            border-radius: 4px 4px 0 0;
        }

        :deep(.w-e-text-container) {
            border-radius: 0 0 4px 4px;

            &:hover {
                border-color: #c0c4cc;
            }
        }

        :deep(.w-e-text-placeholder) {
            top: 10px;
            left: 10px;
        }
    }

    .preview-content {
        max-height: 500px;
        overflow-y: auto;

        .preview-title {
            text-align: center;
            margin-bottom: 20px;
            color: #303133;
        }

        .preview-meta {
            text-align: center;
            color: #909399;
            font-size: 14px;
            margin-bottom: 20px;
            padding-bottom: 20px;
            border-bottom: 1px solid #ebeef5;

            span {
                margin: 0 10px;
            }
        }

        .preview-summary {
            background-color: #f5f7fa;
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
            color: #606266;
        }

        .preview-body {
            line-height: 1.8;
            color: #2c3e50;

            :deep(img) {
                max-width: 100%;
            }
        }
    }

    // 响应式布局
    @media (max-width: 768px) {
        padding: 10px;

        .form-card :deep(.el-card__body) {
            padding: 20px;
        }

        :deep(.el-form-item__label) {
            width: 80px !important;
        }
    }
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

.detail-body :deep(p) {
    margin: 0 0 12px 0;
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
</style>
