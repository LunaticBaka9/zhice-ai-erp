package com.example.demo.controller;

import com.example.demo.common.Result;
import com.example.demo.entity.Notice;
import com.example.demo.entity.SignRecord;
import com.example.demo.service.NoticeService;
import com.github.pagehelper.PageInfo;
import jakarta.annotation.Resource;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/notice")
public class NoticeController {
    @Resource
    NoticeService noticeService;

    @GetMapping("/selectByNid/{nid}")
    public Result getUserById(@PathVariable Long nid){
        Notice notice = noticeService.selectByNid(nid);
        return Result.success(notice);
    }

    @GetMapping("/selectAllNotice")
    public Result selectAllUsers() {
        List<Notice> noticeList = noticeService.selectAllNotice();
        return Result.success(noticeList);
    }

    @GetMapping("/list")
    public Result selectPage(@RequestParam(defaultValue = "1") Integer pageNum,
                             @RequestParam(defaultValue = "10") Integer pageSize,
                             Notice notice){
        PageInfo<Notice> pageInfo = noticeService.selectPage(pageNum, pageSize, notice);
        return Result.success(pageInfo);
    }

    @PostMapping("/update")
    public Result updateNotice(@RequestBody Notice notice){
        noticeService.updateNotice(notice);
        return Result.success();
    }

    @PostMapping("/delete")
    public Result deleteById(@RequestBody Notice notice){
        noticeService.deleteByNid(notice);
        return Result.success();
    }
}
