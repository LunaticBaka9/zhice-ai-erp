<template>
    <div class="purchase-order">
        <el-card shadow="never" class="search-card">
            <el-form :inline="true" :model="searchForm" class="search-form">
                <el-form-item label="单号">
                    <el-input v-model="searchForm.billNo" placeholder="采购单号" clearable style="width: 160px" />
                </el-form-item>
                <el-form-item label="状态">
                    <el-select v-model="searchForm.status" placeholder="全部" clearable style="width: 140px">
                        <el-option label="草稿" :value="0" />
                        <el-option label="已确认待入库" :value="1" />
                        <el-option label="已入库完成" :value="2" />
                        <el-option label="已作废" :value="3" />
                    </el-select>
                </el-form-item>
                <el-form-item>
                    <el-button type="primary" @click="loadList">查询</el-button>
                    <el-button @click="resetSearch">重置</el-button>
                </el-form-item>
            </el-form>
        </el-card>

        <div class="toolbar">
            <el-button type="primary" @click="openAdd">
                <el-icon><Plus /></el-icon>
                新增采购订单
            </el-button>
        </div>

        <el-card shadow="never">
            <el-table v-loading="loading" :data="tableData" border stripe style="width: 100%">
                <el-table-column prop="billNo" label="采购单号" width="160" />
                <el-table-column prop="supplierName" label="供应商" min-width="120" />
                <el-table-column prop="warehouseId" label="仓库ID" width="88" />
                <el-table-column prop="totalAmount" label="总金额" width="100" />
                <el-table-column label="状态" width="120">
                    <template #default="{ row }">
                        <el-tag :type="poStatusType(row.status)">{{ poStatusText(row.status) }}</el-tag>
                    </template>
                </el-table-column>
                <el-table-column prop="createTime" label="创建时间" width="170" />
                <el-table-column label="操作" width="260" fixed="right">
                    <template #default="{ row }">
                        <el-button link type="primary" size="small" @click="openDetail(row)">详情</el-button>
                        <el-button v-if="row.status === 0" link type="primary" size="small" @click="openEdit(row)">编辑</el-button>
                        <el-button v-if="row.status === 0" link type="success" size="small" @click="handleConfirm(row)">确认</el-button>
                        <el-button v-if="row.status !== 2 && row.status !== 3" link type="danger" size="small" @click="handleCancel(row)">作废</el-button>
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

        <el-dialog v-model="dialog.visible" :title="dialog.title" width="900px" destroy-on-close @closed="onDialogClosed">
            <el-form :model="dialog.form" label-width="100px">
                <el-row :gutter="12">
                    <el-col :span="8">
                        <el-form-item label="供应商" required>
                            <el-select v-model="dialog.form.supplierId" placeholder="选择供应商" filterable style="width: 100%">
                                <el-option v-for="s in suppliers" :key="s.id" :label="s.name" :value="s.id" />
                            </el-select>
                        </el-form-item>
                    </el-col>
                    <el-col :span="8">
                        <el-form-item label="入库仓库" required>
                            <el-select v-model="dialog.form.warehouseId" placeholder="选择仓库" filterable style="width: 100%">
                                <el-option v-for="w in warehouses" :key="w.id" :label="w.name" :value="Number(w.id)" />
                            </el-select>
                        </el-form-item>
                    </el-col>
                    <el-col :span="8">
                        <el-form-item label="单号">
                            <el-input v-model="dialog.form.billNo" placeholder="留空自动生成" clearable />
                        </el-form-item>
                    </el-col>
                </el-row>
                <el-form-item label="备注">
                    <el-input v-model="dialog.form.remark" type="textarea" :rows="2" />
                </el-form-item>
            </el-form>
            <div class="sub-table-wrap">
                <div class="sub-table-head">
                    <span>采购明细</span>
                    <el-button type="primary" link @click="addItemRow">添加行</el-button>
                </div>
                <el-table :data="dialog.items" border size="small">
                    <el-table-column label="商品" min-width="200">
                        <template #default="{ row }">
                            <el-select v-model="row.goodsId" placeholder="选择商品" filterable style="width: 100%">
                                <el-option
                                    v-for="g in goodsList"
                                    :key="g.id"
                                    :label="`${g.skuCode || ''} ${g.name}`"
                                    :value="Number(g.id)"
                                />
                            </el-select>
                        </template>
                    </el-table-column>
                    <el-table-column label="数量" width="120">
                        <template #default="{ row }">
                            <el-input-number v-model="row.quantity" :min="0.01" :precision="2" :step="1" style="width: 100%" @change="calcRow(row)" />
                        </template>
                    </el-table-column>
                    <el-table-column label="单价" width="120">
                        <template #default="{ row }">
                            <el-input-number v-model="row.unitPrice" :min="0" :precision="2" :step="1" style="width: 100%" @change="calcRow(row)" />
                        </template>
                    </el-table-column>
                    <el-table-column label="金额" width="100">
                        <template #default="{ row }">
                            {{ row.amount != null ? Number(row.amount).toFixed(2) : "0.00" }}
                        </template>
                    </el-table-column>
                    <el-table-column label="操作" width="70" fixed="right">
                        <template #default="{ $index }">
                            <el-button link type="danger" size="small" @click="dialog.items.splice($index, 1)">删</el-button>
                        </template>
                    </el-table-column>
                </el-table>
            </div>
            <template #footer>
                <el-button @click="dialog.visible = false">取消</el-button>
                <el-button type="primary" :loading="dialog.saving" @click="submitSave">保存</el-button>
            </template>
        </el-dialog>

        <el-dialog
            v-model="detail.visible"
            title="采购订单详情"
            width="640px"
            align-center
            destroy-on-close
        >
            <template v-if="detail.data">
                <el-descriptions :column="1" border>
                    <el-descriptions-item label="单号">{{ detail.data.billNo }}</el-descriptions-item>
                    <el-descriptions-item label="供应商">{{ detail.data.supplierName }}</el-descriptions-item>
                    <el-descriptions-item label="仓库ID">{{ detail.data.warehouseId }}</el-descriptions-item>
                    <el-descriptions-item label="总金额">{{ detail.data.totalAmount }}</el-descriptions-item>
                    <el-descriptions-item label="状态">{{ poStatusText(detail.data.status) }}</el-descriptions-item>
                    <el-descriptions-item label="备注">{{ detail.data.remark || "—" }}</el-descriptions-item>
                </el-descriptions>
                <el-table :data="detail.data.items || []" border size="small" class="mt16">
                    <el-table-column prop="skuCode" label="SKU" width="120" />
                    <el-table-column prop="goodsName" label="商品" />
                    <el-table-column prop="quantity" label="数量" width="90" />
                    <el-table-column prop="unitPrice" label="单价" width="90" />
                    <el-table-column prop="amount" label="金额" width="90" />
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
const suppliers = ref([]);
const warehouses = ref([]);
const goodsList = ref([]);

