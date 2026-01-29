package com.review.controller;

import com.review.dto.Result;
import com.review.entity.ReviewPlan;
import com.review.service.ReviewPlanService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 复习计划控制器
 */
@RestController
@RequestMapping("/api/review-plans")
public class ReviewPlanController {

    @Autowired
    private ReviewPlanService reviewPlanService;

    /**
     * 获取待复习题目
     */
    @GetMapping("/pending")
    public Result<List<ReviewPlan>> getPendingReviews(@RequestParam Long userId) {
        try {
            List<ReviewPlan> plans = reviewPlanService.getPendingReviews(userId);
            return Result.success("查询成功", plans);
        } catch (Exception e) {
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    /**
     * 获取所有复习计划
     */
    @GetMapping("/all")
    public Result<List<ReviewPlan>> getAllReviewPlans(@RequestParam Long userId) {
        try {
            List<ReviewPlan> plans = reviewPlanService.getAllReviewPlans(userId);
            return Result.success("查询成功", plans);
        } catch (Exception e) {
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    /**
     * 删除复习计划
     */
    @DeleteMapping("/{id}")
    public Result<String> deleteReviewPlan(@PathVariable Long id, @RequestParam Long userId) {
        try {
            reviewPlanService.deletePlan(id);
            return Result.success("删除成功", null);
        } catch (Exception e) {
            return Result.error("删除失败: " + e.getMessage());
        }
    }

    /**
     * 跳过当前复习，进入下一周期
     */
    @PostMapping("/{id}/skip")
    public Result<ReviewPlan> skipReview(@PathVariable Long id, @RequestParam Long userId) {
        try {
            ReviewPlan plan = reviewPlanService.skipToNextCycle(userId, id);
            return Result.success("已跳过当前复习", plan);
        } catch (Exception e) {
            return Result.error("操作失败: " + e.getMessage());
        }
    }

    /**
     * 更新复习计划的下次复习时间
     */
    @PutMapping("/{id}")
    public Result<ReviewPlan> updateReviewPlan(@PathVariable Long id, @RequestBody ReviewPlan plan, @RequestParam Long userId) {
        try {
            plan.setId(id);
            ReviewPlan updated = reviewPlanService.updatePlan(userId, plan);
            return Result.success("更新成功", updated);
        } catch (Exception e) {
            return Result.error("更新失败: " + e.getMessage());
        }
    }

    /**
     * 新增复习计划
     */
    @PostMapping
    public Result<ReviewPlan> createReviewPlan(@RequestBody ReviewPlan plan) {
        try {
            // 从请求上下文中获取userId，如果未提供则使用默认值1L
            Long userId = plan.getUserId() != null ? plan.getUserId() : 1L;
            plan.setUserId(userId);
            ReviewPlan created = reviewPlanService.createPlan(plan);
            return Result.success("创建成功", created);
        } catch (Exception e) {
            return Result.error("创建失败: " + e.getMessage());
        }
    }

    /**
     * 完成复习并自动计算下次复习时间
     */
    @PostMapping("/{id}/complete")
    public Result<ReviewPlan> completeReview(
            @PathVariable Long id,
            @RequestParam boolean isCorrect,
            @RequestParam(defaultValue = "60") int timeSpent,
            @RequestParam Long userId) {
        try {
            ReviewPlan updated = reviewPlanService.completeReviewAndScheduleNext(userId, id, isCorrect, timeSpent);
            return Result.success("复习完成", updated);
        } catch (Exception e) {
            return Result.error("操作失败: " + e.getMessage());
        }
    }
}

