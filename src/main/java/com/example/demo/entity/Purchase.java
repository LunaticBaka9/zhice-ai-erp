package com.example.demo.entity;

import java.util.Date;

import lombok.Data;

@Data
public class Purchase {

    private Long id;
    private String billNo;
    private Long supplierId;
    private Long warehouseId;
    private String totalAmount;
    private int status;
    private Date inStockTime;
}
