<script setup>
import { ref, reactive } from "vue";
import { ElMessage } from "element-plus";
import router from "../router";
import { register as apiRegister, emailRegister as apiEmailRegister, sendEmailRegCode } from "@/api";
import { Check } from "@element-plus/icons-vue";

const formRef = ref();
const emailFormRef = ref();
const termsAccepted = ref(false);
const emailTermsAccepted = ref(false);
const loading = ref(false);
const activeTab = ref("account");
const codeLoading = ref(false);
const codeDisabled = ref(false);
const codeCountdown = ref(0);

const validatePass2 = (rule, value, callback) => {
    if (value === "") {
        callback(new Error("请再次输入密码确认！"));
    } else if (value !== data.form.password) {
        callback(new Error("两次密码不一致！"));
    } else {
        callback();
    }
};

const validateEmailPass2 = (rule, value, callback) => {
    if (value === "") {
        callback(new Error("请再次输入密码确认！"));
    } else if (value !== emailData.form.password) {
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

const emailData = reactive({
    form: {
        email: "",
        code: "",
        password: "",
        confirmPassword: "",
    },
    rules: {
        email: [{ validator: checkEmail, trigger: "blur" }],
        code: [
            { required: true, message: "请输入验证码", trigger: "blur" },
            { len: 6, message: "验证码为6位", trigger: "blur" },
        ],
        password: [{ required: true, message: "请输入密码", trigger: "blur" }],
        confirmPassword: [{ validator: validateEmailPass2, trigger: "blur" }],
    },
});

const register = () => {
    formRef.value.validate((valid) => {
        if (valid) {
            loading.value = true;
            apiRegister(data.form)
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

const sendCode = () => {
    emailFormRef.value.validateField("email", (valid) => {
        if (valid) {
            codeLoading.value = true;
            sendEmailRegCode({ email: emailData.form.email })
                .then((res) => {
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

const emailRegister = () => {
    emailFormRef.value.validate((valid) => {
        if (valid) {
            loading.value = true;
            apiEmailRegister({
                    email: emailData.form.email,
                    password: emailData.form.password,
                    code: emailData.form.code,
                })
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
                    <el-tabs v-model="activeTab" class="register-tabs">
                        <el-tab-pane label="账号注册" name="account">
                            <el-form ref="formRef" :model="data.form" :rules="data.rules" class="register-form">
                                <el-form-item prop="username">
                                    <el-input
                                        v-model="data.form.username"
                                        autocomplete="off"
                                        prefix-icon="User"
                                        size="default"
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
                                        size="default"
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
                                        size="default"
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
                                        size="default"
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
                            </el-form>
                        </el-tab-pane>
                        <el-tab-pane label="邮箱注册" name="email">
                            <el-form ref="emailFormRef" :model="emailData.form" :rules="emailData.rules" class="register-form">
                                <el-form-item prop="email">
                                    <el-input
                                        v-model="emailData.form.email"
                                        autocomplete="off"
                                        prefix-icon="Message"
                                        size="default"
                                        placeholder="请输入邮箱"
                                        class="register-input"
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
                                            class="register-input code-input"
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
                                <el-form-item prop="password">
                                    <el-input
                                        v-model="emailData.form.password"
                                        type="password"
                                        autocomplete="off"
                                        prefix-icon="Lock"
                                        size="default"
                                        placeholder="请输入密码"
                                        class="register-input"
                                        show-password
                                    />
                                </el-form-item>
                                <el-form-item prop="confirmPassword">
                                    <el-input
                                        v-model="emailData.form.confirmPassword"
                                        type="password"
                                        autocomplete="off"
                                        prefix-icon="Lock"
                                        size="default"
                                        placeholder="请确认密码"
                                        class="register-input"
                                        show-password
                                    />
                                </el-form-item>
                                <div class="terms-agreement">
                                    <el-checkbox v-model="emailTermsAccepted">
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
                                    @click="emailRegister"
                                    :loading="loading"
                                    :disabled="!emailTermsAccepted"
                                >
                                    注 册
                                </el-button>
                            </el-form>
                        </el-tab-pane>
                    </el-tabs>
                    <div class="register-link">
                        已有账户？
                        <router-link to="/login" class="register-text">立即登录</router-link>
                    </div>
                </div>
                <div class="register-footer">
                    <p>© 库存管理系统 版权所有</p>
                    <p>技术支持：11451419198</p>
                </div>
            </div>
        </div>
    </div>
</template>

<style scoped src="@/assets/css/register.css" />
