<template>
    <div class="goods-info">
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
                        placeholder="请输入SKU、名称搜索"
                        clearable
                        style="width: 240px"
                        @keyup.enter="handleSearch"
                    >
                        <template #prefix>
                            <el-icon><Search /></el-icon>
                        </template>
                    </el-input>

                    <el-cascader
                        v-model="searchForm.categoryId"
                        :options="categoryTree"
                        :props="{
                            value: 'id',
                            label: 'name',
                            children: 'children',
                            checkStrictly: true,
                        }"
                        placeholder="商品分类"
                        clearable
                        style="width: 200px; margin-left: 10px"
                        @change="handleSearch"
                    />

                    <el-button
                        icon="Filter"
                        @click="showFilter = !showFilter"
                        text
                    />
                </div>
            </div>

            <div v-if="showFilter" class="filter-panel">
                <el-row :gutter="20">
                    <el-col :span="6">
                        <el-form-item label="品牌">
                            <el-input
                                v-model="searchForm.brand"
                                clearable
                                @keyup.enter="handleSearch"
                            />
                        </el-form-item>
                    </el-col>
                    <el-col :span="6">
                        <el-form-item label="规格型号">
                            <el-input
                                v-model="searchForm.spec"
                                clearable
                                @keyup.enter="handleSearch"
                            />
                        </el-form-item>
                    </el-col>
                    <el-col :span="6">
                        <el-form-item label="单位">
                            <el-select
                                v-model="searchForm.unit"
                                clearable
                                placeholder="请选择"
                                @change="handleSearch"
                            >
                                <el-option label="个" value="个" />
                                <el-option label="台" value="台" />
                                <el-option label="箱" value="箱" />
                                <el-option label="袋" value="袋" />
                                <el-option label="瓶" value="瓶" />
                                <el-option label="盒" value="盒" />
                            </el-select>
                        </el-form-item>
                    </el-col>
                    <el-col :span="6" class="text-right">
                        <el-button @click="resetFilter">重置</el-button>
                        <el-button type="primary" @click="handleSearch"
                            >搜索</el-button
                        >
                    </el-col>
                </el-row>
            </div>
        </el-card>

        <el-card shadow="never" class="goods-grid">
            <el-row :gutter="20">
                <el-col
                    v-for="item in productList"
                    :key="item.id || item.sku_code"
                    :xs="24"
                    :sm="12"
                    :md="8"
                    :lg="6"
                    :xl="4"
                >
                    <el-card
                        shadow="hover"
                        class="goods-card"
                        :body-style="{ padding: '16px' }"
                    >
                        <div class="goods-image">
                            <el-image
                                :src="item.img"
                                fit="cover"
                                :alt="item.name || item.sku_code"
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

                        <div class="goods-info-content">
                            <h3 class="goods-name">
                                {{ item.name || item.sku_code }}
                            </h3>
                            <p class="goods-sku">
                                <el-icon><Document /></el-icon>
                                SKU：{{ item.skuCode || "-" }}
                            </p>
                            <p class="goods-barcode">
                                条码：{{ item.barcode || "-" }}
                            </p>
                            <p class="goods-brand">
                                <el-icon><Shop /></el-icon>
                                品牌：{{ item.brand || "-" }}
                            </p>
                            <p class="goods-spec">
                                <el-icon><Grid /></el-icon>
                                规格：{{ item.spec || "-" }}
                            </p>
                            <p class="goods-category">
                                <el-icon><Folder /></el-icon>
                                分类：{{
                                    getCategoryName(item.categoryId) || "-"
                                }}
                            </p>
                            <p class="goods-price">
                                <el-icon><PriceTag /></el-icon>
                                售价：{{ item.sale_price || 0 }}元 /
                                {{ item.unit || "个" }}
                            </p>
                        </div>

                        <div class="goods-actions">
                            <el-button
                                size="small"
                                type="primary"
                                plain
                                @click="handleEdit(item)"
                            >
                                <el-icon><Edit /></el-icon>
                                编辑
                            </el-button>
                            <el-button
                                size="small"
                                type="danger"
                                plain
                                @click="handleDelete(item)"
                            >
                                <el-icon><Delete /></el-icon>
                                删除
                            </el-button>
                        </div>
                    </el-card>
                </el-col>
            </el-row>

            <div
                v-if="productList.length === 0 && !loading"
                class="empty-state"
            >
                <el-empty description="暂无商品数据，请添加或导入" />
            </div>

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

        <el-dialog v-model="dialog.visible" :title="dialog.title" width="700px">
            <el-form
                :model="dialog.form"
                ref="goodsFormRef"
                label-width="100px"
                :rules="formRules"
            >
                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="SKU编码" prop="sku_code" required>
                            <el-input
                                v-model="dialog.form.sku_code"
                                placeholder="全局唯一编码"
                            />
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="商品名称" prop="name" required>
                            <el-input
                                v-model="dialog.form.name"
                                placeholder="请输入商品名称"
                            />
                        </el-form-item>
                    </el-col>
                </el-row>

                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="商品分类" prop="category_id">
                            <el-cascader
                                v-model="dialog.form.category_id"
                                :options="categoryTree"
                                :props="{
                                    value: 'id',
                                    label: 'name',
                                    children: 'children',
                                    checkStrictly: true,
                                }"
                                placeholder="请选择分类"
                                style="width: 100%"
                                clearable
                            />
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="品牌" prop="brand">
                            <el-input
                                v-model="dialog.form.brand"
                                placeholder="如：农夫山泉"
                            />
                        </el-form-item>
                    </el-col>
                </el-row>

                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="规格型号" prop="spec">
                            <el-input
                                v-model="dialog.form.spec"
                                placeholder="如：550ml/瓶"
                            />
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="单位" prop="unit">
                            <el-select
                                v-model="dialog.form.unit"
                                placeholder="请选择"
                                style="width: 100%"
                            >
                                <el-option label="个" value="个" />
                                <el-option label="台" value="台" />
                                <el-option label="箱" value="箱" />
                                <el-option label="袋" value="袋" />
                                <el-option label="瓶" value="瓶" />
                                <el-option label="盒" value="盒" />
                            </el-select>
                        </el-form-item>
                    </el-col>
                </el-row>

                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="主条码" prop="barcode">
                            <el-input
                                v-model="dialog.form.barcode"
                                placeholder="商品条形码"
                            />
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="图片" prop="img">
                            <el-input
                                v-model="dialog.form.img"
                                placeholder="图片URL"
                            />
                        </el-form-item>
                    </el-col>
                </el-row>

                <el-divider content-position="left">价格设置</el-divider>

                <el-row :gutter="20">
                    <el-col :span="8">
                        <el-form-item label="采购价" prop="purchase_price">
                            <el-input-number
                                v-model="dialog.form.purchase_price"
                                :min="0"
                                :precision="2"
                                placeholder="参考采购价"
                                style="width: 100%"
                            />
                        </el-form-item>
                    </el-col>
                    <el-col :span="8">
                        <el-form-item label="标准售价" prop="sale_price">
                            <el-input-number
                                v-model="dialog.form.sale_price"
                                :min="0"
                                :precision="2"
                                placeholder="标准售价"
                                style="width: 100%"
                            />
                        </el-form-item>
                    </el-col>
                    <el-col :span="8">
                        <el-form-item label="成本价" prop="cost_price">
                            <el-input-number
                                v-model="dialog.form.cost_price"
                                :min="0"
                                :precision="2"
                                placeholder="移动加权成本"
                                style="width: 100%"
                            />
                        </el-form-item>
                    </el-col>
                </el-row>

                <el-divider content-position="left">库存预警</el-divider>

                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="库存下限" prop="stock_low">
                            <el-input-number
                                v-model="dialog.form.stock_low"
                                :min="0"
                                :precision="2"
                                placeholder="库存预警下限"
                                style="width: 100%"
                            />
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="库存上限" prop="stock_high">
                            <el-input-number
                                v-model="dialog.form.stock_high"
                                :min="0"
                                :precision="2"
                                placeholder="库存预警上限"
                                style="width: 100%"
                            />
                        </el-form-item>
                    </el-col>
                </el-row>
            </el-form>
            <template #footer>
                <span class="dialog-footer">
                    <el-button @click="dialog.visible = false">取消</el-button>
                    <el-button type="primary" @click="submitGoods"
                        >保存</el-button
                    >
                </span>
            </template>
        </el-dialog>
    </div>
