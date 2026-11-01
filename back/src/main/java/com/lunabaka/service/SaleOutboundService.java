package com.lunabaka.service;

import com.lunabaka.entity.SaleOutbound;
import com.github.pagehelper.PageInfo;

import java.util.Map;

public interface SaleOutboundService {

    Long createFromSaleOrderId(Long saleOrderId, String remark);

    void confirm(Long outboundId);

    void deleteDraft(Long outboundId);

    SaleOutbound detail(Long id);

    PageInfo<SaleOutbound> page(int pageNum, int pageSize, SaleOutbound query);

    Map<String, Object> getStatistics();
}
