package com.example.demo.mapper;

import com.example.demo.entity.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

@Mapper
public interface UserMapper {

    void insertUser(User user);

    User selectByUsername(@Param("username") String username);

    User selectById(@Param("uid") Long uid);

    void updateInfoById(User user);

    void updateStatusById(User user);

    void updatePasswordById(User user);

    List<User> selectAllUsers(User user);

    void deleteById(User user);
}
