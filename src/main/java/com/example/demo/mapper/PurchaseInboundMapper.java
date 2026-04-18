package com.example.demo.mapper;

import com.example.demo.entity.PurchaseInbound;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface PurchaseInboundMapper {

    int insert(PurchaseInbound inbound);

    int update(PurchaseInbound inbound);

    PurchaseInbound selectById(@Param("id") Long id);

    PurchaseInbound selectByPurchaseId(@Param("purchaseId") Integer purchaseId);

    int countByPurchaseId(@Param("purchaseId") Integer purchaseId);

    List<PurchaseInbound> selectList(PurchaseInbound query);

    int deleteById(@Param("id") Long id);
}
