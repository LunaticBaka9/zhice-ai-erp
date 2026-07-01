package com.lunabaka.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.lunabaka.common.OperationLogAnnotation;
import com.lunabaka.common.Result;
import com.lunabaka.entity.Meeting;
import com.lunabaka.entity.User;
import com.lunabaka.service.MeetingService;
import com.lunabaka.service.UserService;
import jakarta.annotation.Resource;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.web.bind.annotation.*;

import java.util.Arrays;
import java.util.Date;
import java.util.List;

@RestController
@RequestMapping("/meeting")
public class MeetingController {

    @Resource
    MeetingService meetingService;

    @Resource
    HttpSession session;

    @Resource
    HttpServletRequest request;

    @Resource
    UserService userService;

    // 获取单个会议详情
    @GetMapping("/detail/{id}")
    public Result getDetail(@PathVariable Long id) {
        Meeting meeting = meetingService.getById(id);
        return Result.success(meeting);
    }

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

    // 参加会议（签到）
    @OperationLogAnnotation(module = "会议管理", type = "签到", value = "参加会议签到")
    @PostMapping("/checkin/{id}")
    public Result checkin(@PathVariable Long id) {
        Meeting meeting = meetingService.getById(id);
        if (meeting == null) {
            return Result.error("会议不存在");
        }
        String userId = (String) request.getAttribute("userId");
        if (userId == null) {
            return Result.error("未登录");
        }
        User loginUser = userService.getById(Long.parseLong(userId));
        if (loginUser == null) {
            return Result.error("用户不存在");
        }
        String currentName = loginUser.getName();
        String actualUser = meeting.getActualUser();
        if (actualUser != null && !actualUser.isEmpty()) {
            List<String> names = Arrays.asList(actualUser.split(","));
            if (names.contains(currentName)) {
                return Result.error("已签到");
            }
            meeting.setActualUser(actualUser + "," + currentName);
        } else {
            meeting.setActualUser(currentName);
        }
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
