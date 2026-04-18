<template>
    <div class="sale-order">
        <el-card shadow="never" class="search-card">
            <el-form :inline="true" :model="searchForm">
                <el-form-item label="订单号">
                    <el-input v-model="searchForm.orderNo" clearable style="width: 150px" />
                </el-form-item>
                <el-form-item label="状态">
                    <el-select v-model="searchForm.status" clearable placeholder="全部" style="width: 150px">
                        <el-option label="草稿" :value="0" />
                        <el-option label="已确认待出库" :value="1" />
                        <el-option label="已出库完成" :value="2" />
                        <el-option label="已作废" :value="3" />
                    </el-select>
                </el-form-item>
                <el-form-item>
                    <el-button type="primary" @click="loadList">查询</el-button>
                    <el-button @click="resetSearch">重置</el-button>
                </el-form-item>
            </el-form>
        </el-card>

        <!-- 作业统计卡片 -->
        <el-row :gutter="20" class="stat-row" style="margin-bottom: 12px">
            <el-col :span="6">
                <el-card shadow="hover" class="stat-card">
                    <div class="stat-content">
                        <div class="stat-icon" style="background-color: #409eff">
                            <el-icon><Document /></el-icon>
                        </div>
                        <div class="stat-info">
                            <div class="stat-label">订单总数</div>
                            <div class="stat-value">{{ statistics.totalCount }}</div>
                        </div>
                    </div>
                </el-card>
            </el-col>
            <el-col :span="6">
                <el-card shadow="hover" class="stat-card">
                    <div class="stat-content">
                        <div class="stat-icon" style="background-color: #67c23a">
                            <el-icon><Clock /></el-icon>
                        </div>
                        <div class="stat-info">
                            <div class="stat-label">待出库订单</div>
                            <div class="stat-value">{{ statistics.pendingCount }}</div>
                        </div>
                    </div>
                </el-card>
            </el-col>
            <el-col :span="6">
                <el-card shadow="hover" class="stat-card">
                    <div class="stat-content">
                        <div class="stat-icon" style="background-color: #e6a23c">
                            <el-icon><Check /></el-icon>
                        </div>
                        <div class="stat-info">
                            <div class="stat-label">已完成订单</div>
                            <div class="stat-value">{{ statistics.completedCount }}</div>
                        </div>
                    </div>
                </el-card>
            </el-col>
            <el-col :span="6">
                <el-card shadow="hover" class="stat-card">
                    <div class="stat-content">
                        <div class="stat-icon" style="background-color: #f56c6c">
                            <el-icon><Close /></el-icon>
                        </div>
                        <div class="stat-info">
                            <div class="stat-label">已作废订单</div>
                            <div class="stat-value">{{ statistics.cancelledCount }}</div>
                        </div>
                    </div>
                </el-card>
            </el-col>
        </el-row>

        <div class="toolbar">
            <el-button type="primary" @click="openAdd">
                <el-icon><Plus /></el-icon>
                新建销售订单
            </el-button>
        </div>

        <el-card shadow="never">
            <el-table v-loading="loading" :data="tableData" border stripe>
                <el-table-column prop="orderNo" label="订单号" width="160" />
                <el-table-column prop="customerName" label="客户" min-width="120" />
                <el-table-column prop="warehouseId" label="仓库ID" width="88" />
                <el-table-column prop="finalAmount" label="应收" width="100" />
                <el-table-column label="状态" width="120">
                    <template #default="{ row }">
                        <el-tag :type="statusType(row.status)">{{ statusText(row.status) }}</el-tag>
                    </template>
                </el-table-column>
                <el-table-column prop="orderDate" label="下单日期" width="120" />
                <el-table-column label="操作" width="260" fixed="right">
                    <template #default="{ row }">
                        <el-button link type="primary" size="small" @click="openDetail(row)">详情</el-button>
                        <el-button v-if="row.status === 0" link type="primary" size="small" @click="openEdit(row)"
                            >编辑</el-button
                        >
                        <el-button v-if="row.status === 0" link type="success" size="small" @click="handleConfirm(row)"
                            >确认</el-button
                        >
                        <el-button
                            v-if="row.status !== 2 && row.status !== 3"
                            link
                            type="danger"
                            size="small"
                            @click="handleCancel(row)"
                            >作废</el-button
                        >
                    </template>
                </el-table-column>
            </el-table>
            <div class="pagination-container">
                <el-pagination
                    v-model:current-page="pagination.pageNum"
                    v-model:page-size="pagination.pageSize"
                    :total="pagination.total"
                    :page-sizes="[10, 20, 50]"
                    layout="total, sizes, prev, pager, next, jumper"
                    @size-change="loadList"
                    @current-change="loadList"
                />
            </div>
        </el-card>

        <el-dialog v-model="dialog.visible" :title="dialog.title" width="920px" destroy-on-close>
            <el-form :model="dialog.form" label-width="100px">
                <el-row :gutter="12">
                    <el-col :span="8">
                        <el-form-item label="客户" required>
                            <el-select
                                v-model="dialog.form.customerId"
                                filterable
                                placeholder="选择客户"
                                style="width: 100%"
                            >
                                <el-option v-for="c in customers" :key="c.id" :label="c.name" :value="c.id" />
                            </el-select>
                        </el-form-item>
                    </el-col>
                    <el-col :span="8">
                        <el-form-item label="出库仓库" required>
                            <el-select
                                v-model="dialog.form.warehouseId"
                                filterable
                                placeholder="选择仓库"
                                style="width: 100%"
                            >
                                <el-option v-for="w in warehouses" :key="w.id" :label="w.name" :value="Number(w.id)" />
                            </el-select>
                        </el-form-item>
                    </el-col>
                    <el-col :span="8">
                        <el-form-item label="下单日期" required>
                            <el-date-picker
                                v-model="dialog.form.orderDate"
                                type="date"
                                value-format="YYYY-MM-DD"
                                style="width: 100%"
                            />
                        </el-form-item>
                    </el-col>
                </el-row>
                <el-form-item label="订单号">
                    <el-input v-model="dialog.form.orderNo" placeholder="留空自动生成" clearable />
                </el-form-item>
                <el-form-item label="备注">
                    <el-input v-model="dialog.form.remark" type="textarea" :rows="2" />
                </el-form-item>
            </el-form>
            <div class="sub-head">
                <span>明细</span>
                <el-button type="primary" link @click="addRow">添加行</el-button>
            </div>
            <el-table :data="dialog.items" border size="small">
                <el-table-column label="商品" min-width="220">
                    <template #default="{ row }">
                        <el-select v-model="row.productId" filterable placeholder="商品" style="width: 100%">
                            <el-option
                                v-for="g in goodsList"
                                :key="g.id"
                                :label="`${g.skuCode || ''} ${g.name}`"
                                :value="Number(g.id)"
                            />
                        </el-select>
                    </template>
                </el-table-column>
                <el-table-column label="单价" width="120">
                    <template #default="{ row }">
                        <el-input-number v-model="row.price" :min="0" :precision="2" style="width: 100%" />
                    </template>
                </el-table-column>
                <el-table-column label="数量" width="110">
                    <template #default="{ row }">
                        <el-input-number v-model="row.quantity" :min="1" :precision="0" style="width: 100%" />
                    </template>
                </el-table-column>
                <el-table-column label="操作" width="70">
                    <template #default="{ $index }">
                        <el-button link type="danger" size="small" @click="dialog.items.splice($index, 1)"
                            >删</el-button
                        >
                    </template>
                </el-table-column>
            </el-table>
            <template #footer>
                <el-button @click="dialog.visible = false">取消</el-button>
                <el-button type="primary" :loading="dialog.saving" @click="submitSave">保存</el-button>
            </template>
        </el-dialog>

        <el-dialog v-model="detail.visible" title="订单详情" width="640px" align-center destroy-on-close>
            <template v-if="detail.data">
                <el-descriptions :column="1" border>
                    <el-descriptions-item label="订单号">{{ detail.data.orderNo }}</el-descriptions-item>
                    <el-descriptions-item label="客户">{{ detail.data.customerName }}</el-descriptions-item>
                    <el-descriptions-item label="仓库ID">{{ detail.data.warehouseId }}</el-descriptions-item>
                    <el-descriptions-item label="应收">{{ detail.data.finalAmount }}</el-descriptions-item>
                    <el-descriptions-item label="状态">{{ statusText(detail.data.status) }}</el-descriptions-item>
                </el-descriptions>
                <el-table :data="detail.data.items || []" border size="small" class="mt16">
                    <el-table-column prop="skuCode" label="SKU" width="110" />
                    <el-table-column prop="productNameSnapshot" label="商品" />
                    <el-table-column prop="price" label="单价" width="90" />
                    <el-table-column prop="quantity" label="数量" width="80" />
                    <el-table-column prop="subtotal" label="小计" width="90" />
                </el-table>
            </template>
            <template #footer>
                <el-button @click="detail.visible = false">关闭</el-button>
            </template>
        </el-dialog>
    </div>
