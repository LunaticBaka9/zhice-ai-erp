package com.lunabaka.dto;

import lombok.Data;

/**
 * 消息中心列表查询条件。
 */
@Data
public class MessageQueryDTO {

    /** 页码，从 1 开始 */
    private Integer pageNum = 1;

    /** 每页条数 */
    private Integer pageSize = 10;

    /** 消息类型：system / approval / todo / finance / hr */
    private String type;

    /** 优先级：high / medium / low */
    private String priority;

    /** 关键字，匹配标题 / 摘要 / 正文 */
    private String keyword;

    /** 是否已读：0-未读 1-已读，null-全部 */
    private Integer isRead;

    /** 是否需要处理：0-否 1-是，null-全部 */
    private Integer needAction;

    /** 发布时间起（yyyy-MM-dd） */
    private String startDate;

    /** 发布时间止（yyyy-MM-dd） */
    private String endDate;
}
