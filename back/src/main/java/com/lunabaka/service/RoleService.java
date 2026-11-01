package com.lunabaka.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.lunabaka.entity.Role;

/**
* @author je123
* @description 针对表【role(用户角色表)】的数据库操作Service
* @createDate 2026-06-18 15:11:32
*/
public interface RoleService extends IService<Role> {

    void updateStatus(Role role);

}
