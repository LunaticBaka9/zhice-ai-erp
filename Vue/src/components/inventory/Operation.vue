<template>
    <div class="warehouse-operation">
        <!-- 操作按钮区域 -->
        <el-card class="operation-card" shadow="never">
            <el-button type="primary" @click="handleInbound">
                <el-icon><Plus /></el-icon>
                入库作业
            </el-button>
            <el-button type="danger" @click="handleOutbound">
                <el-icon><Minus /></el-icon>
                出库作业
            </el-button>
            <el-button type="warning" @click="handleTransfer">
                <el-icon><Switch /></el-icon>
                库存调拨
            </el-button>
            <el-button type="info" @click="handleAdjustment">
                <el-icon><Document /></el-icon>
                库存盘点
            </el-button>
        </el-card>

        <!-- 搜索栏 -->
        <el-card class="search-card" shadow="never">
            <el-form :inline="true" :model="searchForm" class="search-form">
                <el-form-item label="作业单号">
                    <el-input
                        v-model="searchForm.operationNo"
                        placeholder="请输入作业单号"
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
                <el-form-item label="源仓库">
                    <el-select
                        v-model="searchForm.fromWarehouseId"
                        placeholder="请选择源仓库"
                        clearable
                        @change="handleSearch"
                        style="width: 120px"
                    >
                        <el-option label="全部" value="" />
                        <el-option label="一号仓库" value="1" />
                        <el-option label="二号仓库" value="2" />
                        <el-option label="三号仓库" value="3" />
                        <el-option label="四号仓库" value="4" />
                    </el-select>
                </el-form-item>
                <el-form-item label="目标仓库">
                    <el-select
                        v-model="searchForm.toWarehouseId"
                        placeholder="请选择目标仓库"
                        clearable
                        @change="handleSearch"
                        style="width: 120px"
                    >
                        <el-option label="全部" value="" />
                        <el-option label="一号仓库" value="1" />
                        <el-option label="二号仓库" value="2" />
                        <el-option label="三号仓库" value="3" />
                        <el-option label="四号仓库" value="4" />
                    </el-select>
                </el-form-item>
                <el-form-item label="作业类型">
                    <el-select
                        v-model="searchForm.operationType"
                        placeholder="请选择作业类型"
                        clearable
                        @change="handleSearch"
                        style="width: 120px"
                    >
                        <el-option label="全部" value="" />
                        <el-option label="入库" value="inbound" />
                        <el-option label="出库" value="outbound" />
                        <el-option label="调拨" value="transfer" />
                        <el-option label="盘点" value="adjustment" />
                    </el-select>
                </el-form-item>
                <el-form-item label="状态">
                    <el-select
                        v-model="searchForm.status"
                        placeholder="请选择状态"
                        clearable
                        @change="handleSearch"
                        style="width: 120px"
                    >
                        <el-option label="全部" value="" />
                        <el-option label="待处理" value="pending" />
                        <el-option label="已完成" value="completed" />
                        <el-option label="已取消" value="cancelled" />
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

        <!-- 作业统计卡片 -->
        <el-row :gutter="20" style="margin-bottom: 20px">
            <el-col :span="6">
                <el-card shadow="hover" class="stat-card">
                    <div class="stat-content">
                        <div class="stat-title">今日入库</div>
                        <div class="stat-value">
                            {{ statistics.todayInbound }}
                        </div>
                        <div class="stat-trend">
                            <el-icon color="#67C23A"><TrendCharts /></el-icon>
                            <span>数量: {{ statistics.todayInboundQty }}</span>
                        </div>
                    </div>
                </el-card>
            </el-col>
            <el-col :span="6">
                <el-card shadow="hover" class="stat-card">
                    <div class="stat-content">
                        <div class="stat-title">今日出库</div>
                        <div class="stat-value">
                            {{ statistics.todayOutbound }}
                        </div>
                        <div class="stat-trend">
                            <el-icon color="#F56C6C"><Box /></el-icon>
                            <span>数量: {{ statistics.todayOutboundQty }}</span>
                        </div>
                    </div>
                </el-card>
            </el-col>
            <el-col :span="6">
                <el-card shadow="hover" class="stat-card">
                    <div class="stat-content">
                        <div class="stat-title">待处理单据</div>
                        <div class="stat-value" style="color: #e6a23c">
                            {{ statistics.pendingOrders }}
                        </div>
                        <div class="stat-trend">
                            <el-icon color="#E6A23C"><Warning /></el-icon>
                            <span>请及时处理</span>
                        </div>
                    </div>
                </el-card>
            </el-col>
            <el-col :span="6">
                <el-card shadow="hover" class="stat-card">
                    <div class="stat-content">
                        <div class="stat-title">本月作业</div>
                        <div class="stat-value" style="color: #409eff">
                            {{ statistics.monthlyOperations }}
                        </div>
                        <div class="stat-trend">
                            <el-icon color="#409EFF"><Document /></el-icon>
                            <span>累计作业次数</span>
                        </div>
                    </div>
                </el-card>
            </el-col>
        </el-row>

        <!-- 作业记录表格 -->
        <el-card class="table-card" shadow="never">
            <el-table
                :data="operationList"
                v-loading="loading"
                stripe
                border
                style="width: 100%"
                @selection-change="handleSelectionChange"
            >
                <el-table-column type="selection" width="55" />
                <el-table-column
                    prop="operationNo"
                    label="作业单号"
                    width="180"
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
                            {{ getOperationTypeText(row.operationType) }}
                        </el-tag>
                    </template>
                </el-table-column>
                <el-table-column
                    prop="goodsName"
                    label="商品名称"
                    width="150"
                />
                <el-table-column prop="skuCode" label="SKU编码" width="120" />
                <el-table-column
                    prop="fromWarehouseName"
                    label="源仓库"
                    width="100"
                />
                <el-table-column
                    prop="toWarehouseName"
                    label="目标仓库"
                    width="100"
                />
                <el-table-column prop="quantity" label="数量" width="80" />
                <el-table-column prop="operator" label="操作员" width="100" />
                <el-table-column prop="status" label="状态" width="100">
                    <template #default="{ row }">
                        <el-tag :type="getStatusTagType(row.status)">
                            {{ getStatusText(row.status) }}
                        </el-tag>
                    </template>
                </el-table-column>
                <el-table-column prop="remark" label="备注" width="150" />
                <el-table-column prop="createTime" label="创建时间" width="150">
                    <template #default="{ row }">
                        {{ formatDateTime(row.createTime) }}
                    </template>
                </el-table-column>
                <el-table-column prop="updateTime" label="更新时间" width="150">
                    <template #default="{ row }">
                        {{ formatDateTime(row.updateTime) }}
                    </template>
                </el-table-column>
                <el-table-column label="操作" width="200" fixed="right">
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
                            :disabled="row.status !== 'pending'"
                        >
                            <el-icon><Edit /></el-icon>
                            编辑
                        </el-button>
                        <el-button
                            link
                            type="success"
                            size="small"
                            @click="handleComplete(row)"
                            :disabled="row.status === 'completed'"
                        >
                            <el-icon><Check /></el-icon>
                            完成
                        </el-button>
                        <el-button
                            link
                            type="danger"
                            size="small"
                            @click="handleCancel(row)"
                            :disabled="
                                row.status === 'completed' ||
                                row.status === 'cancelled'
                            "
                        >
                            <el-icon><CircleClose /></el-icon>
                            取消
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

        <!-- 新增/编辑作业对话框 -->
        <el-dialog
            v-model="dialog.visible"
            :title="dialog.title"
            width="800px"
            :close-on-click-modal="false"
            @close="handleDialogClose"
        >
            <el-form
                ref="operationFormRef"
                :model="dialog.form"
                :rules="dialog.rules"
                label-width="120px"
                status-icon
            >
                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="作业单号" prop="operationNo">
                            <el-input
                                v-model="dialog.form.operationNo"
                                placeholder="系统自动生成"
                                :disabled="true"
                            />
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="作业类型" prop="operationType">
                            <el-select
                                v-model="dialog.form.operationType"
                                placeholder="请选择作业类型"
                                :disabled="dialog.isView"
                                @change="handleOperationTypeChange"
                            >
                                <el-option label="入库" value="inbound" />
                                <el-option label="出库" value="outbound" />
                                <el-option label="调拨" value="transfer" />
                                <el-option label="盘点" value="adjustment" />
                            </el-select>
                        </el-form-item>
                    </el-col>
                </el-row>

                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="源仓库" prop="fromWarehouseId">
                            <el-select
                                v-model="dialog.form.fromWarehouseId"
                                placeholder="请选择源仓库"
                                :disabled="
                                    dialog.isView ||
                                    dialog.form.operationType === 'inbound'
                                "
                            >
                                <el-option label="一号仓库" value="1" />
                                <el-option label="二号仓库" value="2" />
                                <el-option label="三号仓库" value="3" />
                                <el-option label="四号仓库" value="4" />
                            </el-select>
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="目标仓库" prop="toWarehouseId">
                            <el-select
                                v-model="dialog.form.toWarehouseId"
                                placeholder="请选择目标仓库"
                                :disabled="
                                    dialog.isView ||
                                    dialog.form.operationType === 'outbound'
                                "
                            >
                                <el-option label="一号仓库" value="1" />
                                <el-option label="二号仓库" value="2" />
                                <el-option label="三号仓库" value="3" />
                                <el-option label="四号仓库" value="4" />
                            </el-select>
                        </el-form-item>
                    </el-col>
                </el-row>

                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="商品" prop="goodsId">
                            <el-select
                                v-model="dialog.form.goodsId"
                                placeholder="请选择商品"
                                :disabled="dialog.isView"
                                @change="handleGoodsChange"
                                filterable
                            >
                                <el-option
                                    v-for="item in goodsOptions"
                                    :key="item.id"
                                    :label="`${item.name} (${item.skuCode})`"
                                    :value="item.id"
                                />
                            </el-select>
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="数量" prop="quantity">
                            <el-input-number
                                v-model="dialog.form.quantity"
                                :min="1"
                                :precision="0"
                                placeholder="请输入数量"
                                :disabled="dialog.isView"
                                style="width: 100%"
                            />
                        </el-form-item>
                    </el-col>
                </el-row>

                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="操作员" prop="operator">
                            <el-input
                                v-model="dialog.form.operator"
                                placeholder="请输入操作员姓名"
                                :disabled="dialog.isView"
                            />
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="状态" prop="status">
                            <el-select
                                v-model="dialog.form.status"
                                placeholder="请选择状态"
                                :disabled="dialog.isView"
                            >
                                <el-option label="待处理" value="pending" />
                                <el-option label="已完成" value="completed" />
                                <el-option label="已取消" value="cancelled" />
                            </el-select>
                        </el-form-item>
                    </el-col>
                </el-row>

                <el-form-item label="备注">
                    <el-input
                        v-model="dialog.form.remark"
                        type="textarea"
                        :rows="3"
                        placeholder="请输入备注信息"
                        :disabled="dialog.isView"
                    />
                </el-form-item>
            </el-form>

            <template #footer>
                <span class="dialog-footer">
                    <el-button @click="dialog.visible = false">取消</el-button>
                    <el-button
                        v-if="!dialog.isView"
                        type="primary"
                        @click="submitOperation"
                        :loading="dialog.loading"
                    >
                        确认
                    </el-button>
                </span>
            </template>
        </el-dialog>

        <!-- 查看作业详情对话框 -->
        <el-dialog v-model="viewDialog.visible" title="作业详情" width="700px">
            <el-descriptions :column="1" border>
                <el-descriptions-item label="作业单号">
                    {{ viewDialog.data.operationNo }}
                </el-descriptions-item>
                <el-descriptions-item label="作业类型">
                    <el-tag
                        :type="
                            getOperationTypeTagType(
                                viewDialog.data.operationType,
                            )
                        "
                    >
                        {{
                            getOperationTypeText(viewDialog.data.operationType)
                        }}
                    </el-tag>
                </el-descriptions-item>
                <el-descriptions-item label="源仓库">
                    {{ viewDialog.data.fromWarehouseName || "未设置" }}
                </el-descriptions-item>
                <el-descriptions-item label="目标仓库">
                    {{ viewDialog.data.toWarehouseName || "未设置" }}
                </el-descriptions-item>
                <el-descriptions-item label="商品名称">
                    {{ viewDialog.data.goodsName }}
                </el-descriptions-item>
                <el-descriptions-item label="SKU编码">
                    {{ viewDialog.data.skuCode }}
                </el-descriptions-item>
                <el-descriptions-item label="数量">
                    {{ viewDialog.data.quantity }}
                </el-descriptions-item>
                <el-descriptions-item label="操作员">
                    {{ viewDialog.data.operator }}
                </el-descriptions-item>
                <el-descriptions-item label="状态">
                    <el-tag :type="getStatusTagType(viewDialog.data.status)">
                        {{ getStatusText(viewDialog.data.status) }}
                    </el-tag>
                </el-descriptions-item>
                <el-descriptions-item label="备注">
                    {{ viewDialog.data.remark || "无" }}
                </el-descriptions-item>
                <el-descriptions-item label="创建时间">
                    {{ formatDateTime(viewDialog.data.createTime) }}
                </el-descriptions-item>
                <el-descriptions-item label="更新时间">
                    {{ formatDateTime(viewDialog.data.updateTime) }}
                </el-descriptions-item>
            </el-descriptions>
        </el-dialog>
    </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import {
    Plus,
    Minus,
    Switch,
    Document,
    Search,
    Refresh,
    View,
    Edit,
    Check,
    CircleClose,
    TrendCharts,
    Box,
    Warning,
    WarningFilled,
} from "@element-plus/icons-vue";
import request from "../../utils/request.js";
import { formatDateTime } from "../../utils/date.js";

