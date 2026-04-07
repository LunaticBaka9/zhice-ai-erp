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
                        ref="uploadRef"
                        class="upload-demo"
                        :action="uploadAction"
                        :headers="uploadHeaders"
                        :on-success="handleUploadSuccess"
                        :on-error="handleUploadError"
                        :on-remove="handleUploadRemove"
                        :on-change="handleFileChange"
                        :before-upload="beforeUpload"
                        v-model:file-list="fileList"
                        :limit="5"
                        :on-exceed="handleExceed"
                        multiple
                        :auto-upload="true"
                    >
                        <el-button type="primary">上传附件</el-button>
                        <template #tip>
                            <div class="el-upload__tip">
                                支持上传图片、文档、压缩包等，单个文件不超过
                                10MB，最多5个文件
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
                <!-- 附件预览 -->
                <div v-if="fileList.length > 0" class="attachment-section">
                    <h4>附件列表</h4>
                    <div class="attachment-list">
                        <div
                            v-for="(file, index) in fileList"
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
                                下载
                            </el-button>
                        </div>
                    </div>
                </div>
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
import {
    ref,
    reactive,
    onBeforeUnmount,
    onMounted,
    computed,
    watch,
} from "vue";
import { formatDateTime } from "../../utils/date.js";
import { useRouter, useRoute, onBeforeRouteLeave } from "vue-router";
import { ElMessage, ElMessageBox } from "element-plus";
import { Document, Download } from "@element-plus/icons-vue";
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

// 附件列表
const fileList = ref([]);
const uploadRef = ref(null);

// 表单更改检测
const isFormDirty = ref(false);
const originalFormData = ref(null);

// 上传配置
const uploadAction = computed(() => {
    // el-upload 的 action 需要完整的 URL
    // 由于使用了代理，直接使用相对路径即可
    return "/api/file/upload";
});

const uploadHeaders = computed(() => {
    // 文件上传使用 multipart/form-data，不要设置 Content-Type
    // 浏览器会自动设置正确的 Content-Type 和 boundary
    const headers = {};
    // 如果需要认证 token，可以在这里添加
    const token = localStorage.getItem("token");
    if (token) {
        headers["Authorization"] = `Bearer ${token}`;
    }
    return headers;
});

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
            server: "/file/upload",
            fieldName: "file",
            maxFileSize: 5 * 1024 * 1024, // 5MB
            maxNumberOfFiles: 10,
            allowedFileTypes: ["image/*"],
            onSuccess(file, res) {
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
            server: "/file/upload",
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

    // 添加工具栏菜单收起功能
    setTimeout(() => {
        // 获取工具栏元素
        const toolbarElement = document.querySelector(".w-e-toolbar");
        const editorElement = document.querySelector(".w-e-text-container");

        if (toolbarElement) {
            // 点击工具栏空白处收起菜单
            toolbarElement.addEventListener("click", (e) => {
                // 检查是否点击的是工具栏本身而不是按钮
                if (
                    e.target === toolbarElement ||
                    e.target.classList.contains("w-e-bar-item")
                ) {
                    closeAllMenus();
                }
            });
        }

        if (editorElement) {
            // 点击编辑器区域收起菜单
            editorElement.addEventListener("click", () => {
                closeAllMenus();
            });
        }

        // 按 ESC 键收起菜单
        const handleEscKey = (e) => {
            if (e.key === "Escape" || e.keyCode === 27) {
                closeAllMenus();
            }
        };
        document.addEventListener("keydown", handleEscKey);

        // 保存清理函数引用
        instance._cleanupEscHandler = () => {
            document.removeEventListener("keydown", handleEscKey);
        };
    }, 500);

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

// 关闭所有打开的菜单
const closeAllMenus = () => {
    // 查找所有打开的菜单面板
    const menus = document.querySelectorAll(
        ".w-e-bar-item .w-e-drop-panel, .w-e-drop-panel",
    );
    menus.forEach((menu) => {
        if (menu.style.display !== "none") {
            menu.style.display = "none";
        }
    });

    // 移除菜单的激活状态
    const activeButtons = document.querySelectorAll(
        ".w-e-bar-item button.w-e-active",
    );
    activeButtons.forEach((btn) => {
        btn.classList.remove("w-e-active");
    });
};

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
    if (!formData.status === "定时发布") {
        formData.publishDate = Date.now();
    }
    try {
        // 准备提交数据
        // 打印 fileList 用于调试
        console.log("当前 fileList:", JSON.stringify(fileList.value));

        // 过滤掉没有 url 的文件（只要有 url 就认为是上传成功的）
        const validFiles = fileList.value.filter((f) => f.url);
        console.log("有效附件:", JSON.stringify(validFiles));

        const submitData = {
            ...formData,
            attachments: JSON.stringify(
                validFiles.map((file) => ({
                    name: file.name,
                    url: file.url,
                    size: file.size,
                })),
            ),
        };
        console.log("提交数据:", submitData);

        if (isEditor.value) {
            request.post("/notice/update", submitData).then((res) => {
                if (res.code === "200") {
                    ElMessage.success("公告修改成功");
                    isFormDirty.value = false; // 重置脏状态
                } else {
                    ElMessage.error("修改失败");
                }
            });
        } else {
            request.post("/notice/postNotice", submitData).then((res) => {
                if (res.code === "200") {
                    ElMessage.success("公告发布成功");
                    isFormDirty.value = false; // 重置脏状态
                } else {
                    ElMessage.error("发布失败");
                }
            });
        }

        // 延迟跳转
        setTimeout(() => {
            isFormDirty.value = false; // 跳转前重置脏状态
            router.push("/notice/index");
        }, 1000);
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
        // 过滤掉没有 url 的文件
        const validFiles = fileList.value.filter(
            (f) => f.url && f.status === "success",
        );
        const draftData = {
            ...formData,
            status: "草稿", // 草稿状态
            attachments: JSON.stringify(
                validFiles.map((file) => ({
                    name: file.name,
                    url: file.url,
                    size: file.size,
                })),
            ),
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
            isFormDirty.value = false; // 跳转前重置脏状态
            router.push("/notice/index");
        }, 1000);
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
            isFormDirty.value = false; // 重置脏状态
            router.back();
        })
        .catch(() => {});
};

