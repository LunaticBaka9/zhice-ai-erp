package com.example.demo.service;

import java.util.List;

import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Service;

import com.example.demo.entity.Warehouse;
import com.example.demo.mapper.WarehouseMapper;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;

import jakarta.annotation.Resource;

@Service
public class WarehouseService {
    @Resource
    WarehouseMapper warehouseMapper;

    public void insertWarehous(Warehouse warehouse){
        warehouseMapper.insert(warehouse);
    }

    public List<Warehouse> selectAllUsers(){
        return warehouseMapper.selectAllWarehouse(null);
    }

    public PageInfo<Warehouse> selectPage(int pageNum, int pageSize, Warehouse user){
        PageHelper.startPage(pageNum, pageSize);
        List<Warehouse> list = warehouseMapper.selectAllWarehouse(user);
        return PageInfo.of(list);
    }

    public Warehouse selectById(Long uid){
        return warehouseMapper.selectById(uid);
    }

    public void deleteById(Warehouse warehouse){
        warehouseMapper.deleteById(warehouse);
    }

    public void deleteBatch(List<Warehouse> list){
        for(Warehouse warehouse: list){
            this.deleteById(warehouse);
        }
    }
}
