package com.lunabaka.service;

import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import com.lunabaka.entity.Notice;
import com.lunabaka.exception.CustomerException;
import com.lunabaka.mapper.NoticeMapper;
import jakarta.annotation.Resource;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Set;

@Service
public class NoticeService {
    @Resource
    NoticeMapper noticeMapper;

    @Resource
    private RedisTemplate<String, Object> redisTemplate;

    public List<Notice> selectAllNotice(){
        List<Notice> list = noticeMapper.selectAllNotice(null);
        enrichWithRedisViews(list);
        return list;
    }

    public PageInfo<Notice> selectPage(int pageNum, int pageSize, Notice notice){
        PageHelper.startPage(pageNum, pageSize);
        List<Notice> list = noticeMapper.selectAllNotice(notice);
        enrichWithRedisViews(list);
        return PageInfo.of(list);
    }
    // 读取Redis中的notice:views
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
        Notice notice = noticeMapper.selectByNid(nid);
        // 调用Redis中的views
        if (notice != null) {
            Object views = redisTemplate.opsForValue().get("notice:views:" + nid);
            if (views instanceof Number) {
                notice.setViews(((Number) views).longValue());
            }
        }
        return notice;
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

    /**
     * 定时将 Redis 中的浏览量同步回 MySQL
     * 每 5 分钟执行一次，防止 Redis 宕机导致数据丢失
     */
    @Scheduled(fixedRate = 300000)
    public void syncViewsToDb() {
        // 查出所有公告的 Redis views 键
        Set<String> keys = redisTemplate.keys("notice:views:*");
        if (keys == null || keys.isEmpty()) {
            return;
        }
        for (String key : keys) {
            // 从 key "notice:views:{nid}" 中提取公告ID
            Long nid = Long.parseLong(key.substring("notice:views:".length()));
            Object views = redisTemplate.opsForValue().get(key);
            if (views instanceof Number) {
                Notice notice = new Notice();
                notice.setNid(nid);
                notice.setViews(((Number) views).longValue());
                noticeMapper.updateNotice(notice);
            }
        }
    }
}
