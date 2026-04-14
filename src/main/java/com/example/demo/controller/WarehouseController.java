package com.example.demo.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.demo.common.OperationLogAnnotation;
import com.example.demo.common.Result;
import com.example.demo.entity.Warehouse;
import com.example.demo.service.WarehouseService;
import com.github.pagehelper.PageInfo;

import jakarta.annotation.Resource;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;

@RestController
@RequestMapping("/warehouse")
public class WarehouseController {
    @Resource
    WarehouseService warehouseService;

    @GetMapping("/selectById/{id}")
    public Result getUserById(@PathVariable Long id) {
        Warehouse warehouse = warehouseService.selectById(id);
        return Result.success(warehouse);
    }

    @GetMapping("/selectAll")
    public Result selectAllGoods() {
        List<Warehouse> wList = warehouseService.selectAllWarehouses();
        return Result.success(wList);
    }

    @GetMapping("/list")
    public Result selectPage(@RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize,
            Warehouse warehouse) {
        PageInfo<Warehouse> pageInfo = warehouseService.selectPage(pageNum, pageSize, warehouse);
        return Result.success(pageInfo);
    }

    @OperationLogAnnotation(module = "仓库管理", type = "新增", value = "新增仓库")
    @PostMapping("/add")
    public Result insertGoods(@RequestBody Warehouse warehouse) {
        warehouseService.insert(warehouse);
        return Result.success();
    }

    @OperationLogAnnotation(module="用户管理", type="修改", value="修改仓库信息")
    @PostMapping("/update")
    public Result updateWarehouse(@RequestBody Warehouse warehouse) {
        warehouseService.update(warehouse);
        return Result.success();
    }

    @OperationLogAnnotation(module="用户管理", type="修改", value="修改仓库状态")
    @PostMapping("/updateStatus")
    public Result updateStatus(@RequestBody Warehouse warehouse){
        warehouseService.updateStatus(warehouse);
        return Result.success();
    }

    @OperationLogAnnotation(module = "商品管理", type = "删除", value = "删除商品")
    @PostMapping("/delete")
    public Result deleteGoods(@RequestBody Warehouse warehouse) {
        warehouseService.deleteById(warehouse);
        return Result.success();
    }

}
