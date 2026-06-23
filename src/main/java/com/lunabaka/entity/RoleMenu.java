package com.lunabaka.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serial;
import java.io.Serializable;

/**
 * 用户角色菜单关联表
 * @TableName role_menu
 */
@TableName(value ="role_menu")
@Data
public class RoleMenu implements Serializable {
    /**
     * 角色菜单关联ID
     */
    @TableId
    private Long id;

    /**
     * 角色ID
     */
    private Long roleId;

    /**
     * 菜单ID
     */
    private Integer menuId;

    @Serial
    @TableField(exist = false)
    private static final long serialVersionUID = 1L;
}