package com.review.entity;

import lombok.Data;
import java.time.LocalDateTime;

/**
 * 知识点实体类
 */
@Data
public class KnowledgePoint {
    private Long id;
    private Long userId;
    private String name;
    private String description;
    private Long parentId;
    private Integer level;
    private String subject;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
