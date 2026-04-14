<template>
    <div class="product-info">
        <!-- 顶部操作栏 -->
        <el-card shadow="never" class="operation-bar">
            <div class="flex-between">
                <div class="left-actions">
                    <el-button type="primary" @click="handleAdd">
                        <el-icon><Plus /></el-icon>
                        添加商品
                    </el-button>
                    <el-button @click="handleImport">
                        <el-icon><UploadFilled /></el-icon>
                        导入
                    </el-button>
                    <el-button @click="handleExport">
                        <el-icon><Download /></el-icon>
                        导出
                    </el-button>
                    <el-button @click="refreshList">
                        <el-icon><Refresh /></el-icon>
                        刷新
                    </el-button>
                </div>

                <div class="right-tools">
                    <el-input
                        v-model="searchForm.keyword"
                        placeholder="请输入SKU、名称或编码搜索"
                        clearable
                        style="width: 240px"
                        @keyup.enter="handleSearch"
                    >
                        <template #prefix>
                            <el-icon><Search /></el-icon>
                        </template>
                    </el-input>

                    <el-select
                        v-model="searchForm.category"
                        placeholder="产品类型"
                        clearable
                        style="width: 140px; margin-left: 10px"
                        @change="handleSearch"
                    >
                        <el-option label="全部" value="" />
                        <el-option label="成品" value="成品" />
                        <el-option label="零件" value="零件" />
                        <el-option label="网关" value="网关" />
                        <el-option label="交换机" value="交换机" />
                        <el-option label="路由器" value="路由器" />
                        <el-option label="CPU芯片" value="CPU芯片" />
                        <el-option label="电源" value="电源" />
                    </el-select>

                    <el-button icon="Filter" @click="showFilter = !showFilter" text />
                </div>
            </div>

            <!-- 筛选区域（折叠式） -->
            <div v-if="showFilter" class="filter-panel">
                <el-row :gutter="20">
                    <el-col :span="6">
                        <el-form-item label="品牌">
                            <el-input v-model="searchForm.brand" clearable @keyup.enter="handleSearch" />
                        </el-form-item>
                    </el-col>
                    <el-col :span="6">
                        <el-form-item label="规格型号">
                            <el-input v-model="searchForm.spec" clearable @keyup.enter="handleSearch" />
                        </el-form-item>
                    </el-col>
                    <el-col :span="6">
                        <el-form-item label="单位">
                            <el-select v-model="searchForm.unit" clearable placeholder="请选择" @change="handleSearch">
                                <el-option label="个" value="个" />
                                <el-option label="台" value="台" />
                                <el-option label="件" value="件" />
                                <el-option label="片" value="片" />
                            </el-select>
                        </el-form-item>
                    </el-col>
                    <el-col :span="6" class="text-right">
                        <el-button @click="resetFilter">重置</el-button>
                        <el-button type="primary" @click="handleSearch">搜索</el-button>
                    </el-col>
                </el-row>
            </div>
        </el-card>

        <!-- 商品卡片列表 -->
        <el-card shadow="never" class="product-grid">
            <el-row :gutter="20">
                <el-col
                    v-for="item in productList"
                    :key="item.id || item.skuCode"
                    :xs="24"
                    :sm="12"
                    :md="8"
                    :lg="6"
                    :xl="4"
                >
                    <el-card shadow="hover" class="product-card" :body-style="{ padding: '16px' }">
                        <!-- 图片区域 -->
                        <div class="product-image">
                            <el-image
                                :src="item.imageUrl || require('@/assets/images/default-product.png')"
                                fit="cover"
                                :alt="item.name || item.skuCode"
                                lazy
                            >
                                <template #error>
                                    <div class="image-placeholder">
                                        <el-icon><Box /></el-icon>
                                        <span>无图</span>
                                    </div>
                                </template>
                            </el-image>
                        </div>

                        <!-- 商品信息 -->
                        <div class="product-info-content">
                            <h3 class="product-name">{{ item.name || item.skuCode }}</h3>
                            <p class="product-sku">
                                <el-icon><Document /></el-icon>
                                SKU：{{ item.skuCode || "-" }}
                            </p>
                            <p class="product-code">
                                <el-icon><DocumentCopy /></el-icon>
                                编码：{{ item.productCode || "-" }}
                            </p>
                            <p class="product-attr">
                                <el-icon><Grid /></el-icon>
                                属性：{{ item.attributes?.join(" / ") || "无" }}
                            </p>
                            <p class="product-type">
                                <el-icon><CollectionTag /></el-icon>
                                类型：{{ item.productType || "-" }}
                            </p>
                            <p class="product-category">
                                <el-icon><Folder /></el-icon>
                                分类：{{ item.categoryName || item.category || "-" }}
                            </p>
                        </div>

                        <!-- 操作按钮 -->
                        <div class="product-actions">
                            <el-button size="small" type="primary" plain @click="handleApplyPurchase(item)">
                                <el-icon><ShoppingCart /></el-icon>
                                申请采购
                            </el-button>
                            <el-button size="small" type="success" plain @click="handleQuoteEntry(item)">
                                <el-icon><PriceTag /></el-icon>
                                报价录入
                            </el-button>
                        </div>
                    </el-card>
                </el-col>
            </el-row>

            <!-- 空状态 -->
            <div v-if="productList.length === 0 && !loading" class="empty-state">
                <el-empty description="暂无商品数据，请添加或导入" />
            </div>

            <!-- 分页 -->
            <div class="pagination-wrapper">
                <el-pagination
                    v-model:current-page="pagination.pageNum"
                    v-model:page-size="pagination.pageSize"
                    :total="pagination.total"
                    layout="total, prev, pager, next, jumper"
                    @size-change="handleSizeChange"
                    @current-change="handleCurrentChange"
                />
            </div>
        </el-card>

        <!-- 添加商品对话框 -->
        <el-dialog v-model="dialog.visible" :title="dialog.title" width="600px">
            <el-form :model="dialog.form" ref="productFormRef" label-width="100px">
                <el-form-item label="商品名称" prop="name" required>
                    <el-input v-model="dialog.form.name" placeholder="请输入商品名称" />
                </el-form-item>
                <el-form-item label="SKU编码" prop="skuCode" required>
                    <el-input v-model="dialog.form.skuCode" placeholder="如：MTQ8200-HS2F" />
                </el-form-item>
                <el-form-item label="产品编码" prop="productCode">
                    <el-input v-model="dialog.form.productCode" placeholder="内部编码" />
                </el-form-item>
                <el-form-item label="产品类型" prop="productType" required>
                    <el-select v-model="dialog.form.productType" placeholder="请选择">
                        <el-option label="成品" value="成品" />
                        <el-option label="零件" value="零件" />
                        <el-option label="网关" value="网关" />
                        <el-option label="交换机" value="交换机" />
                        <el-option label="路由器" value="路由器" />
                        <el-option label="CPU芯片" value="CPU芯片" />
                        <el-option label="电源" value="电源" />
                    </el-select>
                </el-form-item>
                <el-form-item label="品牌" prop="brand">
                    <el-input v-model="dialog.form.brand" placeholder="如：华为、思科" />
                </el-form-item>
                <el-form-item label="规格型号" prop="spec">
                    <el-input v-model="dialog.form.spec" placeholder="如：8口千兆" />
                </el-form-item>
                <el-form-item label="单位" prop="unit">
                    <el-select v-model="dialog.form.unit" placeholder="请选择">
                        <el-option label="个" value="个" />
                        <el-option label="台" value="台" />
                        <el-option label="件" value="件" />
                        <el-option label="片" value="片" />
                    </el-select>
                </el-form-item>
                <el-form-item label="属性" prop="attributes">
                    <el-input
                        v-model="dialog.form.attributesStr"
                        placeholder="多个属性用逗号分隔，如：千兆,金属外壳"
                        @input="parseAttributes"
                    />
                </el-form-item>
                <el-form-item label="图片上传">
                    <el-upload
                        class="avatar-uploader"
                        action="/api/upload/image"
                        :auto-upload="false"
                        :http-request="customUpload"
                        :show-file-list="false"
                        :on-success="handleUploadSuccess"
                    >
                        <img v-if="dialog.form.imageUrl" :src="dialog.form.imageUrl" class="avatar" alt="preview" />
                        <el-icon v-else class="avatar-uploader-icon"><Plus /></el-icon>
                    </el-upload>
                    <p class="tip">建议尺寸：400×400px，支持 JPG/PNG</p>
                </el-form-item>
            </el-form>
            <template #footer>
                <span class="dialog-footer">
                    <el-button @click="dialog.visible = false">取消</el-button>
                    <el-button type="primary" @click="submitProduct">保存</el-button>
                </span>
            </template>
        </el-dialog>
    </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import {
    Plus,
    Search,
    Refresh,
    UploadFilled,
    Download,
    ShoppingCart,
    PriceTag,
    Document,
    DocumentCopy,
    Grid,
    CollectionTag,
    Folder,
    Box,
    View,
    Edit,
    Delete,
} from "@element-plus/icons-vue";
import request from "@/utils/request.js";
import { formatDateTime } from "@/utils/date.js";

