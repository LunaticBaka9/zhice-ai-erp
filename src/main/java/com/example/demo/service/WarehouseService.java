package com.example.demo.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.example.demo.entity.Warehouse;
import com.example.demo.exception.CustomerException;
import com.example.demo.mapper.WarehouseMapper;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;

import jakarta.annotation.Resource;

@Service
public class WarehouseService {
    @Resource
    WarehouseMapper warehouseMapper;

    public void insert(Warehouse warehouse) {
        warehouseMapper.insert(warehouse);
    }

    public List<Warehouse> selectAllWarehouses() {
        return warehouseMapper.selectAllWarehouse(null);
    }

    public PageInfo<Warehouse> selectPage(int pageNum, int pageSize, Warehouse user) {
        PageHelper.startPage(pageNum, pageSize);
        List<Warehouse> list = warehouseMapper.selectAllWarehouse(user);
        return PageInfo.of(list);
    }

    public Warehouse selectById(Long id) {
        return warehouseMapper.selectById(id);
    }

    public void update(Warehouse warehouse) {
        Warehouse dbWarehouse = warehouseMapper.selectById(warehouse.getId());
        if (dbWarehouse == null) {
            throw new CustomerException("找不到库房，无法更新");
        }
        warehouseMapper.updateById(warehouse);
    }

    public void updateStatus(Warehouse warehouse){
        Warehouse dbWarehouse = warehouseMapper.selectById(warehouse.getId());
        if (dbWarehouse == null){
            throw new CustomerException("不到库房，无法更新");
        }
        warehouseMapper.updateById(warehouse);
    }

    public void deleteById(Warehouse warehouse) {
        warehouseMapper.deleteById(warehouse);
    }

    public void deleteBatch(List<Warehouse> list) {
        for (Warehouse warehouse : list) {
            this.deleteById(warehouse);
        }
    }
}