</template>

<script setup>
import { ref, reactive, onMounted } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import {
    Plus,
    Search,
    Refresh,
    UploadFilled,
    Download,
    Document,
    Box,
    Grid,
    Folder,
    PriceTag,
    Edit,
    Delete,
    Shop,
} from "@element-plus/icons-vue";
import request from "../../utils/request";

const searchForm = reactive({
    keyword: "",
    categoryId: "",
    brand: "",
    spec: "",
    unit: "",
});

const pagination = reactive({
    pageNum: 1,
    pageSize: 12,
    total: 0,
});

const productList = ref([]);
const categoryTree = ref([]);
const loading = ref(false);
const showFilter = ref(false);

const dialog = reactive({
    visible: false,
    title: "添加商品",
    form: {
        id: null,
        sku_code: "",
        name: "",
        img: "",
        category_id: null,
        brand: "",
        spec: "",
        unit: "个",
        barcode: "",
        purchase_price: 0,
        sale_price: 0,
        cost_price: 0,
        stock_low: 0,
        stock_high: 0,
    },
});

const formRules = {
    sku_code: [{ required: true, message: "请输入SKU编码", trigger: "blur" }],
    name: [{ required: true, message: "请输入商品名称", trigger: "blur" }],
};

const getCategoryList = async () => {
    try {
        const res = await request.get("/category/tree");
        if (res.code === "200") {
            categoryTree.value = res.data || [];
        }
    } catch (error) {
        console.error("获取分类列表失败:", error);
    }
};

