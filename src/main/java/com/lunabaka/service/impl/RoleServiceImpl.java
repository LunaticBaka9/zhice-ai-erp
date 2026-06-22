package com.lunabaka.service.impl;

import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.lunabaka.entity.Role;
import com.lunabaka.mapper.RoleMapper;
import com.lunabaka.service.RoleService;
import org.springframework.stereotype.Service;

/**
* @author je123
* {@code @description} 针对表【role(用户角色表)】的数据库操作Service实现
* {@code @createDate} 2026-06-18 15:11:32
 */
@Service
public class RoleServiceImpl extends ServiceImpl<RoleMapper, Role> implements RoleService {

    public void updateStatus(Role role){
        LambdaUpdateWrapper<Role> wrapper = new LambdaUpdateWrapper<>();
        wrapper.eq(Role::getId, role.getId())
                .set(Role::getStatus, role.getStatus());
        baseMapper.update(null, wrapper);
    }

}




