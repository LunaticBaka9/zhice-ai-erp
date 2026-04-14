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
                        v-model="searchForm.goodsName"
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
            <el-form :inline="true" :model="searchForm" class="search-form" style="margin-top: 10px">
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
                <el-form-item label="预警类型">
                    <el-select
                        v-model="searchForm.alertType"
                        placeholder="请选择预警类型"
                        clearable
                        @change="handleSearch"
                        style="width: 120px"
                    >
                        <el-option label="全部" value="" />
                        <el-option label="缺货预警" value="out_of_stock" />
                        <el-option label="库存不足" value="low_stock" />
                        <el-option label="库存过多" value="high_stock" />
                        <el-option label="即将到期" value="expiring_soon" />
                    </el-select>
                </el-form-item>
                <el-form-item label="预警级别">
                    <el-select
                        v-model="searchForm.alertLevel"
                        placeholder="请选择预警级别"
                        clearable
                        @change="handleSearch"
                        style="width: 120px"
                    >
                        <el-option label="全部" value="" />
                        <el-option label="高" value="high" />
                        <el-option label="中" value="medium" />
                        <el-option label="低" value="low" />
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
            <el-button type="primary" @click="refreshAlerts">
                <el-icon><Refresh /></el-icon>
                刷新预警
            </el-button>
            <el-button type="success" @click="exportAlerts">
                <el-icon><Download /></el-icon>
                导出预警
            </el-button>
            <el-button type="info" @click="showSettings">
                <el-icon><Setting /></el-icon>
                预警设置
            </el-button>
        </div>

        <!-- 预警统计卡片 -->
        <el-row :gutter="20" style="margin-bottom: 20px">
            <el-col :span="6">
                <el-card shadow="hover" class="stat-card">
                    <div class="stat-content">
                        <div class="stat-title">缺货预警</div>
                        <div class="stat-value" style="color: #f56c6c">
                            {{ statistics.outOfStock }}
                        </div>
                        <div class="stat-trend">
                            <el-icon color="#F56C6C"><Warning /></el-icon>
                            <span>库存为0的商品</span>
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
            <el-col :span="6">
                <el-card shadow="hover" class="stat-card">
                    <div class="stat-content">
                        <div class="stat-title">库存过多</div>
                        <div class="stat-value" style="color: #409eff">
                            {{ statistics.highStock }}
                        </div>
                        <div class="stat-trend">
                            <el-icon color="#409EFF"><InfoFilled /></el-icon>
                            <span>超过预警上限</span>
                        </div>
                    </div>
                </el-card>
            </el-col>
            <el-col :span="6">
                <el-card shadow="hover" class="stat-card">
                    <div class="stat-content">
                        <div class="stat-title">总计预警</div>
                        <div class="stat-value">
                            {{ statistics.totalAlerts }}
                        </div>
                        <div class="stat-trend">
                            <el-icon color="#67C23A"><Bell /></el-icon>
                            <span>需要处理</span>
                        </div>
                    </div>
                </el-card>
            </el-col>
        </el-row>

        <!-- 预警商品表格 -->
        <el-card class="table-card" shadow="never">
            <el-table :data="alertList" v-loading="loading" stripe border style="width: 100%">
                <el-table-column prop="skuCode" label="SKU编码" width="150" />
                <el-table-column prop="goodsName" label="商品名称" width="180" />
                <el-table-column prop="brand" label="品牌" width="120" />
                <el-table-column prop="spec" label="规格型号" width="150" />
                <el-table-column prop="unit" label="单位" width="80" />
                <el-table-column prop="stockQuantity" label="当前库存" width="100">
                    <template #default="{ row }">
                        <span :class="getStockStatusClass(row)">{{ row.stockQuantity || 0 }}</span>
                    </template>
                </el-table-column>
                <el-table-column prop="stockLow" label="预警下限" width="100" />
                <el-table-column prop="stockHigh" label="预警上限" width="100" />
                <el-table-column prop="alertType" label="预警类型" width="120">
                    <template #default="{ row }">
                        <el-tag :type="getAlertTypeTagType(row.alertType)" size="small">
                            {{ getAlertTypeText(row.alertType) }}
                        </el-tag>
                    </template>
                </el-table-column>
                <el-table-column prop="alertLevel" label="预警级别" width="100">
                    <template #default="{ row }">
                        <el-tag :type="getAlertLevelTagType(row.alertLevel)" size="small">
                            {{ getAlertLevelText(row.alertLevel) }}
                        </el-tag>
                    </template>
                </el-table-column>
                <el-table-column prop="lastUpdated" label="最后更新" width="150">
                    <template #default="{ row }">
                        {{ formatDateTime(row.lastUpdated) }}
                    </template>
                </el-table-column>
                <el-table-column prop="daysToExpiry" label="到期天数" width="100">
                    <template #default="{ row }">
                        <span v-if="row.daysToExpiry !== undefined && row.daysToExpiry !== null">
                            {{ row.daysToExpiry }}
                            <el-tag v-if="row.daysToExpiry <= 7" type="danger" size="small" style="margin-left: 5px"
                                >紧急</el-tag
                            >
                            <el-tag
                                v-else-if="row.daysToExpiry <= 30"
                                type="warning"
                                size="small"
                                style="margin-left: 5px"
                                >提醒</el-tag
                            >
                        </span>
                        <span v-else>-</span>
                    </template>
                </el-table-column>
                <el-table-column label="操作" width="200" fixed="right">
                    <template #default="{ row }">
                        <el-button link type="primary" size="small" @click="handleView(row)">
                            <el-icon><View /></el-icon>
                            查看
                        </el-button>
                        <el-button link type="success" size="small" @click="handleReplenish(row)">
                            <el-icon><ShoppingCart /></el-icon>
                            补货
                        </el-button>
                        <el-button link type="warning" size="small" @click="handleAdjust(row)">
                            <el-icon><Edit /></el-icon>
                            调整
                        </el-button>
                        <el-button link type="info" size="small" @click="handleAcknowledge(row)">
                            <el-icon><Check /></el-icon>
                            确认
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

        <!-- 查看商品详情对话框 -->
        <el-dialog v-model="viewDialog.visible" title="商品详情" width="600px">
            <el-descriptions :column="1" border>
                <el-descriptions-item label="SKU编码">{{ viewDialog.data.skuCode }}</el-descriptions-item>
                <el-descriptions-item label="商品名称">{{ viewDialog.data.name }}</el-descriptions-item>
                <el-descriptions-item label="品牌">{{ viewDialog.data.brand }}</el-descriptions-item>
                <el-descriptions-item label="规格型号">{{ viewDialog.data.spec }}</el-descriptions-item>
                <el-descriptions-item label="单位">{{ viewDialog.data.unit }}</el-descriptions-item>
                <el-descriptions-item label="条码">{{ viewDialog.data.barcode }}</el-descriptions-item>
                <el-descriptions-item label="采购价">
                    ¥{{ formatPrice(viewDialog.data.purchasePrice) }}
                </el-descriptions-item>
                <el-descriptions-item label="售价">
                    ¥{{ formatPrice(viewDialog.data.salePrice) }}
                </el-descriptions-item>
                <el-descriptions-item label="成本价">
                    ¥{{ formatPrice(viewDialog.data.costPrice) }}
                </el-descriptions-item>
                <el-descriptions-item label="库存预警下限">{{ viewDialog.data.stockLow }}</el-descriptions-item>
                <el-descriptions-item label="库存预警上限">{{ viewDialog.data.stockHigh }}</el-descriptions-item>
                <el-descriptions-item label="当前库存">{{ viewDialog.data.stockQuantity || 0 }}</el-descriptions-item>
                <el-descriptions-item label="预警类型">
                    <el-tag :type="getAlertTypeTagType(viewDialog.data.alertType)">
                        {{ getAlertTypeText(viewDialog.data.alertType) }}
                    </el-tag>
                </el-descriptions-item>
                <el-descriptions-item label="预警级别">
                    <el-tag :type="getAlertLevelTagType(viewDialog.data.alertLevel)">
                        {{ getAlertLevelText(viewDialog.data.alertLevel) }}
                    </el-tag>
                </el-descriptions-item>
                <el-descriptions-item label="创建时间">{{
                    formatDateTime(viewDialog.data.createTime)
                }}</el-descriptions-item>
                <el-descriptions-item label="更新时间">{{
                    formatDateTime(viewDialog.data.updateTime)
                }}</el-descriptions-item>
            </el-descriptions>
        </el-dialog>

        <!-- 预警设置对话框 -->
        <el-dialog v-model="settingsDialog.visible" title="预警设置" width="600px">
            <el-form :model="settingsDialog.form" label-width="120px">
                <el-form-item label="预警下限系数">
                    <el-slider
                        v-model="settingsDialog.form.lowThresholdFactor"
                        :min="0.5"
                        :max="2"
                        :step="0.1"
                        show-input
                    />
                    <div class="setting-description">库存下限倍数，用于动态计算预警阈值</div>
                </el-form-item>
                <el-form-item label="预警上限系数">
                    <el-slider
                        v-model="settingsDialog.form.highThresholdFactor"
                        :min="1"
                        :max="5"
                        :step="0.1"
                        show-input
                    />
                    <div class="setting-description">库存上限倍数，用于动态计算预警阈值</div>
                </el-form-item>
                <el-form-item label="预警通知方式">
                    <el-checkbox-group v-model="settingsDialog.form.notificationMethods">
                        <el-checkbox label="email">邮件通知</el-checkbox>
                        <el-checkbox label="sms">短信通知</el-checkbox>
                        <el-checkbox label="wechat">微信通知</el-checkbox>
                        <el-checkbox label="dashboard">系统消息</el-checkbox>
                    </el-checkbox-group>
                </el-form-item>
                <el-form-item label="预警频率">
                    <el-radio-group v-model="settingsDialog.form.checkFrequency">
                        <el-radio label="realtime">实时</el-radio>
                        <el-radio label="hourly">每小时</el-radio>
                        <el-radio label="daily">每天</el-radio>
                        <el-radio label="weekly">每周</el-radio>
                    </el-radio-group>
                </el-form-item>
                <el-form-item label="到期预警天数">
                    <el-input-number
                        v-model="settingsDialog.form.expiryDays"
                        :min="1"
                        :max="365"
                        controls-position="right"
                    />
                    <div class="setting-description">商品到期前多少天开始预警</div>
                </el-form-item>
            </el-form>
            <template #footer>
                <span class="dialog-footer">
                    <el-button @click="settingsDialog.visible = false">取消</el-button>
                    <el-button type="primary" @click="saveSettings">保存设置</el-button>
                </span>
            </template>
        </el-dialog>

        <!-- 补货对话框 -->
        <el-dialog v-model="replenishDialog.visible" title="补货申请" width="500px">
            <el-form :model="replenishDialog.form" label-width="100px">
                <el-form-item label="商品名称">
                    <span>{{ replenishDialog.form.name }}</span>
                </el-form-item>
                <el-form-item label="SKU编码">
                    <span>{{ replenishDialog.form.skuCode }}</span>
                </el-form-item>
                <el-form-item label="当前库存">
                    <span>{{ replenishDialog.form.stockQuantity || 0 }}</span>
                </el-form-item>
                <el-form-item label="建议补货数量">
                    <el-input-number
                        v-model="replenishDialog.form.suggestedQty"
                        :min="1"
                        :max="999999"
                        controls-position="right"
                    />
                </el-form-item>
                <el-form-item label="实际补货数量">
                    <el-input-number
                        v-model="replenishDialog.form.actualQty"
                        :min="1"
                        :max="999999"
                        controls-position="right"
                    />
                </el-form-item>
                <el-form-item label="备注">
                    <el-input
                        v-model="replenishDialog.form.remarks"
                        type="textarea"
                        :rows="3"
                        placeholder="请输入备注信息"
                    />
                </el-form-item>
            </el-form>
            <template #footer>
                <span class="dialog-footer">
                    <el-button @click="replenishDialog.visible = false">取消</el-button>
                    <el-button type="primary" @click="submitReplenishment">提交补货</el-button>
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
    InfoFilled,
    Bell,
    ShoppingCart,
    Check,
    Setting,
    Download,
} from "@element-plus/icons-vue";
import request from "../../utils/request.js";
import { formatDateTime } from "../../utils/date.js";

