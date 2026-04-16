<script setup>
import { ref, reactive } from "vue";
import { ElMessage } from "element-plus";
import router from "../router";
import request from "../utils/request";
import { Check } from "@element-plus/icons-vue";

const formRef = ref();
const termsAccepted = ref(false);
const loading = ref(false);

const validatePass2 = (rule, value, callback) => {
    if (value === "") {
        callback(new Error("请再次输入密码确认！"));
    } else if (value !== data.form.password) {
        callback(new Error("两次密码不一致！"));
    } else {
        callback();
    }
};

const checkEmail = (rule, value, callback) => {
    const regEmail = /^([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4})$/;
    if (value === "") {
        callback(new Error("请输入邮箱"));
    } else if (!regEmail.test(value)) {
        callback(new Error("请输入有效的邮箱"));
    } else {
        callback();
    }
};

const data = reactive({
    form: {
        username: "",
        password: "",
        confirmPassword: "",
        email: "",
    },
    rules: {
        username: [
            { required: true, message: "请输入账号", trigger: "blur" },
            { min: 3, message: "至少输入3位", trigger: "blur" },
        ],
        password: [{ required: true, message: "请输入密码", trigger: "blur" }],
        confirmPassword: [{ validator: validatePass2, trigger: "blur" }],
        email: [{ validator: checkEmail, trigger: "blur" }],
    },
});

