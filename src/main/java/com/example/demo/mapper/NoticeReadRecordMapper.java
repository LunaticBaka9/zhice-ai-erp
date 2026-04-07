package com.example.demo.mapper;

import com.example.demo.entity.NoticeReadRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface NoticeReadRecordMapper {
    // 插入阅读记录
    int insertReadRecord(NoticeReadRecord record);
    
    // 查询用户是否已读某公告
    NoticeReadRecord selectByNoticeIdAndUserId(@Param("noticeId") Long noticeId, @Param("userId") Long userId);
    
    // 获取用户未读公告数量
    int countUnreadNotices(@Param("userId") Long userId);
    
    // 获取用户已读的公告ID列表
    List<Long> selectReadNoticeIdsByUserId(@Param("userId") Long userId);
}
