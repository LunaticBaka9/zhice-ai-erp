package com.lunabaka.controller;

import com.lunabaka.common.OperationLogAnnotation;
import com.lunabaka.common.Result;
import com.lunabaka.entity.Dept;
import com.lunabaka.entity.User;
import com.lunabaka.service.DeptService;
import jakarta.annotation.Resource;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController()
@RequestMapping("/dept")
public class DeptController {

    @Resource
    DeptService deptService;

    /*
        查找部门树状列表
     */
    @GetMapping("/list")
    public Result getList() {
        List<Dept> deptList = deptService.getTreeList();
        return Result.success(deptList);
    }

    /*
    *   查看部门详细信息
    */
    @GetMapping("/detail/{id}")
    public Result getDetail(@PathVariable Long id) {
        Dept dept = deptService.getById(id);
        return Result.success(dept);
    }

    /*
        新增部门
     */
    @OperationLogAnnotation(module = "部门管理", type = "新增", value = "新增部门")
    @PostMapping("/add")
    public Result add(@RequestBody Dept dept) {
        deptService.save(dept);
        return Result.success();
    }

    /*
        更新部门状态
     */
    @PostMapping("/updateStatus")
    public Result updateStatus(@RequestBody Dept dept) {
        deptService.updateStatus(dept);
        return Result.success();
    }

    /*
        更新部门详情
     */
    @PostMapping("/updateInfo")
    public Result updateInfo(@RequestBody Dept dept) {
       deptService.updateInfo(dept);
       return Result.success();
    }

    /**
     * 查询指定部门及其所有子部门的成员
     *
     * @param id          部门ID
     * @param searchQuery 可选搜索关键词（按姓名或职位模糊匹配）
     * @return 成员列表
     */
    @GetMapping("/members/{id}")
    public Result getDeptMembers(@PathVariable Long id,
                                 @RequestParam(required = false) String searchQuery) {
        List<User> members = deptService.getDeptMemberList(id, searchQuery);
        return Result.success(members);
    }

    /*
        删除部门
     */
    @OperationLogAnnotation(module = "部门管理", type = "删除", value = "删除部门")
    @PostMapping("/delete")
    public Result delete(@RequestBody Dept dept) {
        deptService.removeById(dept);
        // 删除子部门
        deptService.deleteSubDepts(dept.getId());
        return Result.success();
    }

}