// 搜索表单
const searchForm = reactive({
    operationNo: "",
    goodsName: "",
    fromWarehouseId: "",
    toWarehouseId: "",
    operationType: "",
    status: "",
});

// 作业记录列表数据
const operationList = ref([]);
const loading = ref(false);

// 分页参数
const pagination = reactive({
    pageNum: 1,
    pageSize: 10,
    total: 0,
});

// 选中的行
const selectedRows = ref([]);

// 商品选项
const goodsOptions = ref([
    { id: 1, name: "苹果", skuCode: "APL001", category: "水果" },
    { id: 2, name: "香蕉", skuCode: "BAN001", category: "水果" },
    { id: 3, name: "橙子", skuCode: "ORA001", category: "水果" },
    { id: 4, name: "西红柿", skuCode: "TOM001", category: "蔬菜" },
    { id: 5, name: "黄瓜", skuCode: "CUC001", category: "蔬菜" },
]);

// 统计信息
const statistics = computed(() => {
    let todayInbound = 0;
    let todayOutbound = 0;
    let pendingOrders = 0;
    let monthlyOperations = 0;
    let todayInboundQty = 0;
    let todayOutboundQty = 0;

    const today = new Date().toISOString().split("T")[0];

    operationList.value.forEach((item) => {
        // 假设数据中有日期字段，这里简化处理
        const itemDate = item.createTime?.substring(0, 10);

        if (itemDate === today) {
            if (item.operationType === "inbound") {
                todayInbound++;
                todayInboundQty += item.quantity || 0;
            } else if (item.operationType === "outbound") {
                todayOutbound++;
                todayOutboundQty += item.quantity || 0;
            }
        }

        if (item.status === "pending") {
            pendingOrders++;
        }

        monthlyOperations++; // 简化处理，实际应根据月份过滤
    });

    return {
        todayInbound,
        todayOutbound,
        pendingOrders,
        monthlyOperations,
        todayInboundQty,
        todayOutboundQty,
    };
});

