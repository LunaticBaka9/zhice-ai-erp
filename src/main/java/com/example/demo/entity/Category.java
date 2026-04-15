package com.example.demo.entity;

import java.util.Date;

import cn.hutool.core.annotation.Alias;
import cn.hutool.core.annotation.PropIgnore;
import lombok.Data;

@Data
public class Category {
    @PropIgnore
    private Integer id;

    @Alias("上级分类")
    private Integer parentId;

    @Alias("分类名称")
    private String name;

    @Alias("排序")
    private Integer sortOrder;

    @Alias("创建时间")
    private Date createTime;

    @Alias("更新时间")
    private Date updateTime;
}
