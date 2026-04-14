package com.example.demo.mapper;

import com.example.demo.entity.InventoryOperation;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 库存作业 Mapper 接口
 */
@Mapper
public interface InventoryOperationMapper {
    
    /**
     * 新增库存作业
     * @param inventoryOperation 库存作业实体
     * @return 影响行数
     */
    int insert(InventoryOperation inventoryOperation);
    
    /**
     * 根据 ID 查询库存作业
     * @param id 作业 ID
     * @return 库存作业实体
     */
    InventoryOperation selectById(@Param("id") Long id);
    
    /**
     * 根据作业单号查询库存作业
     * @param operationNo 作业单号
     * @return 库存作业实体
     */
    InventoryOperation selectByOperationNo(@Param("operationNo") String operationNo);
    
    /**
     * 查询库存作业列表（分页）
     * @param inventoryOperation 查询条件
     * @return 库存作业列表
     */
    List<InventoryOperation> selectList(InventoryOperation inventoryOperation);
    
    /**
     * 更新库存作业
     * @param inventoryOperation 库存作业实体
     * @return 影响行数
     */
    int update(InventoryOperation inventoryOperation);
    
    /**
     * 删除库存作业（逻辑删除）
     * @param id 作业 ID
     * @return 影响行数
     */
    int deleteById(@Param("id") Long id);
    
    /**
     * 批量删除库存作业
     * @param ids 作业 ID 列表
     * @return 影响行数
     */
    int deleteBatch(@Param("ids") List<Long> ids);
    
    /**
     * 更新作业状态
     * @param id 作业 ID
     * @param status 新状态
     * @return 影响行数
     */
    int updateStatus(@Param("id") Long id, @Param("status") String status);
    
    /**
     * 统计作业数量
     * @param inventoryOperation 查询条件
     * @return 数量
     */
    int count(InventoryOperation inventoryOperation);
}