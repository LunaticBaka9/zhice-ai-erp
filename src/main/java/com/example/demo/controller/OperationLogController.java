package com.example.demo.controller;

import com.example.demo.common.OperationLogAnnotation;
import com.example.demo.common.Result;
import com.example.demo.entity.OperationLog;
import com.example.demo.service.OperationLogService;
import jakarta.annotation.Resource;
import org.springframework.web.bind.annotation.*;
import com.github.pagehelper.PageInfo;

import java.util.List;

@RestController
@RequestMapping("/operationLog")
public class OperationLogController {
    @Resource
    OperationLogService operationLogService;

    @GetMapping("/list")
    public Result list(@RequestParam(defaultValue = "1") Integer pageNum,
                       @RequestParam(defaultValue = "10") Integer pageSize,
                       @RequestParam(required = false) String username,
                       @RequestParam(required = false) String module,
                       @RequestParam(required = false) String type) {
        List<OperationLog> list = operationLogService.selectByPage(pageNum, pageSize, username, module, type);
        int total = operationLogService.selectCount(username, module, type);
        PageInfo<OperationLog> pageInfo = new PageInfo<>();
        pageInfo.setList(list);
        pageInfo.setTotal(total);
        return Result.success(pageInfo);
    }

    @GetMapping("/selectAll")
    public Result selectAll() {
        return Result.success(operationLogService.selectAllLogs());
    }

    @PostMapping("/delete")
    @OperationLogAnnotation(module = "操作日志", type = "删除", value = "删除操作日志")
    public Result delete(@RequestBody List<Long> ids) {
        operationLogService.deleteBatch(ids);
        return Result.success();
    }

    @PostMapping("/deleteAll")
    @OperationLogAnnotation(module = "操作日志", type = "删除", value = "清空操作日志")
    public Result deleteAll() {
        operationLogService.deleteAll();
        return Result.success();
    }
}
