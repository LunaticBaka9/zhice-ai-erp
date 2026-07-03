package com.lunabaka.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.lunabaka.entity.NoticeReadRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface NoticeReadRecordMapper extends BaseMapper<NoticeReadRecord> {

    int countUnreadNotices(@Param("userId") Long userId);

    List<Long> selectReadNoticeIdsByUserId(@Param("userId") Long userId);
}
