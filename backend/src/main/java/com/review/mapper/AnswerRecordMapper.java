package com.review.mapper;

import com.review.entity.AnswerRecord;
import java.util.Map;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

/**
 * 答题记录Mapper接口
 */
@Mapper
public interface AnswerRecordMapper {

    /**
     * 插入答题记录
     */
    int insert(AnswerRecord record);

    /**
     * 查询用户的所有答题记录
     */
    List<AnswerRecord> findByUserId(@Param("userId") Long userId);

    /**
     * 查询用户的错题记录（去重，每道题只显示最新的错误记录）
     */
    List<AnswerRecord> findWrongAnswersDeduplicated(@Param("userId") Long userId);

    /**
     * 查询用户的错题记录
     */
    List<AnswerRecord> findWrongAnswers(@Param("userId") Long userId);

    /**
     * 查询用户某题的最新答题记录
     */
    AnswerRecord findLatestByUserAndQuestion(@Param("userId") Long userId, @Param("questionId") Long questionId);

    /**
     * 查询用户某题的所有答题记录
     */
    List<AnswerRecord> findByUserAndQuestion(@Param("userId") Long userId, @Param("questionId") Long questionId);

    /**
     * 统计用户答题数据
     */
    int countByUserId(@Param("userId") Long userId);

    /**
     * 统计用户正确答题数
     */
    int countCorrectByUserId(@Param("userId") Long userId);

    /**
     * 查询用户的所有答题记录（按答题时间倒序,包含题目信息）
     */
    List<Map<String, Object>> findByUserIdOrderByAnswerTimeDescWithQuestion(@Param("userId") Long userId);

    /**
     * 查询用户的所有答题记录（按答题时间倒序）
     */
    List<AnswerRecord> findByUserIdOrderByAnswerTimeDesc(@Param("userId") Long userId);

    /**
     * 更新笔记
     */
    int updateNotes(@Param("id") Long id, @Param("notes") String notes);

    /**
     * 更新是否在错题本中
     */
    int updateIsInWrongbook(@Param("id") Long id, @Param("isInWrongbook") Boolean isInWrongbook);
}
