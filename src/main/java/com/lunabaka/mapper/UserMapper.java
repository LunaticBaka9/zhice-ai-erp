package com.lunabaka.mapper;

import com.lunabaka.entity.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface UserMapper {

    void insertUser(User user);

    User selectByUsername(@Param("username") String username);

    User selectById(@Param("uid") Long uid);

    User selectByEmail(@Param("email") String email);

    void updateInfoById(User user);

    void updateStatusById(User user);

    void updatePasswordById(User user);

    void updateAvatarById(Long uid, String path);

    List<User> selectAllUsers(User user);

    void deleteById(User user);
}
