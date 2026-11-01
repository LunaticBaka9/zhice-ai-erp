package com.lunabaka.mapper;

import com.lunabaka.entity.Customer;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

@Mapper
public interface CustomerMapper {

    List<Customer> selectAll(Customer customer);

    Customer selectById(@Param("id") Integer id);

    void insert(Customer customer);

    void update(Customer customer);

    void deleteById(@Param("id") Integer id);

    long count();
}
