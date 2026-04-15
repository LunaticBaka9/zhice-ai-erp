package com.example.demo.entity;

import cn.hutool.core.annotation.Alias;
import lombok.Data;

import java.util.Date;

@Data
public class Supplier {
    @Alias("供应商ID")
    private Integer id;

    @Alias("供应商编码")
    private String supplierCode;

    @Alias("供应商名称")
    private String name;

    @Alias("供应商类型")
    private String type;

    @Alias("联系人")
    private String contactPerson;

    @Alias("联系电话")
    private String phone;

    @Alias("邮箱")
    private String email;

    @Alias("地址")
    private String address;

    @Alias("邮政编码")
    private String postalCode;

    @Alias("信用等级")
    private Integer creditRating;

    @Alias("合作年限")
    private Integer cooperationYears;

    @Alias("银行账户")
    private String bankAccount;

    @Alias("开户银行")
    private String bankName;

    @Alias("纳税人识别号")
    private String taxId;

    @Alias("状态")
    private String status;

    @Alias("备注")
    private String remarks;

    @Alias("创建时间")
    private Date createDate;

    @Alias("更新时间")
    private Date updateDate;
}
