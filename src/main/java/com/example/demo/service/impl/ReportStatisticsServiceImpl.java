package com.example.demo.service.impl;

import jakarta.annotation.Resource;

import org.springframework.stereotype.Service;

import com.example.demo.dto.InventoryAnalysisDTO;
import com.example.demo.dto.SalesAnalysisDTO;
import com.example.demo.mapper.ReportStatisticsMapper;
import com.example.demo.service.ReportStatisticsService;

@Service
public class ReportStatisticsServiceImpl implements ReportStatisticsService {

    @Resource
    private ReportStatisticsMapper reportStatisticsMapper;

    @Override
    public SalesAnalysisDTO salesAnalysis() {
        SalesAnalysisDTO dto = new SalesAnalysisDTO();
        dto.setSaleOrders(reportStatisticsMapper.selectSaleOrderStatByProduct());
        dto.setSaleOutbounds(reportStatisticsMapper.selectSaleOutboundStatByProduct());
        return dto;
    }

    @Override
    public InventoryAnalysisDTO inventoryAnalysis() {
        InventoryAnalysisDTO dto = new InventoryAnalysisDTO();
        dto.setPurchaseOrders(reportStatisticsMapper.selectPurchaseOrderStatByProduct());
        dto.setPurchaseInbounds(reportStatisticsMapper.selectPurchaseInboundStatByProduct());
        dto.setSaleOutbounds(reportStatisticsMapper.selectSaleOutboundStatByProduct());
        dto.setStocks(reportStatisticsMapper.selectStockStatByProduct());
        return dto;
    }
}
