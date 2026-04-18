package com.example.demo.constants;

/**
 * 销售出库单：0草稿 1已确认（已扣库存）
 */
public final class SaleOutboundStatus {

    private SaleOutboundStatus() {
    }

    public static final int DRAFT = 0;
    public static final int CONFIRMED = 1;
}
