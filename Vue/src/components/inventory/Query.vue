<template>
    <div class="management">
        <!-- 搜索栏 -->
        <el-card class="search-card" shadow="never">
            <el-form :inline="true" :model="searchForm" class="search-form">
                <el-form-item label="SKU编码">
                    <el-input
                        v-model="searchForm.skuCode"
                        placeholder="请输入SKU编码"
                        clearable
                        @clear="handleSearch"
                        @keyup.enter="handleSearch"
                    />
                </el-form-item>
                <el-form-item label="商品名称">
                    <el-input
                        v-model="searchForm.name"
                        placeholder="请输入商品名称"
                        clearable
                        @clear="handleSearch"
                        @keyup.enter="handleSearch"
                    />
                </el-form-item>
                <el-form-item label="品牌">
                    <el-input
                        v-model="searchForm.brand"
                        placeholder="请输入品牌"
                        clearable
                        @clear="handleSearch"
                        @keyup.enter="handleSearch"
                    />
                </el-form-item>
            </el-form>
            <el-form
                :inline="true"
                :model="searchForm"
                class="search-form"
                style="margin-top: 10px"
            >
                <el-form-item label="分类">
                    <el-select
                        v-model="searchForm.categoryId"
                        placeholder="请选择分类"
                        clearable
                        @change="handleSearch"
                        style="width: 120px"
                    >
                        <el-option label="全部" value="" />
                        <el-option label="水果" value="2" />
                        <el-option label="蔬菜" value="3" />
                        <el-option label="饮料" value="4" />
                        <el-option label="零食" value="5" />
                    </el-select>
                </el-form-item>
                <el-form-item label="条码">
                    <el-input
                        v-model="searchForm.barcode"
                        placeholder="请输入条码"
                        clearable
                        @clear="handleSearch"
                        @keyup.enter="handleSearch"
                    />
                </el-form-item>
                <el-form-item label="库存状态">
                    <el-select
                        v-model="searchForm.stockStatus"
                        placeholder="请选择库存状态"
                        clearable
                        @change="handleSearch"
                        style="width: 120px"
                    >
                        <el-option label="全部" value="" />
                        <el-option label="缺货" value="out_of_stock" />
                        <el-option label="库存不足" value="low_stock" />
                        <el-option label="库存正常" value="normal" />
                        <el-option label="库存过剩" value="high_stock" />
                    </el-select>
                </el-form-item>
                <el-form-item>
                    <el-button type="primary" @click="handleSearch">
                        <el-icon><Search /></el-icon>
                        搜索
                    </el-button>
                    <el-button @click="resetSearch">
                        <el-icon><Refresh /></el-icon>
                        重置
                    </el-button>
                </el-form-item>
            </el-form>
        </el-card>

        <div class="card" style="margin-bottom: 10px">
            <el-button type="primary" @click="handleAdd">
                <el-icon><Plus /></el-icon>
                新增商品
            </el-button>
            <el-button type="primary" @click="exportData"> 导出表格 </el-button>
            <el-upload
                action="/api/goods/importData"
                :on-success="handleImport"
                style="display: inline-block; margin-left: 10px"
                :show-file-list="false"
            >
                <el-button type="primary">导入表格</el-button>
            </el-upload>
            <el-button
                type="info"
                @click="showStockFlow"
                style="margin-left: 10px"
            >
                <el-icon><Document /></el-icon>
                库存流水
            </el-button>
        </div>

        <!-- 库存统计卡片 -->
        <el-row :gutter="20" style="margin-bottom: 20px">
            <el-col :span="6">
                <el-card shadow="hover" class="stat-card">
                    <div class="stat-content">
                        <div class="stat-title">总商品数</div>
                        <div class="stat-value">
                            {{ statistics.totalGoods }}
                        </div>
                        <div class="stat-trend">
                            <el-icon color="#67C23A"><TrendCharts /></el-icon>
                            <span>共{{ goodsList.length }}个商品</span>
                        </div>
                    </div>
                </el-card>
            </el-col>
            <el-col :span="6">
                <el-card shadow="hover" class="stat-card">
                    <div class="stat-content">
                        <div class="stat-title">总库存量</div>
                        <div class="stat-value">
                            {{ statistics.totalStock }}
                        </div>
                        <div class="stat-trend">
                            <el-icon color="#409EFF"><Box /></el-icon>
                            <span
                                >库存总额: ¥{{
                                    formatPrice(statistics.totalStockValue)
                                }}</span
                            >
                        </div>
                    </div>
                </el-card>
            </el-col>
            <el-col :span="6">
                <el-card shadow="hover" class="stat-card">
                    <div class="stat-content">
                        <div class="stat-title">缺货商品</div>
                        <div class="stat-value" style="color: #f56c6c">
                            {{ statistics.outOfStock }}
                        </div>
                        <div class="stat-trend">
                            <el-icon color="#F56C6C"><Warning /></el-icon>
                            <span>需要及时补货</span>
                        </div>
                    </div>
                </el-card>
            </el-col>
            <el-col :span="6">
                <el-card shadow="hover" class="stat-card">
                    <div class="stat-content">
                        <div class="stat-title">库存不足</div>
                        <div class="stat-value" style="color: #e6a23c">
                            {{ statistics.lowStock }}
                        </div>
                        <div class="stat-trend">
                            <el-icon color="#E6A23C"><WarningFilled /></el-icon>
                            <span>低于预警下限</span>
                        </div>
                    </div>
                </el-card>
            </el-col>
        </el-row>

        <!-- 商品表格 -->
        <el-card class="table-card" shadow="never">
            <el-table
                :data="goodsList"
                v-loading="loading"
                stripe
                border
                style="width: 100%"
                @selection-change="handleSelectionChange"
            >
                <el-table-column type="selection" width="55" />
                <el-table-column prop="skuCode" label="SKU编码" width="150" />
                <el-table-column prop="name" label="商品名称" width="180" />
                <el-table-column prop="brand" label="品牌" width="120" />
                <el-table-column prop="spec" label="规格型号" width="150" />
                <el-table-column prop="unit" label="单位" width="80" />
                <el-table-column prop="barcode" label="条码" width="150" />
                <el-table-column
                    prop="stockQuantity"
                    label="库存数量"
                    width="120"
                >
                    <template #default="{ row }">
                        <span :class="getStockStatusClass(row)">{{
                            row.stockQuantity || 0
                        }}</span>
                    </template>
                </el-table-column>
                <el-table-column
                    prop="stockStatus"
                    label="库存状态"
                    width="120"
                >
                    <template #default="{ row }">
                        <el-tag :type="getStockStatusTagType(row)" size="small">
                            {{ getStockStatusText(row) }}
                        </el-tag>
                    </template>
                </el-table-column>
                <el-table-column
                    prop="purchasePrice"
                    label="采购价"
                    width="120"
                >
                    <template #default="{ row }">
                        ¥{{ formatPrice(row.purchasePrice) }}
                    </template>
                </el-table-column>
                <el-table-column prop="salePrice" label="售价" width="120">
                    <template #default="{ row }">
                        ¥{{ formatPrice(row.salePrice) }}
                    </template>
                </el-table-column>
                <el-table-column prop="costPrice" label="成本价" width="120">
                    <template #default="{ row }">
                        ¥{{ formatPrice(row.costPrice) }}
                    </template>
                </el-table-column>
                <el-table-column prop="stockLow" label="库存下限" width="100" />
                <el-table-column
                    prop="stockHigh"
                    label="库存上限"
                    width="100"
                />
                <el-table-column prop="createTime" label="创建时间" width="100">
                    <template #default="{ row }">
                        {{ formatDateTime(row.createTime) }}
                    </template>
                </el-table-column>
                <el-table-column label="操作" width="280" fixed="right">
                    <template #default="{ row }">
                        <el-button
                            link
                            type="primary"
                            size="small"
                            @click="handleView(row)"
                        >
                            <el-icon><View /></el-icon>
                            查看
                        </el-button>
                        <el-button
                            link
                            type="primary"
                            size="small"
                            @click="handleEdit(row)"
                        >
                            <el-icon><Edit /></el-icon>
                            编辑
                        </el-button>
                        <el-button
                            link
                            type="warning"
                            size="small"
                            @click="handleViewStockFlow(row)"
                        >
                            <el-icon><Document /></el-icon>
                            流水
                        </el-button>
                        <el-button
                            link
                            type="danger"
                            size="small"
                            @click="handleDelete(row)"
                        >
                            <el-icon><Delete /></el-icon>
                            删除
                        </el-button>
                    </template>
                </el-table-column>
            </el-table>

            <!-- 分页 -->
            <div class="pagination-container">
                <el-pagination
                    v-model:current-page="pagination.pageNum"
                    v-model:page-size="pagination.pageSize"
                    :page-sizes="[5, 10, 20, 50, 100]"
                    :total="pagination.total"
                    layout="total, sizes, prev, pager, next, jumper"
                    @size-change="handleSizeChange"
                    @current-change="handleCurrentChange"
                />
            </div>
        </el-card>

        <!-- 新增/编辑商品对话框 -->
        <el-dialog
            v-model="dialog.visible"
            :title="dialog.title"
            width="700px"
            :close-on-click-modal="false"
            @close="handleDialogClose"
        >
            <el-form
                ref="goodsFormRef"
                :model="dialog.form"
                :rules="dialog.rules"
                label-width="120px"
                status-icon
            >
                <el-form-item label="商品图片" prop="mainImage">
                    <el-upload
                        action="/file/upload"
                        :on-success="handleImageSuccess"
                        :before-upload="beforeUpload"
                        :file-list="imageList"
                        list-type="picture-card"
                    >
                        <el-icon><Plus /></el-icon>
                    </el-upload>
                </el-form-item>

                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="SKU编码" prop="skuCode">
                            <el-input
                                v-model="dialog.form.skuCode"
                                placeholder="请输入SKU编码"
                                :disabled="dialog.isView"
                            />
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="商品名称" prop="name">
                            <el-input
                                v-model="dialog.form.name"
                                placeholder="请输入商品名称"
                                :disabled="dialog.isView"
                            />
                        </el-form-item>
                    </el-col>
                </el-row>

                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="商品种类" prop="categoryId">
                            <el-select
                                v-model="dialog.form.categoryId"
                                placeholder="请选择角色"
                                style="width: 100%"
                                :disabled="dialog.isView"
                            >
                                <el-option label="水果" value="2" />
                            </el-select>
                        </el-form-item>

                        <el-form-item label="品牌" prop="brand">
                            <el-input
                                v-model="dialog.form.brand"
                                placeholder="请输入品牌"
                                :disabled="dialog.isView"
                            />
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="规格型号" prop="spec">
                            <el-input
                                v-model="dialog.form.spec"
                                placeholder="请输入规格型号"
                                :disabled="dialog.isView"
                            />
                        </el-form-item>
                    </el-col>
                </el-row>

                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="单位" prop="unit">
                            <el-input
                                v-model="dialog.form.unit"
                                placeholder="请输入单位"
                                :disabled="dialog.isView"
                            />
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="条码" prop="barcode">
                            <el-input
                                v-model="dialog.form.barcode"
                                placeholder="请输入条码"
                                :disabled="dialog.isView"
                            />
                        </el-form-item>
                    </el-col>
                </el-row>

                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="采购价" prop="purchasePrice">
                            <el-input
                                v-model="dialog.form.purchasePrice"
                                placeholder="请输入采购价"
                                :disabled="dialog.isView"
                            >
                                <template #prefix>¥</template>
                            </el-input>
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="售价" prop="salePrice">
                            <el-input
                                v-model="dialog.form.salePrice"
                                placeholder="请输入售价"
                                :disabled="dialog.isView"
                            >
                                <template #prefix>¥</template>
                            </el-input>
                        </el-form-item>
                    </el-col>
                </el-row>
                <el-row>
                    <el-col :span="12">
                        <el-form-item label="成本价" prop="costPrice">
                            <el-input
                                v-model="dialog.form.costPrice"
                                placeholder="请输入成本价"
                                :disabled="dialog.isView"
                            >
                                <template #prefix>¥</template>
                            </el-input>
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="库存预警下限" prop="stockLow">
                            <el-input
                                v-model="dialog.form.stockLow"
                                placeholder="请输入库存预警下限"
                                :disabled="dialog.isView"
                            />
                        </el-form-item>
                    </el-col>
                </el-row>

                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="库存预警上限" prop="stockHigh">
                            <el-input
                                v-model="dialog.form.stockHigh"
                                placeholder="请输入库存预警上限"
                                :disabled="dialog.isView"
                            />
                        </el-form-item>
                    </el-col>
                </el-row>
            </el-form>

            <template #footer>
                <span class="dialog-footer">
                    <el-button @click="dialog.visible = false">取消</el-button>
                    <el-button
                        v-if="!dialog.isView"
                        type="primary"
                        @click="submitGoods"
                        :loading="dialog.loading"
                    >
                        确认
                    </el-button>
                </span>
            </template>
        </el-dialog>

        <!-- 查看商品详情对话框 -->
        <el-dialog v-model="viewDialog.visible" title="商品详情" width="600px">
            <el-descriptions :column="1" border>
                <el-descriptions-item label="SKU编码">{{
                    viewDialog.data.skuCode
                }}</el-descriptions-item>
                <el-descriptions-item label="商品名称">{{
                    viewDialog.data.name
                }}</el-descriptions-item>
                <el-descriptions-item label="品牌">{{
                    viewDialog.data.brand
                }}</el-descriptions-item>
                <el-descriptions-item label="规格型号">{{
                    viewDialog.data.spec
                }}</el-descriptions-item>
                <el-descriptions-item label="单位">{{
                    viewDialog.data.unit
                }}</el-descriptions-item>
                <el-descriptions-item label="条码">{{
                    viewDialog.data.barcode
                }}</el-descriptions-item>
                <el-descriptions-item label="采购价">
                    ¥{{ formatPrice(viewDialog.data.purchasePrice) }}
                </el-descriptions-item>
                <el-descriptions-item label="售价">
                    ¥{{ formatPrice(viewDialog.data.salePrice) }}
                </el-descriptions-item>
                <el-descriptions-item label="成本价">
                    ¥{{ formatPrice(viewDialog.data.costPrice) }}
                </el-descriptions-item>
                <el-descriptions-item label="库存预警下限">{{
                    viewDialog.data.stockLow
                }}</el-descriptions-item>
                <el-descriptions-item label="库存预警上限">{{
                    viewDialog.data.stockHigh
                }}</el-descriptions-item>
                <el-descriptions-item label="当前库存">{{
                    viewDialog.data.stockQuantity || 0
                }}</el-descriptions-item>
                <el-descriptions-item label="创建时间">{{
                    formatDateTime(viewDialog.data.createTime)
                }}</el-descriptions-item>
                <el-descriptions-item label="更新时间">{{
                    formatDateTime(viewDialog.data.updateTime)
                }}</el-descriptions-item>
            </el-descriptions>
        </el-dialog>

        <!-- 库存流水对话框 -->
        <el-dialog
            v-model="stockFlowDialog.visible"
            title="库存流水"
            width="900px"
            :close-on-click-modal="false"
        >
            <el-table
                :data="stockFlowDialog.data"
                v-loading="stockFlowDialog.loading"
                stripe
                border
                style="width: 100%"
            >
                <el-table-column
                    prop="operationNo"
                    label="作业编号"
                    width="150"
                />
                <el-table-column
                    prop="operationType"
                    label="作业类型"
                    width="100"
                >
                    <template #default="{ row }">
                        <el-tag
                            :type="getOperationTypeTagType(row.operationType)"
                        >
                            {{ getOperationTypeName(row.operationType) }}
                        </el-tag>
                    </template>
                </el-table-column>
                <el-table-column
                    prop="fromWarehouseName"
                    label="来源仓库"
                    width="120"
                />
                <el-table-column
                    prop="toWarehouseName"
                    label="目标仓库"
                    width="120"
                />
                <el-table-column prop="quantity" label="数量" width="80" />
                <el-table-column prop="operator" label="操作人" width="100" />
                <el-table-column prop="status" label="状态" width="100">
                    <template #default="{ row }">
                        <el-tag :type="getStatusTagType(row.status)">
                            {{ getStatusText(row.status) }}
                        </el-tag>
                    </template>
                </el-table-column>
                <el-table-column prop="createTime" label="创建时间" width="150">
                    <template #default="{ row }">
                        {{ formatDateTime(row.createTime) }}
                    </template>
                </el-table-column>
                <el-table-column
                    prop="completeTime"
                    label="完成时间"
                    width="150"
                >
                    <template #default="{ row }">
                        {{
                            row.completeTime
                                ? formatDateTime(row.completeTime)
                                : "-"
                        }}
                    </template>
                </el-table-column>
            </el-table>

            <template #footer>
                <span class="dialog-footer">
                    <el-button @click="stockFlowDialog.visible = false"
                        >关闭</el-button
                    >
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
    View,
    Edit,
    Delete,
    TrendCharts,
    Box,
    Warning,
    WarningFilled,
    Document,
} from "@element-plus/icons-vue";
import request from "../../utils/request.js";
import { formatDateTime } from "../../utils/date.js";