// 新增/编辑对话框
const operationFormRef = ref();
const dialog = reactive({
    visible: false,
    title: "",
    isAdd: false,
    isView: false,
    loading: false,
    form: {
        id: null,
        operationNo: "",
        operationType: "",
        fromWarehouseId: "",
        toWarehouseId: "",
        goodsId: "",
        quantity: 1,
        operator: "",
        status: "pending",
        remark: "",
    },
    rules: {
        operationType: [
            { required: true, message: "请选择作业类型", trigger: "change" },
        ],
        goodsId: [{ required: true, message: "请选择商品", trigger: "change" }],
        quantity: [
            { required: true, message: "请输入数量", trigger: "blur" },
            {
                type: "number",
                min: 1,
                message: "数量必须大于0",
                trigger: "blur",
            },
        ],
        operator: [
            { required: true, message: "请输入操作员姓名", trigger: "blur" },
        ],
    },
});

// 查看详情对话框
const viewDialog = reactive({
    visible: false,
    data: {},
});

// 格式化价格
const formatPrice = (price) => {
    if (!price) return "0.00";
    return parseFloat(price).toFixed(2);
};

// 获取作业类型文本
const getOperationTypeText = (type) => {
    const types = {
        inbound: "入库",
        outbound: "出库",
        transfer: "调拨",
        adjustment: "盘点",
    };
    return types[type] || "未知";
};

