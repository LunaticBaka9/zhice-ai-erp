package com.example.demo.service;

import org.springframework.stereotype.Service;

import com.example.demo.mapper.SysMenuMapper;

import jakarta.annotation.Resource;

@Service
public class SysMenuService {
    @Resource
    SysMenuMapper sysMenuMapper;
}
