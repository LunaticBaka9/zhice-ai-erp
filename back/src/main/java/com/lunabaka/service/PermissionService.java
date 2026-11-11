package com.lunabaka.service;

import com.lunabaka.entity.Permission;
import com.baomidou.mybatisplus.extension.service.IService;

import java.util.List;

/**
 * 针对表【permission(权限表)】的数据库操作 Service
 */
public interface PermissionService extends IService<Permission> {

    /**
     * 启用权限的树形列表，按 sort 排序
     *
     * @return 权限树
     */
    List<Permission> getTreeList();
}
