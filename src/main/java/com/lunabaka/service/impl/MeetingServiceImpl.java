package com.lunabaka.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.lunabaka.entity.Meeting;
import com.lunabaka.service.MeetingService;
import com.lunabaka.mapper.MeetingMapper;
import org.springframework.stereotype.Service;

/**
* @author lunaticbaka
* @description 针对表【meeting】的数据库操作Service实现
* @createDate 2026-06-25 17:13:08
*/
@Service
public class MeetingServiceImpl extends ServiceImpl<MeetingMapper, Meeting>
    implements MeetingService{

}




