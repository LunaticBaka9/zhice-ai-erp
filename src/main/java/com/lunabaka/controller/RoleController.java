package com.lunabaka.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.lunabaka.common.OperationLogAnnotation;
import com.lunabaka.common.Result;
import com.lunabaka.entity.Role;
import com.lunabaka.service.RoleService;
import jakarta.annotation.Resource;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/role")
public class RoleController {

    @Resource
    RoleService roleService;

    @GetMapping("/all")
    public Result all() {
        return Result.success(roleService.list());
    }

    @GetMapping("/list")
    public Result list(@RequestParam(defaultValue = "1") Integer pageNum,
                       @RequestParam(defaultValue = "10") Integer pageSize,
                       @RequestParam(required = false) String name) {

        // MyBatisPlus的分页类
        Page<Role> page = new Page<>(pageNum, pageSize);
        // 搜索条件
        LambdaQueryWrapper<Role> wrapper = Wrappers.lambdaQuery();
        wrapper.like(name != null && !name.isBlank(), Role::getName, name);
        // 进行分页+条件搜索
        roleService.page(page, wrapper);

        return Result.success(page);
    }

    @OperationLogAnnotation(module="用户角色管理", type="新增", value="添加用户角色")
    @PostMapping("/add")
    public Result addRole(@RequestBody Role role){
        // 添加用户角色数据
        roleService.save(role);
        return Result.success();
    }

    @OperationLogAnnotation(module="用户角色管理", type="修改", value="修改用户角色状态")
    @PostMapping("/updateStatus")
    public Result updateStatus(@RequestBody Role role){
        roleService.updateStatus(role);
        return Result.success();
    }

    @OperationLogAnnotation(module="用户角色管理", type="修改", value="修改用户角色信息")
    @PostMapping("/updateInfo")
    public Result updateInfo(@RequestBody Role role){
        roleService.updateById(role);
        return Result.success();
    }

    @OperationLogAnnotation(module="用户角色管理", type="删除", value="删除用户角色")
    @PostMapping("/delete")
    public Result deleteById(@RequestBody Role role){
        roleService.removeById(role.getId());
        return Result.success();
    }
}
