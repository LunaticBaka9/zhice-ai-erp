package com.lunabaka.service;

import com.lunabaka.utils.EmailUtils;
import com.lunabaka.utils.PasswordUtil;
import com.lunabaka.entity.User;
import com.lunabaka.exception.CustomerException;
import com.lunabaka.mapper.UserMapper;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import jakarta.annotation.Resource;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UserService {
    @Resource
    UserMapper userMapper;

    public User login(User user) {
        //验证账号是否存在
        User dbuser = userMapper.selectByUsername(user.getUsername());
        if (dbuser == null) {
            throw new CustomerException("账号或密码错误");
        }
        // 使用BCrypt验证密码
        if (!PasswordUtil.matches(user.getPassword(), dbuser.getPassword())) {
            throw new CustomerException("账号或密码错误");
        }
        if (dbuser.getStatus() != null && dbuser.getStatus().equals("禁用")) {
            throw new CustomerException("账号已被禁用");
        }
        return dbuser;
    }

    public void sendEmailCode(String email, HttpSession session) {
        User dbuser = userMapper.selectByEmail(email);
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

    public void sendEmailRegCode(String email, HttpSession session){
        User dbuser = userMapper.selectByEmail(email);
        if (dbuser == null) {
            String RegCode = String.valueOf((int) ((Math.random() * 9 + 1) * 100000));
            EmailUtils.sendTextMail(email, "乡链-进销存系统", "注册验证码", "您的验证码为: " + RegCode + "，5分钟内有效。");
            System.out.println(RegCode);
            session.setAttribute("email_code", RegCode);
            session.setAttribute("email_code_email", email);
            session.setAttribute("email_code_time", System.currentTimeMillis());
        } else{
            throw new CustomerException("邮箱已被注册");
        }
    }

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

        User dbuser = userMapper.selectByEmail(email);
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

    public void emailRegister(String email,String password, String code, HttpSession session) {
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

    public void insert(User user) {
        //用户名查重
        User dbUser = userMapper.selectByUsername(user.getUsername());
        if (dbUser != null) {
            throw new CustomerException("账号重复");
        }
        user.setName(user.getUsername());
        System.out.println(user.getName());
        // 对密码进行加密
        user.setPassword(PasswordUtil.encode(user.getPassword()));
        userMapper.insertUser(user);
    }

    public List<User> selectAllUsers() {
        return userMapper.selectAllUsers(null);
    }

    public PageInfo<User> selectPage(int pageNum, int pageSize, User user) {
        PageHelper.startPage(pageNum, pageSize);
        List<User> list = userMapper.selectAllUsers(user);
        return PageInfo.of(list);
    }

    public User selectById(Long uid) {
        return userMapper.selectById(uid);
    }

    public void updateInfo(User user) {
        if (user.getUid() == null) {
            throw new CustomerException("用户ID不能为空");
        }
        User dbUser = userMapper.selectByUsername(user.getUsername());
        if (dbUser != null && !dbUser.getUid().equals(user.getUid())) {
            throw new CustomerException("用户名重复");
        }
        userMapper.updateInfoById(user);
    }

    public void updateStatus(User user) {
        userMapper.updateStatusById(user);
    }

    public void updatePassword(User user) {
        // 对密码进行加密
        user.setPassword(PasswordUtil.encode(user.getPassword()));
        userMapper.updatePasswordById(user);
    }

    public void updateAvatar(Long uid, String path) {
        userMapper.updateAvatarById(uid, path);
    }

    public void deleteById(User user) {
        User dbUser = userMapper.selectByUsername(user.getUsername());
        if (dbUser == null) {
            throw new CustomerException("找不到用户，无法删除");
        }
        userMapper.deleteById(user);
    }

    public void deleteBatch(List<User> list) {
        for (User user : list) {
            this.deleteById(user);
        }
    }

    public void insertBatch(List<User> list) {
        for (User user : list) {
            this.insert(user);
        }
    }
}
