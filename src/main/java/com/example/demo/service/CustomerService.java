package com.example.demo.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.example.demo.entity.Customer;
import com.example.demo.exception.CustomerException;
import com.example.demo.mapper.CustomerMapper;

import jakarta.annotation.Resource;

@Service
public class CustomerService {
    @Resource
    private CustomerMapper customerMapper;

    public List<Customer> selectAll(String code, String name, String contactPerson, String phone, Integer status) {
        return customerMapper.selectAll(code, name, contactPerson, phone, status);
    }

    public Customer selectById(Integer id) {
        return customerMapper.selectById(id);
    }

    public void insert(Customer customer) {
        if (customer.getCode() == null || customer.getCode().trim().isEmpty()) {
            throw new CustomerException("客户编码不能为空");
        }
        if (customer.getName() == null || customer.getName().trim().isEmpty()) {
            throw new CustomerException("客户名称不能为空");
        }
        if (customer.getStatus() == null) {
            customer.setStatus(1);
        }
        if (customer.getPriceLevel() == null) {
            customer.setPriceLevel(1);
        }
        if (customer.getCreditLimit() == null) {
            customer.setCreditLimit(java.math.BigDecimal.ZERO);
        }
        customerMapper.insert(customer);
    }

    public void update(Customer customer) {
        Customer dbCustomer = customerMapper.selectById(customer.getId());
        if (dbCustomer == null) {
            throw new CustomerException("找不到该客户，无法更新");
        }
        customerMapper.update(customer);
    }

    public void deleteById(Integer id) {
        Customer customer = customerMapper.selectById(id);
        if (customer == null) {
            throw new CustomerException("找不到该客户，无法删除");
        }
        customerMapper.deleteById(id);
    }

    public long count() {
        return customerMapper.count();
    }
}