const register = () => {
    formRef.value.validate((valid) => {
        if (valid) {
            loading.value = true;
            request
                .post("/register", data.form)
                .then((res) => {
                    if (res.code === "200") {
                        ElMessage.success("注册成功");
                        router.push("/login");
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
    <div class="register-container">
        <div class="register-background">
            <div class="register-left-panel">
                <div class="brand-section">
                    <h1 class="brand-title">加入库存管理系统</h1>
                    <p class="brand-subtitle">开启高效库存管理之旅</p>
                    <div class="feature-list">
                        <div class="feature-item">
                            <el-icon><Check /></el-icon>
                            <span>30秒快速注册</span>
                        </div>
                        <div class="feature-item">
                            <el-icon><Check /></el-icon>
                            <span>免费试用30天</span>
                        </div>
                        <div class="feature-item">
                            <el-icon><Check /></el-icon>
                            <span>专业团队支持</span>
                        </div>
                        <div class="feature-item">
                            <el-icon><Check /></el-icon>
                            <span>数据安全保障</span>
                        </div>
                    </div>
                </div>
            </div>
            <div class="register-right-panel">
                <div class="register-card">
                    <div class="register-header">
                        <h2>创建账户</h2>
                        <p>填写以下信息完成注册</p>
                    </div>
                    <el-form ref="formRef" :model="data.form" :rules="data.rules" class="register-form">
                        <el-form-item prop="username">
                            <el-input
                                v-model="data.form.username"
                                autocomplete="off"
                                prefix-icon="User"
                                size="large"
                                placeholder="请输入账号（至少3位）"
                                class="register-input"
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
                                class="register-input"
                                show-password
                            />
                        </el-form-item>
                        <el-form-item prop="confirmPassword">
                            <el-input
                                v-model="data.form.confirmPassword"
                                type="password"
                                autocomplete="off"
                                prefix-icon="Lock"
                                size="large"
                                placeholder="请确认密码"
                                class="register-input"
                                show-password
                            />
                        </el-form-item>
                        <el-form-item prop="email">
                            <el-input
                                v-model="data.form.email"
                                autocomplete="off"
                                prefix-icon="Message"
                                size="large"
                                placeholder="请输入邮箱"
                                class="register-input"
                            />
                        </el-form-item>
                        <div class="terms-agreement">
                            <el-checkbox v-model="termsAccepted">
                                我已阅读并同意
                                <a href="#" class="terms-link">服务条款</a>
                                和
                                <a href="#" class="terms-link">隐私政策</a>
                            </el-checkbox>
                        </div>
                        <el-button
                            size="large"
                            type="primary"
                            class="register-button"
                            @click="register"
                            :loading="loading"
                            :disabled="!termsAccepted"
                        >
                            注 册
                        </el-button>
                        <div class="register-divider">
                            <span>已有账户？</span>
                        </div>
                        <div class="login-link">
                            <router-link to="/login" class="login-text">立即登录</router-link>
                        </div>
                    </el-form>
                </div>
                <div class="register-footer">
                    <p>© 2024 库存管理系统 版权所有</p>
                    <p>技术支持：400-123-4567</p>
                </div>
            </div>
        </div>
    </div>
</template>

<style scoped>
.register-container {
    height: 100vh;
    width: 100vw;
    overflow: hidden;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.register-background {
    display: flex;
    height: 100%;
    width: 100%;
}

.register-left-panel {
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

.register-right-panel {
    width: 480px;
    background: white;
    display: flex;
    flex-direction: column;
    justify-content: center;
    padding: 40px;
    position: relative;
}

.register-card {
    max-width: 400px;
    margin: 0 auto;
    width: 100%;
}

.register-header {
    text-align: center;
    margin-bottom: 40px;
}

.register-header h2 {
    font-size: 32px;
    font-weight: 700;
    color: #1a1a1a;
    margin-bottom: 8px;
}

.register-header p {
    color: #666;
    font-size: 16px;
}

.register-form {
    width: 100%;
}

.register-input {
    margin-bottom: 20px;
}

.register-input :deep(.el-input__wrapper) {
    border-radius: 8px;
    padding: 12px 16px;
    border: 1px solid #e0e0e0;
    transition: all 0.3s;
}

.register-input :deep(.el-input__wrapper:hover) {
    border-color: #409eff;
}

.register-input :deep(.el-input__wrapper.is-focus) {
    border-color: #409eff;
    box-shadow: 0 0 0 2px rgba(64, 158, 255, 0.1);
}

.terms-agreement {
    margin-bottom: 24px;
}

.terms-agreement :deep(.el-checkbox__label) {
    font-size: 14px;
    color: #666;
}

.terms-link {
    color: #409eff;
    text-decoration: none;
    transition: color 0.3s;
}

.terms-link:hover {
    color: #66b1ff;
    text-decoration: underline;
}

.register-button {
    width: 100%;
    height: 48px;
    border-radius: 8px;
    font-size: 16px;
    font-weight: 600;
    margin-bottom: 24px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border: none;
}

.register-button:hover:not(:disabled) {
    opacity: 0.9;
    transform: translateY(-1px);
    box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

.register-button:disabled {
    opacity: 0.6;
    cursor: not-allowed;
}

.register-divider {
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 24px 0;
    color: #999;
    font-size: 14px;
}

.login-link {
    text-align: center;
}

.login-text {
    display: inline-block;
    padding: 10px 24px;
    background: #f5f7fa;
    color: #409eff;
    font-weight: 600;
    text-decoration: none;
    border-radius: 8px;
    transition: all 0.3s;
}

.login-text:hover {
    background: #e8eef5;
    color: #66b1ff;
    text-decoration: none;
    transform: translateY(-1px);
    box-shadow: 0 2px 8px rgba(64, 158, 255, 0.2);
}

.register-footer {
    position: absolute;
    bottom: 20px;
    left: 0;
    right: 0;
    text-align: center;
    color: #999;
    font-size: 12px;
    line-height: 1.5;
}

.register-footer p {
    margin: 4px 0;
}

/* 响应式设计 */
@media (max-width: 1024px) {
    .register-left-panel {
        display: none;
    }

    .register-right-panel {
        width: 100%;
        max-width: 480px;
        margin: 0 auto;
    }
}

@media (max-width: 480px) {
    .register-right-panel {
        padding: 20px;
    }

    .brand-title {
        font-size: 32px;
    }

    .register-header h2 {
        font-size: 28px;
    }
}
</style>