</template>

<script setup>
import { reactive, ref, onMounted } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import { Plus, Document, Clock, Check, Close } from "@element-plus/icons-vue";
import request from "../../utils/request";

const loading = ref(false);
const tableData = ref([]);
const customers = ref([]);
const warehouses = ref([]);
const goodsList = ref([]);

const searchForm = reactive({ orderNo: "", status: null });
const pagination = reactive({ pageNum: 1, pageSize: 10, total: 0 });

const dialog = reactive({
    visible: false,
    title: "销售订单",
    saving: false,
    form: {
        id: null,
        orderNo: "",
        customerId: null,
        warehouseId: null,
        orderDate: "",
        remark: "",
    },
    items: [],
});

const detail = reactive({ visible: false, data: null });

const statistics = reactive({
    totalCount: 0,
    draftCount: 0,
    pendingCount: 0,
    completedCount: 0,
    cancelledCount: 0,
});

async function loadStatistics() {
    const res = await request.get("/sale/statistics");
    if (res.code === "200" && res.data) {
        statistics.totalCount = res.data.totalCount || 0;
        statistics.draftCount = res.data.draftCount || 0;
        statistics.pendingCount = res.data.pendingCount || 0;
        statistics.completedCount = res.data.completedCount || 0;
        statistics.cancelledCount = res.data.cancelledCount || 0;
    }
}

