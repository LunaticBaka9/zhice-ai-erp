import request from "@/utils/request";

export function getAllRoles() {
    return request.get("/role/all");
}

export function getRoleList(params) {
    return request.get("/role/list", { params });
}

export function addRole(data) {
    return request.post("/role/add", data);
}

export function updateRole(data) {
    return request.post("/role/updateInfo", data);
}

export function deleteRole(data) {
    return request.post("/role/delete", data);
}

export function updateRoleStatus(data) {
    return request.post("/role/updateStatus", data);
}

export function exportRoles() {
    return request.get("/role/exportData", { responseType: "blob" });
}

/** 角色已分配的菜单 ID */
export function getRoleMenus(roleId) {
    return request.get(`/role/menus/${roleId}`);
}

/** 覆盖保存角色菜单 */
export function assignRoleMenus(data) {
    return request.post("/role/assignMenus", data);
}

/** 角色已分配的权限 ID */
export function getRolePermissions(roleId) {
    return request.get(`/role/permissions/${roleId}`);
}

/** 覆盖保存角色权限 */
export function assignRolePermissions(data) {
    return request.post("/role/assignPermissions", data);
}

/** 当前登录用户可见菜单 */
export function getCurrentMenus() {
    return request.get("/role/currentMenus");
}

/** 当前登录用户权限编码 */
export function getCurrentPermissions() {
    return request.get("/role/currentPermissions");
}