// 搜索表单
const searchForm = reactive({
    skuCode: "",
    name: "",
    brand: "",
    categoryId: "",
    alertType: "",
    alertLevel: "",
});

// 预警商品列表数据
const alertList = ref([]);
const loading = ref(false);

// 分页参数
const pagination = reactive({
    pageNum: 1,
    pageSize: 10,
    total: 0,
});

// 统计信息
const statistics = computed(() => {
    let outOfStock = 0;
    let lowStock = 0;
    let highStock = 0;

    alertList.value.forEach((item) => {
        const stock = item.stockQuantity || 0;
        const low = item.stockLow || 0;
        const high = item.stockHigh || 999999;

        if (stock <= 0) {
            outOfStock++;
        } else if (stock < low) {
            lowStock++;
        } else if (stock > high) {
            highStock++;
        }
    });

    return {
        outOfStock,
        lowStock,
        highStock,
        totalAlerts: outOfStock + lowStock + highStock,
    };
});

// 查看详情对话框
const viewDialog = reactive({
    visible: false,
    data: {},
});

// 预警设置对话框
const settingsDialog = reactive({
    visible: false,
    form: {
        lowThresholdFactor: 1.0,
        highThresholdFactor: 2.0,
        notificationMethods: ["dashboard"],
        checkFrequency: "hourly",
        expiryDays: 7,
    },
});

