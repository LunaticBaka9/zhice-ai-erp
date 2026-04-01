package com.example.demo.entity;

import cn.hutool.core.annotation.Alias;
import cn.hutool.core.annotation.PropIgnore;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import org.springframework.format.annotation.DateTimeFormat;

import java.util.Date;

@Data
public class SignRecord {
    @PropIgnore
    private Long sid;

    @PropIgnore
    private Long uid;

    // 关联查询出的用户名，用于返回给前端显示
    @Alias("用户名")
    private String username;

    @Alias("昵称")
    private String name;

    @Alias("签到状态")
    private String signInStatus;

    @Alias("签退状态")
    private String signOutStatus;

    @Alias("签到时间")
    private Date signInTime;

    @Alias("签退时间")
    private Date signOutTime;

    @Alias("备注")
    private String remark;

    @PropIgnore
    private Date createTime;

}
