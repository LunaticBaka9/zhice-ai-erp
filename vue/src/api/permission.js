import request from "@/utils/request";

/** 启用权限树，供角色分配勾选 */
export function getPermissionTree() {
    return request.get("/permission/tree");
}
