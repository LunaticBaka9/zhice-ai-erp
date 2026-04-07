package com.example.demo.service;

import com.example.demo.entity.OperationLog;
import com.example.demo.mapper.OperationLogMapper;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class OperationLogService {
    @Resource
    OperationLogMapper operationLogMapper;

    public void insertLog(OperationLog log) {
        operationLogMapper.insertLog(log);
    }

    public List<OperationLog> selectAllLogs() {
        return operationLogMapper.selectAllLogs();
    }

    public List<OperationLog> selectByPage(int pageNum, int pageSize, String username, String module, String type) {
        return operationLogMapper.selectByPage((pageNum - 1) * pageSize, pageSize, username, module, type);
    }

    public int selectCount(String username, String module, String type) {
        return operationLogMapper.selectCount(username, module, type);
    }

    public void deleteBatch(List<Long> ids) {
        operationLogMapper.deleteBatch(ids);
    }

    public void deleteAll() {
        operationLogMapper.deleteAll();
    }
}