// 搜索表单
const searchForm = reactive({
    skuCode: "",
    name: "",
    brand: "",
    categoryId: "",
    barcode: "",
    stockStatus: "",
});

// 商品列表数据
const goodsList = ref([]);
const loading = ref(false);

// 分页参数
const pagination = reactive({
    pageNum: 1,
    pageSize: 10,
    total: 0,
});

// 选中的行
const selectedRows = ref([]);

// 统计信息
const statistics = computed(() => {
    let totalGoods = goodsList.value.length;
    let totalStock = 0;
    let totalStockValue = 0;
    let outOfStock = 0;
    let lowStock = 0;

    goodsList.value.forEach((item) => {
        const stock = item.stockQuantity || 0;
        const low = item.stockLow || 0;
        const cost = parseFloat(item.costPrice) || 0;

        totalStock += stock;
        totalStockValue += stock * cost;

        if (stock <= 0) {
            outOfStock++;
        } else if (stock < low) {
            lowStock++;
        }
    });

    return {
        totalGoods,
        totalStock,
        totalStockValue: totalStockValue.toFixed(2),
        outOfStock,
        lowStock,
    };
});

// 新增/编辑对话框
const goodsFormRef = ref();
const dialog = reactive({
    visible: false,
    title: "",
    isAdd: false,
    isView: false,
    loading: false,
    form: {
        id: null,
        skuCode: "",
        name: "",
        brand: "",
        spec: "",
        unit: "箱",
        barcode: "",
        purchasePrice: "",
        salePrice: "",
        costPrice: "",
        stockLow: "",
        stockHigh: "",
    },
    rules: {
        skuCode: [
            { required: true, message: "请输入SKU编码", trigger: "blur" },
            {
                min: 3,
                max: 50,
                message: "长度在 3 到 50 个字符",
                trigger: "blur",
            },
        ],
        name: [
            { required: true, message: "请输入商品名称", trigger: "blur" },
            {
                min: 2,
                max: 200,
                message: "长度在 2 到 200 个字符",
                trigger: "blur",
            },
        ],
        unit: [{ required: true, message: "请输入单位", trigger: "blur" }],
        purchasePrice: [
            { required: true, message: "请输入采购价", trigger: "blur" },
            {
                pattern: /^\d+(\.\d{1,2})?$/,
                message: "请输入正确的价格格式",
                trigger: "blur",
            },
        ],
        salePrice: [
            { required: true, message: "请输入售价", trigger: "blur" },
            {
                pattern: /^\d+(\.\d{1,2})?$/,
                message: "请输入正确的价格格式",
                trigger: "blur",
            },
        ],
    },
});

