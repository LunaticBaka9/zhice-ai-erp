<script setup name="Login" lang="ts">
import { reactive, ref } from "vue";
import request from "../utils/request";
import { ElMessage } from "element-plus";
import { Check } from "@element-plus/icons-vue";

const formRef = ref();
const emailFormRef = ref();
const rememberMe = ref(false);
const loading = ref(false);
const activeTab = ref("account");
const codeLoading = ref(false);
const codeDisabled = ref(false);
const codeCountdown = ref(0);

const data = reactive({
    form: {
        username: "",
        password: "",
    },
    rules: {
        username: [
            { required: true, message: "请填写账号", trigger: "blur" },
            { min: 3, message: "至少输入3位", trigger: "blur" },
        ],
        password: [{ required: true, message: "请填写密码", trigger: "blur" }],
    },
});

const emailData = reactive({
    form: {
        email: "",
        code: "",
    },
    rules: {
        email: [
            { required: true, message: "请填写邮箱", trigger: "blur" },
            { type: "email", message: "请输入正确的邮箱格式", trigger: "blur" },
        ],
        code: [
            { required: true, message: "请填写验证码", trigger: "blur" },
            { len: 6, message: "验证码为6位", trigger: "blur" },
        ],
    },
});

const handleLoginSuccess = (res: any) => {
    if (res.code === "200") {
        const userData = res.data?.user || res.data || {};
        const token = res.data?.token || "";
        localStorage.setItem("local_user", JSON.stringify(userData));
        if (token) {
            localStorage.setItem("token", token);
        }
        ElMessage.success("登录成功");
        location.href = "/";
    } else {
        ElMessage.error(res.msg);
    }
};

const login = () => {
    formRef.value.validate((valid: any) => {
        if (valid) {
            loading.value = true;
            request
                .post("/login", data.form)
                .then((res: any) => {
                    handleLoginSuccess(res);
                })
                .finally(() => {
                    loading.value = false;
                });
        }
    });
};

const sendCode = () => {
    emailFormRef.value.validateField("email", (valid: any) => {
        if (valid) {
            codeLoading.value = true;
            request
                .post("/sendEmailCode", { email: emailData.form.email })
                .then((res: any) => {
                    if (res.code === "200") {
                        ElMessage.success("验证码已发送");
                        startCountdown();
                    } else {
                        ElMessage.error(res.msg || "验证码发送失败");
                    }
                })
                .finally(() => {
                    codeLoading.value = false;
                });
        }
    });
};

const startCountdown = () => {
    codeDisabled.value = true;
    codeCountdown.value = 60;
    const timer = setInterval(() => {
        codeCountdown.value--;
        if (codeCountdown.value <= 0) {
            clearInterval(timer);
            codeDisabled.value = false;
        }
    }, 1000);
};

const emailLogin = () => {
    emailFormRef.value.validate((valid: any) => {
        if (valid) {
            loading.value = true;
            request
                .post("/emailLogin", emailData.form)
                .then((res: any) => {
                    handleLoginSuccess(res);
                })
                .finally(() => {
                    loading.value = false;
                });
        }
    });
};
</script>

<template>
    <div class="login-container">
        <div class="login-background">
            <div class="login-left-panel">
                <div class="brand-section">
                    <h1 class="brand-title">进销存管理系统</h1>
                    <p class="brand-subtitle">高效 · 智能 · 安全</p>
                    <div class="feature-list">
                        <div class="feature-item">
                            <el-icon><Check /></el-icon>
                            <span>实时库存监控</span>
                        </div>
                        <div class="feature-item">
                            <el-icon><Check /></el-icon>
                            <span>智能预警系统</span>
                        </div>
                        <div class="feature-item">
                            <el-icon><Check /></el-icon>
                            <span>多维度数据分析</span>
                        </div>
                        <div class="feature-item">
                            <el-icon><Check /></el-icon>
                            <span>移动端支持</span>
                        </div>
                    </div>
                </div>
            </div>
            <div class="login-right-panel">
                <div class="login-card">
                    <div class="login-header">
                        <h2>欢迎回来</h2>
                        <p>请登录您的账户</p>
                    </div>
                    <el-tabs v-model="activeTab" class="login-tabs">
                        <el-tab-pane label="账号登录" name="account">
                            <el-form ref="formRef" :model="data.form" :rules="data.rules" class="login-form">
                                <el-form-item prop="username">
                                    <el-input
                                        v-model="data.form.username"
                                        autocomplete="off"
                                        prefix-icon="User"
                                        size="default"
                                        placeholder="请输入账号"
                                        class="login-input"
                                    />
                                </el-form-item>
                                <el-form-item prop="password">
                                    <el-input
                                        v-model="data.form.password"
                                        type="password"
                                        autocomplete="off"
                                        prefix-icon="Lock"
                                        size="default"
                                        placeholder="请输入密码"
                                        class="login-input"
                                        show-password
                                    />
                                </el-form-item>
                                <div class="login-options">
                                    <el-checkbox v-model="rememberMe">记住我</el-checkbox>
                                    <a href="#" class="forgot-password">忘记密码？</a>
                                </div>
                                <el-button size="large" type="primary" class="login-button" @click="login" :loading="loading">
                                    登 录
                                </el-button>
                            </el-form>
                        </el-tab-pane>
                        <el-tab-pane label="邮箱登录" name="email">
                            <el-form ref="emailFormRef" :model="emailData.form" :rules="emailData.rules" class="login-form">
                                <el-form-item prop="email">
                                    <el-input
                                        v-model="emailData.form.email"
                                        autocomplete="off"
                                        prefix-icon="Message"
                                        size="default"
                                        placeholder="请输入邮箱"
                                        class="login-input"
                                    />
                                </el-form-item>
                                <el-form-item prop="code">
                                    <div class="code-input-wrapper">
                                        <el-input
                                            v-model="emailData.form.code"
                                            autocomplete="off"
                                            prefix-icon="Key"
                                            size="default"
                                            placeholder="请输入验证码"
                                            maxlength="6"
                                            class="login-input code-input"
                                        />
                                        <el-button
                                            size="large"
                                            class="code-button"
                                            :loading="codeLoading"
                                            :disabled="codeDisabled"
                                            @click="sendCode"
                                        >
                                            {{ codeDisabled ? `${codeCountdown}s` : '获取验证码' }}
                                        </el-button>
                                    </div>
                                </el-form-item>
                                <div class="login-options">
                                    <el-checkbox v-model="rememberMe">记住我</el-checkbox>
                                    <a href="#" class="forgot-password">忘记密码？</a>
                                </div>
                                <el-button size="large" type="primary" class="login-button" @click="emailLogin" :loading="loading">
                                    登 录
                                </el-button>
                            </el-form>
                        </el-tab-pane>
                    </el-tabs>
                    <div class="login-divider">
                        <span>或</span>
                    </div>
                    <div class="register-link">
                        没有账号？
                        <router-link to="/register" class="register-text">立即注册</router-link>
                    </div>
                </div>
                <div class="login-footer">
                    <p>© 库存管理系统 版权所有</p>
                    <p>技术支持：11451419198</p>
                </div>
            </div>
        </div>
    </div>
</template>

<style scoped src="@/assets/css/login.css" />
