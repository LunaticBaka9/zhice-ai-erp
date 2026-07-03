package com.lunabaka.service.impl;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Set;

import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.lunabaka.entity.Notice;
import com.lunabaka.exception.CustomerException;
import com.lunabaka.mapper.NoticeMapper;
import com.lunabaka.service.NoticeService;

import jakarta.annotation.Resource;

@Service
public class NoticeServiceImpl extends ServiceImpl<NoticeMapper, Notice> implements NoticeService {

    @Resource
    private RedisTemplate<String, Object> redisTemplate;

    @Override
    public List<Notice> selectAllNotice() {
        LambdaQueryWrapper<Notice> wrapper = Wrappers.lambdaQuery();
        wrapper.orderByDesc(Notice::getPublishDate);
        List<Notice> list = baseMapper.selectList(wrapper);
        enrichWithRedisViews(list);
        return list;
    }

    @Override
    public IPage<Notice> selectPage(int pageNum, int pageSize, Notice notice) {
        LambdaQueryWrapper<Notice> wrapper = buildQueryWrapper(notice);
        IPage<Notice> page = baseMapper.selectPage(new Page<>(pageNum, pageSize), wrapper);
        enrichWithRedisViews(page.getRecords());
        return page;
    }

    private LambdaQueryWrapper<Notice> buildQueryWrapper(Notice notice) {
        LambdaQueryWrapper<Notice> wrapper = Wrappers.lambdaQuery();
        if (notice.getTitle() != null && !notice.getTitle().isEmpty()) {
            wrapper.like(Notice::getTitle, notice.getTitle());
        }
        if (notice.getType() != null && !notice.getType().isEmpty()) {
            wrapper.like(Notice::getType, notice.getType());
        }
        if (notice.getAuthor() != null && !notice.getAuthor().isEmpty()) {
            wrapper.like(Notice::getAuthor, notice.getAuthor());
        }
        if (notice.getUid() != null) {
            wrapper.eq(Notice::getUid, notice.getUid());
        }
        wrapper.orderByDesc(Notice::getPublishDate);
        return wrapper;
    }

    private void enrichWithRedisViews(List<Notice> notices) {
        if (notices == null || notices.isEmpty()) {
            return;
        }
        List<String> keys = new ArrayList<>();
        for (Notice n : notices) {
            keys.add("notice:views:" + n.getNid());
        }
        List<Object> viewsList = redisTemplate.opsForValue().multiGet(keys);
        if (viewsList == null) {
            return;
        }
        for (int i = 0; i < notices.size(); i++) {
            Object views = viewsList.get(i);
            if (views instanceof Number) {
                notices.get(i).setViews(((Number) views).longValue());
            }
        }
    }

    @Override
    public void insertNotice(Notice notice) {
        if (notice.getPublishDate() == null) {
            notice.setPublishDate(new Date());
        }
        baseMapper.insert(notice);
    }

    @Override
    public void insertBatch(List<Notice> list) {
        for (Notice notice : list) {
            this.insertNotice(notice);
        }
    }

    @Override
    public Notice selectByNid(Long nid) {
        Notice notice = baseMapper.selectById(nid);
        if (notice != null) {
            Object views = redisTemplate.opsForValue().get("notice:views:" + nid);
            if (views instanceof Number) {
                notice.setViews(((Number) views).longValue());
            }
        }
        return notice;
    }

    @Override
    public void updateNotice(Notice notice) {
        baseMapper.updateById(notice);
    }

    @Override
    public void deleteByNid(Notice notice) {
        Notice dbNotice = baseMapper.selectById(notice.getNid());
        if (dbNotice == null) {
            throw new CustomerException("找不到公告，无法删除");
        }
        baseMapper.deleteById(notice.getNid());
    }

    @Override
    public void deleteBatch(List<Notice> list) {
        for (Notice notice : list) {
            this.deleteByNid(notice);
        }
    }

    @Override
    @Scheduled(fixedRate = 300000)
    public void syncViewsToDb() {
        Set<String> keys = redisTemplate.keys("notice:views:*");
        if (keys == null || keys.isEmpty()) {
            return;
        }
        for (String key : keys) {
            Long nid = Long.parseLong(key.substring("notice:views:".length()));
            Object views = redisTemplate.opsForValue().get(key);
            if (views instanceof Number) {
                Notice notice = new Notice();
                notice.setNid(nid);
                notice.setViews(((Number) views).longValue());
                baseMapper.updateById(notice);
            }
        }
    }
}
