package com.lunabaka.controller;

import com.lunabaka.common.Result;
import com.lunabaka.entity.Dept;
import com.lunabaka.service.DeptService;
import jakarta.annotation.Resource;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController()
@RequestMapping("/dept")
public class DeptController {

    @Resource
    DeptService deptService;

    @GetMapping("/list")
    public Result getList(){
        List<Dept> deptList = deptService.getTreeList();
        return Result.success(deptList);
    }

    @PostMapping("/updateStatus")
    public Result updateStatus(@RequestBody Dept dept){
        deptService.updateStatus(dept);
        return Result.success();
    }


}
