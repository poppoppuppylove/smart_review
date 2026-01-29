package com.review.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.review.dto.QuestionImportDTO;
import com.review.entity.KnowledgePoint;
import com.review.entity.Question;
import com.review.entity.QuestionSet;
import com.review.mapper.KnowledgePointMapper;
import com.review.mapper.QuestionMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * 题目服务类
 */
@Service
public class QuestionService {

    @Autowired
    private QuestionMapper questionMapper;

    @Autowired
    private KnowledgePointMapper knowledgePointMapper;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private QuestionSetService questionSetService;

    /**
     * 批量导入题目
     */
    @Transactional(rollbackFor = Exception.class)
    public int importQuestions(Long userId, QuestionImportDTO importDTO) throws JsonProcessingException {
        // 1. 处理知识点
        Long knowledgePointId = null;
        if (importDTO.getKnowledgePoint() != null && !importDTO.getKnowledgePoint().isEmpty()) {
            KnowledgePoint kp = knowledgePointMapper.findByName(userId, importDTO.getKnowledgePoint());
            if (kp == null) {
                // 创建新知识点
                kp = new KnowledgePoint();
                kp.setUserId(userId);
                kp.setName(importDTO.getKnowledgePoint());
                kp.setParentId(0L);
                kp.setLevel(1);
                kp.setSubject(importDTO.getSubject());
                knowledgePointMapper.insert(kp);
            }
            knowledgePointId = kp.getId();
        }

        // 2. 转换并插入题目
        List<Question> questions = new ArrayList<>();
        for (QuestionImportDTO.QuestionDTO dto : importDTO.getQuestions()) {
            Question question = new Question();
            question.setUserId(userId);
            question.setKnowledgePointId(knowledgePointId);
            question.setType(dto.getType());
            question.setTitle(dto.getTitle());
            question.setCorrectAnswer(dto.getCorrectAnswer());
            question.setAnalysis(dto.getAnalysis());
            question.setDifficulty(dto.getDifficulty() != null ? dto.getDifficulty() : 3);
            question.setSource(dto.getSource());
            question.setSubject(importDTO.getSubject());

            // 转换选项为JSON
            if (dto.getOptions() != null && !dto.getOptions().isEmpty()) {
                question.setOptions(objectMapper.writeValueAsString(dto.getOptions()));
            }

            // 转换标签为JSON
            if (dto.getTags() != null && !dto.getTags().isEmpty()) {
                question.setTags(objectMapper.writeValueAsString(dto.getTags()));
            }

            questions.add(question);
        }

        // 批量插入
        if (!questions.isEmpty()) {
            int insertedCount = questionMapper.batchInsert(questions);

            // 创建题套
            String setName = "题套-" + new SimpleDateFormat("yyyyMMdd-HHmmss").format(new Date());
            QuestionSet questionSet = questionSetService.createQuestionSet(
                userId,
                setName,
                importDTO.getKnowledgePoint() + "的题目集合",
                importDTO.getKnowledgePoint(),
                knowledgePointId
            );

            // 由于MyBatis批量插入可能无法返回所有ID，需要重新查询
            // 根据用户ID和知识点查询最近插入的N道题目
            List<Question> insertedQuestions = questionMapper.findLatestQuestions(userId, knowledgePointId, insertedCount);

            // 提取插入的题目ID
            List<Long> questionIds = new ArrayList<>();
            for (Question q : insertedQuestions) {
                if (q.getId() != null) {
                    questionIds.add(q.getId());
                }
            }

            // 将题目关联到题套
            if (!questionIds.isEmpty()) {
                questionSetService.addQuestionsToSet(questionSet.getId(), questionIds);
            }

            return insertedCount;
        }

        return 0;
    }

    /**
     * 查询用户的所有题目
     */
    public List<Question> getUserQuestions(Long userId) throws JsonProcessingException {
        List<Question> questions = questionMapper.findByUserId(userId);

        // 解析JSON字段
        for (Question question : questions) {
            parseJsonFields(question);
        }

        return questions;
    }

    /**
     * 根据ID查询题目
     */
    public Question getQuestionById(Long id) throws JsonProcessingException {
        Question question = questionMapper.findById(id);
        if (question != null) {
            parseJsonFields(question);
        }
        return question;
    }

    /**
     * 解析题目的JSON字段
     */
    private void parseJsonFields(Question question) throws JsonProcessingException {
        if (question.getOptions() != null && !question.getOptions().isEmpty()) {
            question.setOptionsList(objectMapper.readValue(question.getOptions(), List.class));
        }
        if (question.getTags() != null && !question.getTags().isEmpty()) {
            question.setTagsList(objectMapper.readValue(question.getTags(), List.class));
        }
    }
}