// 搜索表单
const searchForm = reactive({
    keyword: "",
    category: "",
    brand: "",
    spec: "",
    unit: "",
});

// 分页参数
const pagination = reactive({
    pageNum: 1,
    pageSize: 12, // 卡片布局每页12个更合理
    total: 0,
});

// 商品列表
const productList = ref([]);
const loading = ref(false);

// 对话框
const dialog = reactive({
    visible: false,
    title: "添加商品",
    form: {
        id: null,
        name: "",
        skuCode: "",
        productCode: "",
        productType: "",
        brand: "",
        spec: "",
        unit: "",
        attributes: [], // 实际存储数组
        attributesStr: "", // 输入框用字符串
        imageUrl: "",
    },
});

// 筛选展开状态
const showFilter = ref(false);

// 获取商品列表
const getProductList = async () => {
    loading.value = true;
    try {
        const params = {
            pageNum: pagination.pageNum,
            pageSize: pagination.pageSize,
            ...searchForm,
        };

        const res = await request.get("/product/list", { params });
        if (res.code === "200") {
            const data = res.data.records || res.data.list || [];
            // 标准化字段：确保 attributes 是数组
            const normalized = data.map((item) => ({
                ...item,
                attributes: Array.isArray(item.attributes)
                    ? item.attributes
                    : item.attributes
                      ? item.attributes.split(",")
                      : [],
                categoryName: item.categoryName || item.category || "-",
            }));
            productList.value = normalized;
            pagination.total = res.data.total || data.length;
        } else {
            ElMessage.error(res.msg || "获取商品列表失败");
        }
    } catch (error) {
        console.error("获取商品列表失败:", error);
        ElMessage.error("网络错误，请重试");
    } finally {
        loading.value = false;
    }
};

