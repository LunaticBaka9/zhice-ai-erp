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

import com.example.demo.common.Result;
import com.example.demo.entity.Customer;
import com.example.demo.service.CustomerService;
import com.github.pagehelper.PageInfo;

import jakarta.annotation.Resource;

@RestController
@RequestMapping("/customer")
public class CustomerController {
    @Resource
    private CustomerService customerService;

    @GetMapping("/selectAllCustomer")
    public Result selectAllUsers() {
        List<Customer> userList = customerService.selectAll();
        return Result.success(userList);
    }

    @GetMapping("/list")
    public Result selectPage(@RequestParam(defaultValue = "1") Integer pageNum,
                             @RequestParam(defaultValue = "10") Integer pageSize,
                             Customer customer){
        PageInfo<Customer> pageInfo = customerService.selectPage(pageNum, pageSize, customer);
        return Result.success(pageInfo);
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

    @PostMapping("/add")
    public Result add(@RequestBody Customer customer) {
        customerService.insert(customer);
        return Result.success();
    }

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
