package com.review.service;

import com.review.algorithm.EbbinghausAlgorithm;
import com.review.entity.ReviewPlan;
import com.review.mapper.ReviewPlanMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 复习计划服务类
 */
@Service
public class ReviewPlanService {

    @Autowired
    private ReviewPlanMapper reviewPlanMapper;

    @Autowired
    private EbbinghausAlgorithm ebbinghausAlgorithm;

    /**
     * 获取待复习题目列表
     */
    public List<ReviewPlan> getPendingReviews(Long userId) {
        return reviewPlanMapper.findPendingReviews(userId, LocalDateTime.now());
    }

    /**
     * 获取所有复习计划
     */
    public List<ReviewPlan> getAllReviewPlans(Long userId) {
        return reviewPlanMapper.findByUserId(userId);
    }

    /**
     * 标记复习完成
     */
    public void markAsCompleted(Long userId, Long planId) {
        ReviewPlan plan = getPlanById(planId);

        if (plan != null) {
            // 验证userId是否匹配
            if (!plan.getUserId().equals(userId)) {
                throw new RuntimeException("无权限操作该复习计划");
            }

            plan.setIsCompleted(true);
            reviewPlanMapper.update(plan);
        }
    }

    /**
     * 删除复习计划
     */
    public void deletePlan(Long planId) {
        reviewPlanMapper.delete(planId);
    }

    /**
     * 跳过当前复习，直接进入下一个复习周期
     */
    public ReviewPlan skipToNextCycle(Long userId, Long planId) {
        ReviewPlan plan = getPlanById(planId);
        if (plan == null) {
            throw new RuntimeException("复习计划不存在");
        }

        // 验证userId是否匹配
        if (!plan.getUserId().equals(userId)) {
            throw new RuntimeException("无权限操作该复习计划");
        }

        // 获取当前级别，升一级
        int currentLevel = plan.getReviewLevel() != null ? plan.getReviewLevel() : 1;
        int nextLevel = Math.min(5, currentLevel + 1);

        // 计算下次复习时间
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime nextReviewTime = ebbinghausAlgorithm.calculateNextReviewTime(
                now, currentLevel, true, 0, 0);

        // 更新计划
        plan.setReviewLevel(nextLevel);
        plan.setLastReviewTime(now);
        plan.setNextReviewTime(nextReviewTime);
        plan.setUpdatedAt(now);

        reviewPlanMapper.update(plan);
        return plan;
    }

    /**
     * 更新复习计划
     */
    public ReviewPlan updatePlan(Long userId, ReviewPlan plan) {
        ReviewPlan existing = getPlanById(plan.getId());
        if (existing == null) {
            throw new RuntimeException("复习计划不存在");
        }

        // 验证userId是否匹配
        if (!existing.getUserId().equals(userId)) {
            throw new RuntimeException("无权限操作该复习计划");
        }

        plan.setUpdatedAt(LocalDateTime.now());
        reviewPlanMapper.update(plan);
        return getPlanById(plan.getId());
    }

    /**
     * 创建新的复习计划
     */
    public ReviewPlan createPlan(ReviewPlan plan) {
        LocalDateTime now = LocalDateTime.now();

        // 设置默认值
        if (plan.getReviewLevel() == null) {
            plan.setReviewLevel(1);
        }
        if (plan.getMasteryScore() == null) {
            plan.setMasteryScore(BigDecimal.ZERO);
        }
        if (plan.getPriority() == null) {
            plan.setPriority(5);
        }
        if (plan.getIsCompleted() == null) {
            plan.setIsCompleted(false);
        }
        if (plan.getLastReviewTime() == null) {
            plan.setLastReviewTime(now);
        }
        if (plan.getNextReviewTime() == null) {
            // 默认1天后复习
            plan.setNextReviewTime(now.plusDays(1));
        }

        plan.setCreatedAt(now);
        plan.setUpdatedAt(now);

        reviewPlanMapper.insert(plan);
        return plan;
    }

    /**
     * 完成复习并自动计算下次复习时间
     */
    public ReviewPlan completeReviewAndScheduleNext(Long userId, Long planId, boolean isCorrect, int timeSpent) {
        ReviewPlan plan = getPlanById(planId);
        if (plan == null) {
            throw new RuntimeException("复习计划不存在");
        }

        // 验证userId是否匹配
        if (!plan.getUserId().equals(userId)) {
            throw new RuntimeException("无权限操作该复习计划");
        }

        LocalDateTime now = LocalDateTime.now();
        int currentLevel = plan.getReviewLevel() != null ? plan.getReviewLevel() : 1;

        // 计算掌握度
        BigDecimal masteryScore = ebbinghausAlgorithm.calculateMasteryScore(
                isCorrect, timeSpent, 0);

        // 计算下次复习时间
        LocalDateTime nextReviewTime = ebbinghausAlgorithm.calculateNextReviewTime(
                now, currentLevel, isCorrect, timeSpent, 0);

        // 确定下一个级别
        int nextLevel = isCorrect ? Math.min(5, currentLevel + 1) : 1;

        // 计算优先级
        int priority = ebbinghausAlgorithm.calculatePriority(
                nextReviewTime, masteryScore, 3);

        // 更新计划
        plan.setLastReviewTime(now);
        plan.setNextReviewTime(nextReviewTime);
        plan.setReviewLevel(nextLevel);
        plan.setMasteryScore(masteryScore);
        plan.setPriority(priority);
        plan.setUpdatedAt(now);

        reviewPlanMapper.update(plan);
        return plan;
    }

    /**
     * 根据ID获取复习计划
     */
    private ReviewPlan getPlanById(Long planId) {
        return reviewPlanMapper.findById(planId);
    }
}
