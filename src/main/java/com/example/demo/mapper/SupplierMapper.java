package com.example.demo.mapper;

import com.example.demo.entity.Supplier;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface SupplierMapper {

    List<Supplier> selectAll(Supplier supplier);

    Supplier selectById(@Param("id") Integer id);

    void insert(Supplier supplier);

    void update(Supplier supplier);

    void deleteById(@Param("id") Integer id);

    long count();
}
