package com.lunabaka.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.lunabaka.common.OperationLogAnnotation;
import com.lunabaka.common.Result;
import com.lunabaka.entity.Post;
import com.lunabaka.service.PostService;
import jakarta.annotation.Resource;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/post")
public class PostController {

    @Resource
    PostService postService;

    // 获取全部
    @GetMapping("/all")
    public Result all() {
        return Result.success(postService.list());
    }

    // 分页查询
    @GetMapping("/list")
    public Result list(@RequestParam(defaultValue = "1") Integer pageNum,
                       @RequestParam(defaultValue = "10") Integer pageSize,
                       @RequestParam(required = false) String name) {
        // MyBatisPlus的分页类
        Page<Post> page = new Page<>(pageNum, pageSize);
        // 搜索条件
        LambdaQueryWrapper<Post> wrapper = Wrappers.lambdaQuery();
        wrapper.like(name != null && !name.isBlank(), Post::getName, name);
        // 进行分页+条件搜索
        postService.page(page, wrapper);

        return Result.success(page);
    }


    @OperationLogAnnotation(module="用户职位管理", type="新增", value="添加用户职位")
    @PostMapping("/add")
    public Result addRole(@RequestBody Post post){
        // 添加用户角色数据
        postService.save(post);
        return Result.success();
    }

    @OperationLogAnnotation(module="用户职位管理", type="修改", value="修改用户职位状态")
    @PostMapping("/updateStatus")
    public Result updateStatus(@RequestBody Post post){
        postService.updateStatus(post);
        return Result.success();
    }

    @OperationLogAnnotation(module="用户职位管理", type="修改", value="修改用户职位信息")
    @PostMapping("/updateInfo")
    public Result updateInfo(@RequestBody Post post){
        postService.updateById(post);
        return Result.success();
    }

    @OperationLogAnnotation(module="用户职位管理", type="删除", value="删除用户职位")
    @PostMapping("/delete")
    public Result deleteById(@RequestBody Post post){
        postService.removeById(post.getId());
        return Result.success();
    }
}
