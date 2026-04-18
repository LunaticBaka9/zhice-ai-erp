<template>
    <div class="sale-delivery">
        <el-card shadow="never" class="search-card">
            <el-form :inline="true" :model="searchForm">
                <el-form-item label="出库单号">
                    <el-input v-model="searchForm.billNo" clearable style="width: 140px" />
                </el-form-item>
                <el-form-item label="销售订单号">
                    <el-input v-model="searchForm.orderNo" clearable style="width: 140px" />
                </el-form-item>
                <el-form-item label="状态">
                    <el-select v-model="searchForm.status" clearable placeholder="全部" style="width: 120px">
                        <el-option label="草稿" :value="0" />
                        <el-option label="已确认出库" :value="1" />
                    </el-select>
                </el-form-item>
                <el-form-item>
                    <el-button type="primary" @click="loadList">查询</el-button>
                    <el-button @click="resetSearch">重置</el-button>
                </el-form-item>
            </el-form>
        </el-card>

        <el-row :gutter="20" class="stat-row" style="margin-bottom: 12px">
            <el-col :span="8">
                <el-card shadow="hover" class="stat-card">
                    <div class="stat-content">
                        <div class="stat-icon" style="background-color: #409eff">
                            <el-icon><Document /></el-icon>
                        </div>
                        <div class="stat-info">
                            <div class="stat-label">出库单总数</div>
                            <div class="stat-value">{{ statistics.total }}</div>
                        </div>
                    </div>
                </el-card>
            </el-col>
            <el-col :span="8">
                <el-card shadow="hover" class="stat-card">
                    <div class="stat-content">
                        <div class="stat-icon" style="background-color: #67c23a">
                            <el-icon><Edit /></el-icon>
                        </div>
                        <div class="stat-info">
                            <div class="stat-label">草稿</div>
                            <div class="stat-value">{{ statistics.draft }}</div>
                        </div>
                    </div>
                </el-card>
            </el-col>
            <el-col :span="8">
                <el-card shadow="hover" class="stat-card">
                    <div class="stat-content">
                        <div class="stat-icon" style="background-color: #e6a23c">
                            <el-icon><Check /></el-icon>
                        </div>
                        <div class="stat-info">
                            <div class="stat-label">已确认出库</div>
                            <div class="stat-value">{{ statistics.confirmed }}</div>
                        </div>
                    </div>
                </el-card>
            </el-col>
        </el-row>

        <div class="toolbar">
            <el-button type="primary" @click="openCreate">
                <el-icon><Plus /></el-icon>
                按销售订单生成出库单
            </el-button>
        </div>

        <el-card shadow="never">
            <el-table v-loading="loading" :data="tableData" border stripe>
                <el-table-column prop="billNo" label="出库单号" width="170" />
                <el-table-column prop="orderNo" label="销售订单号" width="160" />
                <el-table-column prop="warehouseId" label="仓库ID" width="88" />
                <el-table-column label="状态" width="120">
                    <template #default="{ row }">
                        <el-tag :type="row.status === 1 ? 'success' : 'info'">{{
                            row.status === 1 ? "已确认出库" : "草稿"
                        }}</el-tag>
                    </template>
                </el-table-column>
                <el-table-column prop="createTime" label="创建时间" width="170" />
                <el-table-column prop="confirmTime" label="出库时间" width="170" />
                <el-table-column label="操作" width="220" fixed="right">
                    <template #default="{ row }">
                        <el-button link type="primary" size="small" @click="openDetail(row)">详情</el-button>
                        <el-button v-if="row.status === 0" link type="success" size="small" @click="handleConfirm(row)"
                            >确认出库</el-button
                        >
                        <el-button
                            v-if="row.status === 0"
                            link
                            type="danger"
                            size="small"
                            @click="handleDeleteDraft(row)"
                            >删除草稿</el-button
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

        <el-dialog v-model="createDlg.visible" title="选择销售订单" width="560px">
            <el-form label-width="110px">
                <el-form-item label="待出库订单" required>
                    <el-select
                        v-model="createDlg.saleOrderId"
                        filterable
                        placeholder="已确认且无出库单"
                        style="width: 100%"
                    >
                        <el-option
                            v-for="p in eligibleList"
                            :key="p.id"
                            :label="`${p.orderNo} | ${p.customerName || ''} | ￥${p.finalAmount ?? p.totalAmount}`"
                            :value="p.id"
                        />
                    </el-select>
                </el-form-item>
                <el-form-item label="备注">
                    <el-input v-model="createDlg.remark" type="textarea" :rows="2" />
                </el-form-item>
            </el-form>
            <template #footer>
                <el-button @click="createDlg.visible = false">取消</el-button>
                <el-button type="primary" :loading="createDlg.submitting" @click="submitCreate">生成</el-button>
            </template>
        </el-dialog>

        <el-dialog v-model="detail.visible" title="出库详情" width="640px" align-center destroy-on-close>
            <template v-if="detail.data">
                <el-descriptions :column="1" border>
                    <el-descriptions-item label="出库单号">{{ detail.data.billNo }}</el-descriptions-item>
                    <el-descriptions-item label="销售订单">{{ detail.data.orderNo }}</el-descriptions-item>
                    <el-descriptions-item label="仓库ID">{{ detail.data.warehouseId }}</el-descriptions-item>
                    <el-descriptions-item label="状态">{{
                        detail.data.status === 1 ? "已确认出库" : "草稿"
                    }}</el-descriptions-item>
                </el-descriptions>
                <el-table :data="detail.data.items || []" border size="small" class="mt16">
                    <el-table-column prop="skuCode" label="SKU" width="110" />
                    <el-table-column prop="productNameSnapshot" label="商品" />
                    <el-table-column prop="quantity" label="数量" width="80" />
                    <el-table-column prop="price" label="单价" width="90" />
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
import { Plus, Document, Edit, Check } from "@element-plus/icons-vue";
import request from "../../utils/request";

