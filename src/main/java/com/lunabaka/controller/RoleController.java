package com.lunabaka.controller;

import com.github.pagehelper.PageInfo;
import com.lunabaka.common.Result;
import com.lunabaka.entity.Role;
import com.lunabaka.service.RoleService;
import jakarta.annotation.Resource;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/role")
public class RoleController {

    @Resource
    RoleService roleService;

    @GetMapping("/list")
    public Result list(@RequestParam(defaultValue = "1") Integer pageNum,
                       @RequestParam(defaultValue = "10") Integer pageSize,
                       Role query) {
        PageInfo<Role> page = roleService.page(pageNum, pageSize, query);
        return Result.success(page);
    }
}