// 获取作业类型标签类型
const getOperationTypeTagType = (type) => {
    const types = {
        inbound: "success",
        outbound: "danger",
        transfer: "warning",
        adjustment: "info",
    };
    return types[type] || "info";
};

// 获取状态文本
const getStatusText = (status) => {
    const statuses = {
        pending: "待处理",
        completed: "已完成",
        cancelled: "已取消",
    };
    return statuses[status] || "未知";
};

// 获取状态标签类型
const getStatusTagType = (status) => {
    const statuses = {
        pending: "warning",
        completed: "success",
        cancelled: "danger",
    };
    return statuses[status] || "info";
};

// 获取仓库名称
const getWarehouseName = (id) => {
    const warehouses = {
        1: "一号仓库",
        2: "二号仓库",
        3: "三号仓库",
        4: "四号仓库",
    };
    return warehouses[id] || "无";
};

// 获取作业列表
const getOperationList = async () => {
    loading.value = true;
    try {
        // 构建查询参数
        const params = {
            pageNum: pagination.pageNum,
            pageSize: pagination.pageSize,
        };

        // 添加搜索条件
        if (searchForm.operationNo) {
            params.operationNo = searchForm.operationNo;
        }
        if (searchForm.goodsName) {
            params.goodsName = searchForm.goodsName;
        }
        if (searchForm.operationType) {
            params.operationType = searchForm.operationType;
        }
        if (searchForm.status) {
            params.status = searchForm.status;
        }
        if (searchForm.fromWarehouseId) {
            params.fromWarehouseId = Number(searchForm.fromWarehouseId); // 确保转换为数字
        }
        if (searchForm.toWarehouseId) {
            params.toWarehouseId = Number(searchForm.toWarehouseId); // 确保转换为数字
        }

        console.log("请求参数:", params); // 调试日志

        // 调用后端 API
        const res = await request.get("/inventoryOperation/list", { params });

        console.log("API响应:", res); // 调试日志

        // 更灵活的响应处理
        if (
            res &&
            (res.code === 0 ||
                res.code === 200 ||
                res.code === "0" ||
                res.code === "200")
        ) {
            // 尝试多种可能的数据结构
            let data = null;

            // 检查最常见的数据结构
            if (res.data && res.data.list) {
                data = res.data;
            } else if (res.data && Array.isArray(res.data)) {
                data = { list: res.data, total: res.data.length };
            } else if (res.data && res.data.records) {
                data = res.data;
            } else if (Array.isArray(res)) {
                data = { list: res, total: res.length };
            } else if (res.data && typeof res.data === "object") {
                // 如果直接是对象，尝试解析
                data = res.data;
            } else {
                // 如果以上都不匹配，抛出错误
                throw new Error("API响应数据结构不符合预期");
            }

            // 确保数据结构正确
            operationList.value = data.list || data.records || data || [];
            pagination.total =
                data.total || data.totalElements || operationList.value.length;

            // 确保每个项目都有完整的仓库名称
            operationList.value = operationList.value.map((item) => ({
                ...item,
                fromWarehouseName:
                    item.fromWarehouseName ||
                    getWarehouseName(item.fromWarehouseId),
                toWarehouseName:
                    item.toWarehouseName ||
                    getWarehouseName(item.toWarehouseId),
            }));
        } else {
            ElMessage.error(res.msg || res.message || "获取作业列表失败");
            operationList.value = [];
            pagination.total = 0;
        }
    } catch (error) {
        console.error("获取作业列表失败:", error);
        ElMessage.error("获取作业列表失败：" + (error.message || ""));
        operationList.value = [];
        pagination.total = 0;
    } finally {
        loading.value = false;
    }
};

