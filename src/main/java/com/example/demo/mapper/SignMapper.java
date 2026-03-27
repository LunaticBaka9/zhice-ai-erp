package com.example.demo.mapper;

import org.apache.ibatis.annotations.Mapper;

import com.example.demo.entity.SignRecord;

import java.util.List;

@Mapper
public interface SignMapper {
    List<SignRecord> selectAllSign(SignRecord signRecord);

    int insertSign(SignRecord signRecord);

    SignRecord selectLatestOpenSign(Long uid);

    int updateSignOut(SignRecord signRecord);

    void updateById(SignRecord signRecord);
}
