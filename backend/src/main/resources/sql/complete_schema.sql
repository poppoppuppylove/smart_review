-- ======================================================
-- 智能错题复习系统 - 完整数据库脚本
-- 基于艾宾浩斯遗忘曲线的智能学习系统
-- 包含题套系统功能
-- ======================================================

-- 创建数据库(如果需要)
CREATE DATABASE IF NOT EXISTS new_smart_review DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE new_smart_review;

-- MySQL dump 10.13  Distrib 5.7.43, for Linux (x86_64)
--
-- Host: localhost    Database: new_smart_review
-- ------------------------------------------------------
-- Server version	5.7.43-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `answer_record`
--

DROP TABLE IF EXISTS `answer_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `answer_record` (
                                 `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '记录ID',
                                 `user_id` bigint(20) NOT NULL COMMENT '用户ID',
                                 `question_id` bigint(20) NOT NULL COMMENT '题目ID',
                                 `user_answer` text COLLATE utf8mb4_unicode_ci COMMENT '用户答案',
                                 `is_correct` tinyint(1) NOT NULL COMMENT '是否正确:0-错误,1-正确',
                                 `time_spent` int(11) DEFAULT NULL COMMENT '答题耗时(秒)',
                                 `answer_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '答题时间',
                                 `review_count` int(11) DEFAULT '0' COMMENT '复习次数',
                                 `consecutive_correct` int(11) DEFAULT '0' COMMENT '连续正确次数',
                                 `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                                 `notes` text COLLATE utf8mb4_unicode_ci,
                                 `is_in_wrongbook` bit(1) DEFAULT b'1',
                                 `retry_count` int(11) DEFAULT '0',
                                 `subject` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '科目(冗余字段,便于错题分析)',
                                 `topic_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '知识点名称(冗余字段,便于错题分析)',
                                 PRIMARY KEY (`id`),
                                 KEY `idx_user_question` (`user_id`,`question_id`),
                                 KEY `idx_is_correct` (`is_correct`),
                                 KEY `idx_answer_time` (`answer_time`),
                                 KEY `question_id` (`question_id`),
                                 KEY `idx_subject` (`subject`),
                                 CONSTRAINT `answer_record_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
                                 CONSTRAINT `answer_record_ibfk_2` FOREIGN KEY (`question_id`) REFERENCES `question` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=67 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户答题记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `answer_record`
--

