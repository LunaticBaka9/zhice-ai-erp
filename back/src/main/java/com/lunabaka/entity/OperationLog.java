package com.lunabaka.entity;

import lombok.Data;
import java.util.Date;

@Data
public class OperationLog {
    Long id;
    String username;
    String operation;
    String method;
    String params;
    Long time;
    String ip;
    Date createTime;
    String module;
    String type;
}
