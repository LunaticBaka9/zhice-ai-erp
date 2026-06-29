package com.lunabaka.entity;

import cn.hutool.core.annotation.Alias;
import cn.hutool.core.annotation.PropIgnore;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@TableName("user")
@Data
public class User {
    @Alias("UID")
    @TableId(type = IdType.AUTO)
    private Long uid;

    @Alias("用户名")
    private String username;

    @Alias("昵称")
    private String name;

    @Alias("密码")
    private String password;

    @Alias("邮箱")
    private String email;

    @Alias("角色")
    private String role;

    @PropIgnore
    private Long deptId;

    @Alias("部门")
    private String deptName;

    @Alias("电话")
    private String phone;

    @Alias("备注")
    private String bio;

    @Alias("入职时间")
    private String joinDate;

    @Alias("状态")
    private String status;

    @PropIgnore
    private String createTime;

    @PropIgnore
    private String updateTime;

    @PropIgnore
    private String avatar;

    @PropIgnore
    @TableLogic(value = "0", delval = "1")
    private int delFlag;
}