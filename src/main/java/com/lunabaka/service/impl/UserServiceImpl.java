package com.lunabaka.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.lunabaka.entity.User;
import com.lunabaka.exception.CustomerException;
import com.lunabaka.mapper.UserMapper;
import com.lunabaka.service.DeptService;
import com.lunabaka.service.UserService;
import com.lunabaka.utils.EmailUtils;
import com.lunabaka.utils.PasswordUtil;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {

    @Autowired
    private DeptService deptService;
    @Autowired
    private UserMapper userMapper;

    @Override
    public User login(User user) {
        User dbuser = baseMapper.selectOne(
                Wrappers.<User>lambdaQuery().eq(User::getUsername, user.getUsername()));
        if (dbuser == null) {
            throw new CustomerException("账号或密码错误");
        }
        if (!PasswordUtil.matches(user.getPassword(), dbuser.getPassword())) {
            throw new CustomerException("账号或密码错误");
        }
        if (dbuser.getStatus() != null && dbuser.getStatus().equals("禁用")) {
            throw new CustomerException("账号已被禁用");
        }
        return dbuser;
    }

    @Override
    public void sendEmailCode(String email, HttpSession session) {
        User dbuser = baseMapper.selectOne(
                Wrappers.<User>lambdaQuery().eq(User::getEmail, email));
        if (dbuser == null) {
            throw new CustomerException("找不到该邮箱，请重试");
        }
        if (dbuser.getStatus() != null && dbuser.getStatus().equals("禁用")) {
            throw new CustomerException("账号已被禁用");
        }
        String loginCode = String.valueOf((int) ((Math.random() * 9 + 1) * 100000));
        EmailUtils.sendTextMail(email, "乡链-进销存系统", "登录验证码", "您的验证码为: " + loginCode + "，5分钟内有效。");
        System.out.println(loginCode);
        session.setAttribute("email_code", loginCode);
        session.setAttribute("email_code_email", email);
        session.setAttribute("email_code_time", System.currentTimeMillis());
    }

    @Override
    public void sendEmailRegCode(String email, HttpSession session) {
        User dbuser = baseMapper.selectOne(
                Wrappers.<User>lambdaQuery().eq(User::getEmail, email));
        if (dbuser == null) {
            String RegCode = String.valueOf((int) ((Math.random() * 9 + 1) * 100000));
            EmailUtils.sendTextMail(email, "乡链-进销存系统", "注册验证码", "您的验证码为: " + RegCode + "，5分钟内有效。");
            System.out.println(RegCode);
            session.setAttribute("email_code", RegCode);
            session.setAttribute("email_code_email", email);
            session.setAttribute("email_code_time", System.currentTimeMillis());
        } else {
            throw new CustomerException("邮箱已被注册");
        }
    }

    @Override
    public User emailLogin(String email, String code, HttpSession session) {
        String sessionCode = (String) session.getAttribute("email_code");
        String sessionEmail = (String) session.getAttribute("email_code_email");
        Long sessionCodeTime = (Long) session.getAttribute("email_code_time");

        if (sessionCode == null || sessionEmail == null) {
            throw new CustomerException("请先获取验证码");
        }
        if (!sessionEmail.equals(email)) {
            throw new CustomerException("邮箱与验证码不匹配");
        }
        if (sessionCodeTime != null && System.currentTimeMillis() - sessionCodeTime > 5 * 60 * 1000) {
            session.removeAttribute("email_code");
            session.removeAttribute("email_code_email");
            session.removeAttribute("email_code_time");
            throw new CustomerException("验证码已过期，请重新获取");
        }
        if (!sessionCode.equals(code)) {
            throw new CustomerException("验证码错误");
        }

        User dbuser = baseMapper.selectOne(
                Wrappers.<User>lambdaQuery().eq(User::getEmail, email));
        if (dbuser == null) {
            throw new CustomerException("找不到该邮箱，请重试");
        }
        if (dbuser.getStatus() != null && dbuser.getStatus().equals("禁用")) {
            throw new CustomerException("账号已被禁用");
        }

        session.removeAttribute("email_code");
        session.removeAttribute("email_code_email");
        session.removeAttribute("email_code_time");

        return dbuser;
    }

    @Override
    public void emailRegister(String email, String password, String code, HttpSession session) {
        String sessionCode = (String) session.getAttribute("email_code");
        String sessionEmail = (String) session.getAttribute("email_code_email");
        Long sessionCodeTime = (Long) session.getAttribute("email_code_time");

        if (sessionCode == null || sessionEmail == null) {
            throw new CustomerException("请先获取验证码");
        }
        if (sessionCodeTime != null && System.currentTimeMillis() - sessionCodeTime > 5 * 60 * 1000) {
            session.removeAttribute("email_code");
            session.removeAttribute("email_code_email");
            session.removeAttribute("email_code_time");
            throw new CustomerException("验证码已过期，请重新获取");
        }
        if (!sessionCode.equals(code)) {
            throw new CustomerException("验证码错误");
        }

        User newUser = new User();
        newUser.setUsername(email);
        newUser.setEmail(email);
        newUser.setPassword(password);
        insert(newUser);

        session.removeAttribute("email_code");
        session.removeAttribute("email_code_email");
        session.removeAttribute("email_code_time");
    }

    @Override
    public void insert(User user) {
        User dbUser = baseMapper.selectOne(
                Wrappers.<User>lambdaQuery().eq(User::getUsername, user.getUsername()));
        if (dbUser != null) {
            throw new CustomerException("账号重复");
        }
        user.setName(user.getUsername());
        user.setPassword(PasswordUtil.encode(user.getPassword()));
        baseMapper.insert(user);
    }

    @Override
    public List<User> selectAllUsers() {
        return baseMapper.selectList(null);
    }

    @Override
    public IPage<User> selectPage(int pageNum, int pageSize, User user) {
        LambdaQueryWrapper<User> wrapper = Wrappers.<User>lambdaQuery();
        if (user.getUsername() != null && !user.getUsername().isEmpty()) {
            wrapper.like(User::getUsername, user.getUsername());
        }
        if (user.getName() != null && !user.getName().isEmpty()) {
            wrapper.like(User::getName, user.getName());
        }
        if (user.getPhone() != null && !user.getPhone().isEmpty()) {
            wrapper.like(User::getPhone, user.getPhone());
        }
        if (user.getEmail() != null && !user.getEmail().isEmpty()) {
            wrapper.like(User::getEmail, user.getEmail());
        }
        return baseMapper.selectPage(new Page<>(pageNum, pageSize), wrapper);
    }

    @Override
    public void updateInfo(User user) {
        if (user.getUid() == null) {
            throw new CustomerException("用户ID不能为空");
        }
        User dbUser = baseMapper.selectOne(
                Wrappers.<User>lambdaQuery().eq(User::getUsername, user.getUsername()));
        if (dbUser != null && !dbUser.getUid().equals(user.getUid())) {
            throw new CustomerException("用户名重复");
        }
        LambdaUpdateWrapper<User> wrapper = Wrappers.<User>lambdaUpdate()
                .eq(User::getUid, user.getUid())
                .set(User::getName, user.getName())
                .set(User::getRole, user.getRole())
                .set(User::getDeptName, user.getDeptName())
                .set(User::getBio, user.getBio())
                .set(User::getJoinDate, user.getJoinDate())
                .set(User::getAvatar, user.getAvatar())
                .setSql("updateTime = NOW()");
        baseMapper.update(null, wrapper);
    }

    @Override
    public void updateStatus(User user) {
        LambdaUpdateWrapper<User> wrapper = Wrappers.<User>lambdaUpdate()
                .eq(User::getUid, user.getUid())
                .set(User::getStatus, user.getStatus())
                .setSql("updateTime = NOW()");
        baseMapper.update(null, wrapper);
    }

    @Override
    public void updatePassword(User user) {
        user.setPassword(PasswordUtil.encode(user.getPassword()));
        LambdaUpdateWrapper<User> wrapper = Wrappers.<User>lambdaUpdate()
                .eq(User::getUid, user.getUid())
                .set(User::getPassword, user.getPassword())
                .setSql("updateTime = NOW()");
        baseMapper.update(null, wrapper);
    }

    @Override
    public void updateAvatar(Long uid, String path) {
        baseMapper.updateAvatarById(uid, path);
    }

    @Override
    public void deleteById(User user) {
        User dbUser = baseMapper.selectOne(
                Wrappers.<User>lambdaQuery().eq(User::getUsername, user.getUsername()));
        if (dbUser == null) {
            throw new CustomerException("找不到用户，无法删除");
        }
        baseMapper.deleteById(user.getUid());
    }

    @Override
    public void deleteBatch(List<User> list) {
        for (User user : list) {
            deleteById(user);
        }
    }

    @Override
    public void insertBatch(List<User> list) {
        for (User user : list) {
            insert(user);
        }
    }
}
