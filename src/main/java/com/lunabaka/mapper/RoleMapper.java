package com.lunabaka.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.lunabaka.entity.Role;

import java.util.List;

/**
* @author je123
* @description 针对表【role(用户角色表)】的数据库操作Mapper
* @createDate 2026-06-18 15:11:32
* @Entity com.lunabaka.entity.role
*/

public interface RoleMapper extends BaseMapper<Role> {

    Role findAll();

    List<Role> selectList(Role role);
}




