<template>
    <div class="core-analysis">
        <el-card shadow="never" class="toolbar-card">
            <el-button type="primary" :loading="loading" @click="loadData">刷新数据</el-button>
        </el-card>

        <el-row :gutter="16" class="stat-row">
            <el-col :span="8">
                <el-card shadow="hover" class="stat-card">
                    <div class="stat-content">
                        <div class="stat-icon" style="background-color: #409eff">
                            <el-icon><User /></el-icon>
                        </div>
                        <div class="stat-info">
                            <div class="stat-label">客户数量</div>
                            <div class="stat-value">{{ statistics.customerCount }}</div>
                        </div>
                    </div>
                </el-card>
            </el-col>
            <el-col :span="8">
                <el-card shadow="hover" class="stat-card">
                    <div class="stat-content">
                        <div class="stat-icon" style="background-color: #67c23a">
                            <el-icon><OfficeBuilding /></el-icon>
                        </div>
                        <div class="stat-info">
                            <div class="stat-label">仓库数量</div>
                            <div class="stat-value">{{ statistics.warehouseCount }}</div>
                        </div>
                    </div>
                </el-card>
            </el-col>
            <el-col :span="8">
                <el-card shadow="hover" class="stat-card">
                    <div class="stat-content">
                        <div class="stat-icon" style="background-color: #e6a23c">
                            <el-icon><Shop /></el-icon>
                        </div>
                        <div class="stat-info">
                            <div class="stat-label">供应商数量</div>
                            <div class="stat-value">{{ statistics.supplierCount }}</div>
                        </div>
                    </div>
                </el-card>
            </el-col>
        </el-row>

        <el-row :gutter="16">
            <el-col :span="12">
                <el-card shadow="never" header="销售订单统计">
                    <div ref="saleChartRef" class="chart-box"></div>
                </el-card>
            </el-col>
            <el-col :span="12">
                <el-card shadow="never" header="销售出库统计">
                    <div ref="outboundChartRef" class="chart-box"></div>
                </el-card>
            </el-col>
        </el-row>

        <el-row :gutter="16" class="mt16">
            <el-col :span="12">
                <el-card shadow="never" header="销售订单状态分布">
                    <div ref="salePieRef" class="chart-box"></div>
                </el-card>
            </el-col>
            <el-col :span="12">
                <el-card shadow="never" header="出库单状态分布">
                    <div ref="outboundPieRef" class="chart-box"></div>
                </el-card>
            </el-col>
        </el-row>
    </div>
</template>

<script setup>
import { ref, reactive, onMounted, onBeforeUnmount, nextTick } from "vue";
import { ElMessage } from "element-plus";
import { User, OfficeBuilding, Shop } from "@element-plus/icons-vue";
import * as echarts from "echarts";
import request from "../../utils/request";

const loading = ref(false);
const statistics = reactive({
    customerCount: 0,
    warehouseCount: 0,
    supplierCount: 0,
});
const saleChartRef = ref(null);
const outboundChartRef = ref(null);
const salePieRef = ref(null);
const outboundPieRef = ref(null);
let saleChart = null;
let outboundChart = null;
let salePie = null;
let outboundPie = null;

function isApiOk(res) {
    return res && (res.code === "200" || res.code === 200);
}

function buildBarOption(title, data) {
    const categories = Object.keys(data);
    const values = Object.values(data);
    return {
        tooltip: { trigger: "axis" },
        grid: { left: "3%", right: "4%", bottom: "12%", containLabel: true },
        xAxis: { type: "category", data: categories },
        yAxis: { type: "value" },
        series: [{ type: "bar", data: values, itemStyle: { color: "#409eff" } }],
    };
}

function buildPieOption(data) {
    const chartData = Object.entries(data).map(([name, value]) => ({ name, value }));
    return {
        tooltip: { trigger: "item" },
        legend: { bottom: "0%" },
        series: [
            {
                type: "pie",
                radius: ["40%", "70%"],
                center: ["50%", "45%"],
                data: chartData,
                emphasis: {
                    itemStyle: {
                        shadowBlur: 10,
                        shadowOffsetX: 0,
                        shadowColor: "rgba(0, 0, 0, 0.5)",
                    },
                },
            },
        ],
    };
}

function disposeCharts() {
    saleChart?.dispose();
    outboundChart?.dispose();
    salePie?.dispose();
    outboundPie?.dispose();
    saleChart = null;
    outboundChart = null;
    salePie = null;
    outboundPie = null;
}

function resizeCharts() {
    saleChart?.resize();
    outboundChart?.resize();
    salePie?.resize();
    outboundPie?.resize();
}

async function loadData() {
    loading.value = true;
    try {
        const res = await request.get("/report/stat/core");
        if (!isApiOk(res) || !res.data) {
            ElMessage.error(res?.msg || "加载失败");
            return;
        }
        const { sale = {}, outbound = {}, customerCount = 0, warehouseCount = 0, supplierCount = 0 } = res.data;
        statistics.customerCount = customerCount || 0;
        statistics.warehouseCount = warehouseCount || 0;
        statistics.supplierCount = supplierCount || 0;
        await nextTick();
        disposeCharts();

        if (saleChartRef.value) {
            saleChart = echarts.init(saleChartRef.value);
            saleChart.setOption(buildBarOption("销售订单统计", {
                订单总数: sale.totalCount || 0,
                草稿: sale.draftCount || 0,
                待出库: sale.pendingCount || 0,
                已完成: sale.completedCount || 0,
                已作废: sale.cancelledCount || 0,
            }));
        }

        if (outboundChartRef.value) {
            outboundChart = echarts.init(outboundChartRef.value);
            outboundChart.setOption(buildBarOption("出库单统计", {
                出库单总数: outbound.total || 0,
                草稿: outbound.draft || 0,
                已确认: outbound.confirmed || 0,
            }));
        }

        if (salePieRef.value) {
            salePie = echarts.init(salePieRef.value);
            salePie.setOption(buildPieOption({
                草稿: sale.draftCount || 0,
                待出库: sale.pendingCount || 0,
                已完成: sale.completedCount || 0,
                已作废: sale.cancelledCount || 0,
            }));
        }

        if (outboundPieRef.value) {
            outboundPie = echarts.init(outboundPieRef.value);
            outboundPie.setOption(buildPieOption({
                草稿: outbound.draft || 0,
                已确认: outbound.confirmed || 0,
            }));
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
.core-analysis {
    padding: 12px;
}
.toolbar-card {
    margin-bottom: 12px;
}
.stat-row {
    margin-bottom: 16px;
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
.chart-box {
    width: 100%;
    height: 320px;
}
.mt16 {
    margin-top: 16px;
}
</style>