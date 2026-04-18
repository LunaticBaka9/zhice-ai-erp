package com.example.demo.mapper;

import com.example.demo.entity.SaleOutboundItem;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface SaleOutboundItemMapper {

    int insert(SaleOutboundItem item);

    int deleteByOutboundId(@Param("outboundId") Long outboundId);

    List<SaleOutboundItem> selectByOutboundId(@Param("outboundId") Long outboundId);
}
