package com.example.demo.mapper;

import com.example.demo.entity.Purchase;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface PurchaseMapper {

    int insert(Purchase purchase);

    int update(Purchase purchase);

    Purchase selectById(@Param("id") Long id);

    List<Purchase> selectList(Purchase query);

    /**
     * 已确认且尚未生成入库单的采购订单
     */
    List<Purchase> selectEligibleForInbound();
}
