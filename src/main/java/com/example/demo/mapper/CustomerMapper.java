package com.example.demo.mapper;

import com.example.demo.entity.Customer;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

@Mapper
public interface CustomerMapper {

    List<Customer> selectAll(
            @Param("code") String code,
            @Param("name") String name,
            @Param("contactPerson") String contactPerson,
            @Param("phone") String phone,
            @Param("status") Integer status);

    Customer selectById(@Param("id") Integer id);

    void insert(Customer customer);

    void update(Customer customer);

    void deleteById(@Param("id") Integer id);

    long count();
}
