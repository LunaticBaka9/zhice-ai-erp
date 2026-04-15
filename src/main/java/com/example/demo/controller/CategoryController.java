package com.example.demo.controller;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.demo.common.Result;
import com.example.demo.entity.Category;
import com.example.demo.entity.CategoryTree;
import com.example.demo.service.CategoryService;

import jakarta.annotation.Resource;

@RestController
@RequestMapping("/category")
public class CategoryController {
    @Resource
    private CategoryService categoryService;

    @GetMapping("/list")
    public Result list(@RequestParam(required = false) String name) {
        List<Category> list = categoryService.selectAll(name);
        return Result.success(list);
    }

    @GetMapping("/tree")
    public Result tree(@RequestParam(required = false) String name) {
        List<CategoryTree> tree = categoryService.selectTree(name);
        return Result.success(tree);
    }

    @GetMapping("/{id}")
    public Result getById(@PathVariable Integer id) {
        Category category = categoryService.selectById(id);
        return Result.success(category);
    }

    @PostMapping("/add")
    public Result add(@RequestBody Category category) {
        categoryService.insert(category);
        return Result.success();
    }

    @PostMapping("/update")
    public Result update(@RequestBody Category category) {
        categoryService.update(category);
        return Result.success();
    }

    @PostMapping("/delete")
    public Result delete(@RequestBody Category category) {
        categoryService.deleteById(category.getId());
        return Result.success();
    }
}
