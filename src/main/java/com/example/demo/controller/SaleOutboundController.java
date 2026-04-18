package com.example.demo.controller;

import com.example.demo.common.OperationLogAnnotation;
import com.example.demo.common.Result;
import com.example.demo.entity.SaleOutbound;
import com.example.demo.service.SaleOutboundService;
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
@RequestMapping("/sale/outbound")
public class SaleOutboundController {

    @Resource
    private SaleOutboundService saleOutboundService;

    @GetMapping("/list")
    public Result list(@RequestParam(defaultValue = "1") Integer pageNum,
                       @RequestParam(defaultValue = "10") Integer pageSize,
                       SaleOutbound query) {
        PageInfo<SaleOutbound> page = saleOutboundService.page(pageNum, pageSize, query);
        return Result.success(page);
    }

    @GetMapping("/detail/{id}")
    public Result detail(@PathVariable Long id) {
        return Result.success(saleOutboundService.detail(id));
    }

    @OperationLogAnnotation(module = "销售管理", type = "新增", value = "生成销售出库单")
    @PostMapping("/create")
    public Result create(@RequestBody Map<String, Object> body) {
        if (body == null || body.get("saleOrderId") == null) {
            return Result.error("请传入 saleOrderId");
        }
        Long saleOrderId = Long.valueOf(body.get("saleOrderId").toString());
        String remark = body.get("remark") != null ? body.get("remark").toString() : null;
        Long id = saleOutboundService.createFromSaleOrderId(saleOrderId, remark);
        return Result.success(id);
    }

    @OperationLogAnnotation(module = "销售管理", type = "确认", value = "确认销售出库")
    @PostMapping("/confirm/{id}")
    public Result confirm(@PathVariable Long id) {
        saleOutboundService.confirm(id);
        return Result.success();
    }

    @OperationLogAnnotation(module = "销售管理", type = "删除", value = "删除草稿出库单")
    @PostMapping("/deleteDraft/{id}")
    public Result deleteDraft(@PathVariable Long id) {
        saleOutboundService.deleteDraft(id);
        return Result.success();
    }

    @GetMapping("/statistics")
    public Result statistics() {
        return Result.success(saleOutboundService.getStatistics());
    }
}
