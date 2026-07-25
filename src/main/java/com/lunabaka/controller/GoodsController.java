package com.lunabaka.controller;

import com.github.pagehelper.PageInfo;
import com.lunabaka.common.OperationLogAnnotation;
import com.lunabaka.common.Result;
import com.lunabaka.entity.Goods;
import com.lunabaka.service.GoodsService;
import jakarta.annotation.Resource;
import org.springframework.web.bind.annotation.*;

import java.util.List;

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

    @GetMapping("/alertlist")
    public Result getMethodName(@RequestParam(defaultValue = "1") Integer pageNum,
                             @RequestParam(defaultValue = "10") Integer pageSize,
                             Goods goods) {
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
