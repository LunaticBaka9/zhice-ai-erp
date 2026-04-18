<template>
    <div class="purchase-inbound">
        <el-card shadow="never" class="search-card">
            <el-form :inline="true" :model="searchForm" class="search-form">
                <el-form-item label="入库单号">
                    <el-input v-model="searchForm.billNo" clearable style="width: 150px" />
                </el-form-item>
                <el-form-item label="采购单号">
                    <el-input v-model="searchForm.purchaseBillNo" clearable style="width: 150px" />
                </el-form-item>
                <el-form-item label="状态">
                    <el-select v-model="searchForm.status" placeholder="全部" clearable style="width: 120px">
                        <el-option label="草稿" :value="0" />
                        <el-option label="已确认入账" :value="1" />
                    </el-select>
                </el-form-item>
                <el-form-item>
                    <el-button type="primary" @click="loadList">查询</el-button>
                    <el-button @click="resetSearch">重置</el-button>
                </el-form-item>
            </el-form>
        </el-card>

        <div class="toolbar">
            <el-button type="primary" @click="openCreate">
                <el-icon><Plus /></el-icon>
                按采购订单生成入库单
            </el-button>
        </div>

        <el-card shadow="never">
            <el-table v-loading="loading" :data="tableData" border stripe>
                <el-table-column prop="billNo" label="入库单号" width="170" />
                <el-table-column prop="purchaseBillNo" label="采购单号" width="160" />
                <el-table-column prop="warehouseId" label="仓库ID" width="88" />
                <el-table-column label="状态" width="120">
                    <template #default="{ row }">
                        <el-tag :type="row.status === 1 ? 'success' : 'info'">{{ row.status === 1 ? "已确认入账" : "草稿" }}</el-tag>
                    </template>
                </el-table-column>
                <el-table-column prop="createTime" label="创建时间" width="170" />
                <el-table-column prop="confirmTime" label="入账时间" width="170" />
                <el-table-column label="操作" width="220" fixed="right">
                    <template #default="{ row }">
                        <el-button link type="primary" size="small" @click="openDetail(row)">详情</el-button>
                        <el-button v-if="row.status === 0" link type="success" size="small" @click="handleConfirm(row)">确认入账</el-button>
                        <el-button v-if="row.status === 0" link type="danger" size="small" @click="handleDeleteDraft(row)">删除草稿</el-button>
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

        <el-dialog v-model="createDlg.visible" title="选择采购订单" width="560px">
            <el-form label-width="100px">
                <el-form-item label="待入库订单" required>
                    <el-select v-model="createDlg.purchaseId" placeholder="仅显示已确认且无入库单的订单" filterable style="width: 100%">
                        <el-option
                            v-for="p in eligibleList"
                            :key="p.id"
                            :label="`${p.billNo} | ${p.supplierName || ''} | ￥${p.totalAmount || 0}`"
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

        <el-dialog
            v-model="detail.visible"
            title="采购入库详情"
            width="640px"
            align-center
            destroy-on-close
        >
            <template v-if="detail.data">
                <el-descriptions :column="1" border>
                    <el-descriptions-item label="入库单号">{{ detail.data.billNo }}</el-descriptions-item>
                    <el-descriptions-item label="采购单号">{{ detail.data.purchaseBillNo }}</el-descriptions-item>
                    <el-descriptions-item label="仓库ID">{{ detail.data.warehouseId }}</el-descriptions-item>
                    <el-descriptions-item label="状态">{{ detail.data.status === 1 ? "已确认入账" : "草稿" }}</el-descriptions-item>
                    <el-descriptions-item label="备注">{{ detail.data.remark || "—" }}</el-descriptions-item>
                </el-descriptions>
                <el-table :data="detail.data.items || []" border size="small" class="mt16">
                    <el-table-column prop="skuCode" label="SKU" width="120" />
                    <el-table-column prop="goodsName" label="商品" />
                    <el-table-column prop="quantity" label="数量" width="90" />
                    <el-table-column prop="unitPrice" label="单价" width="90" />
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
import { Plus } from "@element-plus/icons-vue";
import request from "../../utils/request";

const loading = ref(false);
const tableData = ref([]);
const eligibleList = ref([]);

const searchForm = reactive({
    billNo: "",
    purchaseBillNo: "",
    status: null,
});

const pagination = reactive({
    pageNum: 1,
    pageSize: 10,
    total: 0,
});

const createDlg = reactive({
    visible: false,
    purchaseId: null,
    remark: "",
    submitting: false,
});

const detail = reactive({
    visible: false,
    data: null,
});

async function loadEligible() {
    const res = await request.get("/purchase/order/eligibleInbound");
    if (res.code === "200") eligibleList.value = res.data || [];
}

async function loadList() {
    loading.value = true;
    try {
        const res = await request.get("/purchase/inbound/list", {
            params: {
                pageNum: pagination.pageNum,
                pageSize: pagination.pageSize,
                billNo: searchForm.billNo || undefined,
                purchaseBillNo: searchForm.purchaseBillNo || undefined,
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
    searchForm.purchaseBillNo = "";
    searchForm.status = null;
    pagination.pageNum = 1;
    loadList();
}

async function openCreate() {
    await loadEligible();
    if (!eligibleList.value.length) {
        ElMessage.info("当前没有「已确认且未生成入库单」的采购订单");
        return;
    }
    createDlg.purchaseId = null;
    createDlg.remark = "";
    createDlg.visible = true;
}

async function submitCreate() {
    if (!createDlg.purchaseId) {
        ElMessage.warning("请选择采购订单");
        return;
    }
    createDlg.submitting = true;
    try {
        const res = await request.post("/purchase/inbound/create", {
            purchaseId: createDlg.purchaseId,
            remark: createDlg.remark || null,
        });
        if (res.code === "200") {
            ElMessage.success("已生成入库单");
            createDlg.visible = false;
            loadList();
        } else {
            ElMessage.error(res.msg || "生成失败");
        }
    } finally {
        createDlg.submitting = false;
    }
}

async function openDetail(row) {
    const res = await request.get(`/purchase/inbound/detail/${row.id}`);
    if (res.code === "200") {
        detail.data = res.data;
        detail.visible = true;
    } else {
        ElMessage.error(res.msg || "加载失败");
    }
}

function handleConfirm(row) {
    ElMessageBox.confirm("确认后将按明细增加库存，且不可撤销。是否继续？", "确认入库", { type: "warning" })
        .then(async () => {
            const res = await request.post(`/purchase/inbound/confirm/${row.id}`);
            if (res.code === "200") {
                ElMessage.success("入库已入账");
                loadList();
            } else {
                ElMessage.error(res.msg || "操作失败");
            }
        })
        .catch(() => {});
}

function handleDeleteDraft(row) {
    ElMessageBox.confirm("删除草稿入库单后，可重新从采购订单生成。", "删除", { type: "warning" })
        .then(async () => {
            const res = await request.post(`/purchase/inbound/deleteDraft/${row.id}`);
            if (res.code === "200") {
                ElMessage.success("已删除");
                loadList();
            } else {
                ElMessage.error(res.msg || "操作失败");
            }
        })
        .catch(() => {});
}

onMounted(() => {
    loadList();
});
</script>

<style scoped>
.purchase-inbound {
    padding: 12px;
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
