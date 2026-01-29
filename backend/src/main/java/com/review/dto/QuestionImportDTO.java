package com.review.dto;

import lombok.Data;
import java.util.List;

/**
 * 题目导入DTO
 * 用于接收前端上传的JSON题目数据
 */
@Data
public class QuestionImportDTO {

    /** 知识点名称 */
    private String knowledgePoint;

    /** 科目名称 */
    private String subject;

    /** 题目列表 */
    private List<QuestionDTO> questions;

    @Data
    public static class QuestionDTO {
        /** 题目类型 */
        private String type;

        /** 题干 */
        private String title;

        /** 选项 */
        private List<String> options;

        /** 正确答案 */
        private String correctAnswer;

        /** 答案解析 */
        private String analysis;

        /** 难度等级(1-5) */
        private Integer difficulty;

        /** 标签 */
        private List<String> tags;

        /** 来源 */
        private String source;
    }
}