const getCategoryName = (categoryId) => {
    if (!categoryId) return "-";
    for (const parent of categoryTree.value) {
        if (parent.id === categoryId) return parent.name;
        const child = parent.children?.find((c) => c.id === categoryId);
        if (child) return `${parent.name} / ${child.name}`;
    }
    return "-";
};

const getProductList = async () => {
    loading.value = true;
    try {
        const categoryId = Array.isArray(searchForm.categoryId)
            ? searchForm.categoryId[searchForm.categoryId.length - 1]
            : searchForm.categoryId;
        const params = {
            pageNum: pagination.pageNum,
            pageSize: pagination.pageSize,
            keyword: searchForm.keyword,
            categoryId: categoryId,
            brand: searchForm.brand,
            spec: searchForm.spec,
            unit: searchForm.unit,
        };
        const res = await request.get("/goods/list", { params });
        if (res.code === "200") {
            productList.value = res.data.records || res.data.list || [];
            pagination.total = res.data.total || productList.value.length;
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

const handleSearch = () => {
    pagination.pageNum = 1;
    getProductList();
};

const resetFilter = () => {
    searchForm.categoryId = "";
    Object.assign(searchForm, {
        keyword: "",
        brand: "",
        spec: "",
        unit: "",
    });
    showFilter.value = false;
    handleSearch();
};

const handleSizeChange = (val) => {
    pagination.pageSize = val;
    getProductList();
};

const handleCurrentChange = (val) => {
    pagination.pageNum = val;
    getProductList();
};

const refreshList = () => {
    getProductList();
};

const handleAdd = () => {
    dialog.title = "添加商品";
    dialog.form = {
        id: null,
        sku_code: "",
        name: "",
        img: "",
        category_id: null,
        brand: "",
        spec: "",
        unit: "个",
        barcode: "",
        purchase_price: 0,
        sale_price: 0,
        cost_price: 0,
        stock_low: 0,
        stock_high: 0,
    };
    dialog.visible = true;
};

const handleEdit = (item) => {
    dialog.title = "编辑商品";
    let categoryPath = null;
    for (const parent of categoryTree.value) {
        if (parent.id === item.category_id) {
            categoryPath = [parent.id];
            break;
        }
        const child = parent.children?.find((c) => c.id === item.category_id);
        if (child) {
            categoryPath = [parent.id, child.id];
            break;
        }
    }
    dialog.form = {
        id: item.id,
        sku_code: item.sku_code,
        name: item.name,
        img: item.img,
        category_id: categoryPath,
        brand: item.brand,
        spec: item.spec,
        unit: item.unit || "个",
        barcode: item.barcode,
        purchase_price: Number(item.purchase_price) || 0,
        sale_price: Number(item.sale_price) || 0,
        cost_price: Number(item.cost_price) || 0,
        stock_low: Number(item.stock_low) || 0,
        stock_high: Number(item.stock_high) || 0,
    };
    dialog.visible = true;
};

const handleDelete = (item) => {
    ElMessageBox.confirm(
        `确认删除商品【${item.name || item.sku_code}】？`,
        "提示",
        {
            confirmButtonText: "确认",
            cancelButtonText: "取消",
            type: "warning",
        },
    ).then(async () => {
        try {
            const res = await request.delete(`/goods/${item.id}`);
            if (res.code === "200") {
                ElMessage.success("删除成功");
                getProductList();
            } else {
                ElMessage.error(res.msg || "删除失败");
            }
        } catch (error) {
            ElMessage.error("删除失败，请检查网络");
        }
    });
};

const submitGoods = async () => {
    if (!dialog.form.name || !dialog.form.sku_code) {
        ElMessage.warning("请填写商品名称和SKU编码");
        return;
    }

    try {
        const categoryId = Array.isArray(dialog.form.category_id)
            ? dialog.form.category_id[dialog.form.category_id.length - 1]
            : dialog.form.category_id;
        const payload = {
            ...dialog.form,
            category_id: categoryId,
        };
        const api = dialog.form.id ? "/goods/update" : "/goods/add";
        const res = dialog.form.id
            ? await request.put(api, payload)
            : await request.post(api, payload);

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

const handleImport = () => {
    ElMessage.info("导入功能待实现");
};

const handleExport = () => {
    ElMessage.info("导出功能待实现");
};

onMounted(() => {
    getCategoryList();
    getProductList();
});
</script>

<style scoped>
.goods-info {
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

.goods-grid {
    position: relative;
}

.goods-card {
    height: 370px;
    display: flex;
    flex-direction: column;
    transition: all 0.3s ease;
    margin: 5px;
}

.goods-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 8px 20px rgba(0, 0, 0, 0.08);
}

.goods-image {
    height: 120px;
    overflow: hidden;
    border-radius: 6px;
    background-color: #f5f7fa;
    display: flex;
    align-items: center;
    justify-content: center;
}

.goods-image img {
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

.goods-info-content {
    flex: 1;
    padding: 12px 0;
    overflow: hidden;
}

.goods-name {
    font-size: 16px;
    font-weight: 600;
    color: #303133;
    margin: 0 0 8px 0;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.goods-sku,
.goods-barcode,
.goods-brand,
.goods-spec,
.goods-category,
.goods-price {
    font-size: 13px;
    color: #606266;
    margin: 4px 0;
    display: flex;
    align-items: center;
}

.goods-sku .el-icon,
.goods-barcode .el-icon,
.goods-brand .el-icon,
.goods-spec .el-icon,
.goods-category .el-icon,
.goods-price .el-icon {
    margin-right: 6px;
    font-size: 14px;
}

.goods-price {
    color: #f56c6c;
    font-weight: 500;
}

.goods-actions {
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

@media (max-width: 768px) {
    .goods-card {
        height: auto;
    }
    .goods-image {
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
