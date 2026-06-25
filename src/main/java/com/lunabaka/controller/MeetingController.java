package com.lunabaka.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.lunabaka.common.OperationLogAnnotation;
import com.lunabaka.common.Result;
import com.lunabaka.entity.Meeting;
import com.lunabaka.entity.User;
import com.lunabaka.service.MeetingService;
import jakarta.annotation.Resource;
import jakarta.servlet.http.HttpSession;
import org.springframework.web.bind.annotation.*;

import java.util.Date;

@RestController
@RequestMapping("/meeting")
public class MeetingController {

    @Resource
    MeetingService meetingService;

    @Resource
    HttpSession session;

    // 获取会议列表
    @GetMapping("/list")
    public Result getList(String searchQuery, Integer statusFilter,
                          @RequestParam(defaultValue = "1") Integer currentPage,
                          @RequestParam(defaultValue = "10") Integer pageSize) {

        Page<Meeting> pageData = new Page<>(currentPage, pageSize);
        LambdaQueryWrapper<Meeting> wrapper = Wrappers.lambdaQuery();

        if (searchQuery != null && !searchQuery.isEmpty()) {
            wrapper.like(Meeting::getTitle, searchQuery);
        }
        if (statusFilter != null && statusFilter != -1) {
            wrapper.eq(Meeting::getStatus, statusFilter);
        }

        wrapper.orderByDesc(Meeting::getId);
        meetingService.page(pageData, wrapper);

        return Result.success(pageData);
    }

    // 创建会议
    @OperationLogAnnotation(module = "会议管理", type = "创建", value = "创建新会议")
    @PostMapping("/create")
    public Result create(@RequestBody Meeting meeting) {
        User loginUser = (User) session.getAttribute("loginUser");
        if (loginUser != null) {
            meeting.setUserId(loginUser.getUid());
            meeting.setUserName(loginUser.getName());
        }
        meeting.setPublishTime(new Date());
        if (meeting.getStatus() == null) meeting.setStatus(0);
        meetingService.save(meeting);
        return Result.success();
    }

    // 修改会议
    @OperationLogAnnotation(module = "会议管理", type = "修改", value = "修改会议")
    @PostMapping("/update")
    public Result update(@RequestBody Meeting meeting) {
        meetingService.updateById(meeting);
        return Result.success();
    }

    // 删除会议
    @OperationLogAnnotation(module = "会议管理", type = "删除", value = "删除会议")
    @PostMapping("/delete")
    public Result delete(@RequestBody Meeting meeting) {
        meetingService.removeById(meeting.getId());
        return Result.success();
    }

}