const loading = ref(false);
const tableData = ref([]);
const eligibleList = ref([]);

const statistics = reactive({ total: 0, draft: 0, confirmed: 0 });

async function loadStatistics() {
    const res = await request.get("/sale/outbound/statistics");
    if (res.code === "200" && res.data) {
        statistics.total = res.data.total || 0;
        statistics.draft = res.data.draft || 0;
        statistics.confirmed = res.data.confirmed || 0;
    }
}

const searchForm = reactive({ billNo: "", orderNo: "", status: null });
const pagination = reactive({ pageNum: 1, pageSize: 10, total: 0 });

const createDlg = reactive({ visible: false, saleOrderId: null, remark: "", submitting: false });
const detail = reactive({ visible: false, data: null });

async function loadEligible() {
    const res = await request.get("/sale/eligibleOutbound");
    if (res.code === "200") eligibleList.value = res.data || [];
}

async function loadList() {
    loading.value = true;
    try {
        const res = await request.get("/sale/outbound/list", {
            params: {
                pageNum: pagination.pageNum,
                pageSize: pagination.pageSize,
                billNo: searchForm.billNo || undefined,
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
    searchForm.billNo = "";
    searchForm.orderNo = "";
    searchForm.status = null;
    pagination.pageNum = 1;
    loadList();
}

async function openCreate() {
    await loadEligible();
    if (!eligibleList.value.length) {
        ElMessage.info("没有「已确认且未生成出库单」的销售订单");
        return;
    }
    createDlg.saleOrderId = null;
    createDlg.remark = "";
    createDlg.visible = true;
}

async function submitCreate() {
    if (!createDlg.saleOrderId) {
        ElMessage.warning("请选择销售订单");
        return;
    }
    createDlg.submitting = true;
    try {
        const res = await request.post("/sale/outbound/create", {
            saleOrderId: createDlg.saleOrderId,
            remark: createDlg.remark || null,
        });
        if (res.code === "200") {
            ElMessage.success("已生成出库单");
            createDlg.visible = false;
            loadList();
        } else {
            ElMessage.error(res.msg || "失败");
        }
    } finally {
        createDlg.submitting = false;
    }
}

async function openDetail(row) {
    const res = await request.get(`/sale/outbound/detail/${row.id}`);
    if (res.code === "200") {
        detail.data = res.data;
        detail.visible = true;
    } else {
        ElMessage.error(res.msg || "加载失败");
    }
}

function handleConfirm(row) {
    ElMessageBox.confirm("确认后将按明细扣减库存，不可撤销。", "确认出库", { type: "warning" })
        .then(async () => {
            const res = await request.post(`/sale/outbound/confirm/${row.id}`);
            if (res.code === "200") {
                ElMessage.success("出库已确认");
                loadList();
            } else {
                ElMessage.error(res.msg || "失败");
            }
        })
        .catch(() => {});
}

function handleDeleteDraft(row) {
    ElMessageBox.confirm("删除后可重新从销售订单生成出库单。", "删除草稿", { type: "warning" })
        .then(async () => {
            const res = await request.post(`/sale/outbound/deleteDraft/${row.id}`);
            if (res.code === "200") {
                ElMessage.success("已删除");
                loadList();
            } else {
                ElMessage.error(res.msg || "失败");
            }
        })
        .catch(() => {});
}

onMounted(() => {
    loadStatistics();
    loadList();
});
</script>

<style scoped>
.sale-delivery {
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
.mt16 {
    margin-top: 16px;
}
</style>
