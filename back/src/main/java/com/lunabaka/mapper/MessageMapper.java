package com.lunabaka.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.lunabaka.entity.Message;
import org.apache.ibatis.annotations.Mapper;

/**
 * 消息中心 Mapper。
 *
 * <p>常规增删改查统一复用 MyBatis-Plus 的 BaseMapper，逻辑删除由
 * {@link Message#getDelFlag()} 上的 @TableLogic 自动处理。</p>
 */
@Mapper
public interface MessageMapper extends BaseMapper<Message> {
}
