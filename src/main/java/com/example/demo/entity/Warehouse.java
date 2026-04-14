package com.example.demo.entity;


import java.util.Date;

import lombok.Data;

@Data
public class Warehouse {
    private Long id;
    private String code;
    private String name;
    private String kind;
    private String address;
    private String manager;
    private String phone;
    private Integer status;
    private Date createTime;
    private int delFlag;
}
