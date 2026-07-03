package com.lunabaka.scheduled;

import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.lunabaka.entity.Meeting;
import com.lunabaka.service.MeetingService;
import jakarta.annotation.Resource;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.Date;
import java.util.List;

/**
 * @author lscl
 * @version 1.0
 * @intro: 会议定时开启和结束
 */
@Component
public class MeetingScheduled {

    @Resource
    private MeetingService meetingService;

    @Scheduled(cron = "* * * * * ?")
    public void scheduled() {
        // 查询会议状态不为2的会议
        List<Meeting> meetingList = meetingService.list(
                Wrappers.lambdaQuery(Meeting.class)
                        .ne(Meeting::getStatus, 2)
        );

        for (Meeting meeting : meetingList) {
            // 获取会议的开始和结束数据
            Date startTime = meeting.getStartTime();
            Date endTime = meeting.getEndTime();

            // 如果当前时间到达了会议的开始时间并且会议状态为0（未开始）,那么应该将会议状态改为1(进行中)
            if (new Date().getTime() > startTime.getTime() && meeting.getStatus()== 0) {
                meetingService.update(
                        Wrappers.lambdaUpdate(Meeting.class)
                                .eq(Meeting::getId, meeting.getId())
                                .set(Meeting::getStatus, 1)
                );
            }

            // 如果当前时间到达了会议的结束时间并且会议状态为1（进行中）,那么应该将会议状态改为2(已结束)
            if (new Date().getTime() > endTime.getTime() && meeting.getStatus() == 1) {
                meetingService.update(
                        Wrappers.lambdaUpdate(Meeting.class)
                                .eq(Meeting::getId, meeting.getId())
                                .set(Meeting::getStatus, 2)
                );
            }
        }
    }
}
