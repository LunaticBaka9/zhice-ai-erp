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
import com.example.demo.entity.Sale;
import com.example.demo.entity.SaleItem;
import com.example.demo.service.SaleService;
import com.github.pagehelper.PageInfo;

import jakarta.annotation.Resource;

@RestController
@RequestMapping("/sale")
public class SaleController {
    @Resource
    private SaleService saleService;

    @GetMapping("/list")
    public Result selectPage(@RequestParam(defaultValue = "1") Integer pageNum,
                             @RequestParam(defaultValue = "10") Integer pageSize,
                             Sale sale){
        PageInfo<Sale> pageInfo = saleService.selectPage(pageNum, pageSize, sale);
        return Result.success(pageInfo);
    }

    @GetMapping("/selectById/{id}")
    public Result getById(@PathVariable Long id) {
        Sale sale = saleService.selectById(id);
        return Result.success(sale);
    }

    @GetMapping("/count")
    public Result count() {
        long count = saleService.count();
        return Result.success(count);
    }

    @PostMapping("/add")
    public Result add(@RequestBody Sale sale) {
        saleService.insert(sale);
        return Result.success();
    }

    @PostMapping("/update")
    public Result update(@RequestBody Sale sale) {
        saleService.update(sale);
        return Result.success();
    }

    @DeleteMapping("/delete/{id}")
    public Result delete(@PathVariable Long id) {
        saleService.deleteById(id);
        return Result.success();
    }
    
}
