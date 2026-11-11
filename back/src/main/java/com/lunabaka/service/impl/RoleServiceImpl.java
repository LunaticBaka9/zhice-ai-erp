package com.lunabaka.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.lunabaka.entity.Menu;
import com.lunabaka.entity.Permission;
import com.lunabaka.entity.Role;
import com.lunabaka.entity.RoleMenu;
import com.lunabaka.entity.RolePermission;
import com.lunabaka.entity.User;
import com.lunabaka.exception.CustomerException;
import com.lunabaka.mapper.RoleMapper;
import com.lunabaka.mapper.UserMapper;
import com.lunabaka.service.MenuService;
import com.lunabaka.service.PermissionService;
import com.lunabaka.service.RoleMenuService;
import com.lunabaka.service.RolePermissionService;
import com.lunabaka.service.RoleService;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * 角色 Service：CRUD、分配菜单/权限、按登录用户解析可见资源。
 */
@Service
public class RoleServiceImpl extends ServiceImpl<RoleMapper, Role> implements RoleService {

    @Resource
    private RoleMenuService roleMenuService;
    @Resource
    private RolePermissionService rolePermissionService;
    @Resource
    private MenuService menuService;
    @Resource
    private PermissionService permissionService;
    @Resource
    private UserMapper userMapper;

    /**
     * 只更新状态字段，避免把其它列为 null。
     */
    @Override
    public void updateStatus(Role role) {
        if (role.getId() == null) {
            throw new CustomerException("角色ID不能为空");
        }
        LambdaUpdateWrapper<Role> wrapper = new LambdaUpdateWrapper<>();
        wrapper.eq(Role::getId, role.getId())
                .set(Role::getStatus, role.getStatus());
        baseMapper.update(null, wrapper);
    }

    @Override
    public void addRole(Role role) {
        validateNameAndCode(role, null);
        if (role.getStatus() == null) {
            role.setStatus(1);
        }
        if (role.getSort() == null) {
            role.setSort(0);
        }
        if (role.getIsSystem() == null) {
            role.setIsSystem(0);
        }
        baseMapper.insert(role);
    }

