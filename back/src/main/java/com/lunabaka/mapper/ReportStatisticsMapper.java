package com.lunabaka.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.lunabaka.dto.ProductStatVO;

@Mapper
public interface ReportStatisticsMapper {

    List<ProductStatVO> selectSaleOrderStatByProduct();

    List<ProductStatVO> selectSaleOutboundStatByProduct();

    List<ProductStatVO> selectPurchaseOrderStatByProduct();

    List<ProductStatVO> selectPurchaseInboundStatByProduct();

    List<ProductStatVO> selectStockStatByProduct();
}
