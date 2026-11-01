package com.lunabaka.controller;

import com.lunabaka.common.OperationLogAnnotation;
import com.lunabaka.common.Result;
import com.lunabaka.dto.MessageActionDTO;
import com.lunabaka.dto.MessagePageVO;
import com.lunabaka.dto.MessageQueryDTO;
import com.lunabaka.entity.Message;
import com.lunabaka.service.MessageService;
import jakarta.annotation.Resource;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * 消息中心接口。
 *
 * <p>当前登录用户从 JWT 拦截器写入的 request 属性 userId 中获取，
 * 消息可见范围为“本人消息 + 全员广播消息”。</p>
 */
@RestController
@RequestMapping("/message")
public class MessageController {

    @Resource
    private MessageService messageService;

    /**
     * 分页查询当前用户的消息列表（支持类型/优先级/关键字/已读/时间范围筛选）。
     */
    @GetMapping("/list")
    public Result list(HttpServletRequest request, MessageQueryDTO query) {
        Long userId = currentUserId(request);
        if (userId == null) {
            return Result.error("401", "未登录");
        }
        MessagePageVO page = messageService.queryPage(userId, query);
        return Result.success(page);
    }

    /**
     * 查询单条消息详情。
     */
    @GetMapping("/selectByMsgId/{msgId}")
    public Result selectByMsgId(HttpServletRequest request, @PathVariable Long msgId) {
        Long userId = currentUserId(request);
        if (userId == null) {
            return Result.error("401", "未登录");
        }
        return Result.success(messageService.getDetail(userId, msgId));
    }

    /**
     * 当前用户未读消息数。
     */
    @GetMapping("/unreadCount")
    public Result unreadCount(HttpServletRequest request) {
        Long userId = currentUserId(request);
        if (userId == null) {
            return Result.error("401", "未登录");
        }
        return Result.success(messageService.countUnread(userId));
    }

    /**
     * 当前用户待处理消息数。
     */
    @GetMapping("/pendingCount")
    public Result pendingCount(HttpServletRequest request) {
        Long userId = currentUserId(request);
        if (userId == null) {
            return Result.error("401", "未登录");
        }
        return Result.success(messageService.countPending(userId));
    }

    /**
     * 标记单条消息已读。
     */
    @PostMapping("/markRead")
    public Result markRead(HttpServletRequest request, @RequestBody MessageActionDTO body) {
        Long userId = currentUserId(request);
        if (userId == null) {
            return Result.error("401", "未登录");
        }
        if (body == null || body.getMsgId() == null) {
            return Result.error("消息ID不能为空");
        }
        messageService.markRead(userId, body.getMsgId());
        return Result.success();
    }

    /**
     * 当前用户全部标记已读。
     */
    @PostMapping("/markAllRead")
    public Result markAllRead(HttpServletRequest request) {
        Long userId = currentUserId(request);
        if (userId == null) {
            return Result.error("401", "未登录");
        }
        return Result.success(messageService.markAllRead(userId));
    }

    /**
     * 批量标记已读。
     */
    @PostMapping("/markBatchRead")
    public Result markBatchRead(HttpServletRequest request, @RequestBody MessageActionDTO body) {
        Long userId = currentUserId(request);
        if (userId == null) {
            return Result.error("401", "未登录");
        }
        List<Long> msgIds = body == null ? null : body.getMsgIds();
        return Result.success(messageService.markBatchRead(userId, msgIds));
    }

    /**
     * 删除单条消息（逻辑删除）。
     */
    @OperationLogAnnotation(module = "消息中心", type = "删除", value = "删除消息")
    @PostMapping("/delete")
    public Result delete(HttpServletRequest request, @RequestBody MessageActionDTO body) {
        Long userId = currentUserId(request);
        if (userId == null) {
            return Result.error("401", "未登录");
        }
        if (body == null || body.getMsgId() == null) {
            return Result.error("消息ID不能为空");
        }
        messageService.deleteMessage(userId, body.getMsgId());
        return Result.success();
    }

    /**
     * 批量删除消息（逻辑删除）。
     */
    @OperationLogAnnotation(module = "消息中心", type = "删除", value = "批量删除消息")
    @PostMapping("/batchDelete")
    public Result batchDelete(HttpServletRequest request, @RequestBody MessageActionDTO body) {
        Long userId = currentUserId(request);
        if (userId == null) {
            return Result.error("401", "未登录");
        }
        List<Long> msgIds = body == null ? null : body.getMsgIds();
        return Result.success(messageService.deleteBatch(userId, msgIds));
    }

    /**
     * 清空当前用户的全部消息（逻辑删除）。
     */
    @OperationLogAnnotation(module = "消息中心", type = "删除", value = "清空消息")
    @PostMapping("/clearAll")
    public Result clearAll(HttpServletRequest request) {
        Long userId = currentUserId(request);
        if (userId == null) {
            return Result.error("401", "未登录");
        }
        return Result.success(messageService.clearAll(userId));
    }

    /**
     * 发送消息（供其它业务模块或联调使用）。
     */
    @OperationLogAnnotation(module = "消息中心", type = "新增", value = "发送消息")
    @PostMapping("/send")
    public Result send(HttpServletRequest request, @RequestBody Message message) {
        Long userId = currentUserId(request);
        if (userId == null) {
            return Result.error("401", "未登录");
        }
        if (message.getSenderId() == null) {
            message.setSenderId(userId);
        }
        return Result.success(messageService.send(message));
    }

    private Long currentUserId(HttpServletRequest request) {
        Object value = request.getAttribute("userId");
        if (value == null) {
            return null;
        }
        try {
            return Long.valueOf(value.toString());
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
