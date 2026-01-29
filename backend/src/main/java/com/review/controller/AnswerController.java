package com.review.controller;

import com.review.dto.AnswerSubmitDTO;
import com.review.dto.Result;
import com.review.entity.AnswerRecord;
import com.review.service.AnswerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 答题控制器
 */
@RestController
@RequestMapping("/api/answers")
public class AnswerController {

    @Autowired
    private AnswerService answerService;

    /**
     * 提交答案
     */
    @PostMapping("/submit")
    public Result<Map<String, Object>> submitAnswer(@RequestBody AnswerSubmitDTO submitDTO, @RequestParam Long userId) {
        try {
            Map<String, Object> result = answerService.submitAnswer(userId, submitDTO);
            return Result.success("提交成功", result);
        } catch (Exception e) {
            return Result.error("提交失败: " + e.getMessage());
        }
    }

    /**
     * 获取错题列表
     */
    @GetMapping("/wrong")
    public Result<List<AnswerRecord>> getWrongAnswers(@RequestParam Long userId) {
        try {
            List<AnswerRecord> wrongAnswers = answerService.getWrongAnswers(userId);
            return Result.success("查询成功", wrongAnswers);
        } catch (Exception e) {
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    /**
     * 获取答题统计
     */
    @GetMapping("/statistics")
    public Result<Map<String, Object>> getStatistics(@RequestParam Long userId) {
        try {
            Map<String, Object> stats = answerService.getStatistics(userId);
            return Result.success("查询成功", stats);
        } catch (Exception e) {
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    /**
     * 获取答题历史
     */
    @GetMapping("/history")
    public Result<List<Map<String, Object>>> getAnswerHistory(@RequestParam Long userId) {
        try {
            List<Map<String, Object>> history = answerService.getAnswerHistory(userId);
            return Result.success("查询成功", history);
        } catch (Exception e) {
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    /**
     * 更新笔记
     */
    @PutMapping("/notes")
    public Result<Void> updateNotes(@RequestParam Long recordId, @RequestParam String notes) {
        try {
            answerService.updateNotes(recordId, notes);
            return Result.success("保存成功", null);
        } catch (Exception e) {
            return Result.error("保存失败: " + e.getMessage());
        }
    }

    /**
     * 移出错题本
     */
    @PutMapping("/remove-from-wrongbook")
    public Result<Void> removeFromWrongBook(@RequestParam Long recordId) {
        try {
            answerService.removeFromWrongBook(recordId);
            return Result.success("已移出错题本", null);
        } catch (Exception e) {
            return Result.error("操作失败: " + e.getMessage());
        }
    }
}
