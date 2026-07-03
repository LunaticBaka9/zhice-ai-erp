package com.lunabaka.service;

import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.lunabaka.entity.NoticeReadRecord;
import com.lunabaka.mapper.NoticeReadRecordMapper;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;

@Service
public class NoticeReadRecordService extends ServiceImpl<NoticeReadRecordMapper, NoticeReadRecord> {

    public void markAsRead(Long noticeId, Long userId) {
        NoticeReadRecord existing = baseMapper.selectOne(
                Wrappers.<NoticeReadRecord>lambdaQuery()
                        .eq(NoticeReadRecord::getNoticeId, noticeId)
                        .eq(NoticeReadRecord::getUserId, userId)
        );
        if (existing == null) {
            NoticeReadRecord record = new NoticeReadRecord();
            record.setNoticeId(noticeId);
            record.setUserId(userId);
            record.setReadTime(new Date());
            baseMapper.insert(record);
        }
    }

    public int getUnreadCount(Long userId) {
        return baseMapper.countUnreadNotices(userId);
    }

    public List<Long> getReadNoticeIds(Long userId) {
        return baseMapper.selectReadNoticeIdsByUserId(userId);
    }
}
