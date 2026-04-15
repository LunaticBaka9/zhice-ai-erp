package com.example.demo.mapper;

import com.example.demo.entity.Supplier;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface SupplierMapper {

    List<Supplier> selectList(
            @Param("pageNum") Integer pageNum,
            @Param("pageSize") Integer pageSize,
            @Param("name") String name,
            @Param("contactPerson") String contactPerson,
            @Param("phone") String phone,
            @Param("status") String status,
            @Param("type") String type);

    long selectCount(
            @Param("name") String name,
            @Param("contactPerson") String contactPerson,
            @Param("phone") String phone,
            @Param("status") String status,
            @Param("type") String type);

    Supplier selectById(@Param("id") Integer id);

    void insert(Supplier supplier);

    void update(Supplier supplier);

    void deleteById(@Param("id") Integer id);

    void updateStatus(@Param("id") Integer id, @Param("status") String status);
}