function statusText(s) {
    const m = { 0: "草稿", 1: "已确认待出库", 2: "已出库完成", 3: "已作废" };
    return m[s] != null ? m[s] : s;
}

function statusType(s) {
    const m = { 0: "info", 1: "warning", 2: "success", 3: "danger" };
    return m[s] || "info";
}

function isApiOk(res) {
    return res && (res.code === "200" || res.code === 200);
}

/** 分别请求，避免任一失败导致客户/仓库/商品全部为空 */
async function loadBase() {
    customers.value = [];
    warehouses.value = [];
    goodsList.value = [];
    try {
        const cust = await request.get("/customer/selectAllCustomer");
        if (isApiOk(cust)) {
            customers.value = Array.isArray(cust.data) ? cust.data : [];
        } else {
            ElMessage.error(cust?.msg || "客户列表加载失败");
        }
    } catch {
        /* request 拦截器已提示 */
    }
    try {
        const wh = await request.get("/warehouse/selectAll");
        if (isApiOk(wh)) {
            warehouses.value = Array.isArray(wh.data) ? wh.data : [];
        } else {
            ElMessage.error(wh?.msg || "仓库列表加载失败");
        }
    } catch {
        /* request 拦截器已提示 */
    }
    try {
        const goods = await request.get("/goods/selectAllGoods");
        if (isApiOk(goods)) {
            goodsList.value = Array.isArray(goods.data) ? goods.data : [];
        } else {
            ElMessage.error(goods?.msg || "商品列表加载失败");
        }
    } catch {
        /* request 拦截器已提示 */
    }
}

async function loadList() {
    loading.value = true;
    try {
        const res = await request.get("/sale/list", {
            params: {
                pageNum: pagination.pageNum,
                pageSize: pagination.pageSize,
                orderNo: searchForm.orderNo || undefined,
                status: searchForm.status != null && searchForm.status !== "" ? searchForm.status : undefined,
            },
        });
        if (res.code === "200" && res.data) {
            tableData.value = res.data.list || [];
            pagination.total = res.data.total || 0;
        } else {
            ElMessage.error(res.msg || "加载失败");
        }
    } finally {
        loading.value = false;
    }
}

function resetSearch() {
    searchForm.orderNo = "";
    searchForm.status = null;
    pagination.pageNum = 1;
    loadList();
}

async function openAdd() {
    await loadBase();
    dialog.title = "新建销售订单";
    dialog.form = { id: null, orderNo: "", customerId: null, warehouseId: null, orderDate: "", remark: "" };
    const d = new Date();
    dialog.form.orderDate = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
    dialog.items = [];
    dialog.visible = true;
}

