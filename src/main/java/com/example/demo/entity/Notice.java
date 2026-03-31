package com.example.demo.entity;

import lombok.Data;

import java.util.Date;

@Data
public class Notice {
    Long nid;
    Long uid;
    String title;
    String type;
    String content;
    Date publishDate;
    String author;
    Long views;
}
