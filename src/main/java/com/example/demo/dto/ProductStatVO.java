package com.example.demo.dto;

import java.math.BigDecimal;

import lombok.Data;

@Data
public class ProductStatVO {
    private Long goodsId;
    private String goodsName;
    /** 数量（订单行/出入库件数等） */
    private BigDecimal qty;
    /** 金额（订单小计等，无则 null） */
    private BigDecimal amount;
}
