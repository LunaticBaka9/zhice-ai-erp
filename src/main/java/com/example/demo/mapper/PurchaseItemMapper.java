package com.example.demo.mapper;

import com.example.demo.entity.PurchaseItem;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface PurchaseItemMapper {

    int insert(PurchaseItem item);

    int deleteByPurchaseId(@Param("purchaseId") Integer purchaseId);

    List<PurchaseItem> selectByPurchaseId(@Param("purchaseId") Integer purchaseId);
}
