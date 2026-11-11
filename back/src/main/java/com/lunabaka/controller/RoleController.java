package com.lunabaka.controller;

import cn.hutool.poi.excel.ExcelReader;
import cn.hutool.poi.excel.ExcelUtil;
import cn.hutool.poi.excel.ExcelWriter;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.lunabaka.common.OperationLogAnnotation;
import com.lunabaka.common.Result;
import com.lunabaka.dto.RoleAssignDTO;
import com.lunabaka.entity.Role;
import com.lunabaka.exception.CustomerException;
import com.lunabaka.service.RoleService;
import jakarta.annotation.Resource;
import jakarta.servlet.ServletOutputStream;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.Font;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

/**
 * 角色管理：CRUD、导入导出、分配菜单与权限、当前用户资源。
 */
@RestController
@RequestMapping("/role")
public class RoleController {

    @Resource
    RoleService roleService;

    /**
     * 全部角色（下拉框）
     */
    @GetMapping("/all")
    public Result all() {
        return Result.success(roleService.list(Wrappers.<Role>lambdaQuery()
                .orderByAsc(Role::getSort)
                .orderByAsc(Role::getId)));
    }

    /**
     * 分页查询角色
     *
     * @param pageNum  页码
     * @param pageSize 每页条数
     * @param name     角色名称，模糊
     */
    @GetMapping("/list")
    public Result list(@RequestParam(defaultValue = "1") Integer pageNum,
                       @RequestParam(defaultValue = "10") Integer pageSize,
                       @RequestParam(required = false) String name) {
        Page<Role> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<Role> wrapper = Wrappers.lambdaQuery();
        wrapper.like(name != null && !name.isBlank(), Role::getName, name);
        wrapper.orderByAsc(Role::getSort).orderByAsc(Role::getId);
        roleService.page(page, wrapper);
        return Result.success(page);
    }

    /**
     * 新增角色
     */
    @OperationLogAnnotation(module = "用户角色管理", type = "新增", value = "添加用户角色")
    @PostMapping("/add")
    public Result addRole(@RequestBody Role role) {
        roleService.addRole(role);
        return Result.success();
    }

    /**
     * 修改角色状态
     */
    @OperationLogAnnotation(module = "用户角色管理", type = "修改", value = "修改用户角色状态")
    @PostMapping("/updateStatus")
    public Result updateStatus(@RequestBody Role role) {
        roleService.updateStatus(role);
        return Result.success();
    }

    /**
     * 修改角色信息
     */
    @OperationLogAnnotation(module = "用户角色管理", type = "修改", value = "修改用户角色信息")
    @PostMapping("/updateInfo")
    public Result updateInfo(@RequestBody Role role) {
        roleService.updateInfo(role);
        return Result.success();
    }

    /**
     * 删除角色
     */
    @OperationLogAnnotation(module = "用户角色管理", type = "删除", value = "删除用户角色")
    @PostMapping("/delete")
    public Result deleteById(@RequestBody Role role) {
        roleService.deleteRole(role.getId());
        return Result.success();
    }

    /**
     * 查询角色已分配的菜单ID
     */
    @GetMapping("/menus/{roleId}")
    public Result menus(@PathVariable Long roleId) {
        return Result.success(roleService.listMenuIds(roleId));
    }

    /**
     * 覆盖分配角色菜单
     */
    @OperationLogAnnotation(module = "用户角色管理", type = "修改", value = "分配角色菜单")
    @PostMapping("/assignMenus")
    public Result assignMenus(@RequestBody RoleAssignDTO dto) {
        roleService.assignMenus(dto.getRoleId(), dto.getMenuIds());
        return Result.success();
    }

    /**
     * 查询角色已分配的权限ID
     */
    @GetMapping("/permissions/{roleId}")
    public Result permissions(@PathVariable Long roleId) {
        return Result.success(roleService.listPermissionIds(roleId));
    }

    /**
     * 覆盖分配角色权限
     */
    @OperationLogAnnotation(module = "用户角色管理", type = "修改", value = "分配角色权限")
    @PostMapping("/assignPermissions")
    public Result assignPermissions(@RequestBody RoleAssignDTO dto) {
        roleService.assignPermissions(dto.getRoleId(), dto.getPermissionIds());
        return Result.success();
    }

    /**
     * 当前登录用户可见菜单树
     */
    @GetMapping("/currentMenus")
    public Result currentMenus(HttpServletRequest request) {
        return Result.success(roleService.getCurrentMenus(currentUserId(request)));
    }

    /**
     * 当前登录用户权限编码
     */
    @GetMapping("/currentPermissions")
    public Result currentPermissions(HttpServletRequest request) {
        return Result.success(roleService.getCurrentPermissionCodes(currentUserId(request)));
    }

    /**
     * 导出角色 Excel
     */
    @GetMapping("/exportData")
    public void exportData(HttpServletResponse response) throws IOException {
        try (ExcelWriter writer = ExcelUtil.getWriter()) {
            CellStyle cellStyle = writer.getCellStyle();
            Font font = writer.createFont();
            font.setFontHeightInPoints((short) 10);
            font.setFontName("宋体");
            cellStyle.setFont(font);
            writer.setColumnWidth(-1, 15);
            writer.setColumnWidth(0, 20);
            writer.setRowHeight(-1, 25);

            List<Role> list = roleService.list();
            writer.write(list, true);
            response.setContentType("application/vnd.ms-excel;charset=utf-8");
            response.setHeader("Content-Disposition",
                    "attachment;filename=" + URLEncoder.encode("用户角色信息表", StandardCharsets.UTF_8) + ".xls");
            ServletOutputStream out = response.getOutputStream();
            writer.flush(out, true);
        }
    }

    /**
     * 从 Excel 批量导入角色
     */
    @OperationLogAnnotation(module = "用户角色管理", type = "新增", value = "批量导入用户角色")
    @PostMapping("/importData")
    public Result importData(MultipartFile file) throws IOException {
        ExcelReader reader = ExcelUtil.getReader(file.getInputStream());
        List<Role> roleList = reader.readAll(Role.class);
        try {
            for (Role role : roleList) {
                roleService.addRole(role);
            }
        } catch (CustomerException e) {
            return Result.error(e.getMsg());
        } catch (Exception e) {
            return Result.error("数据批量导入错误");
        }
        return Result.success();
    }

    /**
     * 从 JWT 拦截器写入的 request 属性取出当前用户 ID。
     */
    private Long currentUserId(HttpServletRequest request) {
        Object userId = request.getAttribute("userId");
        if (userId == null) {
            throw new CustomerException("401", "请先登录");
        }
        return Long.valueOf(String.valueOf(userId));
    }
}
