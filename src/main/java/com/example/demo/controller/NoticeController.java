package com.example.demo.controller;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.Font;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.example.demo.common.OperationLogAnnotation;
import com.example.demo.common.Result;
import com.example.demo.entity.Notice;
import com.example.demo.service.NoticeService;
import com.example.demo.service.NoticeReadRecordService;
import com.github.pagehelper.PageInfo;

import cn.hutool.poi.excel.ExcelReader;
import cn.hutool.poi.excel.ExcelUtil;
import cn.hutool.poi.excel.ExcelWriter;
import jakarta.annotation.Resource;
import jakarta.servlet.ServletOutputStream;
import jakarta.servlet.http.HttpServletResponse;

@RestController
@RequestMapping("/notice")
public class NoticeController {
    @Resource
    NoticeService noticeService;
    
    @Resource
    NoticeReadRecordService noticeReadRecordService;

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

    @OperationLogAnnotation(module="公告管理", type="新增", value="新增公告")
    @PostMapping("/postNotice")
    public Result postNotice(@RequestBody Notice notice){
        noticeService.insertNotice(notice);
        return Result.success();
    }

    @PostMapping("/saveDraft")
    public Result saveDraft(@RequestBody Notice notice){
        noticeService.insertNotice(notice);
        return Result.success();
    }

    @OperationLogAnnotation(module="公告管理", type="修改", value="修改公告")
    @PostMapping("/update")
    public Result updateNotice(@RequestBody Notice notice){
        noticeService.updateNotice(notice);
        return Result.success();
    }

    @PostMapping("/updateViews")
    public Result updateViews(@RequestBody Notice notice){
        noticeService.updateNotice(notice);
        return Result.success();
    }

    @OperationLogAnnotation(module="公告管理", type="删除", value="删除公告")
    @PostMapping("/delete")
    public Result deleteById(@RequestBody Notice notice){
        noticeService.deleteByNid(notice);
        return Result.success();
    }

    @GetMapping("/exportData")
    public void exportData(
            @RequestParam(required = false) String username,
            @RequestParam(required = false) String name,
            HttpServletResponse response) throws IOException {
        //全局
        try (ExcelWriter writer = ExcelUtil.getWriter(username, name)) {
            //全局
            CellStyle cellStyle = writer.getCellStyle();
            //创建标题字体
            Font font = writer.createFont();
            //大小
            font.setFontHeightInPoints((short) 10);
            font.setFontName("宋体");
            cellStyle.setFont(font);
            //全局  宽15
            writer.setColumnWidth(-1,15);
            writer.setColumnWidth(0,20);
            //全局  高25
            writer.setRowHeight(-1,25);
            
            List<Notice> list = noticeService.selectAllNotice();
            writer.write(list,true);
            //response为HttpServletResponse对象
            response.setContentType("application/vnd.ms-excel;charset=utf-8");
            //test.xls是弹出下载对话框的文件名，不能为中文，中文请自行编码
            response.setHeader("Content-Disposition","attachment;filename="+ URLEncoder.encode("公告信息表", StandardCharsets.UTF_8) +".xls");
            ServletOutputStream out = response.getOutputStream();
            writer.flush(out,true);
        }
    }

    @OperationLogAnnotation(module="公告管理", type="新增", value="公告批量导入")
    @PostMapping("/importData")
    public Result importData(MultipartFile file) throws IOException{
        ExcelReader reader = ExcelUtil.getReader(file.getInputStream());
        List<Notice> noticeList = reader.readAll(Notice.class);
        try {
            noticeService.insertBatch(noticeList);
        } catch (Exception e) {
            return Result.error("数据批量导入错误");
        }
        return Result.success();
    }
    
    //标记公告为已读
    @PostMapping("/markAsRead")
    public Result markAsRead(@RequestBody java.util.Map<String, Long> params) {
        Long noticeId = params.get("noticeId");
        Long userId = params.get("userId");
        if (noticeId == null || userId == null) {
            return Result.error("参数错误");
        }
        noticeReadRecordService.markAsRead(noticeId, userId);
        return Result.success();
    }
    
    /**
     * 获取用户未读公告数量
     */
    @GetMapping("/unreadCount")
    public Result getUnreadCount(@RequestParam Long userId) {
        if (userId == null) {
            return Result.error("用户ID不能为空");
        }
        int count = noticeReadRecordService.getUnreadCount(userId);
        return Result.success(count);
    }
    
    /**
     * 获取用户已读的公告ID列表
     */
    @GetMapping("/readNoticeIds")
    public Result getReadNoticeIds(@RequestParam Long userId) {
        if (userId == null) {
            return Result.error("用户ID不能为空");
        }
        List<Long> readIds = noticeReadRecordService.getReadNoticeIds(userId);
        return Result.success(readIds);
    }
}
