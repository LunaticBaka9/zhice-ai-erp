package com.example.demo.controller;

import cn.hutool.poi.excel.ExcelReader;
import cn.hutool.poi.excel.ExcelUtil;
import cn.hutool.poi.excel.ExcelWriter;
import com.example.demo.common.Result;
import com.example.demo.entity.Notice;
import com.example.demo.service.NoticeService;
import com.github.pagehelper.PageInfo;
import jakarta.annotation.Resource;
import jakarta.servlet.ServletOutputStream;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.Font;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
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
        ExcelWriter writer = ExcelUtil.getWriter(username, name);
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
        writer.close();
    }

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
}
