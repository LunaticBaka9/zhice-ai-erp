package com.example.demo.controller;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

import org.apache.commons.io.FilenameUtils;
import org.springframework.util.ResourceUtils;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.example.demo.common.Result;
import com.example.demo.service.UserService;

import jakarta.annotation.Resource;
import jakarta.servlet.http.HttpServletRequest;

@RestController
@RequestMapping("/file")
public class FileController {

    @Resource
    UserService userService;

    @PostMapping("/uploadAvatar")
    public Result uploadAvatar(@RequestParam(required = false) Long uid, @RequestParam("photo") MultipartFile photo, HttpServletRequest request) throws IOException{
        if (photo == null || photo.isEmpty()) {
            return Result.error("上传文件为空");
        }
        // 使用 ResourceUtils 获取 classpath 下的 static 目录，避免手动拼接路径导致的非法字符
        File staticDir = ResourceUtils.getFile("classpath:static");
        File uploadDirFile = new File(staticDir, "upload/avatars");
        if (!uploadDirFile.exists()) {
            uploadDirFile.mkdirs();
        }

        String original = photo.getOriginalFilename();
        String fileName = System.currentTimeMillis() + "_" + (original != null ? original : "avatar.jpg");
        Path target = uploadDirFile.toPath().resolve(fileName);
        Files.copy(photo.getInputStream(), target);

        // 返回前端可访问的静态资源路径
        String publicPath =  "api/static/upload/avatars/" + fileName; // 前端访问地址: /static/upload 映射到 /upload/
        userService.updateAvatar(uid, publicPath);
        return Result.success(publicPath);
    }

    @PostMapping("/upload")
    public Result uploadFile(@RequestParam("file") MultipartFile file, HttpServletRequest request) throws IOException {
        if (file.isEmpty()) {
            return Result.error("上传文件为空");
        }
        
        String original = file.getOriginalFilename();
        // 获取文件后缀
        String suffix = FilenameUtils.getExtension(original).toLowerCase();
        
        // 使用 ResourceUtils 获取 classpath 下的 static 目录
        File staticDir = ResourceUtils.getFile("classpath:static");
        File uploadDirFile;
        String fileName;
        String publicPath;
        
        // 根据文件类型分类存储
        // 注意：返回的路径需要加上 /api 前缀，以便前端通过代理访问
        if (suffix.matches(".*(jpg|jpeg|png|gif|bmp|webp|svg|ico).*")) {
            // 图片文件
            uploadDirFile = new File(staticDir, "upload/picture");
            if (!uploadDirFile.exists()) {
                uploadDirFile.mkdirs();
            }
            fileName = System.currentTimeMillis() + "_" + (original != null ? original : "picture.jpg");
            publicPath = "/api/static/upload/picture/" + fileName;
        } else if (suffix.matches(".*(txt|doc|docx|xls|xlsx|pdf|ppt|pptx|csv).*")) {
            // 文档文件
            uploadDirFile = new File(staticDir, "upload/file");
            if (!uploadDirFile.exists()) {
                uploadDirFile.mkdirs();
            }
            fileName = System.currentTimeMillis() + "_" + (original != null ? original : "file");
            publicPath = "/api/static/upload/file/" + fileName;
        } else if (suffix.matches(".*(zip|rar|7z|tar|gz).*")) {
            // 压缩包文件
            uploadDirFile = new File(staticDir, "upload/archive");
            if (!uploadDirFile.exists()) {
                uploadDirFile.mkdirs();
            }
            fileName = System.currentTimeMillis() + "_" + (original != null ? original : "archive");
            publicPath = "/api/static/upload/archive/" + fileName;
        } else {
            // 其他文件类型，存储到通用目录
            uploadDirFile = new File(staticDir, "upload/other");
            if (!uploadDirFile.exists()) {
                uploadDirFile.mkdirs();
            }
            fileName = System.currentTimeMillis() + "_" + (original != null ? original : "file");
            publicPath = "/api/static/upload/other/" + fileName;
        }
        
        // 保存文件
        Path target = uploadDirFile.toPath().resolve(fileName);
        Files.copy(file.getInputStream(), target);
        
        // 返回文件信息
        java.util.Map<String, Object> fileInfo = new java.util.HashMap<>();
        fileInfo.put("url", publicPath);
        fileInfo.put("name", original);
        fileInfo.put("size", file.getSize());
        fileInfo.put("type", suffix);
        
        System.out.println(fileInfo);

        return Result.success(fileInfo);
    }
}