package com.example.demo.service;

import com.example.demo.entity.User;
import com.example.demo.exception.CustomerException;
import com.example.demo.mapper.UserMapper;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import jakarta.annotation.Resource;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UserService {
    @Resource
    UserMapper userMapper;

    public User login(User user){
        //验证账号是否存在
        User dbuser = userMapper.selectByUsername(user.getUsername());
        if(dbuser == null){
            throw new CustomerException("账号或密码错误");
        }
        if(!dbuser.getPassword().equals(user.getPassword())){
            throw new CustomerException("账号或密码错误");
        }
        if(dbuser.getStatus().equals("禁用")){
            throw new CustomerException("账号已被禁用");
        }
        return dbuser;
    }

    public void insert(User user){
        //用户名查重
        User dbUser = userMapper.selectByUsername(user.getUsername());
        if(dbUser != null){
            throw new CustomerException("账号重复");
        }
        user.setName(user.getUsername());
        System.out.println(user.getName());
        userMapper.insertUser(user);
    }

    public List<User> selectAllUsers(){
        return userMapper.selectAllUsers(null);
    }

    public PageInfo<User> selectPage(int pageNum, int pageSize, User user){
        PageHelper.startPage(pageNum, pageSize);
        List<User> list = userMapper.selectAllUsers(user);
        return PageInfo.of(list);
    }

    public User selectById(Long uid){
        return userMapper.selectById(uid);
    }

    public void updateInfo(User user){
        User dbUser = userMapper.selectByUsername(user.getUsername());
        if(dbUser != null){
            throw new CustomerException("用户名重复");
        }
        userMapper.updateInfoById(user);
    }

    public void updateStatus(User user){
        userMapper.updateStatusById(user);
    }

    public void updatePassword(User user){
        userMapper.updatePasswordById(user);
    }

    public void updateAvatar(Long uid, String path){
        userMapper.updateAvatarById(uid, path);
    }

    public void deleteById(User user){
        User dbUser = userMapper.selectByUsername(user.getUsername());
        if(dbUser == null){
            throw new CustomerException("找不到用户，无法删除");
        }
        userMapper.deleteById(user);
    }

    public void deleteBatch(List<User> list){
        for(User user: list){
            this.deleteById(user);
        }
    }

    @Transactional(rollbackFor = Exception.class)
    public void insertBatch(List<User> list){
        if(list == null || list.isEmpty()){
            return;
        }
        for(User user: list){
            if(user == null){
                throw new CustomerException("导入数据包含空记录");
            }
            String username = user.getUsername();
            if(username == null || username.trim().isEmpty()){
                throw new CustomerException("用户名不能为空");
            }
            User dbUser = userMapper.selectByUsername(username);
            if(dbUser != null){
                throw new CustomerException("账号重复: " + username);
            }
            if(user.getName() == null || user.getName().trim().isEmpty()){
                user.setName(username);
            }
            userMapper.insertUser(user);
        }
    }
}
