package com.review.mapper;

import com.review.entity.ReviewPlan;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 复习计划Mapper接口
 */
@Mapper
public interface ReviewPlanMapper {

    /**
     * 插入复习计划
     */
    int insert(ReviewPlan plan);

    /**
     * 插入或更新复习计划
     */
    int insertOrUpdate(ReviewPlan plan);

    /**
     * 查询用户的待复习题目(按优先级排序)
     */
    List<ReviewPlan> findPendingReviews(@Param("userId") Long userId, @Param("currentTime") LocalDateTime currentTime);

    /**
     * 查询用户的所有复习计划
     */
    List<ReviewPlan> findByUserId(@Param("userId") Long userId);

    /**
     * 根据ID查询复习计划
     */
    ReviewPlan findById(@Param("id") Long id);

    /**
     * 根据用户和题目查询复习计划
     */
    ReviewPlan findByUserAndQuestion(@Param("userId") Long userId, @Param("questionId") Long questionId);

    /**
     * 更新复习计划
     */
    int update(ReviewPlan plan);

    /**
     * 删除复习计划
     */
    int delete(@Param("id") Long id);

    /**
     * 删除复习计划
     */
    int deleteById(@Param("id") Long id);
}
