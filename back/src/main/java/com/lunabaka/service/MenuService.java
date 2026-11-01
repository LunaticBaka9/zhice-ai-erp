package com.lunabaka.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.lunabaka.entity.Menu;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface MenuService extends IService<Menu> {

    void updateStatus(Menu menu);

    List<Menu> getTreeList();
}
