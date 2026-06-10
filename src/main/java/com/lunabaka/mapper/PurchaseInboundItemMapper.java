package com.lunabaka.mapper;

import com.lunabaka.entity.PurchaseInboundItem;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface PurchaseInboundItemMapper {

    int insert(PurchaseInboundItem item);

    int deleteByInboundId(@Param("inboundId") Long inboundId);

    List<PurchaseInboundItem> selectByInboundId(@Param("inboundId") Long inboundId);
}
