package com.example.demo.entity;

import lombok.Data;

import java.util.Date;
import java.util.List;

@Data
public class Purchase {

    private Long id;
    private String billNo;
    private Long supplierId;
    private Integer warehouseId;
    private String totalAmount;
    private Integer status;
    private Date inStockTime;
    private String remark;
    private Date createTime;
    private Date updateTime;
    private Date confirmTime;

    private List<PurchaseItem> items;
    private String supplierName;
}
