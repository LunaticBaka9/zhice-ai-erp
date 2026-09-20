package com.lunabaka.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.lunabaka.dto.MessageQueryDTO;
import com.lunabaka.dto.MessagePageVO;
import com.lunabaka.entity.Message;

import java.util.List;

/**
 * 消息中心业务接口。
 */
public interface MessageService extends IService<Message> {

    /**
     * 分页查询当前用户（含全员广播）的消息。
     */
    MessagePageVO queryPage(Long userId, MessageQueryDTO query);

    /**
     * 查询单条消息详情，并校验当前用户是否有权查看。
     */
    Message getDetail(Long userId, Long msgId);

    /**
     * 当前用户未读消息数。
     */
    long countUnread(Long userId);

    /**
     * 当前用户待处理消息数（need_action = 1 且 is_processed = 0）。
     */
    long countPending(Long userId);

    /**
     * 标记单条消息已读。
     */
    void markRead(Long userId, Long msgId);

    /**
     * 当前用户全部消息标记已读。
     *
     * @return 影响条数
     */
    int markAllRead(Long userId);

    /**
     * 批量标记已读。
     *
     * @return 影响条数
     */
    int markBatchRead(Long userId, List<Long> msgIds);

    /**
     * 删除单条消息（逻辑删除）。
     */
    void deleteMessage(Long userId, Long msgId);

    /**
     * 批量删除消息（逻辑删除）。
     *
     * @return 影响条数
     */
    int deleteBatch(Long userId, List<Long> msgIds);

    /**
     * 清空当前用户的全部消息（逻辑删除）。
     *
     * @return 影响条数
     */
    int clearAll(Long userId);

    /**
     * 发送一条消息，未指定的字段使用默认值。
     */
    Message send(Message message);
}