// 查看详情对话框
const viewDialog = reactive({
    visible: false,
    data: {},
});

// 库存流水对话框
const stockFlowDialog = reactive({
    visible: false,
    loading: false,
    data: [],
    currentSkuCode: "",
});

// 格式化价格
const formatPrice = (price) => {
    if (!price) return "0.00";
    return parseFloat(price).toFixed(2);
};

// 获取库存状态文本
const getStockStatusText = (row) => {
    const stock = row.stockQuantity || 0;
    const low = row.stockLow || 0;
    const high = row.stockHigh || 999999;

    if (stock <= 0) {
        return "缺货";
    } else if (stock < low) {
        return "库存不足";
    } else if (stock > high) {
        return "库存过剩";
    } else {
        return "库存正常";
    }
};

// 获取库存状态标签类型
const getStockStatusTagType = (row) => {
    const stock = row.stockQuantity || 0;
    const low = row.stockLow || 0;
    const high = row.stockHigh || 999999;

    if (stock <= 0) {
        return "danger";
    } else if (stock < low) {
        return "warning";
    } else if (stock > high) {
        return "info";
    } else {
        return "success";
    }
};

// 获取库存状态CSS类
const getStockStatusClass = (row) => {
    const stock = row.stockQuantity || 0;
    const low = row.stockLow || 0;
    const high = row.stockHigh || 999999;

    if (stock <= 0) {
        return "stock-out";
    } else if (stock < low) {
        return "stock-low";
    } else if (stock > high) {
        return "stock-high";
    } else {
        return "stock-normal";
    }
};