    @Override
    public void updateInfo(Role role) {
        if (role.getId() == null) {
            throw new CustomerException("角色ID不能为空");
        }
        Role db = baseMapper.selectById(role.getId());
        if (db == null) {
            throw new CustomerException("角色不存在");
        }
        validateNameAndCode(role, role.getId());
        // 系统角色不允许改编码，避免超管标识丢失
        if (isSuperAdmin(db)) {
            role.setCode(db.getCode());
            role.setIsSystem(1);
        }
        baseMapper.updateById(role);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteRole(Long id) {
        if (id == null) {
            throw new CustomerException("角色ID不能为空");
        }
        Role db = baseMapper.selectById(id);
        if (db == null) {
            throw new CustomerException("角色不存在");
        }
        if (isSuperAdmin(db) || (db.getIsSystem() != null && db.getIsSystem() == 1)) {
            throw new CustomerException("系统角色不可删除");
        }
        Long used = userMapper.selectCount(Wrappers.<User>lambdaQuery().eq(User::getRoleId, id));
        if (used != null && used > 0) {
            throw new CustomerException("该角色已分配给用户，无法删除");
        }
        roleMenuService.remove(Wrappers.<RoleMenu>lambdaQuery().eq(RoleMenu::getRoleId, id));
        rolePermissionService.remove(Wrappers.<RolePermission>lambdaQuery().eq(RolePermission::getRoleId, id.intValue()));
        baseMapper.deleteById(id);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void assignMenus(Long roleId, List<Integer> menuIds) {
        assertRoleExists(roleId);
        roleMenuService.remove(Wrappers.<RoleMenu>lambdaQuery().eq(RoleMenu::getRoleId, roleId));
        if (menuIds == null || menuIds.isEmpty()) {
            return;
        }
        List<RoleMenu> rows = new ArrayList<>();
        Set<Integer> seen = new HashSet<>();
        for (Integer menuId : menuIds) {
            if (menuId == null || !seen.add(menuId)) {
                continue;
            }
            RoleMenu row = new RoleMenu();
            row.setRoleId(roleId);
            row.setMenuId(menuId);
            rows.add(row);
        }
        if (!rows.isEmpty()) {
            roleMenuService.saveBatch(rows);
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void assignPermissions(Long roleId, List<Integer> permissionIds) {
        assertRoleExists(roleId);
        rolePermissionService.remove(Wrappers.<RolePermission>lambdaQuery()
                .eq(RolePermission::getRoleId, roleId.intValue()));
        if (permissionIds == null || permissionIds.isEmpty()) {
            return;
        }
        List<RolePermission> rows = new ArrayList<>();
        Set<Integer> seen = new HashSet<>();
        for (Integer permissionId : permissionIds) {
            if (permissionId == null || !seen.add(permissionId)) {
                continue;
            }
            RolePermission row = new RolePermission();
            row.setRoleId(roleId.intValue());
            row.setPermisionId(permissionId);
            rows.add(row);
        }
        if (!rows.isEmpty()) {
            rolePermissionService.saveBatch(rows);
        }
    }

    @Override
    public List<Integer> listMenuIds(Long roleId) {
        assertRoleExists(roleId);
        List<RoleMenu> list = roleMenuService.list(
                Wrappers.<RoleMenu>lambdaQuery().eq(RoleMenu::getRoleId, roleId));
        return list.stream().map(RoleMenu::getMenuId).collect(Collectors.toList());
    }

    @Override
    public List<Integer> listPermissionIds(Long roleId) {
        assertRoleExists(roleId);
        List<RolePermission> list = rolePermissionService.list(
                Wrappers.<RolePermission>lambdaQuery().eq(RolePermission::getRoleId, roleId.intValue()));
        return list.stream().map(RolePermission::getPermisionId).collect(Collectors.toList());
    }

    @Override
    public Map<String, Object> getCurrentMenus(Long userId) {
        Role role = loadUserRole(userId);
        boolean superAdmin = isSuperAdmin(role);
        List<Menu> all = menuService.list(Wrappers.<Menu>lambdaQuery()
                .eq(Menu::getStatus, true)
                .orderByAsc(Menu::getSort_num));
        List<Menu> visible;
        if (superAdmin || role == null) {
            // 超管或未绑定角色时：超管看全部；未绑定角色只给默认入口，避免空侧边栏
            if (superAdmin) {
                visible = all;
            } else {
                visible = all.stream()
                        .filter(m -> "/".equals(m.getPath()) || "/userInfo".equals(m.getPath()))
                        .collect(Collectors.toList());
            }
        } else {
            Set<Integer> allowed = new HashSet<>(listMenuIds(role.getId()));
            visible = all.stream()
                    .filter(m -> allowed.contains(m.getId())
                            || "/".equals(m.getPath())
                            || "/userInfo".equals(m.getPath()))
                    .collect(Collectors.toList());
        }
        Map<String, Object> result = new HashMap<>();
        result.put("superAdmin", superAdmin);
        result.put("menus", buildMenuTree(visible));
        result.put("paths", visible.stream()
                .map(Menu::getPath)
                .filter(p -> p != null && !p.isBlank())
                .collect(Collectors.toList()));
        return result;
    }

    @Override
    public Map<String, Object> getCurrentPermissionCodes(Long userId) {
        Role role = loadUserRole(userId);
        boolean superAdmin = isSuperAdmin(role);
        List<String> codes;
        if (superAdmin) {
            codes = permissionService.list(Wrappers.<Permission>lambdaQuery()
                            .eq(Permission::getStatus, 1))
                    .stream()
                    .map(Permission::getCode)
                    .filter(c -> c != null && !c.isBlank())
                    .collect(Collectors.toList());
        } else if (role == null) {
            codes = Collections.emptyList();
        } else {
            List<Integer> ids = listPermissionIds(role.getId());
            if (ids.isEmpty()) {
                codes = Collections.emptyList();
            } else {
                List<Long> longIds = ids.stream().map(Integer::longValue).collect(Collectors.toList());
                codes = permissionService.listByIds(longIds).stream()
                        .filter(p -> p.getStatus() != null && p.getStatus() == 1)
                        .map(Permission::getCode)
                        .filter(c -> c != null && !c.isBlank())
                        .collect(Collectors.toList());
            }
        }
        Map<String, Object> result = new HashMap<>();
        result.put("superAdmin", superAdmin);
        result.put("codes", codes);
        return result;
    }

    @Override
    public Role resolveRole(Long roleId, String roleName) {
        if (roleId != null) {
            Role byId = baseMapper.selectById(roleId);
            if (byId != null) {
                return byId;
            }
        }
        if (roleName != null && !roleName.isBlank()) {
            return baseMapper.selectOne(Wrappers.<Role>lambdaQuery().eq(Role::getName, roleName));
        }
        return null;
    }

    /**
     * 名称、编码必填且唯一。
     */
    private void validateNameAndCode(Role role, Long excludeId) {
        if (role.getName() == null || role.getName().isBlank()) {
            throw new CustomerException("角色名称不能为空");
        }
        if (role.getCode() == null || role.getCode().isBlank()) {
            throw new CustomerException("角色编码不能为空");
        }
        LambdaQueryWrapper<Role> nameQuery = Wrappers.<Role>lambdaQuery().eq(Role::getName, role.getName());
        if (excludeId != null) {
            nameQuery.ne(Role::getId, excludeId);
        }
        if (baseMapper.selectCount(nameQuery) > 0) {
            throw new CustomerException("角色名称已存在");
        }
        LambdaQueryWrapper<Role> codeQuery = Wrappers.<Role>lambdaQuery().eq(Role::getCode, role.getCode());
        if (excludeId != null) {
            codeQuery.ne(Role::getId, excludeId);
        }
        if (baseMapper.selectCount(codeQuery) > 0) {
            throw new CustomerException("角色编码已存在");
        }
    }

    private void assertRoleExists(Long roleId) {
        if (roleId == null) {
            throw new CustomerException("角色ID不能为空");
        }
        if (baseMapper.selectById(roleId) == null) {
            throw new CustomerException("角色不存在");
        }
    }

    private boolean isSuperAdmin(Role role) {
        if (role == null) {
            return false;
        }
        if (role.getIsSystem() != null && role.getIsSystem() == 1
                && "SUPER_ADMIN".equalsIgnoreCase(role.getCode())) {
            return true;
        }
        return "SUPER_ADMIN".equalsIgnoreCase(role.getCode());
    }

    private Role loadUserRole(Long userId) {
        if (userId == null) {
            return null;
        }
        User user = userMapper.selectById(userId);
        if (user == null) {
            return null;
        }
        return resolveRole(user.getRoleId(), user.getRoleName());
    }

    /**
     * 把扁平菜单列表组装成树，结构与 MenuService.getTreeList 一致。
     */
    private List<Menu> buildMenuTree(List<Menu> allMenus) {
        Map<Integer, Menu> menuMap = allMenus.stream()
                .collect(Collectors.toMap(Menu::getId, m -> m, (a, b) -> a));
        List<Menu> tree = new ArrayList<>();
        for (Menu menu : allMenus) {
            if (menu.getPid() == null || menu.getPid() == 0) {
                tree.add(menu);
            } else {
                Menu parent = menuMap.get(menu.getPid());
                if (parent != null) {
                    if (parent.getChildren() == null) {
                        parent.setChildren(new ArrayList<>());
                    }
                    parent.getChildren().add(menu);
                } else {
                    tree.add(menu);
                }
            }
        }
        return tree;
    }
}
