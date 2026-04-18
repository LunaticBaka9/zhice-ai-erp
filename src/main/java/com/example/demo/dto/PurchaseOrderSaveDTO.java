package com.example.demo.dto;

import com.example.demo.entity.Purchase;
import com.example.demo.entity.PurchaseItem;
import lombok.Data;

import java.util.List;

@Data
public class PurchaseOrderSaveDTO {
    private Purchase purchase;
    private List<PurchaseItem> items;
}