// 补货对话框
const replenishDialog = reactive({
    visible: false,
    form: {
        id: null,
        name: "",
        skuCode: "",
        stockQuantity: 0,
        suggestedQty: 10,
        actualQty: 10,
        remarks: "",
    },
});

// 格式化价格
const formatPrice = (price) => {
    if (!price) return "0.00";
    return parseFloat(price).toFixed(2);
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

// 获取预警类型标签类型
const getAlertTypeTagType = (type) => {
    switch (type) {
        case "out_of_stock":
            return "danger";
        case "low_stock":
            return "warning";
        case "high_stock":
            return "info";
        case "expiring_soon":
            return "danger";
        default:
            return "info";
    }
};

// 获取预警类型文本
const getAlertTypeText = (type) => {
    switch (type) {
        case "out_of_stock":
            return "缺货预警";
        case "low_stock":
            return "库存不足";
        case "high_stock":
            return "库存过多";
        case "expiring_soon":
            return "即将到期";
        default:
            return type;
    }
};

// 获取预警级别标签类型
const getAlertLevelTagType = (level) => {
    switch (level) {
        case "high":
            return "danger";
        case "medium":
            return "warning";
        case "low":
            return "info";
        default:
            return "info";
    }
};

// 获取预警级别文本
const getAlertLevelText = (level) => {
    switch (level) {
        case "high":
            return "高";
        case "medium":
            return "中";
        case "low":
            return "低";
        default:
            return level;
    }
};

// 获取预警商品列表
const getAlertList = async () => {
    loading.value = true;
    try {
        // 构建查询参数
        const params = {
            pageNum: pagination.pageNum,
            pageSize: pagination.pageSize,
            ...searchForm,
        };

        const res = await request.get("/inventoryAlert/list", { params });
        if (res.code === "200") {
            const data = res.data.records || res.data.list || [];
            const originalTotal = res.data.total || data.length;
            console.log(res.data);

            // 计算额外的预警信息
            const enhancedData = data.map((item) => ({
                ...item,
                alertType: calculateAlertType(item),
                alertLevel: calculateAlertLevel(item),
                lastUpdated: item.updateTime || item.createTime,
                daysToExpiry: calculateDaysToExpiry(item),
            }));

            alertList.value = enhancedData;
            pagination.total = originalTotal;
        } else {
            ElMessage.error(res.msg || "获取预警列表失败");
        }
    } catch (error) {
        console.error("获取预警列表失败:", error);
        ElMessage.error("获取预警列表失败");
    } finally {
        loading.value = false;
    }
};

// 计算预警类型
const calculateAlertType = (item) => {
    const stock = item.stockQuantity || 0;
    const low = item.stockLow || 0;
    const high = item.stockHigh || 999999;

    if (stock <= 0) {
        return "out_of_stock";
    } else if (stock < low) {
        return "low_stock";
    } else if (stock > high) {
        return "high_stock";
    } else if (calculateDaysToExpiry(item) <= 7) {
        return "expiring_soon";
    }
    return null; // 正常情况，无预警
};

// 计算预警级别
const calculateAlertLevel = (item) => {
    const stock = item.stockQuantity || 0;
    const low = item.stockLow || 0;
    const high = item.stockHigh || 999999;

    if (stock <= 0) {
        return "high"; // 缺货是最高级别的预警
    } else if (stock < low * 0.5) {
        return "high"; // 库存远低于下限
    } else if (stock < low) {
        return "medium"; // 库存低于下限
    } else if (stock > high * 1.5) {
        return "high"; // 库存远高于上限
    } else if (stock > high) {
        return "medium"; // 库存高于上限
    } else if (calculateDaysToExpiry(item) <= 7) {
        return "high"; // 即将到期
    } else if (calculateDaysToExpiry(item) <= 30) {
        return "medium"; // 即将到期
    }
    return "low"; // 低风险
};

// 计算到期天数
const calculateDaysToExpiry = (item) => {
    // 这里假设商品对象中有批次信息和有效期字段
    // 在实际应用中，这可能需要从批次管理或其他地方获取
    if (item.batchNumber && item.expiryDate) {
        const expiryDate = new Date(item.expiryDate);
        const today = new Date();
        const diffTime = expiryDate - today;
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
        return diffDays;
    }
    return null;
};

// 搜索
const handleSearch = () => {
    pagination.pageNum = 1;
    getAlertList();
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
    getAlertList();
};

const handleCurrentChange = (val) => {
    pagination.pageNum = val;
    getAlertList();
};

// 刷新预警
const refreshAlerts = () => {
    ElMessage.success("预警刷新成功");
    getAlertList();
};

// 导出预警
const exportAlerts = () => {
    ElMessage.info("导出功能待实现");
};

// 显示设置
const showSettings = () => {
    settingsDialog.visible = true;
};

// 保存设置
const saveSettings = () => {
    ElMessage.success("预警设置保存成功");
    settingsDialog.visible = false;
};

// 查看商品
const handleView = (row) => {
    viewDialog.data = { ...row };
    viewDialog.visible = true;
};

// 补货处理
const handleReplenish = (row) => {
    replenishDialog.form = {
        id: row.id,
        name: row.name,
        skuCode: row.skuCode,
        stockQuantity: row.stockQuantity || 0,
        suggestedQty: Math.max(10, row.stockLow - (row.stockQuantity || 0)), // 建议补到安全库存
        actualQty: Math.max(10, row.stockLow - (row.stockQuantity || 0)),
        remarks: `针对${row.name}(${row.skuCode})的补货申请`,
    };
    replenishDialog.visible = true;
};

// 提交补货
const submitReplenishment = async () => {
    try {
        // 这里应该调用后端的补货接口
        const res = await request.post("/inventory/replenish", {
            ...replenishDialog.form,
            operationType: "inbound",
            reason: "inventory_alert",
        });

        if (res.code === "200") {
            ElMessage.success("补货申请提交成功");
            replenishDialog.visible = false;
            // 重新加载数据
            getAlertList();
        } else {
            ElMessage.error(res.msg || "补货申请提交失败");
        }
    } catch (error) {
        ElMessage.error("补货申请提交失败");
    }
};

// 调整库存
const handleAdjust = (row) => {
    ElMessageBox.confirm(`确定要手动调整 "${row.name}" 的库存预警参数吗？`, "提示", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning",
    }).then(() => {
        // 这里可以跳转到编辑页面或打开编辑对话框
        ElMessage.info("调整功能待实现");
    });
};

// 确认预警
const handleAcknowledge = (row) => {
    ElMessageBox.confirm(`确定要确认处理 "${row.name}" 的预警吗？`, "提示", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "info",
    }).then(async () => {
        try {
            const res = await request.post(`/inventoryAlert/acknowledge/${row.id}`);
            if (res.code === "200") {
                ElMessage.success("预警已确认");
                getAlertList(); // 重新加载列表
            } else {
                ElMessage.error(res.msg || "确认失败");
            }
        } catch (error) {
            ElMessage.error("确认失败");
        }
    });
};

onMounted(() => {
    getAlertList();
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

/* 设置描述文本样式 */
.setting-description {
    font-size: 12px;
    color: #909399;
    margin-top: 5px;
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
