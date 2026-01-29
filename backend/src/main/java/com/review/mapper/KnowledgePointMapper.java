package com.review.mapper;

import com.review.entity.KnowledgePoint;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

/**
 * 知识点Mapper接口
 */
@Mapper
public interface KnowledgePointMapper {

    /**
     * 插入知识点
     */
    int insert(KnowledgePoint knowledgePoint);

    /**
     * 批量插入知识点
     */
    int batchInsert(@Param("knowledgePoints") List<KnowledgePoint> knowledgePoints);

    /**
     * 查询用户的所有知识点
     */
    List<KnowledgePoint> findByUserId(@Param("userId") Long userId);

    /**
     * 根据ID查询知识点
     */
    KnowledgePoint findById(@Param("id") Long id);

    /**
     * 根据名称查询知识点
     */
    KnowledgePoint findByName(@Param("userId") Long userId, @Param("name") String name);

    /**
     * 更新知识点
     */
    int update(KnowledgePoint knowledgePoint);

    /**
     * 删除知识点
     */
    int deleteById(@Param("id") Long id);
}
