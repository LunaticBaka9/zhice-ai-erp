package com.lunabaka.entity;

import lombok.Data;

import java.util.Date;
import java.util.List;

@Data
public class PurchaseInbound {
    private Long id;
    private Integer purchaseId;
    private String billNo;
    private Integer warehouseId;
    private Integer status;
    private String remark;
    private Date createTime;
    private Date confirmTime;

    private String purchaseBillNo;
    private Long supplierId;
    private List<PurchaseInboundItem> items;
}
