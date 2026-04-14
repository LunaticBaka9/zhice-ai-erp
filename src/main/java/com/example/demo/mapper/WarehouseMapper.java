package com.example.demo.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.example.demo.entity.Warehouse;

@Mapper
public interface WarehouseMapper {

    void insert(Warehouse warehouse);

    Warehouse selectById(@Param("id") Long id);

    List<Warehouse> selectAllWarehouse(Warehouse warehouse);

    void deleteById(Warehouse warehouse);

    void updateById(Warehouse warehouse);
}
