package com.lunabaka.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.lunabaka.entity.Post;
import com.lunabaka.service.PostService;
import com.lunabaka.mapper.PostMapper;
import org.springframework.stereotype.Service;

/**
* @author lunaticbaka
* @description 针对表【post(职位表)】的数据库操作Service实现
* @createDate 2026-06-30 17:38:07
*/
@Service
public class PostServiceImpl extends ServiceImpl<PostMapper, Post>
    implements PostService{

}




