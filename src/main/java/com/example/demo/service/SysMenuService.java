package com.example.demo.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.example.demo.entity.SysMenu;
import com.example.demo.mapper.SysMenuMapper;

import jakarta.annotation.Resource;

@Service
public class SysMenuService {
    @Resource
    SysMenuMapper sysMenuMapper;
}
