package com.example.demo.entity;

import cn.hutool.core.annotation.Alias;
import lombok.Data;

import java.util.Date;

@Data
public class Supplier {
    @Alias("供应商ID")
    private Integer id;

    @Alias("供应商编码")
    private String code;

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

    @Alias("银行账户")
    private String bankAccount;

    @Alias("开户银行")
    private String bankName;

    @Alias("纳税人识别号")
    private String taxNumber;

    @Alias("状态")
    private int status;

    @Alias("创建时间")
    private Date createDate;

    @Alias("更新时间")
    private Date updateDate;
}
