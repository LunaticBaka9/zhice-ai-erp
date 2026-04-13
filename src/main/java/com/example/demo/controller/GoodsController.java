package com.example.demo.controller;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.demo.common.OperationLogAnnotation;
import com.example.demo.common.Result;
import com.example.demo.entity.Goods;
import com.example.demo.service.GoodsService;
import com.github.pagehelper.PageInfo;

import jakarta.annotation.Resource;

@RestController
@RequestMapping("/goods")
public class GoodsController {
    @Resource
    GoodsService goodsService;

    @GetMapping("/selectById/{id}")
    public Result getUserById(@PathVariable Long id){
        Goods goods = goodsService.selectById(id);
        return Result.success(goods);
    }

    @GetMapping("/selectAllGoods")
    public Result selectAllGoods() {
        List<Goods> goodsList = goodsService.selectAllGoods();
        return Result.success(goodsList);
    }

    @GetMapping("/list")
    public Result selectPage(@RequestParam(defaultValue = "1") Integer pageNum,
                             @RequestParam(defaultValue = "10") Integer pageSize,
                             Goods goods){
        PageInfo<Goods> pageInfo = goodsService.selectPage(pageNum, pageSize, goods);
        return Result.success(pageInfo);
    }

    @OperationLogAnnotation(module="商品管理", type="新增", value="新增商品")
    @PostMapping("/add")
    public Result insertGoods(@RequestBody Goods goods){
        goodsService.insert(goods);
        return Result.success();
    }

    @PostMapping("/update")
    public Result updateGoods(@RequestBody Goods goods) {
        goodsService.updateGoods(goods);
        return Result.success();
    }
    

    @OperationLogAnnotation(module = "商品管理", type = "删除", value = "删除商品")
    @PostMapping("/delete")
    public Result deleteGoods(@RequestBody Goods goods) {
        goodsService.deleteById(goods);
        return Result.success();
    }
    
}
