package com.example.demo.controller;

import com.example.demo.common.OperationLogAnnotation;
import com.example.demo.common.Result;
import com.example.demo.dto.PurchaseOrderSaveDTO;
import com.example.demo.entity.Purchase;
import com.example.demo.service.PurchaseOrderService;
import com.github.pagehelper.PageInfo;
import jakarta.annotation.Resource;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/purchase/order")
public class PurchaseOrderController {

    @Resource
    private PurchaseOrderService purchaseOrderService;

    @GetMapping("/list")
    public Result list(@RequestParam(defaultValue = "1") Integer pageNum,
                       @RequestParam(defaultValue = "10") Integer pageSize,
                       Purchase query) {
        PageInfo<Purchase> page = purchaseOrderService.page(pageNum, pageSize, query);
        return Result.success(page);
    }

    @GetMapping("/eligibleInbound")
    public Result eligibleInbound() {
        List<Purchase> list = purchaseOrderService.listEligibleForInbound();
        return Result.success(list);
    }

    @GetMapping("/detail/{id}")
    public Result detail(@PathVariable Long id) {
        return Result.success(purchaseOrderService.detail(id));
    }

    @OperationLogAnnotation(module = "采购管理", type = "保存", value = "保存采购订单")
    @PostMapping("/save")
    public Result save(@RequestBody PurchaseOrderSaveDTO dto) {
        Long id = purchaseOrderService.save(dto);
        return Result.success(id);
    }

    @OperationLogAnnotation(module = "采购管理", type = "确认", value = "确认采购订单")
    @PostMapping("/confirm/{id}")
    public Result confirm(@PathVariable Long id) {
        purchaseOrderService.confirm(id);
        return Result.success();
    }

    @OperationLogAnnotation(module = "采购管理", type = "作废", value = "作废采购订单")
    @PostMapping("/cancel/{id}")
    public Result cancel(@PathVariable Long id) {
        purchaseOrderService.cancel(id);
        return Result.success();
    }
}
