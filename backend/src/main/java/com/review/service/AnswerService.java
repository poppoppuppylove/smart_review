package com.review.service;

import com.review.algorithm.EbbinghausAlgorithm;
import com.review.dto.AnswerSubmitDTO;
import com.review.entity.AnswerRecord;
import com.review.entity.Question;
import com.review.entity.ReviewPlan;
import com.review.mapper.AnswerRecordMapper;
import com.review.mapper.QuestionMapper;
import com.review.mapper.ReviewPlanMapper;
import com.review.mapper.QuestionSetQuestionMapper;
import com.review.service.QuestionSetService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 答题服务类
 */
@Service
public class AnswerService {

    @Autowired
    private AnswerRecordMapper answerRecordMapper;

    @Autowired
    private QuestionMapper questionMapper;

    @Autowired
    private ReviewPlanMapper reviewPlanMapper;

    @Autowired
    private EbbinghausAlgorithm ebbinghausAlgorithm;

    @Autowired
    private QuestionSetQuestionMapper questionSetQuestionMapper;

    @Autowired
    private QuestionSetService questionSetService;

    /**
     * 提交答案
     */
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> submitAnswer(Long userId, AnswerSubmitDTO submitDTO) {
        // 1. 查询题目
        Question question = questionMapper.findById(submitDTO.getQuestionId());
        if (question == null) {
            throw new RuntimeException("题目不存在");
        }

        // 2. 判断答案是否正确
        boolean isCorrect = checkAnswer(question.getCorrectAnswer(), submitDTO.getUserAnswer());

        // 3. 查询历史记录
        AnswerRecord lastRecord = answerRecordMapper.findLatestByUserAndQuestion(userId, submitDTO.getQuestionId());
        int reviewCount = lastRecord != null ? lastRecord.getReviewCount() + 1 : 1;
        int consecutiveCorrect = isCorrect
                ? (lastRecord != null && lastRecord.getIsCorrect() ? lastRecord.getConsecutiveCorrect() + 1 : 1)
                : 0;

        // 4. 保存答题记录
        AnswerRecord record = new AnswerRecord();
        record.setUserId(userId);
        record.setQuestionId(submitDTO.getQuestionId());
        record.setUserAnswer(submitDTO.getUserAnswer());
        record.setIsCorrect(isCorrect);
        record.setTimeSpent(submitDTO.getTimeSpent());
        record.setAnswerTime(LocalDateTime.now());
        record.setReviewCount(reviewCount);
        record.setConsecutiveCorrect(consecutiveCorrect);
        record.setRetryCount(!isCorrect ? (lastRecord != null ? lastRecord.getRetryCount() + 1 : 1) : 0);
        record.setNotes(null);
        record.setIsInWrongbook(!isCorrect); // 错题自动加入错题本
        record.setSubject(question.getSubject());
        record.setTopicName(question.getKnowledgePointName());
        record.setCreatedAt(LocalDateTime.now());
        answerRecordMapper.insert(record);

        // 5. 更新或创建复习计划
        updateReviewPlan(userId, question, isCorrect, submitDTO.getTimeSpent(), consecutiveCorrect);

        // 6. 更新题套统计信息
        java.util.List<Long> questionSetIds = questionSetQuestionMapper.selectQuestionSetIdsByQuestionId(question.getId());
        if (questionSetIds != null) {
            for (Long questionSetId : questionSetIds) {
                questionSetService.updateQuestionSetStatistics(questionSetId, userId);
            }
        }

        // 7. 返回结果
        Map<String, Object> result = new HashMap<>();
        result.put("isCorrect", isCorrect);
        result.put("correctAnswer", question.getCorrectAnswer());
        result.put("analysis", question.getAnalysis());
        result.put("reviewCount", reviewCount);
        result.put("consecutiveCorrect", consecutiveCorrect);

        return result;
    }

    /**
     * 检查答案是否正确
     */
    private boolean checkAnswer(String correctAnswer, String userAnswer) {
        if (correctAnswer == null || userAnswer == null) {
            return false;
        }

        // 规范化答案（处理判断题的多种表达方式）
        String normalizedCorrect = normalizeAnswer(correctAnswer.trim());
        String normalizedUser = normalizeAnswer(userAnswer.trim());

        // 转小写比较
        return normalizedCorrect.equalsIgnoreCase(normalizedUser);
    }

