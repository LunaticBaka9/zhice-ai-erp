package com.lunabaka.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.lunabaka.entity.Permission;
import com.lunabaka.service.PermissionService;
import com.lunabaka.mapper.PermissionMapper;
import org.springframework.stereotype.Service;

/**
* @author lunaticbaka
* @description 针对表【permission(权限表)】的数据库操作Service实现
* @createDate 2026-06-30 17:42:19
*/
@Service
public class PermissionServiceImpl extends ServiceImpl<PermissionMapper, Permission>
    implements PermissionService{

}




