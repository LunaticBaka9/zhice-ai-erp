package com.lunabaka.dto;

import com.lunabaka.entity.Message;
import lombok.Data;

import java.util.List;

/**
 * 消息中心分页返回结构：当前页数据 + 全局统计。
 */
@Data
public class MessagePageVO {

    /** 当前页消息列表 */
    private List<Message> records;

    /** 满足筛选条件的总条数 */
    private long total;

    /** 当前用户未读消息总数（不受筛选影响） */
    private long unreadCount;

    /** 当前用户待处理消息总数（不受筛选影响） */
    private long pendingCount;
}
