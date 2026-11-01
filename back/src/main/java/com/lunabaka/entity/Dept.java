package com.lunabaka.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;

import java.io.Serial;
import java.io.Serializable;
import java.util.Date;
import java.util.List;

import lombok.Data;

/**
 * 部门表
 * @TableName dept
 */
@TableName(value ="dept")
@Data
public class Dept implements Serializable {
    /**
     * 部门ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 部门名称
     */
    private String name;

    /**
     * 部门代码
     */
    private String code;

    /**
     * 部门简介
     */
    private String intro;

    /**
     * 父部门ID
     */
    private Long parentId;

    /**
     * 父部门名称
     */
    private String parentName;

    /**
     * 部门电话
     */
    private String phone;

    /**
     * 部门地址
     */
    private String address;

    /**
     * 创建时间
     */
    private Date createTime;

    /**
     * 部门状态 0-禁用 1-启用
     */
    private Integer status;

    /**
     * 部门负责人ID
     */
    private Long userId;

    /**
     * 部门负责人名称
     */
    private String userName;

    /**
     * 子菜单集合（非数据库字段）
     */
    @TableField(exist = false)
    private List<Dept> children;

    @Serial
    @TableField(exist = false)
    private static final long serialVersionUID = 1L;
}