package com.lunabaka.service.impl;

import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import com.lunabaka.entity.Role;
import com.lunabaka.mapper.RoleMapper;
import com.lunabaka.service.RoleService;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;

import java.util.List;

/**
* @author je123
* {@code @description} 针对表【role(用户角色表)】的数据库操作Service实现
* {@code @createDate} 2026-06-18 15:11:32
 */
@Service
public class RoleServiceImpl implements RoleService {

    @Resource
    RoleMapper roleMapper;

    public RoleServiceImpl(RoleMapper roleMapper) {
        this.roleMapper = roleMapper;
    }

    @Override
    public PageInfo<Role> page(int pageNum, int pageSize, Role query) {
        PageHelper.startPage(pageNum, pageSize);
        List<Role> list = roleMapper.selectList(query != null ? query : new Role());
        return PageInfo.of(list);
    }

    @Override
    public PageInfo<Role> page(Integer pageNum, Integer pageSize, Role role) {
        return null;
    }

}




