package com.example.demo.mapper;

import com.example.demo.entity.Inventory;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.math.BigDecimal;

@Mapper
public interface InventoryMapper {

    Inventory selectByGoodsWarehouseBatch(@Param("goodsId") Integer goodsId,
                                          @Param("warehouseId") Integer warehouseId,
                                          @Param("batchNo") String batchNo);

    /**
     * 与 uk_inventory_goods_warehouse(goods_id, warehouse_id) 一致，不区分批次
     */
    Inventory selectByGoodsAndWarehouse(@Param("goodsId") Integer goodsId,
                                        @Param("warehouseId") Integer warehouseId);

    int insert(Inventory inventory);

    int addQty(@Param("id") Long id,
               @Param("qty") BigDecimal qty,
               @Param("costDelta") BigDecimal costDelta);

    /**
     * 扣减库存；仅当 qty_available &gt;= qty 时更新，返回影响行数
     */
    int subtractQty(@Param("id") Long id,
                    @Param("qty") BigDecimal qty,
                    @Param("costDelta") BigDecimal costDelta);
}
