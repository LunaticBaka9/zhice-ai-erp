package com.example.demo.entity;

import java.math.BigDecimal;
import java.util.Date;

import lombok.Data;

@Data
public class SaleItem {
    private Long id;
    private Long orderId;
    private Long productId;
    private String productNameSnapshot;
    private BigDecimal price;
    private Integer quantity;
    private BigDecimal subtotal;
    private Date createdAt;

    // 关联字段（非数据库列）
    private String skuCode;
    private String unit;
}
