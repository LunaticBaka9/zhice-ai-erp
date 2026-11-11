package com.lunabaka.entity;

import cn.hutool.core.annotation.Alias;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serial;
import java.io.Serializable;
import java.util.Date;

/**
 * 用户角色表
 *
 * @TableName role
 */
@TableName(value = "role")
@Data
@AllArgsConstructor
@NoArgsConstructor
public class Role implements Serializable {
    /** 角色ID */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 角色名称 */
    @Alias("角色名称")
    private String name;

    /** 角色编码（唯一） */
    @Alias("角色编码")
    private String code;

    /** 角色简介 */
    @Alias("角色简介")
    private String bio;

    /** 排序，越小越靠前 */
    @Alias("排序")
    private Integer sort;

    /** 是否系统角色（1是 0否），系统角色禁止删除 */
    private Integer isSystem;

    /** 状态（1启用 0禁用） */
    @Alias("状态")
    private Integer status;

    /** 创建时间 */
    private Date createTime;

    @Serial
    @TableField(exist = false)
    private static final long serialVersionUID = 1L;
}