async function openEdit(row) {
    await loadBase();
    const res = await request.get(`/sale/selectById/${row.id}`);
    if (res.code !== "200" || !res.data) {
        ElMessage.error(res.msg || "加载失败");
        return;
    }
    const p = res.data;
    dialog.title = "编辑销售订单";
    const od = p.orderDate;
    let orderDateStr = "";
    if (od) {
        orderDateStr = typeof od === "string" ? od.slice(0, 10) : od;
    }
    dialog.form = {
        id: p.id,
        orderNo: p.orderNo,
        customerId: p.customerId,
        warehouseId: p.warehouseId,
        orderDate: orderDateStr,
        remark: p.remark || "",
    };
    dialog.items = (p.items || []).map((it) => ({
        productId: Number(it.productId),
        price: Number(it.price),
        quantity: Number(it.quantity),
    }));
    dialog.visible = true;
}

async function openDetail(row) {
    const res = await request.get(`/sale/selectById/${row.id}`);
    if (res.code === "200") {
        detail.data = res.data;
        detail.visible = true;
    } else {
        ElMessage.error(res.msg || "加载失败");
    }
}

function addRow() {
    dialog.items.push({ productId: null, price: 0, quantity: 1 });
}

async function submitSave() {
    if (!dialog.form.customerId || !dialog.form.warehouseId || !dialog.form.orderDate) {
        ElMessage.warning("请填写客户、仓库、下单日期");
        return;
    }
    if (!dialog.items.length) {
        ElMessage.warning("请添加明细");
        return;
    }
    for (const it of dialog.items) {
        if (!it.productId || !it.quantity || it.quantity < 1) {
            ElMessage.warning("明细不完整");
            return;
        }
    }
    dialog.saving = true;
    try {
        const payload = {
            id: dialog.form.id,
            orderNo: dialog.form.orderNo || null,
            customerId: dialog.form.customerId,
            warehouseId: dialog.form.warehouseId,
            orderDate: dialog.form.orderDate,
            remark: dialog.form.remark || null,
            items: dialog.items.map((it) => ({
                productId: it.productId,
                price: it.price,
                quantity: it.quantity,
            })),
        };
        const url = dialog.form.id ? "/sale/update" : "/sale/add";
        const res = dialog.form.id ? await request.post(url, payload) : await request.post(url, payload);
        if (res.code === "200") {
            ElMessage.success("保存成功");
            dialog.visible = false;
            loadList();
        } else {
            ElMessage.error(res.msg || "保存失败");
        }
    } finally {
        dialog.saving = false;
    }
}

function handleConfirm(row) {
    ElMessageBox.confirm("确认后订单进入「待出库」，不可再改明细。", "确认订单", { type: "warning" })
        .then(async () => {
            const res = await request.post(`/sale/confirm/${row.id}`);
            if (res.code === "200") {
                ElMessage.success("已确认");
                loadList();
            } else {
                ElMessage.error(res.msg || "失败");
            }
        })
        .catch(() => {});
}

function handleCancel(row) {
    ElMessageBox.confirm("确定作废该订单？", "作废", { type: "warning" })
        .then(async () => {
            const res = await request.post(`/sale/cancel/${row.id}`);
            if (res.code === "200") {
                ElMessage.success("已作废");
                loadList();
            } else {
                ElMessage.error(res.msg || "失败");
            }
        })
        .catch(() => {});
}

onMounted(() => {
    loadStatistics();
    loadBase();
    loadList();
});
</script>

<style scoped>
.sale-order {
    padding: 12px;
}
.stat-row {
    margin-bottom: 12px;
}
.stat-card {
    cursor: default;
}
.stat-content {
    display: flex;
    align-items: center;
    gap: 12px;
}
.stat-icon {
    width: 48px;
    height: 48px;
    border-radius: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #fff;
    font-size: 22px;
}
.stat-info {
    flex: 1;
}
.stat-label {
    font-size: 13px;
    color: #909399;
    margin-bottom: 4px;
}
.stat-value {
    font-size: 22px;
    font-weight: 600;
    color: #303133;
}
.search-card {
    margin-bottom: 12px;
}
.toolbar {
    margin-bottom: 12px;
}
.pagination-container {
    margin-top: 16px;
    display: flex;
    justify-content: flex-end;
}
.sub-head {
    display: flex;
    justify-content: space-between;
    margin: 8px 0;
    font-weight: 500;
}
.mt16 {
    margin-top: 16px;
}
</style>