// 获取作业类型标签类型
const getOperationTypeTagType = (type) => {
    switch (type) {
        case "inbound":
            return "success";
        case "outbound":
            return "danger";
        case "transfer":
            return "warning";
        default:
            return "info";
    }
};

// 获取作业类型名称
const getOperationTypeName = (type) => {
    switch (type) {
        case "inbound":
            return "入库";
        case "outbound":
            return "出库";
        case "transfer":
            return "调拨";
        case "adjustment":
            return "盘点";
        default:
            return type;
    }
};

// 获取状态标签类型
const getStatusTagType = (status) => {
    switch (status) {
        case "pending":
            return "info";
        case "processing":
            return "warning";
        case "completed":
            return "success";
        case "cancelled":
            return "danger";
        default:
            return "info";
    }
};

// 获取状态文本
const getStatusText = (status) => {
    switch (status) {
        case "pending":
            return "待处理";
        case "processing":
            return "处理中";
        case "completed":
            return "已完成";
        case "cancelled":
            return "已取消";
        default:
            return status;
    }
};

// 获取商品列表
const getGoodsList = async () => {
    loading.value = true;
    try {
        // 构建查询参数，移除stockStatus（这是前端筛选条件）
        const { stockStatus, ...otherParams } = searchForm;
        const params = {
            pageNum: pagination.pageNum,
            pageSize: pagination.pageSize,
            ...otherParams,
        };

        const res = await request.get("/goods/list", { params });
        if (res.code === "200") {
            let data = res.data.records || res.data.list || [];
            const originalTotal = res.data.total || data.length;
            console.log(res.data);

            // 前端库存状态筛选
            if (stockStatus) {
                data = data.filter((item) => {
                    const stock = item.stockQuantity || 0;
                    const low = item.stockLow || 0;
                    const high = item.stockHigh || 999999;

                    switch (stockStatus) {
                        case "out_of_stock":
                            return stock <= 0;
                        case "low_stock":
                            return stock > 0 && stock < low;
                        case "normal":
                            return stock >= low && stock <= high;
                        case "high_stock":
                            return stock > high;
                        default:
                            return true;
                    }
                });
            }

            goodsList.value = data;
            // 如果进行了前端筛选，使用筛选后的数量作为分页总数
            // 否则使用后端返回的总数
            pagination.total = stockStatus ? data.length : originalTotal;
        } else {
            ElMessage.error(res.msg || "获取商品列表失败");
        }
    } catch (error) {
        ElMessage.error("获取商品列表失败");
    } finally {
        loading.value = false;
    }
};