// 搜索
const handleSearch = () => {
    pagination.pageNum = 1;
    getOperationList();
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
    getOperationList();
};

const handleCurrentChange = (val) => {
    pagination.pageNum = val;
    getOperationList();
};

// 表格选择变化
const handleSelectionChange = (val) => {
    selectedRows.value = val;
};

// 入库作业
const handleInbound = () => {
    dialog.title = "新增入库作业";
    dialog.isAdd = true;
    dialog.isView = false;
    dialog.form = {
        id: null,
        operationNo: generateOperationNo(),
        operationType: "inbound",
        fromWarehouseId: null, // 入库无需源仓库
        toWarehouseId: "",
        goodsId: "",
        quantity: 1,
        operator: "",
        status: "pending",
        remark: "",
    };
    dialog.visible = true;
};

// 出库作业
const handleOutbound = () => {
    dialog.title = "新增出库作业";
    dialog.isAdd = true;
    dialog.isView = false;
    dialog.form = {
        id: null,
        operationNo: generateOperationNo(),
        operationType: "outbound",
        fromWarehouseId: "",
        toWarehouseId: null, // 出库无需目标仓库
        goodsId: "",
        quantity: 1,
        operator: "",
        status: "pending",
        remark: "",
    };
    dialog.visible = true;
};