// 搜索
const handleSearch = () => {
    pagination.pageNum = 1;
    getProductList();
};

// 重置筛选
const resetFilter = () => {
    Object.assign(searchForm, {
        keyword: "",
        category: "",
        brand: "",
        spec: "",
        unit: "",
    });
    showFilter.value = false;
    handleSearch();
};

// 分页变更
const handleSizeChange = (val) => {
    pagination.pageSize = val;
    getProductList();
};
const handleCurrentChange = (val) => {
    pagination.pageNum = val;
    getProductList();
};

// 刷新
const refreshList = () => {
    getProductList();
};

// 添加商品
const handleAdd = () => {
    dialog.title = "添加商品";
    dialog.form = {
        id: null,
        name: "",
        skuCode: "",
        productCode: "",
        productType: "",
        brand: "",
        spec: "",
        unit: "",
        attributes: [],
        attributesStr: "",
        imageUrl: "",
    };
    dialog.visible = true;
};

// 解析属性输入（逗号分隔 → 数组）
const parseAttributes = () => {
    if (dialog.form.attributesStr) {
        dialog.form.attributes = dialog.form.attributesStr
            .split(",")
            .map((s) => s.trim())
            .filter((s) => s);
    } else {
        dialog.form.attributes = [];
    }
};

// 自定义上传（模拟，实际应替换为后端接口）
const customUpload = ({ file }) => {
    // 模拟上传：这里仅设置本地预览
    const reader = new FileReader();
    reader.onload = (e) => {
        dialog.form.imageUrl = e.target.result;
    };
    reader.readAsDataURL(file);
};

// 上传成功回调（仅用于预览）
const handleUploadSuccess = (response, file) => {
    // 如果后端返回真实URL，可在此赋值
    // dialog.form.imageUrl = response.data.url;
};

