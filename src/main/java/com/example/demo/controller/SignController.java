package com.example.demo.controller;

import cn.hutool.poi.excel.ExcelUtil;
import cn.hutool.poi.excel.ExcelWriter;
import com.example.demo.common.Result;
import com.example.demo.entity.SignRecord;
import com.example.demo.service.SignService;
import com.github.pagehelper.PageInfo;
import jakarta.annotation.Resource;
import jakarta.servlet.ServletOutputStream;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.Font;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.Calendar;
import java.util.List;

@RestController
@RequestMapping("/sign")
public class SignController {

    @Resource
    private SignService signService;

    @GetMapping("/selectPage")
    public Result selectPage(@RequestParam(defaultValue = "1") Integer pageNum,
                             @RequestParam(defaultValue = "10") Integer pageSize,
                             SignRecord signRecord) {
        PageInfo<SignRecord> pageInfo = signService.selectPage(pageNum,pageSize,signRecord);
        return Result.success(pageInfo);
    }

    @PostMapping("/add")
    public Result add(@RequestBody SignRecord signRecord) {
        Date now = new Date();
        // 设置创建时间、打卡日期和打卡时间
        if (signRecord.getCreateTime() == null) {
            signRecord.setCreateTime(now);
        }
        if (signRecord.getSignDate() == null) {
            signRecord.setSignDate(now);
        }
        if (signRecord.getSignInTime() == null) {
            signRecord.setSignInTime(now);
        }

        // 判断签到状态（迟到/准时），并设置 signInStatus；兼容性地同步到旧的 status 字段
        try {
            Date signIn = signRecord.getSignInTime();
            String inStatus = "准时";
            if (signIn != null) {
                Calendar cal = Calendar.getInstance();
                cal.setTime(signIn);
                Calendar thresh = Calendar.getInstance();
                thresh.setTime(signIn);
                thresh.set(Calendar.HOUR_OF_DAY, 9);
                thresh.set(Calendar.MINUTE, 30);
                thresh.set(Calendar.SECOND, 0);
                thresh.set(Calendar.MILLISECOND, 0);
                if (signIn.after(thresh.getTime())) {
                    inStatus = "迟到";
                }
            }
            signRecord.setSignInStatus(inStatus);
        } catch (Exception ignored) {
            signRecord.setSignInStatus("准时");
        }

        int rows = signService.insertSign(signRecord);
        if (rows > 0) {
            return Result.success(signRecord);
        } else {
            return Result.error("插入失败");
        }
    }

    @PostMapping("/signOut")
    public Result signOut(@RequestBody SignRecord req) {
        Long uid = req.getUid();
        if (uid == null) {
            return Result.error("缺少 uid");
        }
        // 查找该用户最近一条未签退的记录
        SignRecord open = signService.selectLatestOpenSign(uid);
        if (open == null) {
            return Result.error("未找到可签退的打卡记录");
        }
        Date now = new Date();
        open.setSignOutTime(now);
        // 判断签退状态（早退/准时），并设置 signOutStatus；兼容性地同步到旧的 status 字段
        try {
            Calendar thresh = Calendar.getInstance();
            thresh.setTime(now);
            thresh.set(Calendar.HOUR_OF_DAY, 18);
            thresh.set(Calendar.MINUTE, 0);
            thresh.set(Calendar.SECOND, 0);
            thresh.set(Calendar.MILLISECOND, 0);
            String outStatus = now.before(thresh.getTime()) ? "早退" : "准时";
            open.setSignOutStatus(outStatus);
        } catch (Exception ignored) {
            open.setSignOutStatus("准时");
        }

        int rows = signService.updateSignOut(open);
        if (rows > 0) {
            return Result.success(open);
        } else {
            return Result.error("签退失败");
        }
    }

    @PostMapping("/update")
    public Result update(@RequestBody SignRecord signRecord) {
        signService.updateById(signRecord);
        return Result.success(signRecord);
    }

    @PostMapping("/delete")
    public Result deleteById(@RequestBody SignRecord signRecord){
        signService.deleteById(signRecord);
        return Result.success();
    }

    @GetMapping("/exportData")
    public void exportData(
            @RequestParam(required = false) String username,
            @RequestParam(required = false) String name,
            HttpServletResponse response) throws IOException{
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

        List<SignRecord> list = signService.selectAllSign();
        writer.write(list,true);
        //response为HttpServletResponse对象
        response.setContentType("application/vnd.ms-excel;charset=utf-8");
        //test.xls是弹出下载对话框的文件名，不能为中文，中文请自行编码
        response.setHeader("Content-Disposition","attachment;filename="+ URLEncoder.encode("签到信息表", StandardCharsets.UTF_8) +".xls");
        ServletOutputStream out = response.getOutputStream();
        writer.flush(out,true);
        writer.close();
    }

}
