package com.review.dto;

import lombok.Data;

/**
 * 答题提交DTO
 */
@Data
public class AnswerSubmitDTO {
    /** 题目ID */
    private Long questionId;

    /** 用户答案 */
    private String userAnswer;

    /** 答题耗时(秒) */
    private Integer timeSpent;
}
