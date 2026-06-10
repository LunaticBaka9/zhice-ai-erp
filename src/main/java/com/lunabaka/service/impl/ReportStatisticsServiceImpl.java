package com.lunabaka.service.impl;

import jakarta.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lunabaka.dto.InventoryAnalysisDTO;
import com.lunabaka.dto.SalesAnalysisDTO;
import com.lunabaka.mapper.ReportStatisticsMapper;
import com.lunabaka.service.ReportStatisticsService;

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
