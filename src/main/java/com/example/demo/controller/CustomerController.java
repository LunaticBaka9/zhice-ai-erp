package com.example.demo.controller;

import java.util.List;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.demo.common.OperationLogAnnotation;
import com.example.demo.common.Result;
import com.example.demo.entity.Customer;
import com.example.demo.service.CustomerService;

import jakarta.annotation.Resource;

@RestController
@RequestMapping("/customer")
public class CustomerController {
    @Resource
    private CustomerService customerService;

    @GetMapping("/list")
    public Result list(
            @RequestParam(required = false) String code,
            @RequestParam(required = false) String name,
            @RequestParam(required = false) String contactPerson,
            @RequestParam(required = false) String phone,
            @RequestParam(required = false) Integer status) {
        List<Customer> list = customerService.selectAll(code, name, contactPerson, phone, status);
        return Result.success(list);
    }

    @GetMapping("/selectById/{id}")
    public Result getById(@PathVariable Integer id) {
        Customer customer = customerService.selectById(id);
        return Result.success(customer);
    }

    @GetMapping("/count")
    public Result count() {
        long count = customerService.count();
        return Result.success(count);
    }

    @OperationLogAnnotation(module="客户管理", type="新增", value="新增客户")
    @PostMapping("/add")
    public Result add(@RequestBody Customer customer) {
        customerService.insert(customer);
        return Result.success();
    }

    @OperationLogAnnotation(module="客户管理", type="修改", value="客户信息修改")
    @PostMapping("/update")
    public Result update(@RequestBody Customer customer) {
        customerService.update(customer);
        return Result.success();
    }

    @DeleteMapping("/delete/{id}")
    public Result delete(@PathVariable Integer id) {
        customerService.deleteById(id);
        return Result.success();
    }
}
