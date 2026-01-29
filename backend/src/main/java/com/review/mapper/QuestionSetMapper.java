package com.review.mapper;

import com.review.entity.QuestionSet;
import org.apache.ibatis.annotations.*;

import java.util.List;

/**
 * 题套Mapper接口
 */
public interface QuestionSetMapper {

    /**
     * 创建题套
     */
    @Insert("INSERT INTO question_set(user_id, name, description, subject, knowledge_point_id, total_questions) " +
            "VALUES(#{userId}, #{name}, #{description}, #{subject}, #{knowledgePointId}, #{totalQuestions})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(QuestionSet questionSet);

    /**
     * 根据ID查询题套
     */
    @Select("SELECT * FROM question_set WHERE id = #{id}")
    QuestionSet selectById(Long id);

    /**
     * 查询用户的所有题套
     */
    @Select("SELECT * FROM question_set WHERE user_id = #{userId} ORDER BY created_at DESC")
    List<QuestionSet> selectByUserId(Long userId);

    /**
     * 更新题套统计信息
     */
    @Update("UPDATE question_set SET total_questions = #{totalQuestions}, done_count = #{doneCount}, correct_count = #{correctCount}, " +
            "wrong_count = #{wrongCount}, is_finished = #{isFinished}, updated_at = NOW() WHERE id = #{id}")
    int updateStatistics(QuestionSet questionSet);

    /**
     * 更新题套完成状态
     */
    @Update("UPDATE question_set SET is_finished = #{isFinished}, updated_at = NOW() WHERE id = #{id}")
    int updateFinishedStatus(@Param("id") Long id, @Param("isFinished") Boolean isFinished);

    /**
     * 更新题套
     */
    @Update("UPDATE question_set SET name = #{name}, description = #{description}, updated_at = NOW() WHERE id = #{id}")
    int update(QuestionSet questionSet);

    /**
     * 删除题套
     */
    @Delete("DELETE FROM question_set WHERE id = #{id}")
    int deleteById(Long id);
}