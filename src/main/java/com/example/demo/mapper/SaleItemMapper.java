package com.example.demo.mapper;

import com.example.demo.entity.SaleItem;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface SaleItemMapper {

    List<SaleItem> selectByOrderId(@Param("orderId") Long orderId);

    void insert(SaleItem saleItem);

    void insertBatch(@Param("items") List<SaleItem> items, @Param("orderId") Long orderId);

    void deleteByOrderId(@Param("orderId") Long orderId);

    void deleteById(@Param("id") Long id);
}
