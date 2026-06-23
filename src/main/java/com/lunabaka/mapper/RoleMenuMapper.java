package com.lunabaka.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.lunabaka.entity.RoleMenu;
import org.apache.ibatis.annotations.Mapper;

/**
* @author je123
* @description 针对表【role_menu(用户角色菜单关联表)】的数据库操作Mapper
* @createDate 2026-06-23 10:06:43
* @Entity com.lunabaka.entity.RoleMenu
*/
@Mapper
public interface RoleMenuMapper extends BaseMapper<RoleMenu> {

}




