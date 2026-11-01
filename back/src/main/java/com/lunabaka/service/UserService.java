package com.lunabaka.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.lunabaka.entity.User;
import jakarta.servlet.http.HttpSession;

import java.util.List;

public interface UserService extends IService<User> {

    User login(User user);

    void sendEmailCode(String email, HttpSession session);

    void sendEmailRegCode(String email, HttpSession session);

    User emailLogin(String email, String code, HttpSession session);

    void emailRegister(String email, String password, String code, HttpSession session);

    void insert(User user);

    List<User> selectAllUsers();

    IPage<User> selectPage(int pageNum, int pageSize, User user);

    void updateInfo(User user);

    void updateStatus(User user);

    void updatePassword(User user);

    void updateAvatar(Long uid, String path);

    void deleteById(User user);

    void deleteBatch(List<User> list);

    void insertBatch(List<User> list);
}
