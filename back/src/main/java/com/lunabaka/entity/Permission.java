package com.lunabaka.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serial;
import java.io.Serializable;
import java.util.Date;
import java.util.List;

/**
 * 权限表
 *
 * @TableName permission
 */
@TableName(value = "permission")
@Data
public class Permission implements Serializable {
    /** 权限ID */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 父权限ID，顶级为 0 */
    private Long parentId;

    /** 权限名称 */
    private String name;

    /** 权限编码，如 goods:add */
    private String code;

    /** 权限类型（1目录 2菜单 3按钮） */
    private Integer type;

    /** 前端路由 */
    private String path;

    /** 前端组件 */
    private String component;

    /** 图标 */
    private String icon;

    /** 排序 */
    private Integer sort;

    /** 状态（1启用 0禁用） */
    private Integer status;

    /** 创建时间 */
    private Date createTime;

    /** 子权限（非数据库字段，用于树） */
    @TableField(exist = false)
    private List<Permission> children;

    @Serial
    @TableField(exist = false)
    private static final long serialVersionUID = 1L;
}
