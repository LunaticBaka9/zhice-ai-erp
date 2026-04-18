package com.example.demo.dto;

import java.util.List;

import lombok.Data;

@Data
public class SalesAnalysisDTO {
    /** 销售订单明细：按商品汇总数量与金额 */
    private List<ProductStatVO> saleOrders;
    /** 已确认销售出库：按商品汇总数量 */
    private List<ProductStatVO> saleOutbounds;
}
