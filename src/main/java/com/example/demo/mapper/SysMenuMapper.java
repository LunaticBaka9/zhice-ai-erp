package com.example.demo.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.example.demo.entity.SysMenu;

@Mapper
public interface SysMenuMapper{
    
    SysMenu selectByParentId(@Param("pid") int pid);
}