// 获取库存流水
const getStockFlow = async (skuCode = null) => {
    try {
        const params = {
            pageNum: 1,
            pageSize: 100, // 获取最近100条记录
        };

        if (skuCode) {
            params.skuCode = skuCode;
        }

        const res = await request.get("/inventoryOperation/list", { params });
        if (res.code === "200") {
            return res.data.records || res.data.list || [];
        } else {
            ElMessage.error(res.msg || "获取库存流水失败");
            return [];
        }
    } catch (error) {
        ElMessage.error("获取库存流水失败");
        return [];
    }
};

// 显示库存流水
const showStockFlow = async () => {
    stockFlowDialog.loading = true;
    stockFlowDialog.visible = true;

    try {
        const flowData = await getStockFlow();
        stockFlowDialog.data = flowData;
    } finally {
        stockFlowDialog.loading = false;
    }
};

// 查看特定商品的库存流水
const handleViewStockFlow = async (row) => {
    stockFlowDialog.loading = true;
    stockFlowDialog.visible = true;
    stockFlowDialog.currentSkuCode = row.skuCode;

    try {
        const flowData = await getStockFlow(row.skuCode);
        stockFlowDialog.data = flowData;
    } finally {
        stockFlowDialog.loading = false;
    }
};

// 搜索
const handleSearch = () => {
    pagination.pageNum = 1;
    getGoodsList();
};

