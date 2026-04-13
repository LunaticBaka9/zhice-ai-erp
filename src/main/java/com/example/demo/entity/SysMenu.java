package com.example.demo.entity;

import java.util.List;

import com.baomidou.mybatisplus.annotation.TableField;

import lombok.Data;

@Data
public class SysMenu {
    
    private int id;

    private int pid;

    private String name;

    private String path;

    private String icon;

    private String description;

    private String page_path;

    private int sort_num;

     /**
     * 子菜单集合（非数据库字段）
     */
    @TableField(exist = false)
    private List<SysMenu> children;
}
