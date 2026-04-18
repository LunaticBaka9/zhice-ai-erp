package com.example.demo.entity;

import java.math.BigDecimal;
import java.util.Date;
import java.util.List;

import lombok.Data;

@Data
public class Sale {
    private Long id;
    private String orderNo;
    private Long customerId;
    /** 出库仓库（确认出库时从该仓扣库存） */
    private Integer warehouseId;
    private Date orderDate;
    private BigDecimal totalAmount;
    private BigDecimal discountAmount;
    private BigDecimal finalAmount;
    private Integer status;
    private String remark;
    private String createdBy;
    private Date createdAt;
    private Date updatedAt;
    private Date confirmTime;
    private Date deliverTime;

    // 关联字段（非数据库列）
    private String customerName;
    private List<SaleItem> items;
}