// 提交商品
const submitProduct = async () => {
    // 表单校验（简化版）
    if (!dialog.form.name || !dialog.form.skuCode) {
        ElMessage.warning("请填写商品名称和SKU编码");
        return;
    }

    try {
        const payload = {
            ...dialog.form,
            attributes: dialog.form.attributes, // 保证是数组
        };
        delete payload.attributesStr; // 移除冗余字段

        const api = dialog.form.id ? "/product/update" : "/product/add";
        const res = await request[dialog.form.id ? "put" : "post"](api, payload);

        if (res.code === "200") {
            ElMessage.success(dialog.form.id ? "更新成功" : "添加成功");
            dialog.visible = false;
            getProductList();
        } else {
            ElMessage.error(res.msg || "操作失败");
        }
    } catch (error) {
        ElMessage.error("提交失败，请检查网络");
    }
};

// 申请采购
const handleApplyPurchase = (item) => {
    ElMessageBox.confirm(`确认为【${item.name || item.skuCode}】发起采购申请？`, "提示", {
        confirmButtonText: "确认",
        cancelButtonText: "取消",
        type: "info",
    }).then(() => {
        ElMessage.success(`采购申请已提交：${item.skuCode}`);
        // 可跳转到采购管理页或调用采购接口
    });
};

// 报价录入
const handleQuoteEntry = (item) => {
    ElMessage.info(`即将进入【${item.name || item.skuCode}】的报价录入页面`);
    // 跳转或打开报价录入弹窗
};

// 导入/导出（占位）
const handleImport = () => {
    ElMessage.info("导入功能待实现：支持Excel模板导入");
};
const handleExport = () => {
    ElMessage.info("导出功能待实现：导出当前筛选结果为Excel");
};

// 初始化
onMounted(() => {
    getProductList();
});
</script>

<style scoped>
.product-info {
    padding: 20px;
    background-color: #f5f7fa;
    min-height: 100vh;
}

.operation-bar {
    margin-bottom: 16px;
}

.flex-between {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.left-actions {
    display: flex;
    gap: 10px;
}

.right-tools {
    display: flex;
    align-items: center;
    gap: 10px;
}

.filter-panel {
    padding: 16px;
    background-color: #fafafa;
    border-radius: 6px;
    margin-top: 12px;
}

.product-grid {
    position: relative;
}

.product-card {
    height: 320px;
    display: flex;
    flex-direction: column;
    transition: all 0.3s ease;
}

.product-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 8px 20px rgba(0, 0, 0, 0.08);
}

.product-image {
    height: 140px;
    overflow: hidden;
    border-radius: 6px;
    background-color: #f5f7fa;
    display: flex;
    align-items: center;
    justify-content: center;
}

.product-image img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.image-placeholder {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    color: #909399;
    font-size: 12px;
    text-align: center;
}

.image-placeholder .el-icon {
    font-size: 24px;
    margin-bottom: 6px;
}

.product-info-content {
    flex: 1;
    padding: 12px 0;
    overflow: hidden;
}

.product-name {
    font-size: 16px;
    font-weight: 600;
    color: #303133;
    margin: 0 0 8px 0;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.product-sku,
.product-code,
.product-attr,
.product-type,
.product-category {
    font-size: 13px;
    color: #606266;
    margin: 4px 0;
    display: flex;
    align-items: center;
}

.product-sku .el-icon,
.product-code .el-icon,
.product-attr .el-icon,
.product-type .el-icon,
.product-category .el-icon {
    margin-right: 6px;
    font-size: 14px;
}

.product-actions {
    margin-top: auto;
    display: flex;
    gap: 8px;
}

.pagination-wrapper {
    margin-top: 24px;
    text-align: center;
}

.empty-state {
    text-align: center;
    padding: 60px 0;
}

/* 头像上传样式 */
.avatar-uploader .el-upload {
    border: 1px dashed #d9d9d9;
    border-radius: 6px;
    cursor: pointer;
    position: relative;
    overflow: hidden;
    width: 100px;
    height: 100px;
    display: flex;
    align-items: center;
    justify-content: center;
    background-color: #fbfbfc;
}

.avatar-uploader .el-upload:hover {
    border-color: #409eff;
}

.avatar-uploader-icon {
    font-size: 28px;
    color: #8c959f;
}

.avatar {
    width: 100%;
    height: 100%;
    display: block;
    object-fit: cover;
    border-radius: 6px;
}

.tip {
    font-size: 12px;
    color: #909399;
    margin-top: 8px;
}

/* 响应式优化 */
@media (max-width: 768px) {
    .product-card {
        height: auto;
    }
    .product-image {
        height: 120px;
    }
    .flex-between {
        flex-direction: column;
        gap: 12px;
    }
    .right-tools {
        width: 100%;
        flex-wrap: wrap;
    }
}
</style>
