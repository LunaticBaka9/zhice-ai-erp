package com.example.demo.controller;

import com.example.demo.common.OperationLogAnnotation;
import com.example.demo.common.Result;
import com.example.demo.entity.InventoryOperation;
import com.example.demo.service.InventoryOperationService;
import com.github.pagehelper.PageInfo;
import jakarta.annotation.Resource;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/inventoryOperation")
public class InventoryOperationController {

    @Resource
    private InventoryOperationService inventoryOperationService;

    /**
     * 新增库存作业
     * @param inventoryOperation 库存作业实体
     * @return Result
     */
    @OperationLogAnnotation(module = "库存作业管理", type = "新增", value = "新增库存作业")
    @PostMapping("/add")
    public Result insert(@RequestBody InventoryOperation inventoryOperation) {
        int result = inventoryOperationService.insert(inventoryOperation);
        if (result > 0) {
            return Result.success();
        } else {
            return Result.error("新增失败");
        }
    }

    /**
     * 根据 ID 查询库存作业
     * @param id 作业 ID
     * @return Result
     */
    @GetMapping("/getById/{id}")
    public Result selectById(@PathVariable Long id) {
        InventoryOperation inventoryOperation = inventoryOperationService.selectById(id);
        return Result.success(inventoryOperation);
    }

    /**
     * 根据作业单号查询库存作业
     * @param operationNo 作业单号
     * @return Result
     */
    @GetMapping("/getByOperationNo/{operationNo}")
    public Result selectByOperationNo(@PathVariable String operationNo) {
        InventoryOperation inventoryOperation = inventoryOperationService.selectByOperationNo(operationNo);
        return Result.success(inventoryOperation);
    }

    /**
     * 查询库存作业列表（分页）
     * @param pageNum 页码
     * @param pageSize 页大小
     * @param inventoryOperation 查询条件
     * @return Result
     */
    @GetMapping("/list")
    public Result selectPage(@RequestParam(defaultValue = "1") Integer pageNum,
                             @RequestParam(defaultValue = "10") Integer pageSize,
                             InventoryOperation inventoryOperation) {
        PageInfo<InventoryOperation> pageInfo = inventoryOperationService.selectPage(pageNum, pageSize, inventoryOperation);
        return Result.success(pageInfo);
    }

    /**
     * 更新库存作业
     * @param inventoryOperation 库存作业实体
     * @return Result
     */
    @OperationLogAnnotation(module = "库存作业管理", type = "修改", value = "修改库存作业")
    @PostMapping("/update")
    public Result update(@RequestBody InventoryOperation inventoryOperation) {
        int result = inventoryOperationService.update(inventoryOperation);
        if (result > 0) {
            return Result.success();
        } else {
            return Result.error("更新失败");
        }
    }

    /**
     * 删除库存作业（逻辑删除）
     * @param id 作业 ID
     * @return Result
     */
    @OperationLogAnnotation(module = "库存作业管理", type = "删除", value = "删除库存作业")
    @PostMapping("/delete/{id}")
    public Result deleteById(@PathVariable Long id) {
        int result = inventoryOperationService.deleteById(id);
        if (result > 0) {
            return Result.success();
        } else {
            return Result.error("删除失败");
        }
    }

    /**
     * 批量删除库存作业
     * @param ids 作业 ID 列表
     * @return Result
     */
    @OperationLogAnnotation(module = "库存作业管理", type = "删除", value = "批量删除库存作业")
    @PostMapping("/deleteBatch")
    public Result deleteBatch(@RequestBody List<Long> ids) {
        int result = inventoryOperationService.deleteBatch(ids);
        if (result > 0) {
            return Result.success();
        } else {
            return Result.error("批量删除失败");
        }
    }

    /**
     * 更新作业状态
     * @param id 作业 ID
     * @param status 新状态
     * @return Result
     */
    @OperationLogAnnotation(module = "库存作业管理", type = "修改", value = "更新库存作业状态")
    @PostMapping("/updateStatus/{id}/{status}")
    public Result updateStatus(@PathVariable Long id, @PathVariable String status) {
        int result = inventoryOperationService.updateStatus(id, status);
        if (result > 0) {
            return Result.success();
        } else {
            return Result.error("更新状态失败");
        }
    }
}