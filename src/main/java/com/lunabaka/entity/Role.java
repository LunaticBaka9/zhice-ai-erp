package com.lunabaka.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;

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
    @TableId(type = IdType.AUTO)
    private Long id;
    private String name;
    private String bio;
    private int status;

}