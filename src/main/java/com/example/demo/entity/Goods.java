package com.example.demo.entity;

import lombok.Data;

@Data
public class Goods {
    private Long id;
    private String name;
    private Long categoryId;
    private String unit;
    private double sale_price;
    private double cost_price;
    private String barcode;
    private int stock_low; //库存预警下限
}
