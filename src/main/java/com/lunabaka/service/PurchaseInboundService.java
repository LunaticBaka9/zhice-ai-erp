package com.lunabaka.service;

import com.lunabaka.entity.PurchaseInbound;
import com.github.pagehelper.PageInfo;

public interface PurchaseInboundService {

    Long createFromPurchaseId(Integer purchaseId, String remark);

    void confirm(Long inboundId);

    void deleteDraft(Long inboundId);

    PurchaseInbound detail(Long id);

    PageInfo<PurchaseInbound> page(int pageNum, int pageSize, PurchaseInbound query);
}