const searchForm = reactive({
    billNo: "",
    status: null,
});

const pagination = reactive({
    pageNum: 1,
    pageSize: 10,
    total: 0,
});

const dialog = reactive({
    visible: false,
    title: "采购订单",
    saving: false,
    form: {
        id: null,
        billNo: "",
        supplierId: null,
        warehouseId: null,
        remark: "",
    },
    items: [],
});

const detail = reactive({
    visible: false,
    data: null,
});

function poStatusText(s) {
    const m = { 0: "草稿", 1: "已确认待入库", 2: "已入库完成", 3: "已作废" };
    return m[s] != null ? m[s] : s;
}

function poStatusType(s) {
    const m = { 0: "info", 1: "warning", 2: "success", 3: "danger" };
    return m[s] || "info";
}

async function loadBase() {
    const [sup, wh, goods] = await Promise.all([
        request.get("/supplier/selectAllCustomer"),
        request.get("/warehouse/selectAll"),
        request.get("/goods/selectAllGoods"),
    ]);
    if (sup.code === "200") suppliers.value = sup.data || [];
    if (wh.code === "200") warehouses.value = wh.data || [];
    if (goods.code === "200") goodsList.value = goods.data || [];
}

async function loadList() {
    loading.value = true;
    try {
        const res = await request.get("/purchase/order/list", {
            params: {
                pageNum: pagination.pageNum,
                pageSize: pagination.pageSize,
                billNo: searchForm.billNo || undefined,
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
    searchForm.status = null;
    pagination.pageNum = 1;
    loadList();
}

function openAdd() {
    dialog.title = "新增采购订单";
    dialog.form = { id: null, billNo: "", supplierId: null, warehouseId: null, remark: "" };
    dialog.items = [];
    dialog.visible = true;
}

async function openEdit(row) {
    const res = await request.get(`/purchase/order/detail/${row.id}`);
    if (res.code !== "200" || !res.data) {
        ElMessage.error(res.msg || "加载失败");
        return;
    }
    const p = res.data;
    dialog.title = "编辑采购订单";
    dialog.form = {
        id: p.id,
        billNo: p.billNo,
        supplierId: p.supplierId,
        warehouseId: p.warehouseId,
        remark: p.remark || "",
    };
    dialog.items = (p.items || []).map((it) => ({
        id: it.id,
        goodsId: it.goodsId,
        quantity: Number(it.quantity),
        unitPrice: Number(it.unitPrice),
        amount: Number(it.amount),
    }));
    dialog.visible = true;
}

async function openDetail(row) {
    const res = await request.get(`/purchase/order/detail/${row.id}`);
    if (res.code === "200") {
        detail.data = res.data;
        detail.visible = true;
    } else {
        ElMessage.error(res.msg || "加载失败");
    }
}

function addItemRow() {
    dialog.items.push({
        goodsId: null,
        quantity: 1,
        unitPrice: 0,
        amount: 0,
    });
}

function calcRow(row) {
    const q = Number(row.quantity) || 0;
    const p = Number(row.unitPrice) || 0;
    row.amount = Math.round(q * p * 100) / 100;
}

async function submitSave() {
    if (!dialog.form.supplierId || !dialog.form.warehouseId) {
        ElMessage.warning("请选择供应商与仓库");
        return;
    }
    if (!dialog.items.length) {
        ElMessage.warning("请至少一行明细");
        return;
    }
    for (const it of dialog.items) {
        if (!it.goodsId || !it.quantity || it.quantity <= 0) {
            ElMessage.warning("明细存在未选商品或数量无效");
            return;
        }
        calcRow(it);
    }
    dialog.saving = true;
    try {
        const payload = {
            purchase: {
                id: dialog.form.id,
                billNo: dialog.form.billNo || null,
                supplierId: dialog.form.supplierId,
                warehouseId: dialog.form.warehouseId,
                remark: dialog.form.remark || null,
            },
            items: dialog.items.map((it) => ({
                id: it.id,
                goodsId: it.goodsId,
                quantity: it.quantity,
                unitPrice: it.unitPrice,
            })),
        };
        const res = await request.post("/purchase/order/save", payload);
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

function onDialogClosed() {
    dialog.saving = false;
}

function handleConfirm(row) {
    ElMessageBox.confirm("确认后订单将进入「待入库」，且不可再改明细。是否确认？", "确认采购订单", {
        type: "warning",
    })
        .then(async () => {
            const res = await request.post(`/purchase/order/confirm/${row.id}`);
            if (res.code === "200") {
                ElMessage.success("已确认");
                loadList();
            } else {
                ElMessage.error(res.msg || "操作失败");
            }
        })
        .catch(() => {});
}

function handleCancel(row) {
    ElMessageBox.confirm("确定作废该采购订单？", "作废", { type: "warning" })
        .then(async () => {
            const res = await request.post(`/purchase/order/cancel/${row.id}`);
            if (res.code === "200") {
                ElMessage.success("已作废");
                loadList();
            } else {
                ElMessage.error(res.msg || "操作失败");
            }
        })
        .catch(() => {});
}

onMounted(() => {
    loadBase();
    loadList();
});
</script>

<style scoped>
.purchase-order {
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
.sub-table-wrap {
    margin-top: 8px;
}
.sub-table-head {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 8px;
    font-weight: 500;
}
.mt16 {
    margin-top: 16px;
}
</style>
