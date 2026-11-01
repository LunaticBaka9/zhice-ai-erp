package com.lunabaka.entity;

import cn.hutool.core.annotation.Alias;
import cn.hutool.core.annotation.PropIgnore;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.util.Date;

@TableName(value ="notice")
@Data
@AllArgsConstructor
@NoArgsConstructor
public class Notice implements Serializable {
    @PropIgnore
    @TableId(type = IdType.AUTO)
    private Long nid;

    @PropIgnore
    private Long uid;

    @Alias("公告标题")
    private String title;

    @Alias("公告类型")
    private String type;

    @Alias("公告摘要")
    private String summary;

    @Alias("公告内容")
    private String content;

    @Alias("发布时间")
    @TableField("publishDate")
    private Date publishDate;

    @Alias("发布作者")
    private String author;

    @Alias("公告状态")
    private String status;

    @Alias("查看数量")
    private Long views;

    @Alias("附件")
    private String attachments;

    @PropIgnore
    @TableField(exist = false)
    private Integer delFlag;
}
