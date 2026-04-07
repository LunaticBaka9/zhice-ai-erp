package com.example.demo.service;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Date;
import java.util.List;

import org.springframework.stereotype.Service;

import com.example.demo.entity.SignRecord;
import com.example.demo.mapper.SignMapper;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;

import jakarta.annotation.Resource;

@Service
public class SignService {
    @Resource
    private SignMapper signMapper;

    public PageInfo<SignRecord> selectPage(Integer pageNum, Integer pageSize, SignRecord signRecord) {
        PageHelper.startPage(pageNum, pageSize);
        List<SignRecord> list = signMapper.selectAllSign(signRecord);
        return PageInfo.of(list);
    }

    public int insertSign(SignRecord signRecord) {
        if (signRecord.getCreateTime() == null) {
            signRecord.setCreateTime(new Date());
        }
        return signMapper.insertSign(signRecord);
    }

    public SignRecord selectLatestOpenSign(Long uid) {
        return signMapper.selectLatestOpenSign(uid);
    }

    public SignRecord selectLatestSign(Long uid) {
        return signMapper.selectLatestSign(uid);
    }

    public void updateById(SignRecord signRecord) {
        signMapper.updateById(signRecord);
    }

    public int updateSignOut(SignRecord signRecord) {
        return signMapper.updateSignOut(signRecord);
    }

    public List<SignRecord> selectAllSign() {
        return signMapper.selectAllSign(null);
    }

    public void deleteById(SignRecord signRecord){
        signMapper.deleteById(signRecord);
    }

    // 查询用户今日是否有打卡记录
    public SignRecord selectTodaySign(Long uid) {
        return signMapper.selectTodaySign(uid);
    }

    // 查询用户本月签到次数
    public int selectMonthSignCount(Long uid, int year, int month) {
        return signMapper.selectMonthSignCount(uid, year, month);
    }

    // 查询用户连续打卡天数
    public int selectContinuousSignDays(Long uid) {
        List<String> signDates = signMapper.selectSignDates(uid);
        if (signDates == null || signDates.isEmpty()) {
            return 0;
        }

        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        LocalDate today = LocalDate.now();
        int consecutiveDays = 0;

        for (String dateStr : signDates) {
            LocalDate signDate = LocalDate.parse(dateStr, formatter);
            LocalDate expectedDate = today.minusDays(consecutiveDays);

            if (signDate.equals(expectedDate)) {
                consecutiveDays++;
            } else if (signDate.isBefore(expectedDate)) {
                // 出现断档，停止计算
                break;
            }
            // 如果 signDate 是未来日期（可能是数据错误），跳过
        }

        return consecutiveDays;
    }
}
