package com.example.demo.service;

import com.example.demo.dto.PurchaseOrderSaveDTO;
import com.example.demo.entity.Purchase;
import com.github.pagehelper.PageInfo;

import java.util.List;

public interface PurchaseOrderService {

    /**
     * @return 采购订单 id
     */
    Long save(PurchaseOrderSaveDTO dto);

    void confirm(Long id);

    void cancel(Long id);

    Purchase detail(Long id);

    PageInfo<Purchase> page(int pageNum, int pageSize, Purchase query);

    List<Purchase> listEligibleForInbound();
}