// 上传前校验
const beforeUpload = (file) => {
    const maxSize = 10 * 1024 * 1024; // 10MB
    if (file.size > maxSize) {
        ElMessage.error(`文件 ${file.name} 超过 10MB 限制`);
        return false;
    }
    return true;
};

// 上传成功回调
const handleUploadSuccess = (response, file) => {
    try {
        let url = "";
        let name = file.name;
        let size = file.size;

        if (response && response.code === "200" && response.data) {
            // 后端返回格式：{ code: "200", msg: "", data: { url, name, size, type } }
            if (typeof response.data === "object") {
                url = response.data.url || "";
                name = response.data.name || file.name;
                size = response.data.size || file.size;
            } else if (typeof response.data === "string") {
                url = response.data;
            }
        }

        if (url) {
            // 更新 fileList 中的对应项
            const index = fileList.value.findIndex((f) => f.uid === file.uid);
            if (index !== -1) {
                fileList.value[index].url = url;
                fileList.value[index].name = name;
                fileList.value[index].size = size;
                fileList.value[index].status = "success";
            } else {
                // 如果没找到，直接添加到 fileList
                fileList.value.push({
                    uid: file.uid,
                    name: name,
                    size: size,
                    url: url,
                    status: "success",
                });
            }

            console.log("更新后的 fileList:", JSON.stringify(fileList.value));
            ElMessage.success(`文件 ${name} 上传成功`);
        } else {
            ElMessage.error("上传失败，未返回文件路径");
            // 从列表中移除上传失败的文件
            const index = fileList.value.findIndex((f) => f.uid === file.uid);
            if (index !== -1) {
                fileList.value.splice(index, 1);
            }
        }
    } catch (e) {
        console.error("处理上传返回值失败", e, response);
        ElMessage.error("处理上传结果失败");
    }
};

// 上传失败回调
const handleUploadError = (error, file) => {
    console.error("文件上传失败", error);
    ElMessage.error(`文件 ${file.name} 上传失败`);
    // 从列表中移除上传失败的文件
    const index = fileList.value.findIndex((f) => f.uid === file.uid);
    if (index !== -1) {
        fileList.value.splice(index, 1);
    }
};

// 文件变化回调（文件添加或移除时触发）
const handleFileChange = (file, uploadedFileList) => {
    console.log("文件变化:", file.name, "状态:", file.status);
    // fileList 已通过 v-model:file-list 自动更新
};

// 移除附件
const handleUploadRemove = (file, uploadedFileList) => {
    console.log("移除附件", file);
    // 从 fileList 中移除
    const index = fileList.value.findIndex(
        (f) => f.uid === file.uid || f.name === file.name,
    );
    if (index !== -1) {
        fileList.value.splice(index, 1);
    }
};

// 超出文件数量限制
const handleExceed = (files, uploadedFileList) => {
    ElMessage.warning("最多只能上传 5 个附件");
};

