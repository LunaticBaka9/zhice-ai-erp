package com.example.demo.service;

import com.example.demo.entity.SignRecord;
import com.example.demo.mapper.SignMapper;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;

@Service
public class SignService {
    @Resource
    private SignMapper signMapper;

    public PageInfo<SignRecord> selectPage(Integer pageNum, Integer pageSize, SignRecord signRecord) {
        PageHelper.startPage(pageNum, pageSize);
        List<SignRecord> list = signMapper.selectAllSign(signRecord);
        return PageInfo.of(list);
    }

    public int insertSign(SignRecord signRecord) {
        if (signRecord.getCreateTime() == null) {
            signRecord.setCreateTime(new Date());
        }
        return signMapper.insertSign(signRecord);
    }

    public SignRecord selectLatestOpenSign(Long uid) {
        return signMapper.selectLatestOpenSign(uid);
    }

    public void updateById(SignRecord signRecord) {
        signMapper.updateById(signRecord);
    }

    public int updateSignOut(SignRecord signRecord) {
        return signMapper.updateSignOut(signRecord);
    }

    public List<SignRecord> selectAllSign() {
        return signMapper.selectAllSign(null);
    }

    public void deleteById(SignRecord signRecord){
        signMapper.deleteById(signRecord);
    }
}
