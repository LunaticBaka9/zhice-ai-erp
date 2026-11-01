package com.lunabaka.scheduled;

import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.lunabaka.entity.Notice;
import com.lunabaka.service.NoticeService;
import com.lunabaka.service.websocket.NoticeWebSocketService;
import jakarta.annotation.Resource;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.Date;
import java.util.List;

@Component
public class NoticeScheduled {

    @Resource
    private NoticeService noticeService;

    @Resource
    private NoticeWebSocketService noticeWebSocketService;

    @Scheduled(cron = "* * * * * ?")
    public void scheduled() {
        List<Notice> noticeList = noticeService.list(
                Wrappers.<Notice>lambdaQuery()
                        .eq(Notice::getStatus, "定时发布")
                        .le(Notice::getPublishDate, new Date())
        );

        for (Notice notice : noticeList) {
            noticeService.update(
                    Wrappers.<Notice>lambdaUpdate()
                            .eq(Notice::getNid, notice.getNid())
                            .set(Notice::getStatus, "已发布")
            );
            notice.setStatus("已发布");
            noticeWebSocketService.notifyNewNotice(notice);
        }
    }
}
