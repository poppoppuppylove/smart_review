package com.review.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.review.entity.QuestionSet;
import com.review.entity.QuestionSetQuestion;
import com.review.entity.Question;
import com.review.mapper.QuestionSetMapper;
import com.review.mapper.QuestionSetQuestionMapper;
import com.review.mapper.QuestionMapper;
import com.review.mapper.AnswerRecordMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 题套服务类
 */
@Service
public class QuestionSetService {

    @Autowired
    private QuestionSetMapper questionSetMapper;

    @Autowired
    private QuestionSetQuestionMapper questionSetQuestionMapper;

    @Autowired
    private QuestionMapper questionMapper;

    @Autowired
    private AnswerRecordMapper answerRecordMapper;

    @Autowired
    private ObjectMapper objectMapper;

    /**
     * 创建题套
     */
    @Transactional(rollbackFor = Exception.class)
    public QuestionSet createQuestionSet(Long userId, String name, String description, String subject, Long knowledgePointId) {
        QuestionSet questionSet = new QuestionSet();
        questionSet.setUserId(userId);
        questionSet.setName(name);
        questionSet.setDescription(description);
        questionSet.setSubject(subject);
        questionSet.setKnowledgePointId(knowledgePointId);
        questionSet.setTotalQuestions(0);
        questionSetMapper.insert(questionSet);
        return questionSet;
    }

    /**
     * 将题目添加到题套
     */
    @Transactional(rollbackFor = Exception.class)
    public void addQuestionsToSet(Long questionSetId, List<Long> questionIds) {
        for (int i = 0; i < questionIds.size(); i++) {
            QuestionSetQuestion qsQuestion = new QuestionSetQuestion();
            qsQuestion.setQuestionSetId(questionSetId);
            qsQuestion.setQuestionId(questionIds.get(i));
            qsQuestion.setOrderIndex(i);
            questionSetQuestionMapper.insert(qsQuestion);
        }

        // 更新题套的总题目数
        QuestionSet questionSet = questionSetMapper.selectById(questionSetId);
        if (questionSet != null) {
            questionSet.setTotalQuestions(questionSetQuestionMapper.countQuestions(questionSetId));
            // 更新统计信息（这里暂时只更新总数）
            questionSetMapper.updateStatistics(questionSet);
        }
    }

    /**
     * 获取用户的所有题套
     */
    public List<QuestionSet> getUserQuestionSets(Long userId) {
        if (userId == null) {
            return List.of(); // 返回空列表
        }
        return questionSetMapper.selectByUserId(userId);
    }

    /**
     * 获取题套下的题目
     */
    public List<Question> getQuestionsBySetId(Long questionSetId) {
        List<Question> questions = questionSetQuestionMapper.selectQuestionsBySetId(questionSetId);
        // 解析JSON字段
        for (Question question : questions) {
            parseJsonFields(question);
        }
        return questions;
    }

    /**
     * 获取题套下的未完成题目（未答对的题目）
     */
    public List<Question> getUnfinishedQuestions(Long questionSetId, Long userId) {
        // 如果userId为null或0，返回所有题目
        if (userId == null || userId == 0L) {
            return getQuestionsBySetId(questionSetId);
        }
        List<Question> questions = questionSetQuestionMapper.selectUnfinishedQuestions(questionSetId, userId);
        // 解析JSON字段
        for (Question question : questions) {
            parseJsonFields(question);
        }
        return questions;
    }

    /**
     * 根据ID获取题套
     */
    public QuestionSet getQuestionSetById(Long id) {
        return questionSetMapper.selectById(id);
    }

    /**
     * 更新题套
     */
    @Transactional(rollbackFor = Exception.class)
    public QuestionSet updateQuestionSet(Long id, Long userId, String name, String description) {
        QuestionSet questionSet = questionSetMapper.selectById(id);
        if (questionSet == null || !userId.equals(questionSet.getUserId())) {
            return null;
        }

        if (name != null && !name.trim().isEmpty()) {
            questionSet.setName(name.trim());
        }

        if (description != null) {
            questionSet.setDescription(description.trim());
        }

        questionSetMapper.update(questionSet);
        return questionSet;
    }

    /**
     * 解析题目的JSON字段
     */
    private void parseJsonFields(Question question) {
        if (question.getOptions() != null && !question.getOptions().isEmpty()) {
            try {
                question.setOptionsList(objectMapper.readValue(question.getOptions(), List.class));
            } catch (JsonProcessingException e) {
                // 解析失败时保持空列表
                question.setOptionsList(null);
            }
        }
        if (question.getTags() != null && !question.getTags().isEmpty()) {
            try {
                question.setTagsList(objectMapper.readValue(question.getTags(), List.class));
            } catch (JsonProcessingException e) {
                // 解析失败时保持空列表
                question.setTagsList(null);
            }
        }
    }

    /**
     * 更新题套统计信息
     */
    @Transactional(rollbackFor = Exception.class)
    public void updateQuestionSetStatistics(Long questionSetId, Long userId) {
        QuestionSet questionSet = questionSetMapper.selectById(questionSetId);
        if (questionSet != null) {
            // 查询题套下的所有题目数量
            int totalQuestions = questionSetQuestionMapper.countQuestions(questionSetId);

            // 查询用户在该题套下已做的题目数量（有答题记录的题目）
            int doneCount = questionSetQuestionMapper.countDoneQuestions(questionSetId, userId);

            // 查询用户在该题套下答对的题目数量
            int correctCount = questionSetQuestionMapper.countCorrectQuestions(questionSetId, userId);

            // 计算错误题目数量
            int wrongCount = doneCount - correctCount;

            // 判断是否完成（所有题目都答对）
            boolean isFinished = (correctCount == totalQuestions) && (totalQuestions > 0);

            // 更新题套统计信息
            questionSet.setTotalQuestions(totalQuestions);
            questionSet.setDoneCount(doneCount);
            questionSet.setCorrectCount(correctCount);
            questionSet.setWrongCount(wrongCount);
            questionSet.setIsFinished(isFinished);

            questionSetMapper.updateStatistics(questionSet);
        }
    }
}