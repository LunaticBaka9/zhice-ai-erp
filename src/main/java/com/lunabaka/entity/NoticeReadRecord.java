package com.lunabaka.entity;

import lombok.Data;

import java.util.Date;

@Data
public class NoticeReadRecord {
    Long id;
    Long noticeId;
    Long userId;
    Date readTime;
}
