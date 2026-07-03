package com.lunabaka.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.util.Date;

@Data
@TableName("notice_read_record")
public class NoticeReadRecord {
    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("notice_id")
    private Long noticeId;

    @TableField("user_id")
    private Long userId;

    @TableField("read_time")
    private Date readTime;
}
