package com.example.demo.controller;

import com.example.demo.common.Result;
import com.example.demo.entity.User;
import com.example.demo.service.UserService;
import jakarta.annotation.Resource;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class WebController {

    @Resource
    UserService userService;

    @PostMapping("/login")
    public Result login(@RequestBody User user) {
        User dbuser = userService.login(user);
        return Result.success(dbuser);
    }

    @PostMapping("/register")
    public Result register(@RequestBody User user){
        userService.insert(user);
        return Result.success();
    }
}
