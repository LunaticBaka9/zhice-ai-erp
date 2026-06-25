package com.lunabaka.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;

import java.io.Serial;
import java.io.Serializable;
import java.util.Date;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 
 * @TableName meeting
 */
@TableName(value ="meeting")
@Data
@AllArgsConstructor
@NoArgsConstructor
public class Meeting implements Serializable {
    /**
     * 会议ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 会议标题
     */
    private String title;

    /**
     * 会议内容
     */
    private String content;

    /**
     * 发布时间
     */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private Date publishTime;

    /**
     * 开始时间
     */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private Date startTime;

    /**
     * 结束时间
     */
    private String endTime;

    /**
     * 会议状态 0:未开始 1:进行中 2:已结束
     */
    private Integer status;

    /**
     * 参加人员
     */
    private String makeUser;

    /**
     * 会议地点
     */
    private String address;

    /**
     * 部门名称
     */
    private String deptName;

    /**
     * 部门ID
     */
    private Integer deptId;

    /**
     * 会议主持人ID
     */
    private Long userId;

    /**
     * 会议主持人名称
     */
    private String userName;

    @Serial
    @TableField(exist = false)
    private static final long serialVersionUID = 1L;
}