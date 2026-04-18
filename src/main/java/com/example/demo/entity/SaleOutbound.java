package com.example.demo.entity;

import lombok.Data;

import java.util.Date;
import java.util.List;

@Data
public class SaleOutbound {
    private Long id;
    private Long saleOrderId;
    private String billNo;
    private Integer warehouseId;
    private Integer status;
    private String remark;
    private Date createTime;
    private Date confirmTime;

    private String orderNo;
    private Long customerId;
    private List<SaleOutboundItem> items;
}
