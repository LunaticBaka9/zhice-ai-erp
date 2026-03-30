package com.example.demo.entity;

import cn.hutool.core.annotation.Alias;
import lombok.Data;

@Data
public class User {
    @Alias("UID")
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
    @Alias("部门")
    private String department;
    @Alias("电话")
    private String phone;
    @Alias("备注")
    private String bio;
    @Alias("入职时间")
    private String joinDate;
    @Alias("状态")
    private String status;
    @Alias("创建时间")
    private String createTime;
    @Alias("更新时间")
    private String updateTime;
    
    private String avatar;
}