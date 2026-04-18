package com.example.demo.controller;

import com.example.demo.common.OperationLogAnnotation;
import com.example.demo.common.Result;
import com.example.demo.entity.PurchaseInbound;
import com.example.demo.service.PurchaseInboundService;
import com.github.pagehelper.PageInfo;
import jakarta.annotation.Resource;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/purchase/inbound")
public class PurchaseInboundController {

    @Resource
    private PurchaseInboundService purchaseInboundService;

    @GetMapping("/list")
    public Result list(@RequestParam(defaultValue = "1") Integer pageNum,
                       @RequestParam(defaultValue = "10") Integer pageSize,
                       PurchaseInbound query) {
        PageInfo<PurchaseInbound> page = purchaseInboundService.page(pageNum, pageSize, query);
        return Result.success(page);
    }

    @GetMapping("/detail/{id}")
    public Result detail(@PathVariable Long id) {
        return Result.success(purchaseInboundService.detail(id));
    }

    @OperationLogAnnotation(module = "采购管理", type = "新增", value = "按采购订单生成入库单")
    @PostMapping("/create")
    public Result create(@RequestBody Map<String, Object> body) {
        if (body == null || body.get("purchaseId") == null) {
            return Result.error("请传入 purchaseId");
        }
        Integer purchaseId = Integer.valueOf(body.get("purchaseId").toString());
        String remark = body.get("remark") != null ? body.get("remark").toString() : null;
        Long id = purchaseInboundService.createFromPurchaseId(purchaseId, remark);
        return Result.success(id);
    }

    @OperationLogAnnotation(module = "采购管理", type = "确认", value = "确认采购入库")
    @PostMapping("/confirm/{id}")
    public Result confirm(@PathVariable Long id) {
        purchaseInboundService.confirm(id);
        return Result.success();
    }

    @OperationLogAnnotation(module = "采购管理", type = "删除", value = "删除草稿入库单")
    @PostMapping("/deleteDraft/{id}")
    public Result deleteDraft(@PathVariable Long id) {
        purchaseInboundService.deleteDraft(id);
        return Result.success();
    }
}
