package com.lunabaka.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.lunabaka.entity.Dept;
import com.lunabaka.entity.User;

import java.util.List;

/**
* @author lunaticbaka
* @description 针对表【dept(部门表)】的数据库操作Service
* @createDate 2026-06-28 18:03:30
*/
public interface DeptService extends IService<Dept> {

    // 获取部门树列表
    List<Dept> getTreeList();

    // 查询指定部门及其所有子部门下的全部成员
    List<User> getDeptMemberList(Long deptId, String searchQuery);

    // 更新部门状态
    void updateStatus(Dept dept);

    // 更新部门信息
    void updateInfo(Dept dept);

    // 删除子部门
    void deleteSubDepts(Long parentId);
}
