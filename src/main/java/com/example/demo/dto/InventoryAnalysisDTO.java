package com.example.demo.dto;

import java.util.List;

import lombok.Data;

@Data
public class InventoryAnalysisDTO {
    /** 采购订单明细：按商品汇总 */
    private List<ProductStatVO> purchaseOrders;
    /** 已确认采购入库：按商品汇总数量 */
    private List<ProductStatVO> purchaseInbounds;
    /** 已确认销售出库：按商品汇总数量 */
    private List<ProductStatVO> saleOutbounds;
    /** 当前在手库存：按商品汇总 qty_on_hand */
    private List<ProductStatVO> stocks;
}
