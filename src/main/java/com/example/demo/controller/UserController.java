package com.example.demo.controller;


import cn.hutool.core.util.StrUtil;
import cn.hutool.poi.excel.ExcelUtil;
import cn.hutool.poi.excel.ExcelWriter;
import com.example.demo.common.Result;
import com.example.demo.entity.User;
import com.example.demo.service.UserService;
import com.github.pagehelper.PageInfo;
import jakarta.annotation.Resource;
import jakarta.servlet.ServletOutputStream;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.net.URLEncoder;
import java.util.ArrayList;
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

    @GetMapping("/exportData")
    public void exportData(
            @RequestParam(required = false) String username,
            @RequestParam(required = false) String name,
            HttpServletResponse response) throws IOException{
        ExcelWriter writer = ExcelUtil.getWriter(username, name);
        List<User> list = new ArrayList<>();
        if ( StrUtil.isBlank(username) && StrUtil.isBlank(name) ){
            list = userService.selectAllUsers();
        }
        writer.write(list,true);
        //response为HttpServletResponse对象
        response.setContentType("application/vnd.ms-excel;charset=utf-8");
        //test.xls是弹出下载对话框的文件名，不能为中文，中文请自行编码
        response.setHeader("Content-Disposition","attachment;filename="+ URLEncoder.encode("用户信息表","UTF-8") +".xls");
        ServletOutputStream out = response.getOutputStream();
        writer.flush(out,true);
        writer.close();
    }
}