LOCK TABLES `answer_record` WRITE;
/*!40000 ALTER TABLE `answer_record` DISABLE KEYS */;
INSERT INTO `answer_record` VALUES (48,1,21,'-3',1,6,'2026-01-26 09:49:49',1,1,'2026-01-26 09:49:48',NULL,_binary '',0,NULL,NULL),(49,1,20,'C',1,40,'2026-01-26 09:50:31',1,1,'2026-01-26 09:50:30',NULL,_binary '',0,NULL,NULL),(50,4,22,'D',1,7,'2026-01-26 20:44:14',1,1,'2026-01-26 20:44:14',NULL,_binary '\0',0,'经济学','稀缺性'),(51,4,25,'B',1,7,'2026-01-26 20:56:36',1,1,'2026-01-26 20:56:36',NULL,_binary '\0',0,'语文','古诗文名句'),(52,4,24,'C',0,17,'2026-01-26 20:56:55',1,0,'2026-01-26 20:56:55',NULL,_binary '',1,'语文','古诗文名句'),(53,4,23,'C',1,8,'2026-01-26 20:57:05',1,1,'2026-01-26 20:57:05',NULL,_binary '\0',0,'语文','古诗文名句'),(54,4,24,'B',1,6,'2026-01-26 20:57:31',2,1,'2026-01-26 20:57:30',NULL,_binary '\0',0,'语文','古诗文名句'),(55,5,26,'我忘了',0,15,'2026-01-26 23:36:35',1,0,'2026-01-26 23:36:35','123\n',_binary '',1,'物理','动量的定义'),(56,7,28,'B',0,1,'2026-01-27 09:57:03',1,0,'2026-01-27 09:57:03',NULL,_binary '',1,'数学','求矩阵的秩'),(57,5,34,'我不知道',0,4,'2026-01-27 09:59:23',1,0,'2026-01-27 09:59:23',NULL,_binary '',1,'计算机','个人ACL访问权限'),(58,5,33,'个人',0,7,'2026-01-27 09:59:32',1,0,'2026-01-27 09:59:32',NULL,_binary '',1,'计算机','个人ACL访问权限'),(59,5,32,'正确',0,3,'2026-01-27 09:59:39',1,0,'2026-01-27 09:59:39',NULL,_binary '\0',1,'计算机','个人ACL访问权限'),(60,5,31,'A,B,C,D',0,6,'2026-01-27 10:00:07',1,0,'2026-01-27 10:00:06',NULL,_binary '',1,'计算机','个人ACL访问权限'),(61,5,30,'B',1,14,'2026-01-27 10:00:25',1,1,'2026-01-27 10:00:24',NULL,_binary '\0',0,'计算机','个人ACL访问权限'),(62,5,34,',',0,2,'2026-01-27 13:58:38',2,0,'2026-01-27 13:58:37',NULL,_binary '',2,'计算机','个人ACL访问权限'),(63,5,33,',',0,3,'2026-01-27 13:58:43',2,0,'2026-01-27 13:58:42',NULL,_binary '',2,'计算机','个人ACL访问权限'),(64,5,32,'正确',1,2,'2026-01-27 13:58:46',2,1,'2026-01-27 13:58:46',NULL,_binary '\0',0,'计算机','个人ACL访问权限'),(65,5,29,'A',0,18,'2026-01-27 18:26:08',1,0,'2026-01-27 18:26:07',NULL,_binary '',1,'数学','有理数的混合运算'),(66,5,26,'物理物理 云里雾里',0,34,'2026-01-27 18:27:16',2,0,'2026-01-27 18:27:15',NULL,_binary '',2,'物理','动量的定义');
/*!40000 ALTER TABLE `answer_record` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `knowledge_point`
--

DROP TABLE IF EXISTS `knowledge_point`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `knowledge_point` (
                                   `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '知识点ID',
                                   `user_id` bigint(20) NOT NULL COMMENT '用户ID',
                                   `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '知识点名称',
                                   `description` text COLLATE utf8mb4_unicode_ci COMMENT '知识点描述',
                                   `parent_id` bigint(20) DEFAULT '0' COMMENT '父知识点ID,0表示顶级',
                                   `level` int(11) DEFAULT '1' COMMENT '层级,1为顶级',
                                   `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                                   `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                                   `subject` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '所属科目(冗余字段,便于查询)',
                                   PRIMARY KEY (`id`),
                                   KEY `idx_user_id` (`user_id`),
                                   KEY `idx_parent_id` (`parent_id`),
                                   KEY `idx_subject` (`subject`),
                                   CONSTRAINT `knowledge_point_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='知识点表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `knowledge_point`
--

LOCK TABLES `knowledge_point` WRITE;
/*!40000 ALTER TABLE `knowledge_point` DISABLE KEYS */;
INSERT INTO `knowledge_point` VALUES (16,1,'数学-代数-一元一次方程',NULL,0,1,'2026-01-26 09:49:35','2026-01-26 09:49:35',NULL),(17,4,'稀缺性',NULL,0,1,'2026-01-26 20:43:46','2026-01-26 20:43:46','经济学'),(18,4,'古诗文名句',NULL,0,1,'2026-01-26 20:56:23','2026-01-26 20:56:23','语文'),(19,5,'动量的定义',NULL,0,1,'2026-01-26 23:36:01','2026-01-26 23:36:01','物理'),(20,7,'求矩阵的秩',NULL,0,1,'2026-01-27 09:27:19','2026-01-27 09:27:19','数学'),(21,5,'有理数的混合运算',NULL,0,1,'2026-01-27 09:38:10','2026-01-27 09:38:10','数学'),(22,5,'个人ACL访问权限',NULL,0,1,'2026-01-27 09:59:14','2026-01-27 09:59:14','计算机');
/*!40000 ALTER TABLE `knowledge_point` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `question`
--

DROP TABLE IF EXISTS `question`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `question` (
                            `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '题目ID',
                            `user_id` bigint(20) NOT NULL COMMENT '用户ID',
                            `knowledge_point_id` bigint(20) DEFAULT NULL COMMENT '知识点ID',
                            `type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '题目类型:single_choice,multiple_choice,true_false,fill_blank,essay',
                            `title` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '题干',
                            `options` longtext COLLATE utf8mb4_unicode_ci COMMENT '选项(JSON格式，后续业务手动序列化/反序列化)',
                            `correct_answer` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '正确答案',
                            `analysis` text COLLATE utf8mb4_unicode_ci COMMENT '答案解析',
                            `difficulty` int(11) DEFAULT '3' COMMENT '难度等级:1-5',
                            `tags` longtext COLLATE utf8mb4_unicode_ci COMMENT '标签(JSON格式，后续业务手动序列化/反序列化)',
                            `source` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '题目来源',
                            `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                            `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                            `subject` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '所属科目(冗余字段,便于查询)',
                            `topic_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '知识点名称(冗余字段,便于查询)',
                            PRIMARY KEY (`id`),
                            KEY `idx_user_id` (`user_id`),
                            KEY `idx_knowledge_point_id` (`knowledge_point_id`),
                            KEY `idx_difficulty` (`difficulty`),
                            KEY `idx_subject` (`subject`),
                            KEY `idx_topic_name` (`topic_name`),
                            CONSTRAINT `question_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
                            CONSTRAINT `question_ibfk_2` FOREIGN KEY (`knowledge_point_id`) REFERENCES `knowledge_point` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='题目表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `question`
--

LOCK TABLES `question` WRITE;
/*!40000 ALTER TABLE `question` DISABLE KEYS */;
INSERT INTO `question` VALUES (20,1,16,'single_choice','下列方程中，属于一元一次方程的是（）','[\"x² - 2x = 3\",\"x + 2y = 5\",\"2x - 6 = 0\",\"1/x + 1 = 2\"]','C','一元一次方程需满足三个条件：只含一个未知数、未知数的次数为1、是整式方程。A选项未知数次数为2，是一元二次方程；B选项含两个未知数，是二元一次方程；C选项符合一元一次方程的所有条件；D选项分母含未知数，是分式方程，非整式方程。',2,'[\"一元一次方程\",\"概念辨析\",\"方程分类\"]','待补充','2026-01-26 09:49:35','2026-01-26 09:49:35',NULL,NULL),(21,1,16,'fill_blank','一元一次方程3x + 9 = 0的解为x = ______',NULL,'-3','解该一元一次方程，先通过移项将常数项移到等号右侧，得3x = -9，再将未知数系数化为1，两边同时除以3，计算可得x = -3。',1,'[\"一元一次方程\",\"解方程\",\"基础运算\"]','待补充','2026-01-26 09:49:35','2026-01-26 09:49:35',NULL,NULL),(22,4,17,'single_choice','经济学中的\'稀缺性\'概念是指什么？','[\"资源是无限的\",\"资源是均匀分布的\",\"资源可以免费获得\",\"资源相对于需求是有限的\"]','D','经济学中的\'稀缺性\'是一个核心概念，它描述的是资源的基本经济问题。选项A、B、C描述的情况与\'稀缺性\'的定义相反，在现实中，资源通常是有限的、分布不均且有获取成本的。选项D准确地描述了\'稀缺性\'的本质：在任何时候，相对于人类无限的欲望和需求，用于满足这些需求的资源（如时间、金钱、原材料等）总是有限的，这种有限性就是稀缺性，它构成了经济学研究的基本出发点。',2,'[\"经济学概念\",\"稀缺性\"]','经济学基础教材','2026-01-26 20:43:47','2026-01-26 20:43:47','经济学',NULL),(23,4,18,'single_choice','以下《诗经》名句中，哪一项常用来形容对爱情的执着追求？','[\"关关雎鸠，在河之洲\",\"昔我往矣，杨柳依依\",\"窈窕淑女，君子好逑\",\"蒹葭苍苍，白露为霜\"]','C','《诗经》中，A项“关关雎鸠，在河之洲”是起兴之句；B项“昔我往矣，杨柳依依”表达的是离别之情和物是人非的感伤；D项“蒹葭苍苍，白露为霜”营造的是一种朦胧、求而不得的意境。而C项“窈窕淑女，君子好逑”直接表达了对美好女子的爱慕和追求，是形容执着追求爱情的典型名句。',3,'[\"古诗文\",\"文学常识\",\"诗经\"]','高考真题','2026-01-26 20:56:23','2026-01-26 20:56:23','语文',NULL),(24,4,18,'single_choice','组成DNA和RNA的核苷酸种类不同，主要取决于？','[\"磷酸的不同\",\"五碳糖的不同\",\"含氮碱基的不同\",\"连接方式的不同\"]','B','DNA的基本组成单位是脱氧核糖核苷酸，RNA的基本组成单位是核糖核苷酸。两者在磷酸和含氮碱基（A、G、C）上可能相同，但核心区别在于五碳糖：DNA含有脱氧核糖，RNA含有核糖。含氮碱基的区别（DNA有T，RNA有U）是结果，而根本原因是五碳糖的不同决定了核苷酸的种类名称和最终形成的核酸大分子类型。',2,'[\"分子生物学\",\"核酸\",\"DNA与RNA\"]','生物必修二','2026-01-26 20:56:23','2026-01-26 20:56:23','语文',NULL),(25,4,18,'single_choice','秦始皇为加强思想控制，接受了李斯的建议，实行了哪一政策？','[\"罢黜百家，独尊儒术\",\"焚书坑儒\",\"文字狱\",\"设立太学\"]','B','A项“罢黜百家，独尊儒术”是汉武帝时期的政策；C项“文字狱”在明清时期尤为盛行；D项“设立太学”是汉武帝时期推行儒学教育、培养人才的重要举措。题干明确指出是秦始皇时期，为加强思想控制而采纳李斯的建议，这正是历史上著名的“焚书坑儒”事件，目的是统一思想，巩固中央集权。',3,'[\"中国古代史\",\"秦朝\",\"思想控制\"]','高中历史教材','2026-01-26 20:56:23','2026-01-26 20:56:23','语文',NULL),(26,5,19,'fill_blank','动量的计算公式为？',NULL,'P=mv','动量是描述物体运动状态的物理量，其大小等于物体的质量与速度的乘积，公式表示为P=mv，其中P为动量，m为物体质量，v为物体的速度。',1,'[\"动量\",\"物理公式\",\"运动状态\"]','待补充','2026-01-26 23:36:01','2026-01-26 23:36:01','物理',NULL),(27,7,20,'待补充','待补充',NULL,'待补充','待补充',0,'[\"矩阵\",\"矩阵的秩\",\"线性代数\"]','待补充','2026-01-27 09:27:19','2026-01-27 09:27:19','数学',NULL),(28,7,20,'single_choice','已知矩阵 $A=\\begin{pmatrix}1 & 2 & 3 \\\\ 2 & 4 & 6 \\\\ 3 & 6 & 9\\end{pmatrix}$，则该矩阵的秩 $r(A)$ 为多少？','[\"1\",\"2\",\"3\",\"4\"]','A','对矩阵A进行初等行变换，将第2行减去第1行的2倍，第3行减去第1行的3倍，可得矩阵 $\\begin{pmatrix}1 & 2 & 3 \\\\ 0 & 0 & 0 \\\\ 0 & 0 & 0\\end{pmatrix}$。矩阵的秩等于其非零行的行数，因此该矩阵的秩为1。',2,'[\"矩阵\",\"矩阵的秩\",\"初等行变换\"]','线性代数教材必修','2026-01-27 09:28:19','2026-01-27 09:28:19','数学',NULL),(29,5,21,'multiple_choice','下列关于初一数学有理数混合运算的法则，说法正确的是哪些？','[\"运算顺序为先算乘方，再算乘除，最后算加减，有括号的先算括号里的（小括号→中括号→大括号）\",\"同号相加、相乘，结果均为正；异号相加、相乘，结果均为负\",\"除以一个数（0 除外），等于乘这个数的倒数\",\"运算时可随意调整运算顺序，只要结果正确即可\"]','A,C','逐一分析各选项：选项 A，有理数混合运算的核心顺序即为先乘方，再乘除，最后加减，有括号时按小括号→中括号→大括号的顺序计算，说法正确；选项 B，同号相加结果为正，但异号相加结果不一定为负（需看绝对值大小，如 3+(-2)=1），异号相乘结果为负，该选项说法错误；选项 C，除以一个不为 0 的数，等价于乘这个数的倒数，这是有理数除法的核心法则，说法正确；选项 D，有理数混合运算必须遵循固定运算顺序，不能随意调整，否则会导致结果错误，说法错误。因此正确答案为 A,C。',2,'[\"有理数\",\"混合运算\",\"初一数学\"]','初一数学核心知识点笔记','2026-01-27 09:38:10','2026-01-27 09:38:10','数学',NULL),(30,5,22,'single_choice','下列关于个人ACL访问权限的定义，说法正确的是？','[\"针对多个用户组成的组配置的批量资源访问规则集合\",\"针对单个用户/账号配置的细粒度资源访问规则集合，用于精准控制个体的操作范围与权限级别\",\"按预设角色为用户批量分配的通用权限规则\",\"无需单独配置，跟随用户所属组的权限自动生效的权限模式\"]','B','个人ACL（Access Control List，访问控制列表）访问权限的核心定义是针对单个用户/账号配置的细粒度资源访问规则集合，目的是精准控制某一个体对特定资源的操作范围与权限级别，属于“按人授权”模式。选项A描述的是组ACL权限，选项C描述的是角色权限（RBAC），选项D错误，个人ACL需单独配置，部分场景下会覆盖组权限，并非自动跟随组权限生效。',2,'[\"个人ACL\",\"权限定义\",\"计算机权限\"]','个人ACL访问权限笔记','2026-01-27 09:59:14','2026-01-27 09:59:14','计算机',NULL),(31,5,22,'multiple_choice','个人ACL访问权限的核心特点包括哪些？','[\"粒度极细，精准到单个用户+单个资源+单个操作\",\"针对性强，可补充角色/组授权的不足\",\"优先级高，多数系统中会覆盖角色/组的默认权限\",\"维护成本低，适合批量授权场景\"]','A,B,C','个人ACL的核心特点有三个：一是粒度极细，可精准控制单个用户对单个资源的单个操作；二是针对性强，能为有特殊需求的个人单独配置权限，解决角色/组授权无法覆盖的场景；三是优先级高，多数系统中特殊规则（个人ACL）优于通用规则（角色/组权限）。选项D错误，维护成本低、适合批量授权是组ACL/角色权限的特点，个人ACL因需单独为每个用户配置，维护成本较高。',2,'[\"个人ACL\",\"核心特点\",\"权限特性\"]','个人ACL访问权限笔记','2026-01-27 09:59:14','2026-01-27 09:59:14','计算机',NULL),(32,5,22,'true_false','在数据库/数据表场景中，个人ACL常见的权限项包括查（SELECT）、增（INSERT）、改（UPDATE）、删（DELETE）、建表等。',NULL,'对','根据笔记内容，不同资源类型的个人ACL权限项存在差异，其中数据库/数据表场景下，常见的个人ACL权限项就包括查（SELECT）、增（INSERT）、改（UPDATE）、删（DELETE）、建表等，用于精准控制单个用户对数据库表的操作权限，因此该表述正确。',1,'[\"个人ACL\",\"权限类型\",\"数据库权限\"]','个人ACL访问权限笔记','2026-01-27 09:59:14','2026-01-27 09:59:14','计算机',NULL),(33,5,22,'fill_blank','个人ACL访问权限的核心价值之一是满足________，仅给用户分配完成工作所需的最少权限，降低数据泄露/误操作风险。',NULL,'最小权限原则','笔记中明确提到，个人ACL的核心价值包括满足最小权限原则、适配个性化需求、精准管控权限，其中最小权限原则即仅给用户分配完成工作所需的最少权限，避免权限过剩导致的数据泄露或误操作风险，因此空白处应填写“最小权限原则”。',1,'[\"个人ACL\",\"核心价值\",\"最小权限原则\"]','个人ACL访问权限笔记','2026-01-27 09:59:14','2026-01-27 09:59:14','计算机',NULL),(34,5,22,'essay','简述个人ACL权限与组ACL/角色权限在授权对象、授权粒度两个维度的核心区别。',NULL,'1. 授权对象区别：个人ACL权限的授权对象是单个用户/账号；组ACL/角色权限的授权对象是多个用户组成的组或预设角色。2. 授权粒度区别：个人ACL权限的授权粒度为细粒度、个性化，可精准控制单个用户对单个资源的单个操作；组ACL/角色权限的授权粒度为粗粒度、标准化，适用于对多个用户批量分配统一权限。','答题核心需围绕“授权对象”和“授权粒度”两个指定维度展开，结合笔记中两者的区别表格作答：授权对象上，个人ACL针对单个用户，组ACL/角色针对组或预设角色；授权粒度上，个人ACL细粒度、个性化，组ACL/角色权限粗粒度、标准化，确保每个维度的区别描述准确、完整，贴合笔记内容。',3,'[\"个人ACL\",\"权限区别\",\"答题类\"]','个人ACL访问权限笔记','2026-01-27 09:59:14','2026-01-27 09:59:14','计算机',NULL);
/*!40000 ALTER TABLE `question` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `question_set`
--

DROP TABLE IF EXISTS `question_set`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `question_set` (
                                `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '题套ID',
                                `user_id` bigint(20) NOT NULL COMMENT '用户ID',
                                `name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '题套名称',
                                `description` text COLLATE utf8mb4_unicode_ci COMMENT '题套描述',
                                `subject` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '科目',
                                `knowledge_point_id` bigint(20) DEFAULT NULL COMMENT '知识点ID',
                                `total_questions` int(11) DEFAULT '0' COMMENT '总题目数',
                                `done_count` int(11) DEFAULT '0' COMMENT '已做题目数',
                                `correct_count` int(11) DEFAULT '0' COMMENT '正确题目数',
                                `wrong_count` int(11) DEFAULT '0' COMMENT '错误题目数',
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
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='题套表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `question_set`
--

LOCK TABLES `question_set` WRITE;
/*!40000 ALTER TABLE `question_set` DISABLE KEYS */;
INSERT INTO `question_set` VALUES (2,1,'题套-20260126-094935','数学-代数-一元一次方程的题目集合','数学-代数-一元一次方程',16,2,2,2,0,1,'2026-01-26 09:49:35','2026-01-26 09:51:12'),(3,4,'题套-20260126-204347','稀缺性的题目集合','稀缺性',17,1,1,1,0,1,'2026-01-26 20:43:47','2026-01-26 20:44:14'),(4,4,'题套-20260126-205623','古诗文名句的题目集合','古诗文名句',18,3,3,3,0,1,'2026-01-26 20:56:23','2026-01-26 20:57:30'),(5,5,'题套-20260126-233601','动量的定义的题目集合','动量的定义',19,1,1,0,1,0,'2026-01-26 23:36:01','2026-01-27 18:27:15'),(6,7,'题套-20260127-092720','求矩阵的秩的题目集合','求矩阵的秩',20,1,0,0,0,0,'2026-01-27 09:27:20','2026-01-27 09:27:20'),(7,7,'题套-20260127-092819','求矩阵的秩的题目集合','求矩阵的秩',20,1,1,0,1,0,'2026-01-27 09:28:19','2026-01-27 09:57:03'),(8,5,'题套-20260127-093810','有理数的混合运算的题目集合','有理数的混合运算',21,1,1,0,1,0,'2026-01-27 09:38:10','2026-01-27 18:26:07'),(9,5,'题套-20260127-095914','个人ACL访问权限的题目集合','个人ACL访问权限',22,5,5,2,3,0,'2026-01-27 09:59:14','2026-01-27 13:58:46');
/*!40000 ALTER TABLE `question_set` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `question_set_question`
--

DROP TABLE IF EXISTS `question_set_question`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `question_set_question` (
                                         `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '关联ID',
                                         `question_set_id` bigint(20) NOT NULL COMMENT '题套ID',
                                         `question_id` bigint(20) NOT NULL COMMENT '题目ID',
                                         `order_index` int(11) DEFAULT '0' COMMENT '题目在题套中的顺序',
                                         `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                                         PRIMARY KEY (`id`),
                                         UNIQUE KEY `uk_set_question` (`question_set_id`,`question_id`),
                                         KEY `idx_question_set_id` (`question_set_id`),
                                         KEY `idx_question_id` (`question_id`),
                                         CONSTRAINT `question_set_question_ibfk_1` FOREIGN KEY (`question_set_id`) REFERENCES `question_set` (`id`) ON DELETE CASCADE,
                                         CONSTRAINT `question_set_question_ibfk_2` FOREIGN KEY (`question_id`) REFERENCES `question` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='题目-题套关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `question_set_question`
--

LOCK TABLES `question_set_question` WRITE;
/*!40000 ALTER TABLE `question_set_question` DISABLE KEYS */;
INSERT INTO `question_set_question` VALUES (12,2,21,0,'2026-01-26 09:49:35'),(13,2,20,1,'2026-01-26 09:49:35'),(14,3,22,0,'2026-01-26 20:43:47'),(15,4,25,0,'2026-01-26 20:56:23'),(16,4,24,1,'2026-01-26 20:56:23'),(17,4,23,2,'2026-01-26 20:56:23'),(18,5,26,0,'2026-01-26 23:36:01'),(19,6,27,0,'2026-01-27 09:27:20'),(20,7,28,0,'2026-01-27 09:28:19'),(21,8,29,0,'2026-01-27 09:38:10'),(22,9,34,0,'2026-01-27 09:59:14'),(23,9,33,1,'2026-01-27 09:59:14'),(24,9,32,2,'2026-01-27 09:59:14'),(25,9,31,3,'2026-01-27 09:59:14'),(26,9,30,4,'2026-01-27 09:59:14');
/*!40000 ALTER TABLE `question_set_question` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `review_plan`
--

DROP TABLE IF EXISTS `review_plan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `review_plan` (
                               `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '计划ID',
                               `user_id` bigint(20) NOT NULL COMMENT '用户ID',
                               `question_id` bigint(20) NOT NULL COMMENT '题目ID',
                               `last_review_time` datetime DEFAULT NULL COMMENT '上次复习时间',
                               `next_review_time` datetime NOT NULL COMMENT '下次复习时间',
                               `review_level` int(11) DEFAULT '1' COMMENT '复习级别:1-5,对应艾宾浩斯曲线阶段',
                               `mastery_score` decimal(5,2) DEFAULT '0.00' COMMENT '掌握度评分:0-100',
                               `priority` int(11) DEFAULT '5' COMMENT '优先级:1-10,数字越大越优先',
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
) ENGINE=InnoDB AUTO_INCREMENT=67 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='复习计划表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `review_plan`
--

LOCK TABLES `review_plan` WRITE;
/*!40000 ALTER TABLE `review_plan` DISABLE KEYS */;
INSERT INTO `review_plan` VALUES (48,1,21,'2026-01-26 09:49:49','2026-01-26 09:49:49',2,100.00,1,0,'2026-01-26 09:49:48','2026-01-26 09:59:31'),(49,1,20,'2026-01-26 09:50:31','2026-01-28 09:50:31',2,100.00,1,0,'2026-01-26 09:50:30','2026-01-26 09:50:30'),(50,4,22,'2026-01-26 20:44:14','2026-01-28 20:44:14',2,100.00,1,0,'2026-01-26 20:44:14','2026-01-26 20:44:14'),(51,4,25,'2026-01-26 20:56:36','2026-01-28 20:56:36',2,100.00,1,0,'2026-01-26 20:56:36','2026-01-26 20:56:36'),(52,4,24,'2026-01-26 20:57:31','2026-01-28 20:57:31',2,100.00,1,0,'2026-01-26 20:56:55','2026-01-26 20:57:30'),(53,4,23,'2026-01-26 20:57:05','2026-01-28 20:57:05',2,100.00,1,0,'2026-01-26 20:57:05','2026-01-26 20:57:05'),(55,5,26,'2026-01-27 18:27:22','2026-01-29 18:27:22',2,100.00,1,0,'2026-01-26 23:36:35','2026-01-27 18:27:22'),(56,7,28,'2026-01-27 09:57:03','2026-01-28 09:57:03',1,40.00,1,0,'2026-01-27 09:57:03','2026-01-27 09:57:03'),(57,5,34,'2026-01-27 13:58:38','2026-01-28 13:58:38',1,40.00,2,0,'2026-01-27 09:59:23','2026-01-27 13:58:37'),(58,5,33,'2026-01-27 13:58:43','2026-01-28 13:58:43',1,40.00,1,0,'2026-01-27 09:59:32','2026-01-27 13:58:42'),(59,5,32,'2026-01-27 13:58:46','2026-01-29 13:58:46',2,100.00,1,0,'2026-01-27 09:59:39','2026-01-27 13:58:46'),(60,5,31,'2026-01-27 10:00:07','2026-01-28 10:00:07',1,40.00,1,0,'2026-01-27 10:00:06','2026-01-27 10:00:06'),(61,5,30,'2026-01-27 10:00:25','2026-01-29 10:00:25',2,100.00,1,0,'2026-01-27 10:00:24','2026-01-27 10:00:24'),(65,5,29,'2026-01-27 18:26:08','2026-01-28 18:26:08',1,40.00,1,0,'2026-01-27 18:26:07','2026-01-27 18:26:07');
/*!40000 ALTER TABLE `review_plan` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user` (
                        `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '用户ID',
                        `username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名',
                        `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '密码(加密)',
                        `nickname` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '昵称',
                        `email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '邮箱',
                        `avatar` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '头像URL',
                        `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                        `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                        PRIMARY KEY (`id`),
                        UNIQUE KEY `username` (`username`),
                        KEY `idx_username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,'test','test','测试用户','test@example.com',NULL,'2026-01-23 09:24:59','2026-01-23 09:24:59'),(4,'Zhx','zhx123456','Suan','',NULL,'2026-01-26 20:41:51','2026-01-26 20:41:51'),(5,'333','3333','333','',NULL,'2026-01-26 23:34:51','2026-01-26 23:34:51'),(6,'2827294239','g123456','妮妮','',NULL,'2026-01-27 01:38:50','2026-01-27 01:38:50'),(7,'wzy','123456','wzy','',NULL,'2026-01-27 09:23:20','2026-01-27 09:23:20');
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'new_smart_review'
--

--
-- Dumping routines for database 'new_smart_review'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-01-29 10:16:09
