package com.example.demo.service;

import com.example.demo.entity.NoticeReadRecord;
import com.example.demo.mapper.NoticeReadRecordMapper;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;

@Service
public class NoticeReadRecordService {
    @Resource
    NoticeReadRecordMapper noticeReadRecordMapper;

    // 标记公告为已读
    public void markAsRead(Long noticeId, Long userId) {
        // 先检查是否已经标记过
        NoticeReadRecord existing = noticeReadRecordMapper.selectByNoticeIdAndUserId(noticeId, userId);
        if (existing == null) {
            NoticeReadRecord record = new NoticeReadRecord();
            record.setNoticeId(noticeId);
            record.setUserId(userId);
            record.setReadTime(new Date());
            noticeReadRecordMapper.insertReadRecord(record);
        }
    }

    // 获取用户未读公告数量
    public int getUnreadCount(Long userId) {
        return noticeReadRecordMapper.countUnreadNotices(userId);
    }

    // 获取用户已读的公告ID列表
    public List<Long> getReadNoticeIds(Long userId) {
        return noticeReadRecordMapper.selectReadNoticeIdsByUserId(userId);
    }
}
