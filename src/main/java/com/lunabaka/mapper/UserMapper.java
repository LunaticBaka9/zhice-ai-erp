package com.lunabaka.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.lunabaka.entity.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface UserMapper extends BaseMapper<User> {

    void updateAvatarById(@Param("uid") Long uid, @Param("path") String path);
}
