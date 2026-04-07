package com.example.demo.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.example.demo.entity.SignRecord;


@Mapper
public interface SignMapper {
    List<SignRecord> selectAllSign(SignRecord signRecord);

    int insertSign(SignRecord signRecord);

    SignRecord selectLatestOpenSign(Long uid);

    SignRecord selectLatestSign(Long uid);

    int updateSignOut(SignRecord signRecord);

    void updateById(SignRecord signRecord);

    void deleteById(SignRecord signRecord);

    // 查询用户今日是否有打卡记录
    SignRecord selectTodaySign(Long uid);

    // 查询用户本月签到次数
    int selectMonthSignCount(@org.apache.ibatis.annotations.Param("uid") Long uid,
                             @org.apache.ibatis.annotations.Param("year") int year,
                             @org.apache.ibatis.annotations.Param("month") int month);
}
