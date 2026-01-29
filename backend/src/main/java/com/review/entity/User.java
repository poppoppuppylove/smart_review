package com.review.entity;

import lombok.Data;
import java.time.LocalDateTime;

/**
 * 用户实体类
 */
@Data
public class User {
    private Long id;
    private String username;
    private String password;
    private String nickname;
    private String email;
    private String avatar;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
