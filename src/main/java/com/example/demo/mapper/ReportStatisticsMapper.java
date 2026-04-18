package com.example.demo.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.example.demo.dto.ProductStatVO;

@Mapper
public interface ReportStatisticsMapper {

    List<ProductStatVO> selectSaleOrderStatByProduct();

    List<ProductStatVO> selectSaleOutboundStatByProduct();

    List<ProductStatVO> selectPurchaseOrderStatByProduct();

    List<ProductStatVO> selectPurchaseInboundStatByProduct();

    List<ProductStatVO> selectStockStatByProduct();
}
