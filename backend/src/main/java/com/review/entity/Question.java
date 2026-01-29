package com.review.entity;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 题目实体类
 */
@Data
public class Question {
    private Long id;
    private Long userId;
    private Long knowledgePointId;
    private String subject;
    private String knowledgePointName;

    /**
     * 题目类型: single_choice(单选), multiple_choice(多选),
     * true_false(判断), fill_blank(填空), essay(简答)
     */
    private String type;

    /** 题干 */
    private String title;

    /** 选项(JSON数组) */
    private String options;

    /** 正确答案 */
    private String correctAnswer;

    /** 答案解析 */
    private String analysis;

    /** 难度等级: 1-5 */
    private Integer difficulty;

    /** 标签(JSON数组) */
    private String tags;

    /** 题目来源 */
    private String source;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // 用于前端展示的字段(不存储到数据库)
    @JsonProperty(access = JsonProperty.Access.READ_ONLY)
    private List<String> optionsList;

    @JsonProperty(access = JsonProperty.Access.READ_ONLY)
    private List<String> tagsList;
}
