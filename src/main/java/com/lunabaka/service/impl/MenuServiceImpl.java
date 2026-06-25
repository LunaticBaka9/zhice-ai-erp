package com.lunabaka.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.lunabaka.entity.Menu;
import com.lunabaka.mapper.MenuMapper;
import com.lunabaka.service.MenuService;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class MenuServiceImpl extends ServiceImpl<MenuMapper, Menu> implements MenuService {

    // 返回Menu树状列表
    public List<Menu> getTreeList() {
        LambdaQueryWrapper<Menu> wrapper = Wrappers.lambdaQuery();
        wrapper.orderByAsc(Menu::getSort_num);
        List<Menu> allMenus = baseMapper.selectList(wrapper);

        Map<Integer, Menu> menuMap = allMenus.stream()
                .collect(Collectors.toMap(Menu::getId, m -> m));

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
                }
            }
        }
        return tree;
    }

    //修改菜单状态
    public void updateStatus(Menu menu) {
        LambdaUpdateWrapper<Menu> wrapper = new LambdaUpdateWrapper<>();
        wrapper.eq(Menu::getId, menu.getId())
                .set(Menu::getStatus, menu.getStatus());
        baseMapper.update(null, wrapper);
    }
}
