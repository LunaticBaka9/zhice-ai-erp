package com.example.demo.controller;

import java.io.File;
import java.io.IOException;

import com.example.demo.service.UserService;
import org.springframework.util.ResourceUtils;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import jakarta.annotation.Resource;
import jakarta.servlet.http.HttpServletRequest;


@RestController
public class FileController {

    @Resource
    UserService userService;

    @PostMapping("/upload")
    public String upload(Long uid, MultipartFile photo, HttpServletRequest request) throws IOException{
        String path = ResourceUtils.getURL("classpath:").getPath()+"static/upload";
        String realPath = path.replace('/','\\').substring(1,path.length());
        System.out.println(realPath);
        saveFile(photo, realPath);
        return "上传成功";
    }

    public void saveFile(MultipartFile photo, String path) throws IOException{
        File upDir = new File(path);
        if(!upDir.exists()){
            upDir.mkdir();
        }
        File file = new File(path + photo.getOriginalFilename());
        photo.transferTo(file);
    }
}