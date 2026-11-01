package com.lunabaka.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.util.Date;

@TableName("ai_conversation")
@Data
@AllArgsConstructor
@NoArgsConstructor
public class AiConversation implements Serializable {
    @TableId(type = IdType.AUTO)
    private Long id;

    private String conversationId;

    private String title;

    private String userId;

    private Date createTime;

    private Date updateTime;
}
