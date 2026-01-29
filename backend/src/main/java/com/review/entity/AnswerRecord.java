package com.review.entity;

import lombok.Data;
import java.time.LocalDateTime;

/**
 * 用户答题记录实体类
 */
@Data
public class AnswerRecord {
    private Long id;
    private Long userId;
    private Long questionId;

    /** 用户答案 */
    private String userAnswer;

    /** 是否正确: 0-错误, 1-正确 */
    private Boolean isCorrect;

    /** 答题耗时(秒) */
    private Integer timeSpent;

    /** 答题时间 */
    private LocalDateTime answerTime;

    /** 复习次数 */
    private Integer reviewCount;

    /** 连续正确次数 */
    private Integer consecutiveCorrect;

    /** 错题重练次数 */
    private Integer retryCount;

    /** 用户笔记备注 */
    private String notes;

    /** 是否在错题本中: 0-移除, 1-保留 */
    private Boolean isInWrongbook;

    /** 科目 */
    private String subject;

    /** 知识点名称 */
    private String topicName;

    private LocalDateTime createdAt;
}
