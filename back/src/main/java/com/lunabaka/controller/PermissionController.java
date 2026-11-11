package com.lunabaka.controller;

import com.lunabaka.common.Result;
import com.lunabaka.service.PermissionService;
import jakarta.annotation.Resource;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 权限树查询，供角色分配权限使用。
 */
@RestController
@RequestMapping("/permission")
public class PermissionController {

    @Resource
    private PermissionService permissionService;

    /**
     * 启用状态的权限树
     */
    @GetMapping("/tree")
    public Result tree() {
        return Result.success(permissionService.getTreeList());
    }
}
