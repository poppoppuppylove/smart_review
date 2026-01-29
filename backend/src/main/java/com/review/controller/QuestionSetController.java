package com.review.controller;

import com.review.dto.Result;
import com.review.entity.QuestionSet;
import com.review.entity.Question;
import com.review.service.QuestionSetService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 题套控制器
 */
@RestController
@RequestMapping("/api/question-sets")
public class QuestionSetController {

    @Autowired
    private QuestionSetService questionSetService;

    /**
     * 获取用户的所有题套
     */
    @GetMapping("/list")
    public Result<List<QuestionSet>> getQuestionSets(@RequestParam(required = false) Long userId) {
        try {
            // 如果没有提供userId参数，返回空列表
            if (userId == null) {
                return Result.success("查询成功", null);
            }
            List<QuestionSet> questionSets = questionSetService.getUserQuestionSets(userId);
            return Result.success("查询成功", questionSets);
        } catch (Exception e) {
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    /**
     * 创建题套
     */
    @PostMapping("/create")
    public Result<QuestionSet> createQuestionSet(@RequestBody Map<String, Object> params, @RequestParam Long userId) {
        try {
            String name = (String) params.get("name");
            String description = (String) params.get("description");
            String subject = (String) params.get("subject");

            QuestionSet questionSet = questionSetService.createQuestionSet(userId, name, description, subject, null);
            return Result.success("题套创建成功", questionSet);
        } catch (Exception e) {
            return Result.error("创建失败: " + e.getMessage());
        }
    }

    /**
     * 获取题套详情
     */
    @GetMapping("/{id}")
    public Result<Map<String, Object>> getQuestionSetDetail(@PathVariable Long id, @RequestParam Long userId) {
        try {
            QuestionSet questionSet = questionSetService.getQuestionSetById(id);
            if (questionSet == null) {
                return Result.error("题套不存在");
            }

            // 获取题套下的所有题目
            List<Question> allQuestions = questionSetService.getQuestionsBySetId(id);

            // 获取未完成的题目
            List<Question> unfinishedQuestions = questionSetService.getUnfinishedQuestions(id, userId);

            Map<String, Object> data = new HashMap<>();
            data.put("questionSet", questionSet);
            data.put("allQuestions", allQuestions);
            data.put("unfinishedQuestions", unfinishedQuestions);
            data.put("totalQuestions", allQuestions.size());
            data.put("unfinishedCount", unfinishedQuestions.size());

            return Result.success("查询成功", data);
        } catch (Exception e) {
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    /**
     * 获取题套的未完成题目（用于答题）
     */
    @GetMapping("/{id}/unfinished")
    public Result<List<Question>> getUnfinishedQuestions(@PathVariable Long id, @RequestParam(required = false) Long userId) {
        try {
            List<Question> questions = questionSetService.getUnfinishedQuestions(id, userId != null ? userId : 0L);
            return Result.success("查询成功", questions);
        } catch (Exception e) {
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    /**
     * 获取题套的所有题目（用于查看全部题目）
     */
    @GetMapping("/{id}/all")
    public Result<List<Question>> getAllQuestions(@PathVariable Long id, @RequestParam(required = false) Long userId) {
        try {
            List<Question> questions = questionSetService.getQuestionsBySetId(id);
            return Result.success("查询成功", questions);
        } catch (Exception e) {
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    /**
     * 更新题套信息
     */
    @PutMapping("/{id}")
    public Result<QuestionSet> updateQuestionSet(@PathVariable Long id, @RequestBody Map<String, Object> params, @RequestParam Long userId) {
        try {
            String name = (String) params.get("name");
            String description = (String) params.get("description");

            QuestionSet questionSet = questionSetService.updateQuestionSet(id, userId, name, description);
            if (questionSet != null) {
                return Result.success("更新成功", questionSet);
            } else {
                return Result.error("题套不存在或无权限");
            }
        } catch (Exception e) {
            return Result.error("更新失败: " + e.getMessage());
        }
    }
}