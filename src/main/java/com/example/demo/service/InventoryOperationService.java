package com.example.demo.service;

import com.example.demo.entity.InventoryOperation;
import com.example.demo.mapper.InventoryOperationMapper;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class InventoryOperationService {

    @Resource
    private InventoryOperationMapper inventoryOperationMapper;

    /**
     * 新增库存作业
     * @param inventoryOperation 库存作业实体
     * @return 影响行数
     */
    public int insert(InventoryOperation inventoryOperation) {
        return inventoryOperationMapper.insert(inventoryOperation);
    }

    /**
     * 根据 ID 查询库存作业
     * @param id 作业 ID
     * @return 库存作业实体
     */
    public InventoryOperation selectById(Long id) {
        return inventoryOperationMapper.selectById(id);
    }

    /**
     * 根据作业单号查询库存作业
     * @param operationNo 作业单号
     * @return 库存作业实体
     */
    public InventoryOperation selectByOperationNo(String operationNo) {
        return inventoryOperationMapper.selectByOperationNo(operationNo);
    }

    /**
     * 查询库存作业列表（分页）
     * @param inventoryOperation 查询条件
     * @param pageNum 页码
     * @param pageSize 页大小
     * @return 库存作业分页列表
     */
    public PageInfo<InventoryOperation> selectPage(int pageNum, int pageSize, InventoryOperation inventoryOperation) {
        PageHelper.startPage(pageNum, pageSize);
        List<InventoryOperation> list = inventoryOperationMapper.selectList(inventoryOperation);
        return PageInfo.of(list);
    }

    /**
     * 更新库存作业
     * @param inventoryOperation 库存作业实体
     * @return 影响行数
     */
    public int update(InventoryOperation inventoryOperation) {
        return inventoryOperationMapper.update(inventoryOperation);
    }

    /**
     * 删除库存作业（逻辑删除）
     * @param id 作业 ID
     * @return 影响行数
     */
    public int deleteById(Long id) {
        return inventoryOperationMapper.deleteById(id);
    }

    /**
     * 批量删除库存作业
     * @param ids 作业 ID 列表
     * @return 影响行数
     */
    public int deleteBatch(List<Long> ids) {
        return inventoryOperationMapper.deleteBatch(ids);
    }

    /**
     * 更新作业状态
     * @param id 作业 ID
     * @param status 新状态
     * @param shouldUpdateCompleteTime 是否更新完成时间
     * @return 影响行数
     */
    public int updateStatus(Long id, String status) {
        return inventoryOperationMapper.updateStatus(id, status);
    }

    /**
     * 统计作业数量
     * @param inventoryOperation 查询条件
     * @return 数量
     */
    public int count(InventoryOperation inventoryOperation) {
        return inventoryOperationMapper.count(inventoryOperation);
    }
}