package com.lunabaka.utils;

// 邮箱发送工具类

import cn.hutool.extra.mail.MailAccount;
import cn.hutool.extra.mail.MailUtil;
import lombok.extern.slf4j.Slf4j;

import java.io.File;
import java.util.Arrays;
import java.util.List;

@Slf4j
public class EmailUtils {
    /**
     * 发送普通文本邮件
     * @param toEmail 收件人邮箱
     * @param subject 邮件主题
     * @param content 邮件内容
     */
    public static void sendTextMail(String toEmail,String senderName, String subject, String content) {
        try {
            // 1. 创建 MailAccount 对象
            MailAccount account = new MailAccount();

            // 读取配置文件
            // 如果你的配置文件在 resources/config/mail.setting
             account = new MailAccount("config/mail.setting");

            // 3. 设置发件人昵称和地址 (格式必须正确)
            // 注意：这里的 user 必须和上面 setUser 的邮箱一致
            account.setFrom(senderName + " <" + account.getUser() + ">");

            // 4. 发送邮件
            MailUtil.send(account, toEmail, subject, content, false);

            log.info("文本邮件发送成功，收件人: {}", toEmail);
        } catch (Exception e) {
            log.error("文本邮件发送失败，收件人: {}, 错误信息: {}", toEmail, e.getMessage(), e);

            // 尝试提取无效地址，方便排查
            if (e.getCause() instanceof javax.mail.SendFailedException) {
                javax.mail.SendFailedException sfe = (javax.mail.SendFailedException) e.getCause();
                javax.mail.Address[] invalidAddresses = sfe.getInvalidAddresses();
                if (invalidAddresses != null && invalidAddresses.length > 0) {
                    log.error("检测到无效的邮箱地址: {}", Arrays.toString(invalidAddresses));
                }
            }

            throw new RuntimeException("邮件发送失败: " + e.getMessage());
        }
    }

    /**
     * 发送 HTML 格式邮件（可带附件）
     * @param toEmail 收件人邮箱
     * @param subject 邮件主题
     * @param htmlContent HTML格式的邮件内容
     * @param files 附件列表（可选）
     */
    public static void sendHtmlMail(String toEmail, String subject, String htmlContent, File... files) {
        try {
            MailUtil.send(toEmail, subject, htmlContent, true, files);
            log.info("HTML邮件发送成功，收件人: {}", toEmail);
        } catch (Exception e) {
            log.error("HTML邮件发送失败，收件人: {}, 错误信息: {}", toEmail, e.getMessage(), e);
            throw new RuntimeException("邮件发送失败: " + e.getMessage());
        }
    }

    /**
     * 批量发送邮件
     * @param toEmails 收件人邮箱列表
     * @param subject 邮件主题
     * @param content 邮件内容
     * @param isHtml 是否为HTML格式
     */
    public static void sendBatchMail(List<String> toEmails, String subject, String content, boolean isHtml) {
        try {
            MailUtil.send(toEmails, subject, content, isHtml);
            log.info("批量邮件发送成功，收件人数量: {}", toEmails.size());
        } catch (Exception e) {
            log.error("批量邮件发送失败，错误信息: {}", e.getMessage(), e);
            throw new RuntimeException("批量邮件发送失败: " + e.getMessage());
        }
    }
}