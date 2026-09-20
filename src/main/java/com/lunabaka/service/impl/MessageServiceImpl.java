package com.lunabaka.service.impl;

import cn.hutool.core.date.DateUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.lunabaka.dto.MessagePageVO;
import com.lunabaka.dto.MessageQueryDTO;
import com.lunabaka.entity.Message;
import com.lunabaka.entity.User;
import com.lunabaka.exception.CustomerException;
import com.lunabaka.mapper.MessageMapper;
import com.lunabaka.service.MessageService;
import com.lunabaka.service.UserService;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * 消息中心业务实现。
 *
 * <p>消息可见范围：receiver_id = 当前用户 或 receiver_id IS NULL（全员广播）；
 * 逻辑删除由 {@link Message#getDelFlag()} 上的 @TableLogic 自动处理，
 * 因此这里所有查询/更新/删除都天然只作用于未删除数据。</p>
 */
@Service
public class MessageServiceImpl extends ServiceImpl<MessageMapper, Message> implements MessageService {

    @Resource
    private UserService userService;

    @Override
    public MessagePageVO queryPage(Long userId, MessageQueryDTO query) {
        MessageQueryDTO condition = query == null ? new MessageQueryDTO() : query;
        int pageNum = condition.getPageNum() == null || condition.getPageNum() < 1 ? 1 : condition.getPageNum();
        int pageSize = condition.getPageSize() == null || condition.getPageSize() < 1 ? 10 : condition.getPageSize();

        IPage<Message> page = baseMapper.selectPage(new Page<>(pageNum, pageSize), buildQueryWrapper(userId, condition));
        enrichSenderNames(page.getRecords());

        MessagePageVO vo = new MessagePageVO();
        vo.setRecords(page.getRecords());
        vo.setTotal(page.getTotal());
        vo.setUnreadCount(countUnread(userId));
        vo.setPendingCount(countPending(userId));
        return vo;
    }

    @Override
    public Message getDetail(Long userId, Long msgId) {
        Message message = baseMapper.selectById(msgId);
        if (message == null) {
            throw new CustomerException("消息不存在或已删除");
        }
        assertAccessible(message, userId);
        enrichSenderNames(Collections.singletonList(message));
        return message;
    }

    @Override
    public long countUnread(Long userId) {
        LambdaQueryWrapper<Message> wrapper = scopeQuery(userId);
        wrapper.eq(Message::getIsRead, 0);
        Long count = baseMapper.selectCount(wrapper);
        return count == null ? 0L : count;
    }

    @Override
    public long countPending(Long userId) {
        LambdaQueryWrapper<Message> wrapper = scopeQuery(userId);
        wrapper.eq(Message::getNeedAction, 1).eq(Message::getIsProcessed, 0);
        Long count = baseMapper.selectCount(wrapper);
        return count == null ? 0L : count;
    }

    @Override
    public void markRead(Long userId, Long msgId) {
        Message message = baseMapper.selectById(msgId);
        if (message == null) {
            throw new CustomerException("消息不存在或已删除");
        }
        assertAccessible(message, userId);
        if (Integer.valueOf(1).equals(message.getIsRead())) {
            return;
        }
        LambdaUpdateWrapper<Message> wrapper = Wrappers.lambdaUpdate();
        wrapper.eq(Message::getMsgId, msgId).set(Message::getIsRead, 1);
        baseMapper.update(null, wrapper);
    }

    @Override
    public int markAllRead(Long userId) {
        LambdaUpdateWrapper<Message> wrapper = Wrappers.lambdaUpdate();
        applyScope(wrapper, userId);
        wrapper.eq(Message::getIsRead, 0).set(Message::getIsRead, 1);
        return baseMapper.update(null, wrapper);
    }

    @Override
    public int markBatchRead(Long userId, List<Long> msgIds) {
        if (msgIds == null || msgIds.isEmpty()) {
            return 0;
        }
        LambdaUpdateWrapper<Message> wrapper = Wrappers.lambdaUpdate();
        applyScope(wrapper, userId);
        wrapper.in(Message::getMsgId, msgIds).eq(Message::getIsRead, 0).set(Message::getIsRead, 1);
        return baseMapper.update(null, wrapper);
    }

    @Override
    public void deleteMessage(Long userId, Long msgId) {
        Message message = baseMapper.selectById(msgId);
        if (message == null) {
            throw new CustomerException("消息不存在或已删除");
        }
        assertAccessible(message, userId);
        baseMapper.deleteById(msgId);
    }

    @Override
    public int deleteBatch(Long userId, List<Long> msgIds) {
        if (msgIds == null || msgIds.isEmpty()) {
            return 0;
        }
        LambdaQueryWrapper<Message> wrapper = scopeQuery(userId);
        wrapper.in(Message::getMsgId, msgIds);
        return baseMapper.delete(wrapper);
    }

    @Override
    public int clearAll(Long userId) {
        return baseMapper.delete(scopeQuery(userId));
    }

    @Override
    public Message send(Message message) {
        if (message == null) {
            throw new CustomerException("消息内容不能为空");
        }
        if (!StringUtils.hasText(message.getType())) {
            message.setType("system");
        }
        if (message.getPublishDate() == null) {
            message.setPublishDate(new Date());
        }
        if (!StringUtils.hasText(message.getPriority())) {
            message.setPriority("medium");
        }
        if (message.getNeedAction() == null) {
            message.setNeedAction(0);
        }
        if (message.getIsProcessed() == null) {
            message.setIsProcessed(0);
        }
        if (message.getIsRead() == null) {
            message.setIsRead(0);
        }
        message.setDelFlag(0);
        baseMapper.insert(message);
        return message;
    }

    // ------------------------------------------------------------------ 内部方法

    private LambdaQueryWrapper<Message> buildQueryWrapper(Long userId, MessageQueryDTO query) {
        LambdaQueryWrapper<Message> wrapper = scopeQuery(userId);

        if (StringUtils.hasText(query.getType())) {
            wrapper.eq(Message::getType, query.getType().trim());
        }
        if (StringUtils.hasText(query.getPriority())) {
            wrapper.eq(Message::getPriority, query.getPriority().trim());
        }
        if (query.getIsRead() != null) {
            wrapper.eq(Message::getIsRead, query.getIsRead());
        }
        if (query.getNeedAction() != null) {
            wrapper.eq(Message::getNeedAction, query.getNeedAction());
        }
        if (StringUtils.hasText(query.getKeyword())) {
            String keyword = query.getKeyword().trim();
            wrapper.and(w -> w.like(Message::getTitle, keyword)
                    .or().like(Message::getSummary, keyword)
                    .or().like(Message::getContent, keyword));
        }
        Date start = parseBeginOfDay(query.getStartDate());
        if (start != null) {
            wrapper.ge(Message::getPublishDate, start);
        }
        Date end = parseEndOfDay(query.getEndDate());
        if (end != null) {
            wrapper.le(Message::getPublishDate, end);
        }
        wrapper.orderByDesc(Message::getPublishDate).orderByDesc(Message::getMsgId);
        return wrapper;
    }

    /** 构造“当前用户可见消息”的基础查询条件（含全员广播）。 */
    private LambdaQueryWrapper<Message> scopeQuery(Long userId) {
        LambdaQueryWrapper<Message> wrapper = Wrappers.lambdaQuery();
        applyScope(wrapper, userId);
        return wrapper;
    }

    private void applyScope(LambdaQueryWrapper<Message> wrapper, Long userId) {
        wrapper.and(w -> w.eq(Message::getReceiverId, userId).or().isNull(Message::getReceiverId));
    }

    private void applyScope(LambdaUpdateWrapper<Message> wrapper, Long userId) {
        wrapper.and(w -> w.eq(Message::getReceiverId, userId).or().isNull(Message::getReceiverId));
    }

    private void assertAccessible(Message message, Long userId) {
        if (message.getReceiverId() != null && !Objects.equals(message.getReceiverId(), userId)) {
            throw new CustomerException("无权查看该消息");
        }
    }

    private Date parseBeginOfDay(String text) {
        if (!StringUtils.hasText(text)) {
            return null;
        }
        try {
            return DateUtil.beginOfDay(DateUtil.parse(text.trim()));
        } catch (Exception e) {
            return null;
        }
    }

    private Date parseEndOfDay(String text) {
        if (!StringUtils.hasText(text)) {
            return null;
        }
        try {
            return DateUtil.endOfDay(DateUtil.parse(text.trim()));
        } catch (Exception e) {
            return null;
        }
    }

    /** 关联 user 表填充发送人显示名。 */
    private void enrichSenderNames(List<Message> messages) {
        if (messages == null || messages.isEmpty()) {
            return;
        }
        Set<Long> senderIds = messages.stream()
                .map(Message::getSenderId)
                .filter(Objects::nonNull)
                .collect(Collectors.toSet());

        Map<Long, String> nameMap = new HashMap<>();
        if (!senderIds.isEmpty()) {
            List<User> users = userService.listByIds(senderIds);
            if (users != null) {
                for (User user : users) {
                    nameMap.put(user.getUid(),
                            StringUtils.hasText(user.getName()) ? user.getName() : user.getUsername());
                }
            }
        }

        for (Message message : messages) {
            if (message.getSenderId() == null) {
                message.setSenderName("系统管理员");
            } else {
                message.setSenderName(nameMap.getOrDefault(message.getSenderId(), "用户" + message.getSenderId()));
            }
        }
    }
}
