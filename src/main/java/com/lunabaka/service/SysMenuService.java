package com.lunabaka.service;

import org.springframework.stereotype.Service;

import com.lunabaka.mapper.SysMenuMapper;

import jakarta.annotation.Resource;

@Service
public class SysMenuService {
    @Resource
    SysMenuMapper sysMenuMapper;
}
