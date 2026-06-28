package com.lunabaka.service;

import com.lunabaka.entity.Dept;
import com.baomidou.mybatisplus.extension.service.IService;
import com.lunabaka.entity.Menu;

import java.util.List;

/**
* @author lunaticbaka
* @description 针对表【dept(部门表)】的数据库操作Service
* @createDate 2026-06-28 18:03:30
*/
public interface DeptService extends IService<Dept> {

    List<Dept> getTreeList();

    void updateStatus(Dept dept);
}
