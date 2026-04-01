package com.example.demo.mapper;

import com.example.demo.entity.Notice;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface NoticeMapper {
    List<Notice> selectAllNotice(Notice notice);

    Notice selectByNid(@Param("nid") Long nid);

    Notice selectByUid(@Param("uid") Long uid);

    int insertNotice(Notice notice);

    void updateNotice(Notice notice);

    void deleteByNid(Notice notice);
}
