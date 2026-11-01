package com.lunabaka.dto;

import com.lunabaka.entity.Purchase;
import com.lunabaka.entity.PurchaseItem;
import lombok.Data;

import java.util.List;

@Data
public class PurchaseOrderSaveDTO {
    private Purchase purchase;
    private List<PurchaseItem> items;
}
