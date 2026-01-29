package com.review.entity;

import lombok.Data;
import java.time.LocalDateTime;

/**
 * 题套实体类
 * 用于管理题目集合
 */
@Data
public class QuestionSet {
    private Long id;
    private Long userId;
    private String name;
    private String description;
    private String subject;
    private Long knowledgePointId;
    private Integer totalQuestions;
    private Integer doneCount;
    private Integer correctCount;
    private Integer wrongCount;
    private Boolean isFinished;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public QuestionSet() {
        this.totalQuestions = 0;
        this.doneCount = 0;
        this.correctCount = 0;
        this.wrongCount = 0;
        this.isFinished = false;
    }
}