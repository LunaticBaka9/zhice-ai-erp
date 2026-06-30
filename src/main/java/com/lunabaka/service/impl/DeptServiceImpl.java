package com.lunabaka.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.lunabaka.entity.Dept;
import com.lunabaka.entity.User;
import com.lunabaka.mapper.DeptMapper;
import com.lunabaka.mapper.UserMapper;
import com.lunabaka.service.DeptService;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class DeptServiceImpl extends ServiceImpl<DeptMapper, Dept>
        implements DeptService {

    @Resource
    UserMapper userMapper;

    /**
    *   获取部门的树状列表
    **/
    public List<Dept> getTreeList() {
        LambdaQueryWrapper<Dept> wrapper = Wrappers.lambdaQuery();
        List<Dept> allDepts = baseMapper.selectList(wrapper);

        Map<Long, Dept> deptMap = allDepts.stream()
                .collect(Collectors.toMap(Dept::getId, m -> m));

        List<Dept> tree = new ArrayList<>();
        for (Dept dept : allDepts) {
            if (dept.getParentId() == null || dept.getParentId() == 0) {
                tree.add(dept);
            } else {
                Dept parent = deptMap.get(dept.getParentId());
                if (parent != null) {
                    if (parent.getChildren() == null) {
                        parent.setChildren(new ArrayList<>());
                    }
                    parent.getChildren().add(dept);
                }
            }
        }
        return tree;
    }

    /**
     * 查询指定部门及其所有子部门的成员
     * @param deptId      部门ID
     * @param searchQuery 可选搜索关键词（姓名/角色）
     * @return 成员列表
     */
    @Override
    public List<User> getDeptMemberList(Long deptId, String searchQuery) {
//        获取全部部门扁列表
        List<Dept> allDepts = baseMapper.selectList(Wrappers.lambdaQuery());

//        递归收集目标部门及所有子孙部门 ID
        Set<Long> deptIds = new HashSet<>();
        collectSubDeptIds(allDepts, deptId, deptIds);
//        将 ID 转换为部门名称集合
        List<String> deptNames = allDepts.stream()
                .filter(d -> deptIds.contains(d.getId()))
                .map(Dept::getName)
                .filter(Objects::nonNull)
                .collect(Collectors.toList());

        if (deptNames.isEmpty()) {
            return Collections.emptyList();
        }
//        查询 user 表中 deptName 匹配这些名称的用户
        QueryWrapper<User> wrapper = new QueryWrapper<User>()
                .in("dept_name", deptNames);
//        若 searchQuery 非空，额外按姓名/角色模糊过滤
        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            String q = searchQuery.trim();
            wrapper.and(w -> w.like("name", q)
                    .or().like("role", q));
        }
        return userMapper.selectList(wrapper);
    }

    /**
     * 递归收集指定父部门及其所有子孙部门的 ID
     * @param allDepts 全部部门扁列表
     * @param parentId 父部门ID
     * @param result   收集结果的集合
     */
    private void collectSubDeptIds(List<Dept> allDepts, Long parentId, Set<Long> result) {
        result.add(parentId);
        for (Dept dept : allDepts) {
            if (Objects.equals(dept.getParentId(), parentId)) {
                collectSubDeptIds(allDepts, dept.getId(), result);
            }
        }
    }

    /**
     * 更新部门状态
     */
    public void updateStatus(Dept dept) {
        LambdaUpdateWrapper<Dept> wrapper = Wrappers.lambdaUpdate();
        wrapper.eq(Dept::getId, dept.getId())
                .set(Dept::getStatus, dept.getStatus());
        baseMapper.update(wrapper);

        // 若部门被停用，递归停用所有子部门
        if (dept.getStatus() != null && dept.getStatus() == 0) {
            disableSubDepts(dept.getId());
        }
    }

    /**
     * 更新部门详细信息
     */
    public void updateInfo(Dept dept) {
        LambdaUpdateWrapper<Dept> wrapper = new LambdaUpdateWrapper<>();
        wrapper.eq(Dept::getId, dept.getId())
                .set(Dept::getName, dept.getName())
                .set(Dept::getCode, dept.getCode())
                .set(Dept::getIntro, dept.getIntro())
                .set(Dept::getPhone, dept.getPhone())
                .set(Dept::getAddress, dept.getAddress())
                .set(Dept::getUserId, dept.getUserId())
                .set(Dept::getStatus, dept.getStatus());
        
        if (dept.getParentId() == null) {
            wrapper.set(Dept::getParentId, 0);
        } else {
            wrapper.set(Dept::getParentId, dept.getParentId());
        }
        // 若 userId 有值，查出用户姓名并填入 user_name
        if (dept.getUserId() != null) {
            User user = userMapper.selectById(dept.getUserId());
            if (user != null) {
                wrapper.set(Dept::getUserName, user.getName());
            }
        }
        baseMapper.update(wrapper);

        // 若部门被停用，递归停用所有子部门
        if (dept.getStatus() != null && dept.getStatus() == 0) {
            disableSubDepts(dept.getId());
        }
    }

    /**
     * 递归停用指定部门下的所有子部门
     */
    private void disableSubDepts(Long parentId) {
        List<Dept> allDepts = baseMapper.selectList(Wrappers.lambdaQuery());
        Set<Long> subIds = new HashSet<>();
        collectSubDeptIds(allDepts, parentId, subIds);
        // 移除父部门自身，只停用子部门
        subIds.remove(parentId);
        if (!subIds.isEmpty()) {
            LambdaUpdateWrapper<Dept> wrapper = Wrappers.lambdaUpdate();
            wrapper.in(Dept::getId, subIds)
                    .set(Dept::getStatus, 0);
            baseMapper.update(wrapper);
        }
    }

    /**
     * 删除部门的子部门
     */
    public void deleteSubDepts(Long parentId) {
        List<Dept> allDepts = baseMapper.selectList(Wrappers.lambdaQuery());
        Set<Long> subIds = new HashSet<>();
        collectSubDeptIds(allDepts, parentId, subIds);
        // 移除父部门自身，删除子部门
        subIds.remove(parentId);
        if (!subIds.isEmpty()) {
            baseMapper.delete(Wrappers.<Dept>lambdaQuery()
                    .in(Dept::getId, subIds));
        }
    }
}