// 下载文件
const handleDownloadFile = (file) => {
    if (!file.url) {
        ElMessage.warning("文件路径不存在");
        return;
    }
    // 后端返回的路径已经包含 /api 前缀
    // 如果路径不以 http 开头，直接使用相对路径
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

// 关闭预览
const handleClosePreview = () => {
    previewVisible.value = false;
};

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

// 保存初始表单状态
const saveOriginalState = () => {
    originalFormData.value = {
        title: formData.title,
        type: formData.type,
        summary: formData.summary,
        content: formData.content,
        status: formData.status,
        publishDate: formData.publishDate,
        attachments: JSON.stringify(fileList.value),
    };
};

// 检查表单是否有更改（与初始状态比较）
const checkFormDirty = () => {
    if (!originalFormData.value) {
        isFormDirty.value = false;
        return;
    }

    const currentState = {
        title: formData.title,
        type: formData.type,
        summary: formData.summary,
        content: formData.content,
        status: formData.status,
        publishDate: formData.publishDate,
        attachments: JSON.stringify(fileList.value),
    };

    // 比较每个字段
    isFormDirty.value =
        currentState.title !== originalFormData.value.title ||
        currentState.type !== originalFormData.value.type ||
        currentState.summary !== originalFormData.value.summary ||
        currentState.content !== originalFormData.value.content ||
        currentState.status !== originalFormData.value.status ||
        currentState.publishDate !== originalFormData.value.publishDate ||
        currentState.attachments !== originalFormData.value.attachments;
};

// 监听表单数据变化
watch(
    () => [
        formData.title,
        formData.type,
        formData.summary,
        formData.content,
        formData.status,
        formData.publishDate,
        fileList.value,
    ],
    () => {
        checkFormDirty();
    },
    { deep: true },
);

// 浏览器刷新/关闭前的提示（使用组合式 API 封装）
const useBeforeUnload = (isDirty) => {
    const handleBeforeUnload = (e) => {
        if (isDirty.value) {
            e.preventDefault();
            e.returnValue = "页面内容将不会保存，确定要离开吗？";
            return "页面内容将不会保存，确定要离开吗？";
        }
    };

    onMounted(() => {
        window.addEventListener("beforeunload", handleBeforeUnload);
    });

    onBeforeUnmount(() => {
        window.removeEventListener("beforeunload", handleBeforeUnload);
    });
};

// 注册浏览器刷新/关闭监听
useBeforeUnload(isFormDirty);

// 路由离开前的提示（Vue Router 导航守卫）
onBeforeRouteLeave((to, from) => {
    if (isFormDirty.value) {
        return ElMessageBox.confirm(
            "页面内容将不会保存，确定要离开吗？",
            "提示",
            {
                confirmButtonText: "确定",
                cancelButtonText: "取消",
                type: "warning",
            },
        )
            .then(() => true)
            .catch(() => false);
    }
    return true;
});

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
                try {
                    fileList.value =
                        typeof obj.attachments === "string"
                            ? JSON.parse(obj.attachments)
                            : obj.attachments;
                } catch (e) {
                    fileList.value = obj.attachments || [];
                }
            }
            sessionStorage.removeItem("editNotice");
        }
    } catch (e) {
        console.warn("读取编辑数据失败", e);
    }

    // 保存初始表单状态（用于后续脏检测比较）
    // 使用 nextTick 确保数据已完全加载
    setTimeout(() => {
        saveOriginalState();
    }, 100);
});

// 组件卸载前
onBeforeUnmount(() => {
    // 销毁编辑器
    if (editor.value) {
        // 清理 ESC 键监听器
        if (editor.value._cleanupEscHandler) {
            editor.value._cleanupEscHandler();
        }
        editor.value.destroy();
    }
});
</script>

<style scoped lang="scss">
.announcement-container {
    padding: 24px 20px;
    background-color: #f5f7fa;
    min-height: calc(100vh - 60px);
}

// 附件列表样式
.file-list {
    margin-top: 10px;
    border: 1px solid #ebeef5;
    border-radius: 4px;
    padding: 10px;
    background-color: #fafafa;
}

.file-item {
    display: flex;
    align-items: center;
    padding: 8px 0;
    border-bottom: 1px solid #ebeef5;

    &:last-child {
        border-bottom: none;
    }
}

.file-icon {
    color: #909399;
    margin-right: 8px;
}

.file-name {
    flex: 1;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    color: #606266;
}

.file-size {
    color: #909399;
    font-size: 12px;
    margin: 0 10px;
}

// 预览对话框中的附件样式
.attachment-section {
    margin-top: 20px;
    padding-top: 15px;
    border-top: 1px solid #ebeef5;

    h4 {
        margin: 0 0 10px 0;
        color: #303133;
        font-size: 14px;
    }
}

.attachment-list {
    display: flex;
    flex-direction: column;
    gap: 8px;
}

.attachment-item {
    display: flex;
    align-items: center;
    padding: 8px 12px;
    background-color: #f5f7fa;
    border-radius: 4px;
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
