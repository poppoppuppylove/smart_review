package com.review.controller;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.review.dto.QuestionImportDTO;
import com.review.dto.Result;
import com.review.entity.Question;
import com.review.entity.QuestionSet;
import com.review.service.QuestionService;
import com.review.service.QuestionSetService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 题目控制器
 */
@RestController
@RequestMapping("/api/questions")
public class QuestionController {

    @Autowired
    private QuestionService questionService;

    @Autowired
    private QuestionSetService questionSetService;

    /**
     * 批量导入题目
     */
    @PostMapping("/import")
    public Result<Integer> importQuestions(@RequestBody QuestionImportDTO importDTO, @RequestParam Long userId) {
        try {
            int count = questionService.importQuestions(userId, importDTO);
            return Result.success("成功导入" + count + "道题目", count);
        } catch (JsonProcessingException e) {
            return Result.error("JSON解析错误: " + e.getMessage());
        } catch (Exception e) {
            return Result.error("导入失败: " + e.getMessage());
        }
    }

    /**
     * 获取所有题目（已弃用，请使用题套相关接口）
     */
    @Deprecated
    @GetMapping("/list")
    public Result<List<Question>> getQuestions(@RequestParam Long userId, @RequestParam(required = false) Long questionSetId) {
        try {
            List<Question> questions;

            if (questionSetId != null) {
                // 获取指定题套的未完成题目
                questions = questionSetService.getUnfinishedQuestions(questionSetId, userId);
            } else {
                // 获取最新导入的题套的未完成题目
                List<QuestionSet> questionSets = questionSetService.getUserQuestionSets(userId);
                if (questionSets != null && !questionSets.isEmpty()) {
                    questions = questionSetService.getUnfinishedQuestions(questionSets.get(0).getId(), userId);
                } else {
                    questions = questionService.getUserQuestions(userId);
                }
            }

            return Result.success("查询成功", questions);
        } catch (Exception e) {
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    /**
     * 根据ID获取题目
     */
    @GetMapping("/{id}")
    public Result<Question> getQuestion(@PathVariable Long id) {
        try {
            Question question = questionService.getQuestionById(id);
            if (question != null) {
                return Result.success(question);
            } else {
                return Result.error("题目不存在");
            }
        } catch (Exception e) {
            return Result.error("查询失败: " + e.getMessage());
        }
    }
}
