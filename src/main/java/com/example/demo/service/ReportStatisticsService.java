package com.example.demo.service;

import com.example.demo.dto.InventoryAnalysisDTO;
import com.example.demo.dto.SalesAnalysisDTO;

public interface ReportStatisticsService {

    SalesAnalysisDTO salesAnalysis();

    InventoryAnalysisDTO inventoryAnalysis();
}
