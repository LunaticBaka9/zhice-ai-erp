package com.lunabaka.service;

import com.lunabaka.dto.InventoryAnalysisDTO;
import com.lunabaka.dto.SalesAnalysisDTO;

public interface ReportStatisticsService {

    SalesAnalysisDTO salesAnalysis();

    InventoryAnalysisDTO inventoryAnalysis();
}
