package com.example.demo.controller;


import com.example.demo.common.Result;
import com.example.demo.entity.User;
import com.example.demo.service.UserService;
import com.github.pagehelper.PageInfo;
import jakarta.annotation.Resource;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/user")
public class UserController {
    @Resource
    UserService userService;

    @GetMapping("/selectById/{uid}")
    public Result getUserById(@PathVariable Long uid){
        User user = userService.selectById(uid);
        return Result.success(user);
    }

    @GetMapping("/selectAllUsers")
    public Result selectAllUsers() {
        List<User> userList = userService.selectAllUsers();
        return Result.success(userList);
    }

    @GetMapping("/list")
    public Result selectPage(@RequestParam(defaultValue = "1") Integer pageNum,
                             @RequestParam(defaultValue = "10") Integer pageSize,
                             User user){
        PageInfo<User> pageInfo = userService.selectPage(pageNum, pageSize, user);
        return Result.success(pageInfo);
    }

    @PostMapping("/updateInfo")
    public Result updateInfo(@RequestBody User user){
        userService.updateInfo(user);
        return Result.success();
    }

    @PostMapping("/updatePassword")
    public Result updatePassword(@RequestBody User user){
        userService.updatePassword(user);
        return Result.success();
    }

    @PostMapping("/updateStatus")
    public Result updateStatus(@RequestBody User user){
        userService.updateStatus(user);
        return Result.success();
    }

    @PostMapping("/add")
    public Result add(@RequestBody User user){
        userService.insert(user);
        return Result.success();
    }

    @PostMapping("/delete")
    public Result deleteById(@RequestBody User user){
        userService.deleteById(user);
        return Result.success();
    }

    @PostMapping("/deleteBatch")
    public Result deleteBatch(@RequestBody List<User> list){
        userService.deleteBatch(list);
        return Result.success();
    }
}
