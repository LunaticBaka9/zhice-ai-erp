package com.lunabaka.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.lunabaka.entity.Notice;

import java.util.List;

public interface NoticeService extends IService<Notice> {

    List<Notice> selectAllNotice();

    IPage<Notice> selectPage(int pageNum, int pageSize, Notice notice);

    void insertNotice(Notice notice);

    void insertBatch(List<Notice> list);

    Notice selectByNid(Long nid);

    void updateNotice(Notice notice);

    void deleteByNid(Notice notice);

    void deleteBatch(List<Notice> list);

    void syncViewsToDb();
}
