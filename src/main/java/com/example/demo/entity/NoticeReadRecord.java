package com.example.demo.entity;

import lombok.Data;

import java.util.Date;

@Data
public class NoticeReadRecord {
    Long id;
    Long noticeId;
    Long userId;
    Date readTime;
}
