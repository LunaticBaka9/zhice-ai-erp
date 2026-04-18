package com.example.demo.mapper;

import com.example.demo.entity.SaleOutbound;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface SaleOutboundMapper {

    int insert(SaleOutbound outbound);

    int update(SaleOutbound outbound);

    SaleOutbound selectById(@Param("id") Long id);

    SaleOutbound selectBySaleOrderId(@Param("saleOrderId") Long saleOrderId);

    int countBySaleOrderId(@Param("saleOrderId") Long saleOrderId);

    List<SaleOutbound> selectList(SaleOutbound query);

    int deleteById(@Param("id") Long id);

    Long countAll();

    Long countByStatus(@Param("status") Integer status);
}