// 调拨作业
const handleTransfer = () => {
    dialog.title = "新增调拨作业";
    dialog.isAdd = true;
    dialog.isView = false;
    dialog.form = {
        id: null,
        operationNo: generateOperationNo(),
        operationType: "transfer",
        fromWarehouseId: "",
        toWarehouseId: "",
        goodsId: "",
        quantity: 1,
        operator: "",
        status: "pending",
        remark: "",
    };
    dialog.visible = true;
};

// 盘点作业
const handleAdjustment = () => {
    dialog.title = "新增盘点作业";
    dialog.isAdd = true;
    dialog.isView = false;
    dialog.form = {
        id: null,
        operationNo: generateOperationNo(),
        operationType: "adjustment",
        fromWarehouseId: "",
        toWarehouseId: "",
        goodsId: "",
        quantity: 1,
        operator: "",
        status: "pending",
        remark: "",
    };
    dialog.visible = true;
};

// 生成作业单号
const generateOperationNo = () => {
    const timestamp = Date.now();
    return `WH${timestamp}`;
};

// 作业类型变更处理
const handleOperationTypeChange = (value) => {
    if (value === "inbound") {
        dialog.form.fromWarehouseId = null; // 入库无源仓库
    } else if (value === "outbound") {
        dialog.form.toWarehouseId = null; // 出库无目标仓库
    }
};

// 商品变更处理
const handleGoodsChange = (value) => {
    const good = goodsOptions.value.find((item) => item.id == value);
    if (good) {
        // 可以在这里设置其他关联字段
    }
};

// 提交作业
const submitOperation = async () => {
    if (!operationFormRef.value) return;

    await operationFormRef.value.validate(async (valid) => {
        if (valid) {
            dialog.loading = true;
            try {
                // 根据商品ID查找商品信息
                const selectedGood = goodsOptions.value.find(
                    (good) => good.id == dialog.form.goodsId,
                );

                // 构建提交数据，适配后端实体类字段
                const submitData = {
                    id: dialog.form.id || null,
                    operationNo: dialog.form.operationNo,
                    operationType: dialog.form.operationType,
                    fromWarehouseId:
                        dialog.form.operationType === "inbound"
                            ? null
                            : dialog.form.fromWarehouseId
                              ? Number(dialog.form.fromWarehouseId)
                              : null,
                    fromWarehouseName:
                        dialog.form.operationType === "inbound"
                            ? null
                            : getWarehouseName(dialog.form.fromWarehouseId),
                    toWarehouseId:
                        dialog.form.operationType === "outbound"
                            ? null
                            : dialog.form.toWarehouseId
                              ? Number(dialog.form.toWarehouseId)
                              : null,
                    toWarehouseName:
                        dialog.form.operationType === "outbound"
                            ? null
                            : getWarehouseName(dialog.form.toWarehouseId),
                    goodsId: dialog.form.goodsId
                        ? Number(dialog.form.goodsId)
                        : null,
                    goodsName: selectedGood ? selectedGood.name : null, // 确保有商品名称
                    skuCode: selectedGood ? selectedGood.skuCode : null, // 确保有SKU编码
                    quantity: Number(dialog.form.quantity),
                    unit: "个", // 默认单位
                    operator: dialog.form.operator,
                    status: dialog.form.status,
                    remark: dialog.form.remark,
                    sourceType: "manual", // 手动录入
                };

                console.log("提交数据:", submitData); // 调试日志

                let res;
                if (dialog.isAdd) {
                    // 调用后端新增 API
                    res = await request.post(
                        "/inventoryOperation/add",
                        submitData,
                    );
                    if (
                        res &&
                        (res.code === 0 ||
                            res.code === 200 ||
                            res.code === "0" ||
                            res.code === "200")
                    ) {
                        ElMessage.success("新增作业成功");
                        dialog.visible = false;
                        getOperationList();
                    } else {
                        ElMessage.error(
                            res.msg || res.message || "新增作业失败",
                        );
                    }
                } else {
                    // 调用后端更新 API
                    res = await request.post(
                        "/inventoryOperation/update",
                        submitData,
                    );
                    if (
                        res &&
                        (res.code === 0 ||
                            res.code === 200 ||
                            res.code === "0" ||
                            res.code === "200")
                    ) {
                        ElMessage.success("更新作业成功");
                        dialog.visible = false;
                        getOperationList();
                    } else {
                        ElMessage.error(
                            res.msg || res.message || "更新作业失败",
                        );
                    }
                }
            } catch (error) {
                console.error("操作失败:", error);
                ElMessage.error("操作失败：" + (error.message || ""));
            } finally {
                dialog.loading = false;
            }
        }
    });
};

