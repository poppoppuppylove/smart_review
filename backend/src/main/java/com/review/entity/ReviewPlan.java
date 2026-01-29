package com.review.entity;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 复习计划实体类
 */
@Data
public class ReviewPlan {
    private Long id;
    private Long userId;
    private Long questionId;

    /** 上次复习时间 */
    private LocalDateTime lastReviewTime;

    /** 下次复习时间 */
    private LocalDateTime nextReviewTime;

    /** 复习级别: 1-5, 对应艾宾浩斯曲线阶段 */
    private Integer reviewLevel;

    /** 掌握度评分: 0-100 */
    private BigDecimal masteryScore;

    /** 优先级: 1-10, 数字越大越优先 */
    private Integer priority;

    /** 是否完成: 0-未完成, 1-已完成 */
    private Boolean isCompleted;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
