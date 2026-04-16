package com.example.demo.controller;

import java.util.List;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.demo.common.Result;
import com.example.demo.entity.Supplier;
import com.example.demo.service.SupplierService;
import com.github.pagehelper.PageInfo;

import jakarta.annotation.Resource;

@RestController
@RequestMapping("/supplier")
public class SupplierController {
    @Resource
    private SupplierService supplierService;

    @GetMapping("/selectAllCustomer")
    public Result selectAllUsers() {
        List<Supplier> suppliersList = supplierService.selectAll();
        return Result.success(suppliersList);
    }

    @GetMapping("/list")
    public Result selectPage(@RequestParam(defaultValue = "1") Integer pageNum,
                             @RequestParam(defaultValue = "10") Integer pageSize,
                             Supplier supplier){
        PageInfo<Supplier> pageInfo = supplierService.selectPage(pageNum, pageSize, supplier);
        return Result.success(pageInfo);
    }

    @GetMapping("/selectById/{id}")
    public Result getById(@PathVariable Integer id) {
        Supplier supplier = supplierService.selectById(id);
        return Result.success(supplier);
    }

    @GetMapping("/count")
    public Result count() {
        long count = supplierService.count();
        return Result.success(count);
    }

    @PostMapping("/add")
    public Result add(@RequestBody Supplier supplier) {
        supplierService.insert(supplier);
        return Result.success();
    }

    @PostMapping("/update")
    public Result update(@RequestBody Supplier supplier) {
        supplierService.update(supplier);
        return Result.success();
    }

    @DeleteMapping("/delete/{id}")
    public Result delete(@PathVariable Integer id) {
        supplierService.deleteById(id);
        return Result.success();
    }
}
