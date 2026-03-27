package com.example.demo.controller;

import java.text.SimpleDateFormat;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/file")
public class FileController {
    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");


}
