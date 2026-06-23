package com.lunabaka.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.lunabaka.entity.UserRole;
import org.apache.ibatis.annotations.Mapper;

/**
* @author je123
* @description 针对表【user_role(用户角色关联表)】的数据库操作Mapper
* @createDate 2026-06-23 10:54:31
* @Entity com.lunabaka.entity.UserRole
*/
@Mapper
public interface UserRoleMapper extends BaseMapper<UserRole> {

}




