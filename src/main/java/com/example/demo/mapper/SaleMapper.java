package com.example.demo.mapper;

import com.example.demo.entity.Sale;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface SaleMapper {

    List<Sale> selectAll(Sale sale);

    Sale selectById(@Param("id") Long id);

    void insert(Sale sale);

    void update(Sale sale);

    void deleteById(@Param("id") Long id);

    long count();
}