// 重置搜索
const resetSearch = () => {
    Object.keys(searchForm).forEach((key) => {
        searchForm[key] = "";
    });
    handleSearch();
};

// 分页改变
const handleSizeChange = (val) => {
    pagination.pageSize = val;
    getGoodsList();
};

const handleCurrentChange = (val) => {
    pagination.pageNum = val;
    getGoodsList();
};

// 表格选择变化
const handleSelectionChange = (val) => {
    selectedRows.value = val;
};

// 新增商品
const handleAdd = () => {
    dialog.title = "新增商品";
    dialog.isAdd = true;
    dialog.isView = false;
    dialog.form = {
        id: null,
        skuCode: "",
        name: "",
        brand: "",
        spec: "",
        unit: "箱",
        barcode: "",
        purchasePrice: "",
        salePrice: "",
        costPrice: "",
        stockLow: "",
        stockHigh: "",
    };
    dialog.visible = true;
};

// 编辑商品
const handleEdit = (row) => {
    dialog.title = "编辑商品";
    dialog.isAdd = false;
    dialog.isView = false;
    dialog.form = { ...row };
    dialog.visible = true;
};

// 查看商品
const handleView = (row) => {
    viewDialog.data = { ...row };
    viewDialog.visible = true;
};

// 提交商品
const submitGoods = async () => {
    if (!goodsFormRef.value) return;

    await goodsFormRef.value.validate(async (valid) => {
        if (valid) {
            dialog.loading = true;
            try {
                const submitData = { ...dialog.form };

                if (dialog.isAdd) {
                    const res = await request.post("/goods/add", submitData);
                    if (res.code === "200") {
                        ElMessage.success("新增商品成功");
                        dialog.visible = false;
                        getGoodsList();
                    } else {
                        ElMessage.error(res.msg || "新增商品失败");
                    }
                } else {
                    delete submitData.password;
                    delete submitData.confirmPassword;
                    const res = await request.post("/goods/update", submitData);
                    if (res.code === "200") {
                        ElMessage.success("更新商品成功");
                        dialog.visible = false;
                        getGoodsList();
                    } else {
                        ElMessage.error(res.msg || "更新商品失败");
                    }
                }
            } catch (error) {
                ElMessage.error("操作失败");
            } finally {
                dialog.loading = false;
            }
        }
    });
};

