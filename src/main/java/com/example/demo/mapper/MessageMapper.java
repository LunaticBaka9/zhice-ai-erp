package com.example.demo.mapper;

import com.example.demo.entity.Message;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface MessageMapper {
    List<Message> selectAllMessage(Message message);

    Message selectByMsgId(@Param("msgId") Long msgId);

    Message selectBySenderId(@Param("senderId") Long senderId);

    int insertMessage(Message message);

    void updateMessage(Message message);

    void deleteByMid(Message message);
}
