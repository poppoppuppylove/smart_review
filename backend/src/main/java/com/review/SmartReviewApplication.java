package com.review;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * 智能错题复习系统 - 主启动类
 * 
 * @author Smart Review Team
 * @version 1.0.0
 */
@SpringBootApplication
@MapperScan("com.review.mapper")
public class SmartReviewApplication {
    
    public static void main(String[] args) {
        SpringApplication.run(SmartReviewApplication.class, args);
        System.out.println("\n========================================");
        System.out.println("智能错题复习系统启动成功!");
        System.out.println("访问地址: http://localhost:8080");
        System.out.println("========================================\n");
    }
}