// 删除商品
const handleDelete = (row) => {
    ElMessageBox.confirm(`确定要删除商品"${row.name}"吗？`, "提示", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning",
    })
        .then(async () => {
            try {
                const res = await request.post(`/goods/delete`, row);
                if (res.code === "200") {
                    ElMessage.success("删除成功");
                    getGoodsList();
                } else {
                    ElMessage.error(res.msg || "删除失败");
                }
            } catch (error) {
                ElMessage.error("删除失败");
            }
        })
        .catch(() => {});
};

// 导出表格
const exportData = () => {
    ElMessage.info("导出功能待实现");
};

// 处理导入
const handleImport = (response) => {
    if (response.code === "200") {
        ElMessage.success("导入成功");
        getGoodsList();
    } else {
        ElMessage.error(response.msg || "导入失败");
    }
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

// 上传图片成功
const handleImageSuccess = (response) => {
    if (response.code === "200") {
        dialog.form.mainImage = response.data.url;
        ElMessage.success("上传成功");
    } else {
        ElMessage.error(response.msg || "上传失败");
    }
};

// 关闭对话框
const handleDialogClose = () => {
    if (goodsFormRef.value) {
        goodsFormRef.value.clearValidate();
    }
};

onMounted(() => {
    getGoodsList();
});
</script>

<style scoped>
.management {
    padding: 20px;
    background-color: #f5f7fa;
    min-height: 100vh;
}

.page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
}

