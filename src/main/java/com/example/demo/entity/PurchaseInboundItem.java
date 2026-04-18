package com.example.demo.entity;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class PurchaseInboundItem {
    private Long id;
    private Long inboundId;
    private Long purchaseItemId;
    private Integer goodsId;
    private BigDecimal quantity;
    private BigDecimal unitPrice;

    private String goodsName;
    private String skuCode;
}
