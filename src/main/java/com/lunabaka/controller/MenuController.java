package com.lunabaka.controller;

import com.lunabaka.common.OperationLogAnnotation;
import com.lunabaka.common.Result;
import com.lunabaka.entity.Dept;
import com.lunabaka.entity.Menu;
import com.lunabaka.service.MenuService;
import jakarta.annotation.Resource;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/menu")
public class MenuController {
    @Resource
    MenuService menuService;

    @GetMapping("/list")
    public Result list() {
        List<Menu> treeList = menuService.getTreeList();
        return Result.success(treeList);
    }

//    添加菜单
    @OperationLogAnnotation(module = "菜单管理", type = "新增", value = "新增菜单")
    @PostMapping("/add")
    public Result add(@RequestBody Menu menu) {
        menuService.save(menu);
        return Result.success();
    }

    //更新菜单信息
    @OperationLogAnnotation(module = "菜单管理", type = "修改", value = "修改菜单信息")
    @PostMapping("/updateInfo")
    public Result updateInfo(@RequestBody Menu menu) {
        menuService.updateById(menu);
        return Result.success();
    }

    //更新菜单状态
    @OperationLogAnnotation(module = "菜单管理", type = "修改", value = "修改菜单状态")
    @PostMapping("/updateStatus")
    public Result updateStatus(@RequestBody Menu menu) {
        menuService.updateStatus(menu);
        return Result.success();
    }

    //删除菜单
    @OperationLogAnnotation(module = "菜单管理", type = "删除", value = "删除菜单")
    @PostMapping("/delete")
    public Result delete(@RequestBody Menu menu){
        menuService.removeById(menu.getId());
        return Result.success();
    }
}
