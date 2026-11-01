package com.lunabaka.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import lombok.Data;

import java.util.List;

@Data
public class Menu {
    private Integer id;
    private Integer pid;
    private String name;
    private String path;
    private String icon;
    private String description;
    private String page_path;
    private Integer sort_num;
    private Boolean status;
     /**
     * 子菜单集合（非数据库字段）
     */
    @TableField(exist = false)
    private List<Menu> children;
}
