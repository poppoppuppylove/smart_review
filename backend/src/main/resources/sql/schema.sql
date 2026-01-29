-- ======================================================
-- 智能错题复习系统 - 数据库初始化脚本 (完整版)
-- 基于艾宾浩斯遗忘曲线的智能学习系统
-- ======================================================

-- 创建数据库(如果需要)
CREATE DATABASE IF NOT EXISTS smart_review DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE smart_review;

-- ======================================================
-- 用户表 (User)
-- ======================================================
CREATE TABLE IF NOT EXISTS `user` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
    `username` VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名(登录用)',
    `password` VARCHAR(255) NOT NULL COMMENT '密码(BCrypt加密)',
    `nickname` VARCHAR(50) COMMENT '昵称(显示用)',
    `email` VARCHAR(100) COMMENT '邮箱',
    `avatar` VARCHAR(255) COMMENT '头像URL',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX `idx_username` (`username`),
    INDEX `idx_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- ======================================================
-- 知识点表 (KnowledgePoint)
-- 支持树形层级结构,便于组织学习内容
-- ======================================================
-- new_smart_review.knowledge_point definition

CREATE TABLE `knowledge_point` (
                                   `id` bigint NOT NULL AUTO_INCREMENT COMMENT '知识点ID',
                                   `user_id` bigint NOT NULL COMMENT '用户ID',
                                   `name` varchar(100) NOT NULL COMMENT '知识点名称',
                                   `description` text COMMENT '知识点描述',
                                   `parent_id` bigint DEFAULT '0' COMMENT '父知识点ID,0表示顶级',
                                   `level` int DEFAULT '1' COMMENT '层级,1为顶级',
                                   `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                                   `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                                   PRIMARY KEY (`id`),
                                   KEY `idx_user_id` (`user_id`),
                                   KEY `idx_parent_id` (`parent_id`),
                                   CONSTRAINT `knowledge_point_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='知识点表';

-- ======================================================
-- 题目表 (Question)
-- 支持多种题型:单选、多选、判断、填空、问答
-- ======================================================
-- new_smart_review.question definition

