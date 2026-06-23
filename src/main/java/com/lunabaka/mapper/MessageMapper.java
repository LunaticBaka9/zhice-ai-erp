package com.lunabaka.mapper;

import com.lunabaka.entity.Message;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface MessageMapper {
    List<Message> selectAllMessage(Message message);

    Message selectByMsgId(@Param("msgId") Long msgId);

    Message selectBySenderId(@Param("senderId") Long senderId);

    int insertMessage(Message message);

    void updateMessage(Message message);

    void deleteByMid(Message message);
}
