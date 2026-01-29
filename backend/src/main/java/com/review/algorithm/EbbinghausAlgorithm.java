package com.review.algorithm;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;

/**
 * 艾宾浩斯遗忘曲线算法实现
 * 
 * 核心原理:
 * 1. 根据答题正确率、答题耗时、历史记录计算掌握度
 * 2. 根据掌握度和复习级别计算下次复习时间
 * 3. 复习间隔: 1天、2天、4天、7天、15天
 * 
 * @author Smart Review Team
 * @version 1.0.0
 */
@Component
public class EbbinghausAlgorithm {

    /** 复习间隔配置(天) */
    @Value("${review.ebbinghaus.intervals:1,2,4,7,15}")
    private String intervalsConfig;

    /** 正确率权重 */
    @Value("${review.ebbinghaus.accuracy-weight:0.6}")
    private double accuracyWeight;

    /** 耗时权重 */
    @Value("${review.ebbinghaus.time-weight:0.4}")
    private double timeWeight;

    /** 标准答题时间(秒) */
    @Value("${review.ebbinghaus.standard-time:60}")
    private int standardTime;

    /**
     * 计算下次复习时间
     * 
     * @param lastReviewTime     上次复习时间
     * @param currentLevel       当前复习级别(1-5)
     * @param isCorrect          本次是否答对
     * @param timeSpent          答题耗时(秒)
     * @param consecutiveCorrect 连续正确次数
     * @return 下次复习时间
     */
    public LocalDateTime calculateNextReviewTime(
            LocalDateTime lastReviewTime,
            int currentLevel,
            boolean isCorrect,
            int timeSpent,
            int consecutiveCorrect) {

        // 如果答错,重置到第一级
        if (!isCorrect) {
            return lastReviewTime.plusDays(getIntervalDays(1));
        }

        // 计算掌握度评分(0-100)
        BigDecimal masteryScore = calculateMasteryScore(isCorrect, timeSpent, consecutiveCorrect);

        // 根据掌握度决定是否升级
        int nextLevel = determineNextLevel(currentLevel, masteryScore);

        // 获取对应级别的复习间隔
        int intervalDays = getIntervalDays(nextLevel);

        // 返回下次复习时间
        return lastReviewTime.plusDays(intervalDays);
    }

    /**
     * 计算掌握度评分
     * 
     * 评分规则:
     * 1. 正确率占60%权重
     * 2. 答题速度占40%权重(耗时越少得分越高)
     * 3. 连续正确次数提供加成
     * 
     * @param isCorrect          是否正确
     * @param timeSpent          答题耗时(秒)
     * @param consecutiveCorrect 连续正确次数
     * @return 掌握度评分(0-100)
     */
    public BigDecimal calculateMasteryScore(boolean isCorrect, int timeSpent, int consecutiveCorrect) {
        // 正确率得分: 答对100分,答错0分
        double accuracyScore = isCorrect ? 100.0 : 0.0;

        // 速度得分: 基于标准时间计算
        // 如果耗时 <= 标准时间,得100分
        // 如果耗时 > 标准时间,按比例递减,最低0分
        double timeScore = 100.0;
        if (timeSpent > standardTime) {
            timeScore = Math.max(0, 100.0 - (timeSpent - standardTime) * 1.0);
        }

        // 加权计算基础得分
        double baseScore = accuracyScore * accuracyWeight + timeScore * timeWeight;

        // 连续正确加成: 每连续答对一次,加5分,最多加20分
        double bonus = Math.min(20.0, consecutiveCorrect * 5.0);

        // 总分不超过100
        double totalScore = Math.min(100.0, baseScore + bonus);

        return BigDecimal.valueOf(totalScore).setScale(2, RoundingMode.HALF_UP);
    }

    /**
     * 根据掌握度决定下一个复习级别
     * 
     * 规则:
     * - 掌握度 >= 80分: 升级
     * - 掌握度 < 60分: 降级
     * - 其他: 保持当前级别
     * 
     * @param currentLevel 当前级别(1-5)
     * @param masteryScore 掌握度评分
     * @return 下一个复习级别
     */
    private int determineNextLevel(int currentLevel, BigDecimal masteryScore) {
        double score = masteryScore.doubleValue();

        if (score >= 80.0) {
            // 升级,但不超过最高级别5
            return Math.min(5, currentLevel + 1);
        } else if (score < 60.0) {
            // 降级,但不低于最低级别1
            return Math.max(1, currentLevel - 1);
        } else {
            // 保持当前级别
            return currentLevel;
        }
    }

    /**
     * 获取指定级别的复习间隔天数
     * 
     * @param level 复习级别(1-5)
     * @return 间隔天数
     */
    private int getIntervalDays(int level) {
        String[] intervals = intervalsConfig.split(",");

        // 确保级别在有效范围内
        int index = Math.max(0, Math.min(level - 1, intervals.length - 1));

        try {
            return Integer.parseInt(intervals[index].trim());
        } catch (NumberFormatException e) {
            // 如果配置错误,使用默认值
            int[] defaultIntervals = { 1, 2, 4, 7, 15 };
            return defaultIntervals[Math.min(index, defaultIntervals.length - 1)];
        }
    }

    /**
     * 计算优先级
     * 
     * 规则:
     * 1. 超期时间越长,优先级越高
     * 2. 掌握度越低,优先级越高
     * 3. 难度越高,优先级越高
     * 
     * @param nextReviewTime 计划复习时间
     * @param masteryScore   掌握度评分
     * @param difficulty     题目难度(1-5)
     * @return 优先级(1-10)
     */
    public int calculatePriority(LocalDateTime nextReviewTime, BigDecimal masteryScore, int difficulty) {
        LocalDateTime now = LocalDateTime.now();

        // 计算超期天数
        long overdueDays = java.time.Duration.between(nextReviewTime, now).toDays();

        // 超期优先级: 每超期1天加1分,最多5分
        int overduePriority = (int) Math.min(5, Math.max(0, overdueDays));

        // 掌握度优先级: 掌握度越低优先级越高,最多3分
        int masteryPriority = (int) Math.max(0, 3 - masteryScore.doubleValue() / 30);

        // 难度优先级: 难度越高优先级越高,最多2分
        int difficultyPriority = (int) Math.min(2, difficulty / 2.5);

        // 总优先级(1-10)
        return Math.max(1, Math.min(10, overduePriority + masteryPriority + difficultyPriority));
    }
}
