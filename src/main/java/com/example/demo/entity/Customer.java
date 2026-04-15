package com.example.demo.entity;

import java.math.BigDecimal;
import java.util.Date;

import cn.hutool.core.annotation.Alias;
import lombok.Data;

@Data
public class Customer {
    @Alias("客户ID")
    private Integer id;

    @Alias("客户编码")
    private String code;

    @Alias("客户名称")
    private String name;

    @Alias("联系人")
    private String contactPerson;

    @Alias("电话")
    private String phone;

    @Alias("邮箱")
    private String email;

    @Alias("地址")
    private String address;

    @Alias("价格等级")
    private Integer priceLevel;

    @Alias("信用额度")
    private BigDecimal creditLimit;

    @Alias("状态")
    private Integer status;

    @Alias("创建时间")
    private Date createTime;

    @Alias("更新时间")
    private Date updateTime;
}
