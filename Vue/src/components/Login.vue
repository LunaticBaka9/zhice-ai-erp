<script setup name="Login" lang="ts">
import { reactive, ref } from "vue";
import request from "../utils/request";
import { ElMessage } from "element-plus";
import { Check } from "@element-plus/icons-vue";

const formRef = ref();
const rememberMe = ref(false);
const loading = ref(false);

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

const login = () => {
    formRef.value.validate((valid: any) => {
        if (valid) {
            loading.value = true;
            request
                .post("/login", data.form)
                .then((res: any) => {
                    console.log(res);
                    if (res.code === "200") {
                        // 后端返回 { user: {...}, token: "..." }
                        const userData = res.data?.user || res.data || {};
                        const token = res.data?.token || "";

                        //存储用户信息和token
                        localStorage.setItem("local_user", JSON.stringify(userData));
                        if (token) {
                            localStorage.setItem("token", token);
                        }
                        ElMessage.success("登录成功");
                        location.href = "/";
                    } else {
                        ElMessage.error(res.msg);
                    }
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
                    <el-form ref="formRef" :model="data.form" :rules="data.rules" class="login-form">
                        <el-form-item prop="username">
                            <el-input
                                v-model="data.form.username"
                                autocomplete="off"
                                prefix-icon="User"
                                size="large"
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
                                size="large"
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
                        <div class="login-divider">
                            <span>或</span>
                        </div>
                        <div class="register-link">
                            没有账号？
                            <router-link to="/register" class="register-text">立即注册</router-link>
                        </div>
                    </el-form>
                </div>
                <div class="login-footer">
                    <p>© 2024 库存管理系统 版权所有</p>
                    <p>技术支持：400-123-4567</p>
                </div>
            </div>
        </div>
    </div>
</template>

<style scoped>
.login-container {
    height: 100vh;
    width: 100vw;
    overflow: hidden;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.login-background {
    display: flex;
    height: 100%;
    width: 100%;
}

.login-left-panel {
    flex: 1;
    background: rgba(255, 255, 255, 0.1);
    backdrop-filter: blur(10px);
    padding: 60px;
    display: flex;
    flex-direction: column;
    justify-content: center;
    color: white;
}

.brand-title {
    font-size: 42px;
    font-weight: 700;
    margin-bottom: 16px;
    line-height: 1.2;
}

.brand-subtitle {
    font-size: 18px;
    opacity: 0.9;
    margin-bottom: 40px;
}

.feature-list {
    display: flex;
    flex-direction: column;
    gap: 20px;
    margin-top: 40px;
}

.feature-item {
    display: flex;
    align-items: center;
    gap: 12px;
    font-size: 16px;
}

.feature-item .el-icon {
    color: #4ade80;
    font-size: 20px;
}

.login-right-panel {
    width: 480px;
    background: white;
    display: flex;
    flex-direction: column;
    justify-content: center;
    padding: 40px;
    position: relative;
}

.login-card {
    max-width: 400px;
    margin: 0 auto;
    width: 100%;
}

.login-header {
    text-align: center;
    margin-bottom: 40px;
}

.login-header h2 {
    font-size: 32px;
    font-weight: 700;
    color: #1a1a1a;
    margin-bottom: 8px;
}

.login-header p {
    color: #666;
    font-size: 16px;
}

.login-form {
    width: 100%;
}

.login-input {
    margin-bottom: 20px;
}

.login-input :deep(.el-input__wrapper) {
    border-radius: 8px;
    padding: 12px 16px;
    border: 1px solid #e0e0e0;
    transition: all 0.3s;
}

.login-input :deep(.el-input__wrapper:hover) {
    border-color: #409eff;
}

.login-input :deep(.el-input__wrapper.is-focus) {
    border-color: #409eff;
    box-shadow: 0 0 0 2px rgba(64, 158, 255, 0.1);
}

.login-options {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 24px;
}

.forgot-password {
    color: #409eff;
    text-decoration: none;
    font-size: 14px;
    transition: color 0.3s;
}

.forgot-password:hover {
    color: #66b1ff;
    text-decoration: underline;
}

.login-button {
    width: 100%;
    height: 48px;
    border-radius: 8px;
    font-size: 16px;
    font-weight: 600;
    margin-bottom: 24px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border: none;
}

.login-button:hover {
    opacity: 0.9;
    transform: translateY(-1px);
    box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

.login-divider {
    display: flex;
    align-items: center;
    margin: 24px 0;
    color: #999;
}

.login-divider::before,
.login-divider::after {
    content: "";
    flex: 1;
    height: 1px;
    background: #e0e0e0;
}

.login-divider span {
    padding: 0 16px;
    font-size: 14px;
}

.register-link {
    text-align: center;
    color: #666;
    font-size: 14px;
}

.register-text {
    color: #409eff;
    font-weight: 600;
    text-decoration: none;
    margin-left: 4px;
    transition: color 0.3s;
}

.register-text:hover {
    color: #66b1ff;
    text-decoration: underline;
}

.login-footer {
    position: absolute;
    bottom: 20px;
    left: 0;
    right: 0;
    text-align: center;
    color: #999;
    font-size: 12px;
    line-height: 1.5;
}

.login-footer p {
    margin: 4px 0;
}

/* 响应式设计 */
@media (max-width: 1024px) {
    .login-left-panel {
        display: none;
    }

    .login-right-panel {
        width: 100%;
        max-width: 480px;
        margin: 0 auto;
    }
}

@media (max-width: 480px) {
    .login-right-panel {
        padding: 20px;
    }

    .brand-title {
        font-size: 32px;
    }

    .login-header h2 {
        font-size: 28px;
    }
}
</style>