    /**
     * 规范化答案，统一判断题的多种表达方式
     * 将"对"、"正确"、"true"、"T"等统一为"true"
     * 将"错"、"错误"、"false"、"F"等统一为"false"
     */
    private String normalizeAnswer(String answer) {
        if (answer == null) {
            return "";
        }

        String normalized = answer.toLowerCase();

        // 判断为"真"的各种表达
        if (normalized.equals("对") || normalized.equals("正确") ||
            normalized.equals("true") || normalized.equals("t") ||
            normalized.equals("是") || normalized.equals("yes") ||
            normalized.equals("y")) {
            return "true";
        }

        // 判断为"假"的各种表达
        if (normalized.equals("错") || normalized.equals("错误") ||
            normalized.equals("false") || normalized.equals("f") ||
            normalized.equals("否") || normalized.equals("no") ||
            normalized.equals("n")) {
            return "false";
        }

        // 其他类型的答案保持原样
        return answer;
    }

    /**
     * 更新复习计划
     */
    private void updateReviewPlan(Long userId, Question question, boolean isCorrect,
            int timeSpent, int consecutiveCorrect) {
        // 查询现有复习计划
        ReviewPlan plan = reviewPlanMapper.findByUserAndQuestion(userId, question.getId());

        LocalDateTime now = LocalDateTime.now();
        int currentLevel = plan != null ? plan.getReviewLevel() : 1;

        // 计算掌握度
        BigDecimal masteryScore = ebbinghausAlgorithm.calculateMasteryScore(
                isCorrect, timeSpent, consecutiveCorrect);

        // 计算下次复习时间
        LocalDateTime nextReviewTime = ebbinghausAlgorithm.calculateNextReviewTime(
                now, currentLevel, isCorrect, timeSpent, consecutiveCorrect);

        // 计算新的复习级别
        int newLevel = isCorrect ? Math.min(5, currentLevel + 1) : 1;

        // 计算优先级
        int priority = ebbinghausAlgorithm.calculatePriority(
                nextReviewTime, masteryScore, question.getDifficulty());

        if (plan == null) {
            // 创建新计划
            plan = new ReviewPlan();
            plan.setUserId(userId);
            plan.setQuestionId(question.getId());
        }

        plan.setLastReviewTime(now);
        plan.setNextReviewTime(nextReviewTime);
        plan.setReviewLevel(newLevel);
        plan.setMasteryScore(masteryScore);
        plan.setPriority(priority);
        plan.setIsCompleted(false);

        reviewPlanMapper.insertOrUpdate(plan);
    }

    /**
     * 查询错题
     */
    public List<AnswerRecord> getWrongAnswers(Long userId) {
        return answerRecordMapper.findWrongAnswersDeduplicated(userId);
    }

    /**
     * 更新笔记
     */
    public void updateNotes(Long recordId, String notes) {
        answerRecordMapper.updateNotes(recordId, notes);
    }

    /**
     * 移出错题本
     */
    public void removeFromWrongBook(Long recordId) {
        answerRecordMapper.updateIsInWrongbook(recordId, false);
    }

    /**
     * 查询答题历史
     */
    public List<Map<String, Object>> getAnswerHistory(Long userId) {
        return answerRecordMapper.findByUserIdOrderByAnswerTimeDescWithQuestion(userId);
    }

    /**
     * 查询答题统计
     */
    public Map<String, Object> getStatistics(Long userId) {
        int totalCount = answerRecordMapper.countByUserId(userId);
        int correctCount = answerRecordMapper.countCorrectByUserId(userId);

        Map<String, Object> stats = new HashMap<>();
        stats.put("totalCount", totalCount);
        stats.put("correctCount", correctCount);
        stats.put("wrongCount", totalCount - correctCount);
        stats.put("accuracy", totalCount > 0 ? (correctCount * 100.0 / totalCount) : 0);

        return stats;
    }
}
