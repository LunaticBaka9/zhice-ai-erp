package com.example.demo.entity;

import lombok.Data;

import java.math.BigDecimal;
import java.util.Date;

@Data
public class Inventory {
    private Long id;
    private Integer goodsId;
    private Integer warehouseId;
    private String location;
    private String batchNo;
    private BigDecimal qtyOnHand;
    private BigDecimal qtyAvailable;
    private BigDecimal lockedQty;
    private BigDecimal totalCost;
    private Date lastInboundTime;
    private Date lastOutboundTime;
    private Date createTime;
    private Date updateTime;
    private Integer createBy;
    private Integer updateBy;
}
