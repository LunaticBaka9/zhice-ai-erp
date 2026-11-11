package com.lunabaka.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serial;
import java.io.Serializable;

/**
 * 角色权限关联表。
 * 库列名为历史拼写 permision_id，Java 字段与之保持映射。
 *
 * @TableName role_permission
 */
@TableName(value = "role_permission")
@Data
public class RolePermission implements Serializable {
    /** 关联ID */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 角色ID */
    private Integer roleId;

    /** 权限ID（对应列 permision_id） */
    @TableField("permision_id")
    private Integer permisionId;

    @Serial
    @TableField(exist = false)
    private static final long serialVersionUID = 1L;
}
