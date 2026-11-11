package com.lunabaka.dto;

import lombok.Data;

import java.util.List;

/**
 * 角色分配菜单 / 权限入参。
 */
@Data
public class RoleAssignDTO {

    /** 角色ID */
    private Long roleId;

    /** 勾选的菜单ID */
    private List<Integer> menuIds;

    /** 勾选的权限ID */
    private List<Integer> permissionIds;
}
