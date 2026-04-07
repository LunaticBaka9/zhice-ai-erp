package com.example.demo.controller;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.Font;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.example.demo.common.OperationLogAnnotation;
import com.example.demo.common.Result;
import com.example.demo.entity.User;
import com.example.demo.service.UserService;
import com.github.pagehelper.PageInfo;

import cn.hutool.poi.excel.ExcelReader;
import cn.hutool.poi.excel.ExcelUtil;
import cn.hutool.poi.excel.ExcelWriter;
import jakarta.annotation.Resource;
import jakarta.servlet.ServletOutputStream;
import jakarta.servlet.http.HttpServletResponse;

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

    @OperationLogAnnotation(module="用户管理", type="修改", value="修改用户")
    @PostMapping("/updateInfo")
    public Result updateInfo(@RequestBody User user){
        userService.updateInfo(user);
        return Result.success();
    }

    @OperationLogAnnotation(module="用户管理", type="修改", value="修改用户密码")
    @PostMapping("/updatePassword")
    public Result updatePassword(@RequestBody User user){
        userService.updatePassword(user);
        return Result.success();
    }

    @OperationLogAnnotation(module="用户管理", type="修改", value="修改用户状态")
    @PostMapping("/updateStatus")
    public Result updateStatus(@RequestBody User user){
        userService.updateStatus(user);
        return Result.success();
    }

    @OperationLogAnnotation(module="用户管理", type="新增", value="新增用户")
    @PostMapping("/add")
    public Result add(@RequestBody User user){
        userService.insert(user);
        return Result.success();
    }

    @OperationLogAnnotation(module="用户管理", type="删除", value="删除用户")
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
        //全局
        try (ExcelWriter writer = ExcelUtil.getWriter(username, name)) {
            //全局
            CellStyle cellStyle = writer.getCellStyle();
            //创建标题字体
            Font font = writer.createFont();
            //大小
            font.setFontHeightInPoints((short) 10);
            font.setFontName("宋体");
            cellStyle.setFont(font);
            //全局  宽15
            writer.setColumnWidth(-1,15);
            writer.setColumnWidth(0,20);
            //全局  高25
            writer.setRowHeight(-1,25);
            
            List<User> list = userService.selectAllUsers();
            writer.write(list,true);
            //response为HttpServletResponse对象
            response.setContentType("application/vnd.ms-excel;charset=utf-8");
            //test.xls是弹出下载对话框的文件名，不能为中文，中文请自行编码
            response.setHeader("Content-Disposition","attachment;filename="+ URLEncoder.encode("用户信息表", StandardCharsets.UTF_8) +".xls");
            ServletOutputStream out = response.getOutputStream();
            writer.flush(out,true);
        }
    }

    @OperationLogAnnotation(module="用户管理", type="新增", value="批量导入用户")
    @PostMapping("/importData")
    public Result importData(MultipartFile file) throws IOException{
        ExcelReader reader = ExcelUtil.getReader(file.getInputStream());
        List<User> userList = reader.readAll(User.class);
        try {
            userService.insertBatch(userList);
        } catch (Exception e) {
            return Result.error("数据批量导入错误");
        }
        return Result.success();
    }

    @PostMapping("/insertBatch")
    public Result insertBatch(@RequestBody List<User> userList){
        userService.insertBatch(userList);
        return Result.success();
    }
}