.page-title {
    margin: 0;
    font-size: 24px;
    font-weight: 500;
    color: #303133;
}

.search-card {
    margin-bottom: 10px;
}

.search-form {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
}

.search-form .el-form-item {
    margin-bottom: 0;
    margin-right: 20px;
}

.table-card {
    position: relative;
}

.pagination-container {
    margin-top: 20px;
    display: flex;
    justify-content: flex-end;
}

.dialog-footer {
    display: flex;
    justify-content: flex-end;
    gap: 12px;
}

/* 响应式调整 */
@media (max-width: 768px) {
    .user-management {
        padding: 12px;
    }

    .search-form {
        flex-direction: column;
        align-items: stretch;
    }

    .search-form .el-form-item {
        margin-bottom: 12px;
        margin-right: 0;
    }

    .page-header {
        flex-direction: column;
        align-items: flex-start;
        gap: 12px;
    }

    :deep(.el-table) {
        overflow-x: auto;
    }
}

/* 表格样式优化 */
:deep(.el-table) {
    font-size: 14px;
}

:deep(.el-table th) {
    background-color: #f5f7fa;
    color: #606266;
    font-weight: 500;
}

:deep(.el-table .el-table__row) {
    transition: background-color 0.2s;
}

:deep(.el-table .el-table__row:hover) {
    background-color: #f5f7fa;
}

/* 设置表格行高 */
:deep(.el-table__row) {
    height: 60px;
}

/* 或者设置单元格内边距 */
:deep(.el-table__body td) {
    padding: 15px 0;
}

/* 或者设置单元格的高度 */
:deep(.el-table td),
:deep(.el-table th) {
    padding: 12px 0;
}

/* 头像样式 */
:deep(.el-avatar) {
    margin: 4px 0;
}

/* 标签样式 */
:deep(.el-tag) {
    font-weight: normal;
}

/* 按钮组样式 */
:deep(.el-button--link) {
    margin: 0 4px;
}

/* 库存状态样式 */
.stock-out {
    color: #f56c6c;
    font-weight: bold;
}

.stock-low {
    color: #e6a23c;
    font-weight: bold;
}

.stock-normal {
    color: #67c23a;
    font-weight: bold;
}

.stock-high {
    color: #409eff;
    font-weight: bold;
}

/* 统计卡片样式 */
.stat-card {
    margin-bottom: 0;
    border-radius: 8px;
    border: 1px solid #ebeef5;
}

.stat-content {
    display: flex;
    flex-direction: column;
}

.stat-title {
    font-size: 14px;
    color: #909399;
    margin-bottom: 8px;
}

.stat-value {
    font-size: 24px;
    font-weight: 600;
    color: #303133;
    margin-bottom: 8px;
}

.stat-trend {
    display: flex;
    align-items: center;
    font-size: 12px;
    color: #909399;
}

.stat-trend .el-icon {
    margin-right: 4px;
}

/* 响应式调整统计卡片 */
@media (max-width: 1200px) {
    .el-col-6 {
        width: 50%;
        margin-bottom: 20px;
    }
}

@media (max-width: 768px) {
    .el-col-6 {
        width: 100%;
    }
}
</style>
