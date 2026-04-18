<template>
    <div class="purchase-query">
        <el-tabs v-model="activeTab" @tab-change="onTab">
            <el-tab-pane label="采购订单" name="order">
                <el-card shadow="never" class="search-card">
                    <el-form :inline="true" :model="orderSearch">
                        <el-form-item label="单号">
                            <el-input v-model="orderSearch.billNo" clearable style="width: 140px" />
                        </el-form-item>
                        <el-form-item label="状态">
                            <el-select v-model="orderSearch.status" clearable placeholder="全部" style="width: 130px">
                                <el-option label="草稿" :value="0" />
                                <el-option label="已确认待入库" :value="1" />
                                <el-option label="已入库完成" :value="2" />
                                <el-option label="已作废" :value="3" />
                            </el-select>
                        </el-form-item>
                        <el-form-item>
                            <el-button type="primary" @click="loadOrders">查询</el-button>
                        </el-form-item>
                    </el-form>
                </el-card>
                <el-card shadow="never">
                    <el-table v-loading="orderLoading" :data="orderList" border stripe>
                        <el-table-column prop="billNo" label="采购单号" width="160" />
                        <el-table-column prop="supplierName" label="供应商" min-width="120" />
                        <el-table-column prop="totalAmount" label="总金额" width="100" />
                        <el-table-column label="状态" width="120">
                            <template #default="{ row }">
                                <el-tag>{{ orderStatusText(row.status) }}</el-tag>
                            </template>
                        </el-table-column>
                        <el-table-column prop="createTime" label="创建时间" width="170" />
                    </el-table>
                    <div class="pagination-container">
                        <el-pagination
                            v-model:current-page="orderPage.pageNum"
                            v-model:page-size="orderPage.pageSize"
                            :total="orderPage.total"
                            layout="total, prev, pager, next"
                            @current-change="loadOrders"
                        />
                    </div>
                </el-card>
            </el-tab-pane>
            <el-tab-pane label="采购入库" name="inbound">
                <el-card shadow="never" class="search-card">
                    <el-form :inline="true" :model="inSearch">
                        <el-form-item label="入库单号">
                            <el-input v-model="inSearch.billNo" clearable style="width: 140px" />
                        </el-form-item>
                        <el-form-item label="采购单号">
                            <el-input v-model="inSearch.purchaseBillNo" clearable style="width: 140px" />
                        </el-form-item>
                        <el-form-item>
                            <el-button type="primary" @click="loadInbounds">查询</el-button>
                        </el-form-item>
                    </el-form>
                </el-card>
                <el-card shadow="never">
                    <el-table v-loading="inLoading" :data="inboundList" border stripe>
                        <el-table-column prop="billNo" label="入库单号" width="170" />
                        <el-table-column prop="purchaseBillNo" label="采购单号" width="160" />
                        <el-table-column prop="warehouseId" label="仓库ID" width="88" />
                        <el-table-column label="状态" width="120">
                            <template #default="{ row }">
                                <el-tag :type="row.status === 1 ? 'success' : 'info'">
                                    {{ row.status === 1 ? "已入账" : "草稿" }}
                                </el-tag>
                            </template>
                        </el-table-column>
                        <el-table-column prop="createTime" label="创建时间" width="170" />
                        <el-table-column prop="confirmTime" label="入账时间" width="170" />
                    </el-table>
                    <div class="pagination-container">
                        <el-pagination
                            v-model:current-page="inPage.pageNum"
                            v-model:page-size="inPage.pageSize"
                            :total="inPage.total"
                            layout="total, prev, pager, next"
                            @current-change="loadInbounds"
                        />
                    </div>
                </el-card>
            </el-tab-pane>
        </el-tabs>
    </div>
</template>

<script setup>
import { reactive, ref, onMounted } from "vue";
import { ElMessage } from "element-plus";
import request from "../../utils/request";

const activeTab = ref("order");

const orderSearch = reactive({ billNo: "", status: null });
const orderLoading = ref(false);
const orderList = ref([]);
const orderPage = reactive({ pageNum: 1, pageSize: 10, total: 0 });

const inSearch = reactive({ billNo: "", purchaseBillNo: "" });
const inLoading = ref(false);
const inboundList = ref([]);
const inPage = reactive({ pageNum: 1, pageSize: 10, total: 0 });

function orderStatusText(s) {
    const m = { 0: "草稿", 1: "已确认待入库", 2: "已入库完成", 3: "已作废" };
    return m[s] != null ? m[s] : s;
}

async function loadOrders() {
    orderLoading.value = true;
    try {
        const res = await request.get("/purchase/order/list", {
            params: {
                pageNum: orderPage.pageNum,
                pageSize: orderPage.pageSize,
                billNo: orderSearch.billNo || undefined,
                status: orderSearch.status != null ? orderSearch.status : undefined,
            },
        });
        if (res.code === "200" && res.data) {
            orderList.value = res.data.list || [];
            orderPage.total = res.data.total || 0;
        } else {
            ElMessage.error(res.msg || "加载失败");
        }
    } finally {
        orderLoading.value = false;
    }
}

async function loadInbounds() {
    inLoading.value = true;
    try {
        const res = await request.get("/purchase/inbound/list", {
            params: {
                pageNum: inPage.pageNum,
                pageSize: inPage.pageSize,
                billNo: inSearch.billNo || undefined,
                purchaseBillNo: inSearch.purchaseBillNo || undefined,
            },
        });
        if (res.code === "200" && res.data) {
            inboundList.value = res.data.list || [];
            inPage.total = res.data.total || 0;
        } else {
            ElMessage.error(res.msg || "加载失败");
        }
    } finally {
        inLoading.value = false;
    }
}

function onTab(name) {
    if (name === "order") loadOrders();
    else loadInbounds();
}

onMounted(() => {
    loadOrders();
});
</script>

<style scoped>
.purchase-query {
    padding: 12px;
}
.search-card {
    margin-bottom: 12px;
}
.pagination-container {
    margin-top: 16px;
    display: flex;
    justify-content: flex-end;
}
</style>
