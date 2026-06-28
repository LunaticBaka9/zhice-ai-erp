package com.lunabaka.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.lunabaka.entity.Dept;
import com.lunabaka.service.DeptService;
import com.lunabaka.mapper.DeptMapper;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
* @author lunaticbaka
* @description 针对表【dept(部门表)】的数据库操作Service实现
* @createDate 2026-06-28 18:03:30
*/
@Service
public class DeptServiceImpl extends ServiceImpl<DeptMapper, Dept>
    implements DeptService{
    
    public List<Dept> getTreeList(){
        LambdaQueryWrapper<Dept> wrapper = Wrappers.lambdaQuery();
        List<Dept> allDepts = baseMapper.selectList(wrapper);

        Map<Long, Dept> deptMap = allDepts.stream()
                .collect(Collectors.toMap(Dept::getId, m -> m));

        List<Dept> tree = new ArrayList<>();
        for (Dept Dept : allDepts) {
            if (Dept.getParentId() == null || Dept.getParentId() == 0) {
                tree.add(Dept);
            } else {
                Dept parent = deptMap.get(Dept.getParentId());
                if (parent != null) {
                    if (parent.getChildren() == null) {
                        parent.setChildren(new ArrayList<>());
                    }
                    parent.getChildren().add(Dept);
                }
            }
        }
        return tree;
        
    }
    
    public void updateStatus(Dept dept){
        LambdaUpdateWrapper<Dept> wrapper = new LambdaUpdateWrapper<>();
        wrapper.eq(Dept::getId, dept.getId())
                .set(Dept::getStatus, dept.getStatus());
        baseMapper.update(wrapper);
    }
}




