package com.example.demo.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.example.demo.entity.Supplier;
import com.example.demo.exception.CustomerException;
import com.example.demo.mapper.SupplierMapper;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;

import jakarta.annotation.Resource;

@Service
public class SupplierService {
    @Resource
    private SupplierMapper supplierMapper;
    
    public List<Supplier> selectAll(){
        return supplierMapper.selectAll(null);
    }

    public PageInfo<Supplier> selectPage(int pageNum, int pageSize, Supplier customer){
        PageHelper.startPage(pageNum, pageSize);
        List<Supplier> list = supplierMapper.selectAll(customer);
        return PageInfo.of(list);
    }

    public Supplier selectById(Integer id) {
        return supplierMapper.selectById(id);
    }

    public void insert(Supplier customer) {
        if (customer.getCode() == null || customer.getCode().trim().isEmpty()) {
            throw new CustomerException("供应商编码不能为空");
        }
        if (customer.getName() == null || customer.getName().trim().isEmpty()) {
            throw new CustomerException("供应商名称不能为空");
        }
        supplierMapper.insert(customer);
    }

    public void update(Supplier customer) {
        Supplier dbCustomer = supplierMapper.selectById(customer.getId());
        if (dbCustomer == null) {
            throw new CustomerException("找不到该供应商，无法更新");
        }
        supplierMapper.update(customer);
    }

    public void deleteById(Integer id) {
        Supplier customer = supplierMapper.selectById(id);
        if (customer == null) {
            throw new CustomerException("找不到该供应商，无法删除");
        }
        supplierMapper.deleteById(id);
    }

    public long count() {
        return supplierMapper.count();
    }
}
