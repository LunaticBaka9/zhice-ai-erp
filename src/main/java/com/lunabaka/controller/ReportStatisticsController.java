package com.lunabaka.controller;

import jakarta.annotation.Resource;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.lunabaka.common.Result;
import com.lunabaka.dto.InventoryAnalysisDTO;
import com.lunabaka.dto.SalesAnalysisDTO;
import com.lunabaka.service.ReportStatisticsService;
import com.lunabaka.service.SaleService;
import com.lunabaka.service.SaleOutboundService;
import com.lunabaka.service.PurchaseInboundService;

import java.util.HashMap;
import java.util.Map;

import com.lunabaka.service.CustomerService;
import com.lunabaka.service.SupplierService;
import com.lunabaka.service.WarehouseService;

@RestController
@RequestMapping("/report/stat")
public class ReportStatisticsController {

    @Resource
    private ReportStatisticsService reportStatisticsService;

    @Resource
    private SaleService saleService;

    @Resource
    private SaleOutboundService saleOutboundService;

    @Resource
    private PurchaseInboundService purchaseInboundService;

    @Resource
    private CustomerService customerService;

    @Resource
    private SupplierService supplierService;

    @Resource
    private WarehouseService warehouseService;

    @GetMapping("/sales")
    public Result salesAnalysis() {
        SalesAnalysisDTO data = reportStatisticsService.salesAnalysis();
        return Result.success(data);
    }

    @GetMapping("/inventory")
    public Result inventoryAnalysis() {
        InventoryAnalysisDTO data = reportStatisticsService.inventoryAnalysis();
        return Result.success(data);
    }

    @GetMapping("/core")
    public Result coreAnalysis() {
        Map<String, Object> result = new HashMap<>();
        result.put("sale", saleService.getStatistics());
        result.put("outbound", saleOutboundService.getStatistics());
        result.put("customerCount", customerService.count());
        result.put("supplierCount", supplierService.count());
        result.put("warehouseCount", warehouseService.count());
        return Result.success(result);
    }
}
