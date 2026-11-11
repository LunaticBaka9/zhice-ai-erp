package com.lunabaka.mapper;

import com.lunabaka.entity.Permission;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/**
* @author lunaticbaka
* @description 针对表【permission(权限表)】的数据库操作Mapper
* @createDate 2026-06-30 17:42:19
* @Entity com.lunabaka.entity.Permission
*/
@Mapper
public interface PermissionMapper extends BaseMapper<Permission> {

}




