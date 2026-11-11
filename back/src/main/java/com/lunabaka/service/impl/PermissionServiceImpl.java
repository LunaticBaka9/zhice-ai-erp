package com.lunabaka.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.lunabaka.entity.Permission;
import com.lunabaka.mapper.PermissionMapper;
import com.lunabaka.service.PermissionService;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 权限表 Service 实现：构建启用权限树。
 */
@Service
public class PermissionServiceImpl extends ServiceImpl<PermissionMapper, Permission>
        implements PermissionService {

    /**
     * 查询全部启用权限，组装成树。
     */
    @Override
    public List<Permission> getTreeList() {
        LambdaQueryWrapper<Permission> wrapper = Wrappers.lambdaQuery();
        wrapper.eq(Permission::getStatus, 1)
                .orderByAsc(Permission::getSort)
                .orderByAsc(Permission::getId);
        List<Permission> all = baseMapper.selectList(wrapper);

        Map<Long, Permission> map = all.stream()
                .collect(Collectors.toMap(Permission::getId, p -> p, (a, b) -> a));

        List<Permission> tree = new ArrayList<>();
        for (Permission item : all) {
            Long parentId = item.getParentId();
            if (parentId == null || parentId == 0L) {
                tree.add(item);
            } else {
                Permission parent = map.get(parentId);
                if (parent != null) {
                    if (parent.getChildren() == null) {
                        parent.setChildren(new ArrayList<>());
                    }
                    parent.getChildren().add(item);
                } else {
                    // 父节点被禁用时，把该节点挂到根上，避免丢失
                    tree.add(item);
                }
            }
        }
        return tree;
    }
}