CREATE TABLE `question` (
                            `id` bigint NOT NULL AUTO_INCREMENT COMMENT '题目ID',
                            `user_id` bigint NOT NULL COMMENT '用户ID',
                            `knowledge_point_id` bigint DEFAULT NULL COMMENT '知识点ID',
                            `type` varchar(20) NOT NULL COMMENT '题目类型:single_choice,multiple_choice,true_false,fill_blank,essay',
                            `title` text NOT NULL COMMENT '题干',
                            `options` json DEFAULT NULL COMMENT '选项(JSON数组)',
                            `correct_answer` text NOT NULL COMMENT '正确答案',
                            `analysis` text COMMENT '答案解析',
                            `difficulty` int DEFAULT '3' COMMENT '难度等级:1-5',
                            `tags` json DEFAULT NULL COMMENT '标签(JSON数组)',
                            `source` varchar(100) DEFAULT NULL COMMENT '题目来源',
                            `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                            `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                            PRIMARY KEY (`id`),
                            KEY `idx_user_id` (`user_id`),
                            KEY `idx_knowledge_point_id` (`knowledge_point_id`),
                            KEY `idx_difficulty` (`difficulty`),
                            CONSTRAINT `question_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
                            CONSTRAINT `question_ibfk_2` FOREIGN KEY (`knowledge_point_id`) REFERENCES `knowledge_point` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='题目表';

-- ======================================================
-- 用户答题记录表 (AnswerRecord)
-- 记录每次答题的详细信息,用于学习分析
-- ======================================================
-- new_smart_review.answer_record definition

CREATE TABLE `answer_record` (
                                 `id` bigint NOT NULL AUTO_INCREMENT COMMENT '记录ID',
                                 `user_id` bigint NOT NULL COMMENT '用户ID',
                                 `question_id` bigint NOT NULL COMMENT '题目ID',
                                 `user_answer` text COMMENT '用户答案',
                                 `is_correct` tinyint(1) NOT NULL COMMENT '是否正确:0-错误,1-正确',
                                 `time_spent` int DEFAULT NULL COMMENT '答题耗时(秒)',
                                 `answer_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '答题时间',
                                 `review_count` int DEFAULT '0' COMMENT '复习次数',
                                 `consecutive_correct` int DEFAULT '0' COMMENT '连续正确次数',
                                 `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                                 `notes` text COMMENT '用户笔记备注',
                                 `is_in_wrongbook` tinyint(1) DEFAULT '1' COMMENT '是否在错题本中(0=移除,1=保留)',
                                 `retry_count` int DEFAULT '0',
                                 PRIMARY KEY (`id`),
                                 KEY `idx_user_question` (`user_id`,`question_id`),
                                 KEY `idx_is_correct` (`is_correct`),
                                 KEY `idx_answer_time` (`answer_time`),
                                 KEY `question_id` (`question_id`),
                                 CONSTRAINT `answer_record_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
                                 CONSTRAINT `answer_record_ibfk_2` FOREIGN KEY (`question_id`) REFERENCES `question` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户答题记录表';

-- ======================================================
-- 复习计划表 (ReviewPlan)
-- 基于艾宾浩斯遗忘曲线的智能复习调度
-- ======================================================
CREATE TABLE IF NOT EXISTS `review_plan` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '计划ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `question_id` BIGINT NOT NULL COMMENT '题目ID',
    `last_review_time` DATETIME COMMENT '上次复习时间',
    `next_review_time` DATETIME NOT NULL COMMENT '下次复习时间',
    `review_level` INT DEFAULT 1 COMMENT '复习级别(1-5):对应艾宾浩斯曲线阶段',
    `mastery_score` DECIMAL(5,2) DEFAULT 0.00 COMMENT '掌握度评分(0-100)',
    `priority` INT DEFAULT 5 COMMENT '优先级(1-10):数字越大越优先',
    `is_completed` TINYINT(1) DEFAULT 0 COMMENT '是否完成(0=未完成,1=已完成)',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY `uk_user_question` (`user_id`, `question_id`),
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_question_id` (`question_id`),
    INDEX `idx_next_review_time` (`next_review_time`),
    INDEX `idx_priority` (`priority`),
    INDEX `idx_is_completed` (`is_completed`),
    INDEX `idx_mastery_score` (`mastery_score`),
    FOREIGN KEY (`user_id`) REFERENCES `user`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`question_id`) REFERENCES `question`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='复习计划表(基于艾宾浩斯曲线)';

-- ======================================================
-- 初始化测试数据
-- ======================================================

-- 插入测试用户
INSERT IGNORE INTO `user` (`username`, `password`, `nickname`, `email`)
VALUES ('test', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '测试用户', 'test@example.com');

-- 获取测试用户ID(用于后续插入)
SET @test_user_id = (SELECT `id` FROM `user` WHERE `username` = 'test' LIMIT 1);

-- 插入示例知识点
INSERT IGNORE INTO `knowledge_point` (`user_id`, `name`, `subject`, `description`, `parent_id`, `level`)
VALUES
    (@test_user_id, '高等数学', '数学', '大学数学核心课程', 0, 1),
    (@test_user_id, '物理学', '物理', '经典物理与现代物理', 0, 1),
    (@test_user_id, '英语', '英语', '英语语法与词汇', 0, 1);

-- 获取知识点ID
SET @math_id = (SELECT `id` FROM `knowledge_point` WHERE `name` = '高等数学' AND `user_id` = @test_user_id LIMIT 1);
SET @physics_id = (SELECT `id` FROM `knowledge_point` WHERE `name` = '物理学' AND `user_id` = @test_user_id LIMIT 1);

-- 插入二级知识点
INSERT IGNORE INTO `knowledge_point` (`user_id`, `name`, `subject`, `description`, `parent_id`, `level`)
VALUES
    (@test_user_id, '微积分', '数学', '导数与积分', @math_id, 2),
    (@test_user_id, '线性代数', '数学', '矩阵与向量', @math_id, 2),
    (@test_user_id, '力学', '物理', '经典力学基础', @physics_id, 2);

-- 插入示例题目
SET @calculus_id = (SELECT `id` FROM `knowledge_point` WHERE `name` = '微积分' AND `user_id` = @test_user_id LIMIT 1);

INSERT IGNORE INTO `question` (`user_id`, `knowledge_point_id`, `type`, `title`, `options`, `correct_answer`, `analysis`, `difficulty`, `tags`, `source`)
VALUES
    (@test_user_id, @calculus_id, 'single_choice', '函数f(x)=x²的导数是?',
     JSON_ARRAY('2x', 'x', 'x²', '2'),
     'A',
     '根据幂函数求导法则:(xⁿ)\'=nxⁿ⁻¹,所以(x²)\'=2x¹=2x',
     2,
     JSON_ARRAY('导数', '基本求导', '幂函数'),
     '高等数学教材第3章'),

    (@test_user_id, @calculus_id, 'multiple_choice', '以下哪些是可导函数?',
     JSON_ARRAY('f(x)=x²', 'f(x)=|x|', 'f(x)=sin(x)', 'f(x)=1/x'),
     'A,C,D',
     'x²、sin(x)、1/x在其定义域内处处可导;|x|在x=0处不可导',
     3,
     JSON_ARRAY('可导性', '函数性质'),
     '习题集'),

    (@test_user_id, @calculus_id, 'fill_blank', '∫x dx = ____',
     NULL,
     'x²/2 + C',
     '根据不定积分定义,x的原函数是x²/2,加上积分常数C',
     2,
     JSON_ARRAY('不定积分', '基本积分'),
     '教材例题');

-- ======================================================
-- 视图定义(可选,便于查询)
-- ======================================================

-- 用户学习统计视图
CREATE OR REPLACE VIEW `v_user_statistics` AS
SELECT
    u.id AS user_id,
    u.username,
    COUNT(DISTINCT ar.question_id) AS total_answered,
    SUM(CASE WHEN ar.is_correct = 1 THEN 1 ELSE 0 END) AS correct_count,
    SUM(CASE WHEN ar.is_correct = 0 THEN 1 ELSE 0 END) AS wrong_count,
    ROUND(AVG(CASE WHEN ar.is_correct = 1 THEN 100 ELSE 0 END), 2) AS accuracy_rate,
    COUNT(DISTINCT rp.question_id) AS review_plan_count,
    SUM(CASE WHEN rp.is_completed = 0 THEN 1 ELSE 0 END) AS pending_review_count
FROM `user` u
LEFT JOIN `answer_record` ar ON u.id = ar.user_id
LEFT JOIN `review_plan` rp ON u.id = rp.user_id
GROUP BY u.id, u.username;

-- 题目统计视图
CREATE OR REPLACE VIEW `v_question_statistics` AS
SELECT
    q.id AS question_id,
    q.title,
    q.type,
    q.difficulty,
    kp.name AS knowledge_point_name,
    kp.subject,
    COUNT(ar.id) AS attempt_count,
    SUM(CASE WHEN ar.is_correct = 1 THEN 1 ELSE 0 END) AS correct_count,
    ROUND(AVG(CASE WHEN ar.is_correct = 1 THEN 100 ELSE 0 END), 2) AS accuracy_rate,
    AVG(ar.time_spent) AS avg_time_spent
FROM `question` q
LEFT JOIN `knowledge_point` kp ON q.knowledge_point_id = kp.id
LEFT JOIN `answer_record` ar ON q.id = ar.question_id
GROUP BY q.id, q.title, q.type, q.difficulty, kp.name, kp.subject;

-- 错题统计视图(按科目和知识点)
CREATE OR REPLACE VIEW `v_wrong_analysis` AS
SELECT
    ar.user_id,
    ar.subject,
    ar.topic_name,
    k.id AS knowledge_point_id,
    k.description AS knowledge_point_description,
    COUNT(*) AS wrong_count,
    COUNT(DISTINCT ar.question_id) AS distinct_wrong_questions,
    COUNT(CASE WHEN ar.retry_count > 0 THEN 1 END) AS retried_count,
    AVG(ar.time_spent) AS avg_time_wrong,
    MIN(ar.answer_time) AS first_wrong_time,
    MAX(ar.answer_time) AS last_wrong_time
FROM `answer_record` ar
LEFT JOIN `knowledge_point` k ON ar.knowledge_point_id = k.id
WHERE ar.is_correct = 0
GROUP BY ar.user_id, ar.subject, ar.topic_name, k.id, k.description
ORDER BY wrong_count DESC;

-- ======================================================
-- 存储过程(可选,用于复杂业务逻辑)
-- ======================================================

DELIMITER //

-- 计算下次复习时间(基于艾宾浩斯曲线)
CREATE PROCEDURE IF NOT EXISTS `sp_calculate_next_review`(
    IN p_review_level INT,
    OUT p_interval_days INT
)
BEGIN
    -- 艾宾浩斯间隔:1天、2天、4天、7天、15天
    CASE p_review_level
        WHEN 1 THEN SET p_interval_days = 1;
        WHEN 2 THEN SET p_interval_days = 2;
        WHEN 3 THEN SET p_interval_days = 4;
        WHEN 4 THEN SET p_interval_days = 7;
        WHEN 5 THEN SET p_interval_days = 15;
        ELSE SET p_interval_days = 1;
    END CASE;
END //

DELIMITER ;

-- ======================================================
-- 数据库优化建议
-- ======================================================
-- 1. 定期分析表:ANALYZE TABLE table_name;
-- 2. 定期优化表:OPTIMIZE TABLE table_name;
-- 3. 监控慢查询日志
-- 4. 考虑对大表进行分区(按时间分区answer_record)
-- 5. 定期备份数据库

-- ======================================================
-- 完成
-- ======================================================
-- 数据库初始化完成!
-- 默认测试账号: test / test (密码为BCrypt加密后的"test")