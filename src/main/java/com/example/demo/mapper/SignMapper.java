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
}
