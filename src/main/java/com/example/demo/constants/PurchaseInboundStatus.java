package com.example.demo.constants;

/**
 * 采购入库单状态：0草稿 1已确认（已入账库存）
 */
public final class PurchaseInboundStatus {

    private PurchaseInboundStatus() {
    }

    public static final int DRAFT = 0;
    public static final int CONFIRMED = 1;
}
