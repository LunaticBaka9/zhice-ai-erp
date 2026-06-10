package com.lunabaka.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.lunabaka.entity.SysMenu;

@Mapper
public interface SysMenuMapper{
    
    SysMenu selectByParentId(@Param("pid") int pid);
}
