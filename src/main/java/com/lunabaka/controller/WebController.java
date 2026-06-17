package com.lunabaka.controller;

import com.lunabaka.config.JwtConfig;
import com.lunabaka.common.OperationLogAnnotation;
import com.lunabaka.common.Result;
import com.lunabaka.entity.User;
import com.lunabaka.service.UserService;
import jakarta.annotation.Resource;
import jakarta.servlet.http.HttpSession;
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

    @OperationLogAnnotation(module = "用户管理", type = "登录", value = "用户登录")
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

    @OperationLogAnnotation(module = "用户管理", type = "注册", value = "用户注册")
    @PostMapping("/register")
    public Result register(@RequestBody User user) {
        userService.insert(user);
        return Result.success();
    }

    @PostMapping("/sendEmailCode")
    public Result sendEmailCode(@RequestBody Map<String, String> params, HttpSession session) {
        String email = params.get("email");
        userService.sendEmailCode(email, session);
        return Result.success();
    }

    @PostMapping("/sendEmailRegCode")
    public Result sendEmailRegCode(@RequestBody Map<String, String> params, HttpSession session) {
        String email = params.get("email");
        userService.sendEmailRegCode(email, session);
        return Result.success();
    }

    @OperationLogAnnotation(module = "用户管理", type = "登录", value = "邮箱免密登录")
    @PostMapping("/emailLogin")
    public Result emailLogin(@RequestBody Map<String, String> params, HttpSession session) {
        String email = params.get("email");
        String code = params.get("code");
        User dbuser = userService.emailLogin(email, code, session);
        session.setAttribute("loginUser", dbuser);
        String token = jwtConfig.createToken(String.valueOf(dbuser.getUid()));
        Map<String, Object> result = new HashMap<>();
        result.put("user", dbuser);
        result.put("token", token);
        return Result.success(result);
    }

    @OperationLogAnnotation(module = "用户管理", type = "注册", value = "邮箱注册")
    @PostMapping("/emailRegister")
    public Result emailRegister(@RequestBody Map<String, String> params, HttpSession session) {
        String email = params.get("email");
        String password = params.get("password");
        String code = params.get("code");

        userService.emailRegister(email, password, code, session);
        return Result.success();
    }
}
