<template>
    <div class="report-page">
        <el-card shadow="never" class="toolbar-card">
            <el-button type="primary" :loading="loading" @click="loadData">刷新数据</el-button>
        </el-card>
        <el-row :gutter="16">
            <el-col :xs="24" :lg="12">
                <el-card shadow="never" header="采购订单 — 按商品汇总（数量 / 金额）">
                    <div ref="chartPurchaseRef" class="chart-box"></div>
                </el-card>
            </el-col>
            <el-col :xs="24" :lg="12" class="mt16-lg">
                <el-card shadow="never" header="采购入库 — 按商品汇总（已入账数量）">
                    <div ref="chartInboundRef" class="chart-box"></div>
                </el-card>
            </el-col>
            <el-col :xs="24" :lg="12" class="mt16">
                <el-card shadow="never" header="销售出库 — 按商品汇总（已确认出库数量）">
                    <div ref="chartOutboundRef" class="chart-box"></div>
                </el-card>
            </el-col>
            <el-col :xs="24" :lg="12" class="mt16">
                <el-card shadow="never" header="当前库存 — 按商品汇总（在手数量）">
                    <div ref="chartStockRef" class="chart-box"></div>
                </el-card>
            </el-col>
        </el-row>
    </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount, nextTick } from "vue";
import { ElMessage } from "element-plus";
import * as echarts from "echarts";
import request from "../../utils/request";

const loading = ref(false);
const chartPurchaseRef = ref(null);
const chartInboundRef = ref(null);
const chartOutboundRef = ref(null);
const chartStockRef = ref(null);
let chartPurchase = null;
let chartInbound = null;
let chartOutbound = null;
let chartStock = null;

function isApiOk(res) {
    return res && (res.code === "200" || res.code === 200);
}

function toNum(v) {
    if (v == null || v === "") return 0;
    const n = Number(v);
    return Number.isFinite(n) ? n : 0;
}

function buildDualBarOption(list) {
    const categories = (list || []).map((r) => r.goodsName || `ID:${r.goodsId}`);
    const qtyData = (list || []).map((r) => toNum(r.qty));
    const amtData = (list || []).map((r) => toNum(r.amount));
    return {
        tooltip: { trigger: "axis" },
        legend: { data: ["数量", "金额"] },
        grid: { left: "3%", right: "4%", bottom: categories.length > 8 ? "18%" : "12%", containLabel: true },
        xAxis: {
            type: "category",
            data: categories,
            axisLabel: { rotate: categories.length > 6 ? 28 : 0, interval: 0 },
        },
        yAxis: [
            { type: "value", name: "数量", alignTicks: true },
            { type: "value", name: "金额", alignTicks: true },
        ],
        series: [
            { name: "数量", type: "bar", data: qtyData, emphasis: { focus: "series" } },
            { name: "金额", type: "bar", yAxisIndex: 1, data: amtData, emphasis: { focus: "series" } },
        ],
    };
}

function buildSingleBarOption(list, yName) {
    const categories = (list || []).map((r) => r.goodsName || `ID:${r.goodsId}`);
    const data = (list || []).map((r) => toNum(r.qty));
    return {
        tooltip: { trigger: "axis" },
        grid: { left: "3%", right: "4%", bottom: categories.length > 8 ? "18%" : "12%", containLabel: true },
        xAxis: {
            type: "category",
            data: categories,
            axisLabel: { rotate: categories.length > 6 ? 28 : 0, interval: 0 },
        },
        yAxis: { type: "value", name: yName },
        series: [{ type: "bar", data, name: yName, emphasis: { focus: "series" } }],
    };
}

function disposeCharts() {
    chartPurchase?.dispose();
    chartInbound?.dispose();
    chartOutbound?.dispose();
    chartStock?.dispose();
    chartPurchase = null;
    chartInbound = null;
    chartOutbound = null;
    chartStock = null;
}

function resizeCharts() {
    chartPurchase?.resize();
    chartInbound?.resize();
    chartOutbound?.resize();
    chartStock?.resize();
}

async function loadData() {
    loading.value = true;
    try {
        const res = await request.get("/report/stat/inventory");
        if (!isApiOk(res) || !res.data) {
            ElMessage.error(res?.msg || "加载失败");
            return;
        }
        const d = res.data;
        const purchaseOrders = d.purchaseOrders || [];
        const purchaseInbounds = d.purchaseInbounds || [];
        const saleOutbounds = d.saleOutbounds || [];
        const stocks = d.stocks || [];
        await nextTick();
        disposeCharts();
        if (chartPurchaseRef.value) {
            chartPurchase = echarts.init(chartPurchaseRef.value);
            chartPurchase.setOption(buildDualBarOption(purchaseOrders));
        }
        if (chartInboundRef.value) {
            chartInbound = echarts.init(chartInboundRef.value);
            chartInbound.setOption(buildSingleBarOption(purchaseInbounds, "入库数量"));
        }
        if (chartOutboundRef.value) {
            chartOutbound = echarts.init(chartOutboundRef.value);
            chartOutbound.setOption(buildSingleBarOption(saleOutbounds, "出库数量"));
        }
        if (chartStockRef.value) {
            chartStock = echarts.init(chartStockRef.value);
            chartStock.setOption(buildSingleBarOption(stocks, "在手数量"));
        }
    } finally {
        loading.value = false;
    }
}

onMounted(() => {
    loadData();
    window.addEventListener("resize", resizeCharts);
});

onBeforeUnmount(() => {
    window.removeEventListener("resize", resizeCharts);
    disposeCharts();
});
</script>

<style scoped>
.report-page {
    padding: 12px;
}
.toolbar-card {
    margin-bottom: 12px;
}
.chart-box {
    width: 100%;
    height: 340px;
}
.mt16 {
    margin-top: 16px;
}
@media (min-width: 992px) {
    .mt16-lg {
        margin-top: 0;
    }
}
@media (max-width: 991px) {
    .mt16-lg {
        margin-top: 16px;
    }
}
</style>
