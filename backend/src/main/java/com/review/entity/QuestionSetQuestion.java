package com.review.entity;

import lombok.Data;
import java.time.LocalDateTime;

/**
 * 题目-题套关联实体类
 * 多对多关系
 */
@Data
public class QuestionSetQuestion {
    private Long id;
    private Long questionSetId;
    private Long questionId;
    private Integer orderIndex;
    private LocalDateTime createdAt;

    public QuestionSetQuestion() {
        this.orderIndex = 0;
    }
}