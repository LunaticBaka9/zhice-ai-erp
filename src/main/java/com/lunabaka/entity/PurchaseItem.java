package com.lunabaka.entity;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class PurchaseItem {
    private Long id;
    private Integer purchaseId;
    private Integer goodsId;
    private BigDecimal quantity;
    private BigDecimal unitPrice;
    private BigDecimal amount;
    private Integer sortNo;

    private String goodsName;
    private String skuCode;
}
