-- 智能错题复习系统数据库初始化脚本

-- 创建数据库（如果使用MySQL）
-- CREATE DATABASE IF NOT EXISTS smart_review CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 使用数据库
-- USE smart_review;

-- 用户表
CREATE TABLE IF NOT EXISTS users (
                                     id VARCHAR(36) PRIMARY KEY COMMENT '主键，UUID',
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    email VARCHAR(100) NOT NULL UNIQUE COMMENT '邮箱',
    password_hash VARCHAR(255) NOT NULL COMMENT '密码哈希',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_username (username),
    INDEX idx_email (email)
    ) COMMENT '用户表';

-- 知识点表
CREATE TABLE IF NOT EXISTS topics (
                                      id VARCHAR(36) PRIMARY KEY COMMENT '主键，UUID',
    name VARCHAR(100) NOT NULL COMMENT '知识点名称',
    subject VARCHAR(50) NOT NULL COMMENT '所属科目',
    description TEXT COMMENT '描述',
    parent_id VARCHAR(36) COMMENT '父知识点ID',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_subject (subject),
    INDEX idx_parent_id (parent_id)
    ) COMMENT '知识点表';

-- 题目表
CREATE TABLE IF NOT EXISTS questions (
                                         id VARCHAR(36) PRIMARY KEY COMMENT '主键，UUID',
    content TEXT NOT NULL COMMENT '题干内容',
    type VARCHAR(20) NOT NULL COMMENT '题型(choice/fill/short/calculation)',
    options TEXT COMMENT '选项(选择题JSON数组)',
    answer TEXT NOT NULL COMMENT '正确答案',
    explanation TEXT NOT NULL COMMENT '解析',
    difficulty INT NOT NULL COMMENT '难度等级(1-5)',
    subject VARCHAR(50) NOT NULL COMMENT '科目',
    topic_id VARCHAR(36) NOT NULL COMMENT '知识点ID',
    topic VARCHAR(100) COMMENT '知识点名称',
    tags TEXT COMMENT '标签数组(JSON)',
    source_id VARCHAR(36) COMMENT '来源ID',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_subject (subject),
    INDEX idx_topic_id (topic_id),
    INDEX idx_topic (topic),
    INDEX idx_difficulty (difficulty),
    INDEX idx_created_at (created_at)
    ) COMMENT '题目表';

-- 用户答题记录表
CREATE TABLE IF NOT EXISTS review_records (
                                              id VARCHAR(36) PRIMARY KEY COMMENT '主键，UUID',
    user_id VARCHAR(36) NOT NULL COMMENT '用户ID',
    question_id VARCHAR(36) NOT NULL COMMENT '题目ID',
    is_correct BOOLEAN NOT NULL COMMENT '是否正确',
    user_answer TEXT NOT NULL COMMENT '用户答案',
    time_spent INT NOT NULL COMMENT '用时(秒)',
    confidence_level INT NOT NULL COMMENT '信心等级(1-3)',
    notes TEXT COMMENT '用户笔记',
    reviewed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '答题时间',
    INDEX idx_user_id (user_id),
    INDEX idx_question_id (question_id),
    INDEX idx_reviewed_at (reviewed_at),
    INDEX idx_is_correct (is_correct)
    ) COMMENT '用户答题记录表';

-- 复习计划表（艾宾浩斯）
CREATE TABLE IF NOT EXISTS review_items (
                                            id VARCHAR(36) PRIMARY KEY COMMENT '主键，UUID',
    user_id VARCHAR(36) NOT NULL COMMENT '用户ID',
    question_id VARCHAR(36) NOT NULL COMMENT '题目ID',
    review_count INT NOT NULL DEFAULT 0 COMMENT '复习次数',
    correct_count INT NOT NULL DEFAULT 0 COMMENT '正确次数',
    incorrect_count INT NOT NULL DEFAULT 0 COMMENT '错误次数',
    mastery_level INT NOT NULL DEFAULT 0 COMMENT '熟练度(0-100)',
    next_review_date DATETIME NOT NULL COMMENT '下次复习日期',
    last_review_date DATETIME COMMENT '上次复习日期',
    review_history TEXT COMMENT '复习历史记录(JSON)',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_user_id (user_id),
    INDEX idx_question_id (question_id),
    INDEX idx_next_review_date (next_review_date),
    INDEX idx_mastery_level (mastery_level)
    ) COMMENT '复习计划表';

-- 错题本表
CREATE TABLE IF NOT EXISTS error_notebooks (
                                               id VARCHAR(36) PRIMARY KEY COMMENT '主键，UUID',
    user_id VARCHAR(36) NOT NULL COMMENT '用户ID',
    name VARCHAR(100) NOT NULL COMMENT '错题本名称',
    description TEXT COMMENT '描述',
    question_count INT NOT NULL DEFAULT 0 COMMENT '题目数量',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_user_id (user_id),
    INDEX idx_name (name)
    ) COMMENT '错题本表';

-- 错题本题目关联表
CREATE TABLE IF NOT EXISTS notebook_items (
                                              id VARCHAR(36) PRIMARY KEY COMMENT '主键，UUID',
    notebook_id VARCHAR(36) NOT NULL COMMENT '错题本ID',
    question_id VARCHAR(36) NOT NULL COMMENT '题目ID',
    added_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
    added_from VARCHAR(20) NOT NULL COMMENT '添加来源(wrong_answer/manual/low_mastery)',
    reason TEXT COMMENT '添加原因',
    custom_note TEXT COMMENT '自定义笔记',
    INDEX idx_notebook_id (notebook_id),
    INDEX idx_question_id (question_id),
    INDEX idx_added_at (added_at)
    ) COMMENT '错题本题目关联表';

-- 插入初始数据
-- 默认用户（用于演示）
INSERT IGNORE INTO users (id, username, email, password_hash)
VALUES ('user_default', 'default_user', 'default@example.com', 'default_hash');

-- 示例知识点
INSERT IGNORE INTO topics (id, name, subject, description)
VALUES
('topic_math_1', '不定积分', '高等数学', '不定积分的基本概念和计算方法'),
('topic_math_2', '定积分', '高等数学', '定积分的定义、性质和应用'),
('topic_phys_1', '力学', '物理', '经典力学基本概念和定律');