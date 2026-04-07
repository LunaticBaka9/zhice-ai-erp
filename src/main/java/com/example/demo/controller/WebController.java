package com.example.demo.controller;

import com.example.demo.common.JwtConfig;
import com.example.demo.common.OperationLogAnnotation;
import com.example.demo.common.Result;
import com.example.demo.entity.User;
import com.example.demo.service.UserService;
import jakarta.annotation.Resource;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
public class WebController {

    @Resource
    UserService userService;
    
    @Resource
    JwtConfig jwtConfig;

    @OperationLogAnnotation(module="用户管理", type="登录", value="用户登录")
    @PostMapping("/login")
    public Result login(@RequestBody User user) {
        User dbuser = userService.login(user);
        // 生成JWT token
        String token = jwtConfig.createToken(String.valueOf(dbuser.getUid()));
        // 返回用户信息和token
        Map<String, Object> result = new HashMap<>();
        result.put("user", dbuser);
        result.put("token", token);
        return Result.success(result);
    }

    @PostMapping("/register")
    public Result register(@RequestBody User user){
        userService.insert(user);
        return Result.success();
    }
}
