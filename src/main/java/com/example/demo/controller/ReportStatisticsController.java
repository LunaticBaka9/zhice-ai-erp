package com.example.demo.controller;

import jakarta.annotation.Resource;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.demo.common.Result;
import com.example.demo.dto.InventoryAnalysisDTO;
import com.example.demo.dto.SalesAnalysisDTO;
import com.example.demo.service.ReportStatisticsService;
import com.example.demo.service.SaleService;
import com.example.demo.service.SaleOutboundService;
import com.example.demo.service.PurchaseInboundService;

import java.util.HashMap;
import java.util.Map;

import com.example.demo.service.CustomerService;
import com.example.demo.service.SupplierService;
import com.example.demo.service.WarehouseService;

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
