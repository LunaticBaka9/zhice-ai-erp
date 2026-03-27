package com.example.demo.controller;

import com.example.demo.common.Result;
import com.example.demo.entity.SignRecord;
import com.example.demo.service.SignService;
import com.github.pagehelper.PageInfo;
import jakarta.annotation.Resource;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
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

    @GetMapping("/export")
    public void export(@RequestParam(required = false) Long uid, HttpServletResponse response) throws IOException {
        SignRecord filter = new SignRecord();
        if (uid != null) {
            filter.setUid(uid);
        }
        List<SignRecord> list = signService.selectAllSign(filter);

        response.setContentType("text/csv;charset=UTF-8");
        String filename = URLEncoder.encode("sign_records.csv", "UTF-8");
        response.setHeader("Content-Disposition", "attachment;filename*=UTF-8''" + filename);

        PrintWriter writer = response.getWriter();
        writer.println("sid,uid,username,signDate,signInTime,signOutTime,signInStatus,signOutStatus,status,remark,createTime");
        SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");
        SimpleDateFormat dt = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        for (SignRecord r : list) {
            String sid = r.getSid() == null ? "" : String.valueOf(r.getSid());
            String suid = r.getUid() == null ? "" : String.valueOf(r.getUid());
            String username = safe(r.getUsername());
            String signDate = r.getSignDate() == null ? "" : df.format(r.getSignDate());
            String signIn = r.getSignInTime() == null ? "" : dt.format(r.getSignInTime());
            String signOut = r.getSignOutTime() == null ? "" : dt.format(r.getSignOutTime());
            String signInStatus = safe(r.getSignInStatus());
            String signOutStatus = safe(r.getSignOutStatus());
            String remark = safe(r.getRemark());
            String createTime = r.getCreateTime() == null ? "" : dt.format(r.getCreateTime());

            String line = String.join(",", sid, suid, username, signDate, signIn, signOut, signInStatus, signOutStatus, remark, createTime);
            writer.println(line);
        }
        writer.flush();
    }

    private String safe(String s) {
        if (s == null) return "";
        return s.replaceAll(",", " ").replaceAll("\r|\n", " ");
    }
}