// 查看作业
const handleView = (row) => {
    // 确保显示完整信息
    viewDialog.data = {
        ...row,
        fromWarehouseName:
            row.fromWarehouseName || getWarehouseName(row.fromWarehouseId),
        toWarehouseName:
            row.toWarehouseName || getWarehouseName(row.toWarehouseId),
    };
    viewDialog.visible = true;
};

// 编辑作业
const handleEdit = (row) => {
    dialog.title = "编辑作业";
    dialog.isAdd = false;
    dialog.isView = false;

    // 复制数据并确保ID是数字类型
    dialog.form = {
        ...row,
        id: row.id ? Number(row.id) : null,
        fromWarehouseId: row.fromWarehouseId
            ? Number(row.fromWarehouseId)
            : null,
        toWarehouseId: row.toWarehouseId ? Number(row.toWarehouseId) : null,
        goodsId: row.goodsId ? Number(row.goodsId) : null,
        quantity: row.quantity ? Number(row.quantity) : 1,
    };
    dialog.visible = true;
};

// 完成作业
const handleComplete = async (row) => {
    try {
        await ElMessageBox.confirm(
            `确定要完成作业 "${row.operationNo}" 吗？`,
            "提示",
            {
                confirmButtonText: "确定",
                cancelButtonText: "取消",
                type: "warning",
            },
        );

        // 调用后端更新状态 API
        const res = await request.post(
            `/inventoryOperation/updateStatus/${row.id}/completed`,
        );
        if (
            res &&
            (res.code === 0 ||
                res.code === 200 ||
                res.code === "0" ||
                res.code === "200")
        ) {
            ElMessage.success("作业完成");
            getOperationList(); // 重新加载列表
        } else {
            ElMessage.error(res.msg || res.message || "更新状态失败");
        }
    } catch (error) {
        console.error("完成作业失败:", error);
        // 用户取消操作或发生错误
    }
};

// 取消作业
const handleCancel = async (row) => {
    try {
        await ElMessageBox.confirm(
            `确定要取消作业 "${row.operationNo}" 吗？`,
            "提示",
            {
                confirmButtonText: "确定",
                cancelButtonText: "取消",
                type: "warning",
            },
        );

        // 调用后端更新状态 API
        const res = await request.post(
            `/inventoryOperation/updateStatus/${row.id}/cancelled`,
        );
        if (
            res &&
            (res.code === 0 ||
                res.code === 200 ||
                res.code === "0" ||
                res.code === "200")
        ) {
            ElMessage.success("作业已取消");
            getOperationList(); // 重新加载列表
        } else {
            ElMessage.error(res.msg || res.message || "更新状态失败");
        }
    } catch (error) {
        console.error("取消作业失败:", error);
        // 用户取消操作或发生错误
    }
};

// 对话框关闭处理
const handleDialogClose = () => {
    if (operationFormRef.value) {
        operationFormRef.value.clearValidate();
    }
};

onMounted(() => {
    getOperationList();
});
</script>

<style scoped>
.warehouse-operation {
    padding: 20px;
    background-color: #f5f7fa;
    min-height: 100vh;
}

.operation-card {
    margin-bottom: 10px;
}

.operation-card .el-button {
    margin-right: 10px;
    margin-bottom: 10px;
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
    .warehouse-operation {
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

    .operation-card .el-button {
        width: 100%;
        margin-right: 0;
        margin-bottom: 8px;
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
