package com.example.demo.entity;

import lombok.Data;

import java.util.Date;


@Data
public class Message {

    Long msgId;

    Long senderId;

    String receiverId;

    String type;

    String content;

    String attachments;

    Date publishDate;

    boolean isRead;

    private int delFlag;
}
