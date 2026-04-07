package com.example.demo.mapper;

import com.example.demo.entity.OperationLog;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface OperationLogMapper {
    //插入日志
    int insertLog(OperationLog log);

    //选择日志
    List<OperationLog> selectAllLogs();

    List<OperationLog> selectByPage(@Param("pageNum") int pageNum, @Param("pageSize") int pageSize, @Param("username") String username, @Param("module") String module, @Param("type") String type);

    
    int selectCount(@Param("username") String username, @Param("module") String module, @Param("type") String type);

    //删除日志
    int deleteBatch(@Param("ids") List<Long> ids);
    int deleteAll();
}
