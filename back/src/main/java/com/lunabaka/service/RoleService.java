package com.lunabaka.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.lunabaka.entity.Role;

import java.util.List;
import java.util.Map;

/**
 * 针对表【role(用户角色表)】的数据库操作 Service
 */
public interface RoleService extends IService<Role> {

    /**
     * 更新角色启用状态
     *
     * @param role 需包含 id、status
     */
    void updateStatus(Role role);

    /**
     * 新增角色，校验名称与编码唯一
     *
     * @param role 角色信息
     */
    void addRole(Role role);

    /**
     * 修改角色信息，校验名称与编码唯一
     *
     * @param role 角色信息
     */
    void updateInfo(Role role);

    /**
     * 删除角色，系统角色不可删，同时清理菜单和权限关联
     *
     * @param id 角色ID
     */
    void deleteRole(Long id);

    /**
     * 覆盖保存角色菜单
     *
     * @param roleId  角色ID
     * @param menuIds 菜单ID列表，空则清空
     */
    void assignMenus(Long roleId, List<Integer> menuIds);

    /**
     * 覆盖保存角色权限
     *
     * @param roleId        角色ID
     * @param permissionIds 权限ID列表，空则清空
     */
    void assignPermissions(Long roleId, List<Integer> permissionIds);

    /**
     * 查询角色已分配的菜单ID
     *
     * @param roleId 角色ID
     * @return 菜单ID列表
     */
    List<Integer> listMenuIds(Long roleId);

    /**
     * 查询角色已分配的权限ID
     *
     * @param roleId 角色ID
     * @return 权限ID列表
     */
    List<Integer> listPermissionIds(Long roleId);

    /**
     * 当前登录用户可见菜单树。超管返回全部启用菜单。
     *
     * @param userId 用户ID
     * @return superAdmin、menus
     */
    Map<String, Object> getCurrentMenus(Long userId);

    /**
     * 当前登录用户权限编码。超管返回全部启用权限编码。
     *
     * @param userId 用户ID
     * @return superAdmin、codes
     */
    Map<String, Object> getCurrentPermissionCodes(Long userId);

    /**
     * 按角色ID或名称补全用户上的 roleId / roleName
     *
     * @param roleId   角色ID，可空
     * @param roleName 角色名称，可空
     * @return [roleId, roleName]，都找不到时两项均为 null
     */
    Role resolveRole(Long roleId, String roleName);
}
