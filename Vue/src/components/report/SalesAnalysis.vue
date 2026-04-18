<template>
    <div class="report-page">
        <el-card shadow="never" class="toolbar-card">
            <el-button type="primary" :loading="loading" @click="loadData">刷新数据</el-button>
        </el-card>
        <el-row :gutter="16">
            <el-col :span="24">
                <el-card shadow="never" header="销售订单 — 按商品汇总（数量 / 金额）">
                    <div ref="chartOrderRef" class="chart-box"></div>
                </el-card>
            </el-col>
            <el-col :span="24" class="mt16">
                <el-card shadow="never" header="销售出库 — 按商品汇总（已确认出库数量）">
                    <div ref="chartOutboundRef" class="chart-box"></div>
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
const chartOrderRef = ref(null);
const chartOutboundRef = ref(null);
let chartOrder = null;
let chartOutbound = null;

function isApiOk(res) {
    return res && (res.code === "200" || res.code === 200);
}

function toNum(v) {
    if (v == null || v === "") return 0;
    const n = Number(v);
    return Number.isFinite(n) ? n : 0;
}

function buildOrderOption(list) {
    const categories = (list || []).map((r) => r.goodsName || `ID:${r.goodsId}`);
    const qtyData = (list || []).map((r) => toNum(r.qty));
    const amtData = (list || []).map((r) => toNum(r.amount));
    return {
        tooltip: { trigger: "axis" },
        legend: { data: ["订单数量", "订单金额"] },
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
            { name: "订单数量", type: "bar", data: qtyData, emphasis: { focus: "series" } },
            { name: "订单金额", type: "bar", yAxisIndex: 1, data: amtData, emphasis: { focus: "series" } },
        ],
    };
}

function buildSingleBarOption(title, list, valueLabel) {
    const categories = (list || []).map((r) => r.goodsName || `ID:${r.goodsId}`);
    const data = (list || []).map((r) => toNum(r.qty));
    return {
        title: { text: title, left: "center", textStyle: { fontSize: 14 } },
        tooltip: { trigger: "axis" },
        grid: { left: "3%", right: "4%", bottom: categories.length > 8 ? "18%" : "12%", containLabel: true },
        xAxis: {
            type: "category",
            data: categories,
            axisLabel: { rotate: categories.length > 6 ? 28 : 0, interval: 0 },
        },
        yAxis: { type: "value", name: valueLabel },
        series: [{ type: "bar", data, name: valueLabel, emphasis: { focus: "series" } }],
    };
}

function disposeCharts() {
    chartOrder?.dispose();
    chartOutbound?.dispose();
    chartOrder = null;
    chartOutbound = null;
}

function resizeCharts() {
    chartOrder?.resize();
    chartOutbound?.resize();
}

async function loadData() {
    loading.value = true;
    try {
        const res = await request.get("/report/stat/sales");
        if (!isApiOk(res) || !res.data) {
            ElMessage.error(res?.msg || "加载失败");
            return;
        }
        const { saleOrders = [], saleOutbounds = [] } = res.data;
        await nextTick();
        disposeCharts();
        if (chartOrderRef.value) {
            chartOrder = echarts.init(chartOrderRef.value);
            chartOrder.setOption(buildOrderOption(saleOrders));
        }
        if (chartOutboundRef.value) {
            chartOutbound = echarts.init(chartOutboundRef.value);
            chartOutbound.setOption(buildSingleBarOption("", saleOutbounds, "出库数量"));
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
    height: 380px;
}
.mt16 {
    margin-top: 16px;
}
</style>
