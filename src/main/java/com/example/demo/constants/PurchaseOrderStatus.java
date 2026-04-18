package com.example.demo.constants;

/**
 * 采购订单状态：0草稿 1已确认待入库 2已入库完成 3已作废
 */
public final class PurchaseOrderStatus {

    private PurchaseOrderStatus() {
    }

    public static final int DRAFT = 0;
    public static final int CONFIRMED = 1;
    public static final int COMPLETED = 2;
    public static final int CANCELLED = 3;
}
