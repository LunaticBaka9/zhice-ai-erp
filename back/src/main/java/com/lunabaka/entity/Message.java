package com.lunabaka.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.io.Serializable;
import java.util.Date;

/**
 * 消息中心消息实体，对应数据库 message 表。
 *
 * <p>字段说明：</p>
 * <ul>
 *     <li>receiverId 为 null 表示全员广播消息，所有登录用户都可见；</li>
 *     <li>type 取值：system / approval / todo / finance / hr；</li>
 *     <li>priority 取值：high / medium / low；</li>
 *     <li>needAction = 1 表示该消息需要用户处理，isProcessed = 1 表示已处理；</li>
 *     <li>attachments 为 JSON 字符串，形如 [{"name":"附件.pdf","size":"128 KB","url":""}]；</li>
 *     <li>delFlag 使用 MyBatis-Plus 逻辑删除，查询时自动过滤已删除数据。</li>
 * </ul>
 */
@TableName("message")
@Data
public class Message implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 消息ID */
    @TableId(value = "msg_id", type = IdType.AUTO)
    private Long msgId;

    /** 发送人ID，null 表示系统消息 */
    private Long senderId;

    /** 接收人ID，null 表示全员广播 */
    private Long receiverId;

    /** 消息类型：system / approval / todo / finance / hr */
    private String type;

    /** 消息标题 */
    private String title;

    /** 消息摘要 */
    private String summary;

    /** 消息正文 */
    private String content;

    /** 优先级：high / medium / low */
    private String priority;

    /** 是否需要处理：0-否 1-是 */
    private Integer needAction;

    /** 是否已处理：0-否 1-是 */
    private Integer isProcessed;

    /** 处理截止时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private Date deadline;

    /** 关联业务单号 */
    private String relatedId;

    /** 附件（JSON 字符串） */
    private String attachments;

    /** 发布时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private Date publishDate;

    /** 是否已读：0-未读 1-已读 */
    private Integer isRead;

    /** 逻辑删除标记：0-正常 1-已删除 */
    @TableLogic(value = "0", delval = "1")
    private Integer delFlag;

    /** 非数据库字段：发送人显示名，由 Service 层关联 user 表填充 */
    @TableField(exist = false)
    private String senderName;
}
