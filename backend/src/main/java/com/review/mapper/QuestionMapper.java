package com.review.mapper;

import com.review.entity.Question;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

/**
 * 题目Mapper接口
 */
@Mapper
public interface QuestionMapper {

    /**
     * 批量插入题目
     */
    int batchInsert(@Param("questions") List<Question> questions);

    /**
     * 根据用户ID查询所有题目
     */
    List<Question> findByUserId(@Param("userId") Long userId);

    /**
     * 根据ID查询题目
     */
    Question findById(@Param("id") Long id);

    /**
     * 根据知识点ID查询题目
     */
    List<Question> findByKnowledgePointId(@Param("knowledgePointId") Long knowledgePointId);

    /**
     * 根据难度查询题目
     */
    List<Question> findByDifficulty(@Param("userId") Long userId, @Param("difficulty") Integer difficulty);

    /**
     * 更新题目
     */
    int update(Question question);

    /**
     * 删除题目
     */
    int deleteById(@Param("id") Long id);

    /**
     * 查询最近插入的N道题目
     */
    List<Question> findLatestQuestions(@Param("userId") Long userId,
                                       @Param("knowledgePointId") Long knowledgePointId,
                                       @Param("limit") int limit);
}
