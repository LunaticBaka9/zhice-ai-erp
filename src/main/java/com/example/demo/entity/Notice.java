package com.example.demo.entity;

import cn.hutool.core.annotation.Alias;
import cn.hutool.core.annotation.PropIgnore;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import org.springframework.format.annotation.DateTimeFormat;

import java.util.Date;

@Data
public class Notice {
    @PropIgnore
    Long nid;

    @PropIgnore
    Long uid;

    @Alias("公告标题")
    String title;

    @Alias("公告类型")
    String type;

    @Alias("公告摘要")
    String summary;

    @Alias("公告内容")
    String content;

    @Alias("发布时间")
    Date publishDate;

    @Alias("发布作者")
    String author;

    @Alias("公告状态")
    String status;

    @Alias("查看数量")
    Long views;
}
