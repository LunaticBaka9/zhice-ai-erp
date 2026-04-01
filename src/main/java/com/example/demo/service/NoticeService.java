package com.example.demo.service;

import com.example.demo.entity.Notice;
import com.example.demo.entity.SignRecord;
import com.example.demo.exception.CustomerException;
import com.example.demo.mapper.NoticeMapper;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;

@Service
public class NoticeService {
    @Resource
    NoticeMapper noticeMapper;

    public List<Notice> selectAllNotice(){
        return noticeMapper.selectAllNotice(null);
    }

    public PageInfo<Notice> selectPage(int pageNum, int pageSize, Notice notice){
        PageHelper.startPage(pageNum, pageSize);
        List<Notice> list = noticeMapper.selectAllNotice(notice);
        return PageInfo.of(list);
    }

    public void insertNotice(Notice notice) {
        if (notice.getPublishDate() == null) {
            notice.setPublishDate(new Date());
        }
        noticeMapper.insertNotice(notice);
    }

    public void insertBatch(List<Notice> list) {
        for (Notice notice : list) {
            this.insertNotice(notice);
        }
    }

    public Notice selectByNid(Long nid){
        return noticeMapper.selectByNid(nid);
    }

    public void updateNotice(Notice notice){
        noticeMapper.updateNotice(notice);
    }

    public void deleteByNid(Notice notice){
        Notice dbnotice = noticeMapper.selectByNid(notice.getNid());
        if(dbnotice == null){
            throw new CustomerException("找不到公告，无法删除");
        }
        noticeMapper.deleteByNid(notice);
    }

    public void deleteBatch(List<Notice> list){
        for(Notice notice: list){
            this.deleteByNid(notice);
        }
    }
}
