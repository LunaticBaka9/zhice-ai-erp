package com.example.demo.controller;

import com.example.demo.common.OperationLogAnnotation;
import com.example.demo.common.Result;
import com.example.demo.entity.InventoryAlert;
import com.example.demo.service.InventoryAlertService;
import com.example.demo.service.UserService;
import com.github.pagehelper.PageInfo;
import jakarta.annotation.Resource;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/inventoryAlert")
public class InventoryAlertController {

    @Resource
    private InventoryAlertService inventoryAlertService;

    @Resource
    private UserService userService;

    /**
     * 获取预警列表（分页）
     *
     * @param pageNum      页码
     * @param pageSize     页大小
     * @param inventoryAlert 查询条件
     * @return 预警分页列表
     */
    @GetMapping("/list")
    public Result selectPage(@RequestParam(defaultValue = "1") Integer pageNum,
                              @RequestParam(defaultValue = "10") Integer pageSize,
                              InventoryAlert inventoryAlert) {
        PageInfo<InventoryAlert> pageInfo = inventoryAlertService.selectPage(pageNum, pageSize, inventoryAlert);
        return Result.success(pageInfo);
    }

    /**
     * 根据 ID 查询预警
     *
     * @param id 预警 ID
     * @return 预警实体
     */
    @GetMapping("/getById/{id}")
    public Result selectById(@PathVariable Long id) {
        InventoryAlert alert = inventoryAlertService.selectById(id);
        return Result.success(alert);
    }

    /**
     * 根据商品 ID 查询预警
     *
     * @param goodsId 商品 ID
     * @return 预警实体列表
     */
    @GetMapping("/getByGoodsId/{goodsId}")
    public Result selectByGoodsId(@PathVariable Long goodsId) {
        List<InventoryAlert> list = inventoryAlertService.selectByGoodsId(goodsId);
        return Result.success(list);
    }

    /**
     * 生成库存预警（扫描所有商品，生成预警记录）
     *
     * @return 生成的预警数量
     */
    @OperationLogAnnotation(module = "库存预警管理", type = "生成", value = "生成库存预警")
    @PostMapping("/generate")
    public Result generateAlerts() {
        int count = inventoryAlertService.generateAlerts();
        return Result.success(Map.of("count", count, "msg", "成功生成 " + count + " 条预警记录"));
    }

    /**
     * 确认预警
     *
     * @param id 预警 ID
     * @return 操作结果
     */
    @OperationLogAnnotation(module = "库存预警管理", type = "确认", value = "确认库存预警")
    @PostMapping("/acknowledge/{id}")
    public Result acknowledge(@PathVariable Long id) {
        // 获取当前登录用户（从 JWT 或 Session 中获取）
        // 这里简化处理，实际项目中需要从认证信息中获取用户 ID
        Integer userId = getCurrentUserId();
        
        int result = inventoryAlertService.acknowledge(id, userId);
        if (result > 0) {
            return Result.success();
        } else {
            return Result.error("确认失败");
        }
    }

    /**
     * 删除预警记录
     *
     * @param id 预警 ID
     * @return 操作结果
     */
    @OperationLogAnnotation(module = "库存预警管理", type = "删除", value = "删除库存预警")
    @PostMapping("/delete/{id}")
    public Result deleteById(@PathVariable Long id) {
        int result = inventoryAlertService.deleteById(id);
        if (result > 0) {
            return Result.success();
        } else {
            return Result.error("删除失败");
        }
    }

    /**
     * 批量删除预警记录
     *
     * @param ids 预警 ID 列表
     * @return 操作结果
     */
    @OperationLogAnnotation(module = "库存预警管理", type = "批量删除", value = "批量删除库存预警")
    @PostMapping("/deleteBatch")
    public Result deleteBatch(@RequestBody List<Long> ids) {
        int result = inventoryAlertService.deleteBatch(ids);
        if (result > 0) {
            return Result.success();
        } else {
            return Result.error("批量删除失败");
        }
    }

    /**
     * 获取预警统计信息
     *
     * @return 统计信息
     */
    @GetMapping("/statistics")
    public Result getStatistics() {
        Map<String, Object> statistics = inventoryAlertService.getStatistics();
        return Result.success(statistics);
    }

    /**
     * 提交补货申请
     *
     * @param alertId    预警 ID
     * @param actualQty  实际补货数量
     * @param remarks    备注
     * @return 操作结果
     */
    @OperationLogAnnotation(module = "库存预警管理", type = "补货", value = "提交补货申请")
    @PostMapping("/replenish")
    public Result submitReplenishment(@RequestBody Map<String, Object> requestBody) {
        Long alertId = Long.valueOf(requestBody.get("alertId").toString());
        Integer actualQty = Integer.valueOf(requestBody.get("actualQty").toString());
        String remarks = (String) requestBody.get("remarks");

        // 获取当前登录用户
        String operator = getCurrentOperator();

        try {
            Long operationId = inventoryAlertService.submitReplenishment(alertId, actualQty, operator, remarks);
            return Result.success(Map.of("operationId", operationId, "msg", "补货申请提交成功"));
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 获取当前登录用户 ID（简化实现）
     *
     * @return 用户 ID
     */
    private Integer getCurrentUserId() {
        // 实际项目中需要从 JWT Token 或 Session 中获取
        // 这里返回一个默认值，实际使用时需要替换为真实的获取逻辑
        return 1;
    }

    /**
     * 获取当前操作人名称（简化实现）
     *
     * @return 操作人名称
     */
    private String getCurrentOperator() {
        // 实际项目中需要从 JWT Token 或 Session 中获取
        // 这里返回一个默认值，实际使用时需要替换为真实的获取逻辑
        return "admin";
    }
}
