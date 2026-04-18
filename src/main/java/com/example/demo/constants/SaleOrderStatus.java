package com.example.demo.constants;

/**
 * 销售订单状态：0草稿 1已确认待出库 2已出库完成 3已作废
 */
public final class SaleOrderStatus {

    private SaleOrderStatus() {
    }

    public static final int DRAFT = 0;
    public static final int CONFIRMED = 1;
    public static final int COMPLETED = 2;
    public static final int CANCELLED = 3;
}
