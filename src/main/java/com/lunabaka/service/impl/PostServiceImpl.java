package com.lunabaka.service.impl;

import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.lunabaka.entity.Post;
import com.lunabaka.mapper.PostMapper;
import com.lunabaka.service.PostService;
import org.springframework.stereotype.Service;

/**
 * @author lunaticbaka
 * @description 针对表【post(职位表)】的数据库操作Service实现
 * @createDate 2026-06-30 17:38:07
 */
@Service
public class PostServiceImpl extends ServiceImpl<PostMapper, Post>
        implements PostService {

    // 更新职位状态
    public void updateStatus(Post post) {
        LambdaUpdateWrapper<Post> wrapper = new LambdaUpdateWrapper<>();
        wrapper.eq(Post::getId, post.getId())
                .set(Post::getStatus, post.getStatus());
        baseMapper.update(null, wrapper);
    }

}




