CREATE DATABASE IF NOT EXISTS new_smart_review DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE new_smart_review;
-- new_smart_review.`user` definition
CREATE TABLE `user` (
                        `id` bigint NOT NULL AUTO_INCREMENT COMMENT '用户ID',
                        `username` varchar(50) NOT NULL COMMENT '用户名',
                        `password` varchar(255) NOT NULL COMMENT '密码(加密)',
                        `nickname` varchar(50) DEFAULT NULL COMMENT '昵称',
                        `email` varchar(100) DEFAULT NULL COMMENT '邮箱',
                        `avatar` varchar(255) DEFAULT NULL COMMENT '头像URL',
                        `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                        `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                        PRIMARY KEY (`id`),
                        UNIQUE KEY `username` (`username`),
                        KEY `idx_username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

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
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='知识点表';

-- new_smart_review.question definition（额外优化：json字段替换为longtext，兼容低版本MySQL）
CREATE TABLE `question` (
                            `id` bigint NOT NULL AUTO_INCREMENT COMMENT '题目ID',
                            `user_id` bigint NOT NULL COMMENT '用户ID',
                            `knowledge_point_id` bigint DEFAULT NULL COMMENT '知识点ID',
                            `type` varchar(20) NOT NULL COMMENT '题目类型:single_choice,multiple_choice,true_false,fill_blank,essay',
                            `title` text NOT NULL COMMENT '题干',
                            `options` longtext DEFAULT NULL COMMENT '选项(JSON格式，后续业务手动序列化/反序列化)',
                            `correct_answer` text NOT NULL COMMENT '正确答案',
                            `analysis` text COMMENT '答案解析',
                            `difficulty` int DEFAULT '3' COMMENT '难度等级:1-5',
                            `tags` longtext DEFAULT NULL COMMENT '标签(JSON格式，后续业务手动序列化/反序列化)',
                            `source` varchar(100) DEFAULT NULL COMMENT '题目来源',
                            `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                            `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                            PRIMARY KEY (`id`),
                            KEY `idx_user_id` (`user_id`),
                            KEY `idx_knowledge_point_id` (`knowledge_point_id`),
                            KEY `idx_difficulty` (`difficulty`),
                            CONSTRAINT `question_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
                            CONSTRAINT `question_ibfk_2` FOREIGN KEY (`knowledge_point_id`) REFERENCES `knowledge_point` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='题目表';

-- new_smart_review.question_set definition
CREATE TABLE `question_set` (
                                `id` bigint NOT NULL AUTO_INCREMENT COMMENT '题套ID',
                                `user_id` bigint NOT NULL COMMENT '用户ID',
                                `name` varchar(200) NOT NULL COMMENT '题套名称',
                                `description` text COMMENT '题套描述',
                                `subject` varchar(50) DEFAULT NULL COMMENT '科目',
                                `knowledge_point_id` bigint DEFAULT NULL COMMENT '知识点ID',
                                `total_questions` int DEFAULT '0' COMMENT '总题目数',
                                `done_count` int DEFAULT '0' COMMENT '已做题目数',
                                `correct_count` int DEFAULT '0' COMMENT '正确题目数',
                                `wrong_count` int DEFAULT '0' COMMENT '错误题目数',
                                `is_finished` tinyint(1) DEFAULT '0' COMMENT '是否完成(0=未完成,1=已完成)',
                                `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                                `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                                PRIMARY KEY (`id`),
                                KEY `idx_user_id` (`user_id`),
                                KEY `idx_subject` (`subject`),
                                KEY `idx_knowledge_point_id` (`knowledge_point_id`),
                                KEY `idx_created_at` (`created_at`),
                                KEY `idx_is_finished` (`is_finished`),
                                CONSTRAINT `question_set_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
                                CONSTRAINT `question_set_ibfk_2` FOREIGN KEY (`knowledge_point_id`) REFERENCES `knowledge_point` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='题套表';

-- new_smart_review.question_set_question definition
CREATE TABLE `question_set_question` (
                                         `id` bigint NOT NULL AUTO_INCREMENT COMMENT '关联ID',
                                         `question_set_id` bigint NOT NULL COMMENT '题套ID',
                                         `question_id` bigint NOT NULL COMMENT '题目ID',
                                         `order_index` int DEFAULT '0' COMMENT '题目在题套中的顺序',
                                         `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                                         PRIMARY KEY (`id`),
                                         UNIQUE KEY `uk_set_question` (`question_set_id`,`question_id`),
                                         KEY `idx_question_set_id` (`question_set_id`),
                                         KEY `idx_question_id` (`question_id`),
                                         CONSTRAINT `question_set_question_ibfk_1` FOREIGN KEY (`question_set_id`) REFERENCES `question_set` (`id`) ON DELETE CASCADE,
                                         CONSTRAINT `question_set_question_ibfk_2` FOREIGN KEY (`question_id`) REFERENCES `question` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='题目-题套关联表';

-- new_smart_review.review_plan definition
CREATE TABLE `review_plan` (
                               `id` bigint NOT NULL AUTO_INCREMENT COMMENT '计划ID',
                               `user_id` bigint NOT NULL COMMENT '用户ID',
                               `question_id` bigint NOT NULL COMMENT '题目ID',
                               `last_review_time` datetime DEFAULT NULL COMMENT '上次复习时间',
                               `next_review_time` datetime NOT NULL COMMENT '下次复习时间',
                               `review_level` int DEFAULT '1' COMMENT '复习级别:1-5,对应艾宾浩斯曲线阶段',
                               `mastery_score` decimal(5,2) DEFAULT '0.00' COMMENT '掌握度评分:0-100',
                               `priority` int DEFAULT '5' COMMENT '优先级:1-10,数字越大越优先',
                               `is_completed` tinyint(1) DEFAULT '0' COMMENT '是否完成:0-未完成,1-已完成',
                               `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                               `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                               PRIMARY KEY (`id`),
                               UNIQUE KEY `uk_user_question` (`user_id`,`question_id`),
                               KEY `idx_next_review_time` (`next_review_time`),
                               KEY `idx_priority` (`priority`),
                               KEY `idx_is_completed` (`is_completed`),
                               KEY `question_id` (`question_id`),
                               CONSTRAINT `review_plan_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
                               CONSTRAINT `review_plan_ibfk_2` FOREIGN KEY (`question_id`) REFERENCES `question` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=48 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='复习计划表';

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
                                 PRIMARY KEY (`id`),
                                 KEY `idx_user_question` (`user_id`,`question_id`),
                                 KEY `idx_is_correct` (`is_correct`),
                                 KEY `idx_answer_time` (`answer_time`),
                                 KEY `question_id` (`question_id`),
                                 CONSTRAINT `answer_record_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
                                 CONSTRAINT `answer_record_ibfk_2` FOREIGN KEY (`question_id`) REFERENCES `question` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=48 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户答题记录表';

-- new_smart_review.v_question_set_statistics source
create or replace
algorithm = UNDEFINED view `v_question_set_statistics` as
select
    `qs`.`id` as `question_set_id`,
    `qs`.`name` as `question_set_name`,
    `qs`.`description` as `description`,
    `qs`.`subject` as `subject`,
    `qs`.`user_id` as `user_id`,
    `u`.`username` as `username`,
    `kp`.`name` as `knowledge_point_name`,
    count(`qsq`.`question_id`) as `total_questions`,
    sum((case when (`ar`.`question_id` is not null) then 1 else 0 end)) as `done_count`,
    sum((case when (`ar`.`is_correct` = 1) then 1 else 0 end)) as `correct_count`,
    sum((case when (`ar`.`is_correct` = 0) then 1 else 0 end)) as `wrong_count`,
    (case
         when (sum((case when (`ar`.`question_id` is not null) then 1 else 0 end)) = 0) then 0
         else round(((sum((case when (`ar`.`is_correct` = 1) then 1 else 0 end)) * 100.0) / sum((case when (`ar`.`question_id` is not null) then 1 else 0 end))), 2)
        end) as `correct_rate`,
    max(`ar`.`answer_time`) as `last_answer_time`,
    `qs`.`is_finished` as `is_finished`,
    `qs`.`created_at` as `created_at`,
    `qs`.`updated_at` as `updated_at`
from
    ((((`question_set` `qs`
        left join `user` `u` on
        ((`qs`.`user_id` = `u`.`id`)))
        left join `knowledge_point` `kp` on
        ((`qs`.`knowledge_point_id` = `kp`.`id`)))
        left join `question_set_question` `qsq` on
        ((`qs`.`id` = `qsq`.`question_set_id`)))
        left join `answer_record` `ar` on
        (((`qsq`.`question_id` = `ar`.`question_id`) and (`ar`.`user_id` = `qs`.`user_id`))))
group by
    `qs`.`id`,
    `qs`.`name`,
    `qs`.`description`,
    `qs`.`subject`,
    `qs`.`user_id`,
    `u`.`username`,
    `kp`.`name`,
    `qs`.`is_finished`,
    `qs`.`created_at`,
    `qs`.`updated_at`
order by
    `qs`.`updated_at` desc;

-- new_smart_review.v_user_statistics source
create or replace
algorithm = UNDEFINED view `v_user_statistics` as
select
    `u`.`id` as `user_id`,
    `u`.`username` as `username`,
    count(distinct `ar`.`question_id`) as `total_answered`,
    sum((case when (`ar`.`is_correct` = 1) then 1 else 0 end)) as `correct_count`,
    sum((case when (`ar`.`is_correct` = 0) then 1 else 0 end)) as `wrong_count`,
    round(avg((case when (`ar`.`is_correct` = 1) then 100 else 0 end)), 2) as `accuracy_rate`,
    count(distinct `rp`.`question_id`) as `review_plan_count`,
    sum((case when (`rp`.`is_completed` = 0) then 1 else 0 end)) as `pending_review_count`
from
    ((`user` `u`
        left join `answer_record` `ar` on
        ((`u`.`id` = `ar`.`user_id`)))
        left join `review_plan` `rp` on
        ((`u`.`id` = `rp`.`user_id`)))
group by
    `u`.`id`,
    `u`.`username`;
-- 更新 answer_record 表结构，添加新字段（如果不存在）
-- 执行前请根据实际情况调整表名

-- 添加 notes 字段（用户笔记）
ALTER TABLE answer_record ADD COLUMN IF NOT EXISTS notes TEXT COMMENT '用户笔记备注';

-- 添加 is_in_wrongbook 字段（是否在错题本中）
ALTER TABLE answer_record ADD COLUMN IF NOT EXISTS is_in_wrongbook TINYINT(1) DEFAULT 1 COMMENT '是否在错题本中: 0-移除, 1-保留';

-- 确保现有数据默认值
UPDATE answer_record SET is_in_wrongbook = 1 WHERE is_in_wrongbook IS NULL;
UPDATE answer_record SET notes = '' WHERE notes IS NULL;

-- 对于已有的错题，设置为保留在错题本中
UPDATE answer_record SET is_in_wrongbook = 1 WHERE is_correct = 0;

-- 添加索引以提高查询性能
CREATE INDEX IF NOT EXISTS idx_answer_record_user_question ON answer_record(user_id, question_id);
CREATE INDEX IF NOT EXISTS idx_answer_record_user_wrong ON answer_record(user_id, is_correct, is_in_wrongbook);
CREATE INDEX IF NOT EXISTS idx_answer_record_answer_time ON answer_record(answer_time);