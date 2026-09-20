package com.lunabaka.dto;

import lombok.Data;

import java.util.List;

/**
 * 消息中心批量操作入参：单条操作传 msgId，批量操作传 msgIds。
 */
@Data
public class MessageActionDTO {

    /** 单条消息ID */
    private Long msgId;

    /** 批量消息ID集合 */
    private List<Long> msgIds;
}
