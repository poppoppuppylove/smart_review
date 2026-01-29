package com.review.mapper;

import com.review.entity.QuestionSetQuestion;
import com.review.entity.Question;
import org.apache.ibatis.annotations.*;

import java.util.List;

/**
 * 题目-题套关联Mapper接口
 */
public interface QuestionSetQuestionMapper {

    /**
     * 添加题目到题套
     */
    @Insert("INSERT INTO question_set_question(question_set_id, question_id, order_index) " +
            "VALUES(#{questionSetId}, #{questionId}, #{orderIndex})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(QuestionSetQuestion questionSetQuestion);

    /**
     * 批量添加题目到题套
     */
    @Insert("<script>" +
            "INSERT INTO question_set_question(question_set_id, question_id, order_index) VALUES " +
            "<foreach collection='list' item='item' separator=','>" +
            "(#{item.questionSetId}, #{item.questionId}, #{item.orderIndex})" +
            "</foreach>" +
            "</script>")
    int insertBatch(@Param("list") List<QuestionSetQuestion> list);

    /**
     * 查询题套下的所有题目
     */
    @Select("SELECT q.* FROM question q " +
            "INNER JOIN question_set_question qsq ON q.id = qsq.question_id " +
            "WHERE qsq.question_set_id = #{questionSetId} " +
            "ORDER BY qsq.order_index")
    List<Question> selectQuestionsBySetId(Long questionSetId);

    /**
     * 查询题套下的未完成题目
     */
    @Select("SELECT q.* FROM question q " +
            "INNER JOIN question_set_question qsq ON q.id = qsq.question_id " +
            "WHERE qsq.question_set_id = #{questionSetId} " +
            "AND q.id NOT IN (" +
            "  SELECT ar.question_id FROM answer_record ar " +
            "  WHERE ar.user_id = #{userId} AND ar.question_id = q.id AND ar.is_correct = 1" +
            ") " +
            "ORDER BY qsq.order_index")
    List<Question> selectUnfinishedQuestions(@Param("questionSetId") Long questionSetId, @Param("userId") Long userId);

    /**
     * 删除题套下的所有题目关联
     */
    @Delete("DELETE FROM question_set_question WHERE question_set_id = #{questionSetId}")
    int deleteBySetId(Long questionSetId);

    /**
     * 统计题套下的题目数量
     */
    @Select("SELECT COUNT(*) FROM question_set_question WHERE question_set_id = #{questionSetId}")
    int countQuestions(Long questionSetId);

    /**
     * 统计题套下用户已做的题目数量
     */
    @Select("SELECT COUNT(DISTINCT qsq.question_id) FROM question_set_question qsq " +
            "INNER JOIN answer_record ar ON qsq.question_id = ar.question_id " +
            "WHERE qsq.question_set_id = #{questionSetId} AND ar.user_id = #{userId}")
    int countDoneQuestions(@Param("questionSetId") Long questionSetId, @Param("userId") Long userId);

    /**
     * 统计题套下用户答对的题目数量
     */
    @Select("SELECT COUNT(DISTINCT qsq.question_id) FROM question_set_question qsq " +
            "INNER JOIN answer_record ar ON qsq.question_id = ar.question_id " +
            "WHERE qsq.question_set_id = #{questionSetId} AND ar.user_id = #{userId} AND ar.is_correct = 1")
    int countCorrectQuestions(@Param("questionSetId") Long questionSetId, @Param("userId") Long userId);

    /**
     * 查询题目所属的题套ID列表
     */
    @Select("SELECT question_set_id FROM question_set_question WHERE question_id = #{questionId}")
    List<Long> selectQuestionSetIdsByQuestionId(Long questionId);

    /**
     * 删除题目与题套的关联
     */
    @Delete("DELETE FROM question_set_question WHERE question_id = #{questionId}")
    int deleteByQuestionId(Long questionId);
}