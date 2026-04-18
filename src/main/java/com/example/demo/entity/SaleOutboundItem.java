package com.example.demo.entity;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class SaleOutboundItem {
    private Long id;
    private Long outboundId;
    private Long saleOrderItemId;
    private Long productId;
    private Integer quantity;
    private BigDecimal price;

    private String productNameSnapshot;
    private String skuCode;
}
