package com.lunabaka.controller;

import com.lunabaka.common.OperationLogAnnotation;
import com.lunabaka.common.Result;
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
    public Result list(@RequestParam(required = false) String name) {
        List<Menu> treeList = menuService.getTreeList();
        return Result.success(treeList);
    }

    @OperationLogAnnotation(module="菜单管理", type="修改", value="修改菜单状态")
    @PostMapping("/updateStatus")
    public Result updateStatus(@RequestBody Menu menu){
        menuService.updateStatus(menu);
        return Result.success();
    }
}
