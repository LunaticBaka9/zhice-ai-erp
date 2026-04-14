package com.example.demo.mapper;

import com.example.demo.entity.InventoryAlert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface InventoryAlertMapper {

    /**
     * 根据条件查询预警列表（分页）
     * @param inventoryAlert 查询条件
     * @return 预警列表
     */
    List<InventoryAlert> selectList(InventoryAlert inventoryAlert);

    /**
     * 根据 ID 查询预警
     * @param id 预警 ID
     * @return 预警实体
     */
    InventoryAlert selectById(@Param("id") Long id);

    /**
     * 根据商品 ID 查询预警
     * @param goodsId 商品 ID
     * @return 预警实体列表
     */
    List<InventoryAlert> selectByGoodsId(@Param("goodsId") Long goodsId);

    /**
     * 插入预警记录
     * @param inventoryAlert 预警实体
     * @return 影响行数
     */
    int insert(InventoryAlert inventoryAlert);

    /**
     * 批量插入预警记录
     * @param list 预警实体列表
     * @return 影响行数
     */
    int insertBatch(@Param("list") List<InventoryAlert> list);

    /**
     * 更新预警记录
     * @param inventoryAlert 预警实体
     * @return 影响行数
     */
    int update(InventoryAlert inventoryAlert);

    /**
     * 确认预警
     * @param id 预警 ID
     * @param acknowledgedBy 确认人 ID
     * @return 影响行数
     */
    int acknowledge(@Param("id") Long id, @Param("acknowledgedBy") Integer acknowledgedBy);

    /**
     * 删除预警记录
     * @param id 预警 ID
     * @return 影响行数
     */
    int deleteById(@Param("id") Long id);

    /**
     * 批量删除预警记录
     * @param ids 预警 ID 列表
     * @return 影响行数
     */
    int deleteBatch(@Param("ids") List<Long> ids);

    /**
     * 统计预警数量
     * @param inventoryAlert 查询条件
     * @return 数量
     */
    int count(InventoryAlert inventoryAlert);

    /**
     * 统计各类型预警数量
     * @return 统计结果 Map
     */
    java.util.Map<String, Integer> countByAlertType();

    /**
     * 获取所有预警（用于生成预警）
     * @return 预警列表
     */
    List<InventoryAlert> selectAllAlerts();
}
