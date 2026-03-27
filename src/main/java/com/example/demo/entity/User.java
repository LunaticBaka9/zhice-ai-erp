package com.example.demo.entity;

import lombok.Data;

@Data
public class User {
    private Long uid;
    private String username;
    private String name;
    private String password;
    private String email;
    private String role;
    private String department;
    private String phone;
    private String bio;
    private String joinDate;
    private String status;
    private String createTime;
    private String updateTime;
}