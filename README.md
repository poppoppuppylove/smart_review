<div align="center">
  <h1>Smart Review 智能错题复习系统</h1>

  <!-- 徽章行统一间距，视觉更整齐 -->
  <div style="display: flex; justify-content: center; gap: 8px; flex-wrap: wrap; margin: 16px 0;">
    <img src="https://img.shields.io/badge/Smart%20Review-v1.0-6C5CE7?style=for-the-badge" alt="Smart Review Logo">
    <img src="https://img.shields.io/badge/Spring%20Boot-3.2.0-6DB33F?style=for-the-badge&logo=springboot" alt="Spring Boot">
    <img src="https://img.shields.io/badge/Vue-3.4-4FC08D?style=for-the-badge&logo=vue.js" alt="Vue 3">
    <img src="https://img.shields.io/badge/MyBatis-3.0.3-DC382D?style=for-the-badge" alt="MyBatis">
    <img src="https://img.shields.io/badge/MySQL-8.0-4479A1?style=for-the-badge&logo=mysql&logoColor=white" alt="MySQL">
  </div>

  <!-- 标语增强字体和间距，突出主题 -->
  <p style="font-size: 14px; color: #666; line-height: 1.6; margin: 8px 0; font-weight: 500;">
    基于艾宾浩斯遗忘曲线的智能错题复习系统
  </p>
  <p style="font-size: 12px; color: #888; margin: 0 0 24px 0;">
    科学记忆 · 智能复习 · 高效学习
  </p>
</div>

---

## 目录

1. [项目简介](#-项目简介)
2. [核心特性](#-核心特性)
3. [技术栈](#-技术栈)
4. [项目结构](#-项目结构)
5. [使用指南](#-使用指南)
6. [核心功能说明](#-核心功能说明)

---

## 项目简介

**Smart Review System** 是一个基于艾宾浩斯遗忘曲线的智能错题复习系统，采用"前端驱动+超级提示词"架构。用户可以通过AI工具（如ChatGPT、Claude等）将学习笔记转化为结构化的JSON题目数据，导入系统后进行科学化的智能复习。

### 设计理念

- **科学记忆**：基于艾宾浩斯遗忘曲线算法，在最佳时间点提醒复习
- **智能调度**：根据答题表现动态调整复习计划
- **简单易用**：通过AI工具快速将笔记转化为题目，无需手动录入
- **数据驱动**：详细的学习数据统计，帮助优化学习策略

### 适用场景

- 学生考试复习
- 职业资格考试备考
- 日常知识巩固
- 错题本管理

---

## 核心特性

### 智能复习算法

- **艾宾浩斯遗忘曲线**：科学的复习时间间隔（1天 → 2天 → 4天 → 7天 → 15天）
- **智能评分系统**：综合考虑答题正确率（60%）和答题耗时（40%）
- **动态优先级**：根据超期时间、掌握度、题目难度自动计算优先级
- **连续正确加成**：连续答对可延长复习间隔

### 题目管理

- **多题型支持**：选择题、填空题、简答题、计算题
- **AI辅助导入**：通过超级提示词快速将笔记转化为题目
- **知识点分类**：支持科目、知识点、标签多维度分类
- **题目集管理**：可创建专题题目集进行针对性练习

### 学习追踪

- **错题本**：自动记录所有答错的题目
- **复习计划**：基于遗忘曲线生成个性化复习计划
- **答题记录**：详细记录每次答题的时间、耗时、正确率
- **掌握度评估**：实时评估对每道题目的掌握程度

### 数据统计

- **总体统计**：总答题数、正确率、平均耗时
- **科目统计**：按科目查看学习情况
- **知识点分析**：识别薄弱知识点
- **趋势分析**：学习进度和掌握度变化趋势

---

## 🛠 技术栈

### 后端技术栈

| 技术 | 版本 | 说明 |
|------|------|------|
| Spring Boot | 3.2.0 | 核心框架 |
| MyBatis | 3.0.3 | ORM框架 |
| MySQL | 8.0+ | 数据库 |
| Lombok | - | 简化实体类 |
| Jackson | - | JSON处理 |
| Validation | - | 数据校验 |

**核心算法：**
- 艾宾浩斯遗忘曲线算法
- 掌握度评分算法
- 优先级计算算法

### 前端技术栈

| 技术 | 版本 | 说明 |
|------|------|------|
| Vue 3 | 3.4.0 | 核心框架 |
| Vue Router | 4.2.5 | 路由管理 |
| Element Plus | 2.5.0 | UI组件库 |
| Axios | 1.6.2 | HTTP客户端 |
| Vite | 5.0.0 | 构建工具 |

---

## 项目结构

```
review/
├── backend/                          # 后端项目
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/com/review/
│   │   │   │   ├── algorithm/        # 算法模块
│   │   │   │   │   └── EbbinghausAlgorithm.java  # 艾宾浩斯算法
│   │   │   │   ├── config/           # 配置类
│   │   │   │   │   └── CorsConfig.java
│   │   │   │   ├── controller/       # 控制器层
│   │   │   │   │   ├── AnswerController.java
│   │   │   │   │   ├── QuestionController.java
│   │   │   │   │   ├── QuestionSetController.java
│   │   │   │   │   ├── ReviewPlanController.java
│   │   │   │   │   └── UserController.java
│   │   │   │   ├── dto/              # 数据传输对象
│   │   │   │   │   ├── AnswerSubmitDTO.java
│   │   │   │   │   ├── QuestionImportDTO.java
│   │   │   │   │   └── Result.java
│   │   │   │   ├── entity/           # 实体类
│   │   │   │   │   ├── AnswerRecord.java
│   │   │   │   │   ├── KnowledgePoint.java
│   │   │   │   │   ├── Question.java
│   │   │   │   │   ├── QuestionSet.java
│   │   │   │   │   ├── ReviewPlan.java
│   │   │   │   │   └── User.java
│   │   │   │   ├── mapper/           # MyBatis Mapper
│   │   │   │   │   ├── AnswerRecordMapper.java
│   │   │   │   │   ├── KnowledgePointMapper.java
│   │   │   │   │   ├── QuestionMapper.java
│   │   │   │   │   ├── ReviewPlanMapper.java
│   │   │   │   │   └── UserMapper.java
│   │   │   │   ├── service/          # 业务逻辑层
│   │   │   │   │   ├── AnswerService.java
│   │   │   │   │   ├── QuestionService.java
│   │   │   │   │   ├── ReviewPlanService.java
│   │   │   │   │   └── UserService.java
│   │   │   │   └── SmartReviewApplication.java  # 启动类
│   │   │   └── resources/
│   │   │       ├── mapper/           # MyBatis XML
│   │   │       ├── sql/              # SQL脚本
│   │   │       │   └── schema.sql
│   │   │       └── application.yml   # 配置文件
│   │   └── test/
│   └── pom.xml
│
├── frontend/                         # 前端项目
│   ├── src/
│   │   ├── api/                      # API接口
│   │   │   ├── index.js
│   │   │   └── user.js
│   │   ├── router/                   # 路由配置
│   │   │   └── index.js
│   │   ├── utils/                    # 工具函数
│   │   │   └── request.js
│   │   ├── views/                    # 页面组件
│   │   │   ├── Login.vue             # 登录页
│   │   │   ├── Register.vue          # 注册页
│   │   │   ├── QuestionImport.vue    # 题目导入
│   │   │   ├── QuestionSetList.vue   # 题目集列表
│   │   │   ├── QuestionSetDetail.vue # 题目集详情
│   │   │   ├── Practice.vue          # 在线练习
│   │   │   ├── WrongBook.vue         # 错题本
│   │   │   ├── ReviewPlan.vue        # 复习计划
│   │   │   └── Statistics.vue        # 统计分析
│   │   ├── App.vue                   # 根组件
│   │   └── main.js                   # 入口文件
│   ├── index.html
│   ├── package.json
│   └── vite.config.js
│
└── database_update.sql               # 数据库更新脚本
```

---

## 快速开始

### 环境要求

**后端环境：**
- JDK 17+
- Maven 3.6+
- MySQL 8.0+

**前端环境：**
- Node.js 16+
- npm 或 yarn

## 使用指南

### 第一步：准备题目数据

使用**超级提示词**在AI工具中将笔记转化为JSON格式：

#### 超级提示词

```
你是一个专业的教育内容结构化助手。你的任务是将用户提供的笔记内容转换为标准化的JSON格式题目数据。

输入格式：
用户会提供一段笔记内容，可能包含：
- 题目描述
- 选项（如果是选择题）
- 答案
- 解析说明
- 难度评估
- 知识点标签

输出格式要求：
严格按照以下JSON Schema输出：

{
  "questions": [
    {
      "content": "题干内容",
      "type": "题型(choice/fill/short/calculation)",
      "options": ["选项A", "选项B", "选项C", "选项D"],
      "answer": "正确答案",
      "explanation": "详细解析说明",
      "difficulty": 1-5的整数,
      "subject": "科目名称",
      "topic": "知识点名称",
      "tags": ["标签1", "标签2", "标签3"]
    }
  ]
}

处理规则：
1. 准确识别题型
2. 对于选择题，确保选项完整且顺序正确
3. 答案必须准确无误
4. 解析要详细且易于理解
5. 难度等级：1(简单)-5(困难)
6. 自动识别或推断科目和知识点
7. 提取相关的标签信息
8. 如果信息不完整，使用"待补充"标记

请处理以下笔记内容：
[在这里粘贴您的笔记]
```

#### 使用步骤

1. 打开AI对话工具（ChatGPT、Claude、文心一言等）
2. 复制上面的超级提示词
3. 在提示词末尾粘贴您的笔记内容
4. AI将自动生成标准JSON格式的题目数据
5. 复制生成的JSON数据

### 第二步：导入题目

1. 访问系统首页并登录
2. 点击 **"导入题目"** 菜单
3. 将AI生成的JSON数据粘贴到文本框
4. 点击 **"导入题目"** 按钮
5. 系统将自动解析并保存题目

### 第三步：在线答题

1. 点击 **"在线答题"** 或 **"题目集列表"** 菜单
2. 选择要练习的题目集
3. 系统会按顺序展示题目
4. 选择或填写答案后点击 **"提交答案"**
5. 查看答案解析和掌握度评估
6. 点击 **"下一题"** 继续练习

### 第四步：查看错题本

1. 点击 **"错题本"** 菜单
2. 查看所有答错的题目
3. 点击题目可展开查看详细信息
4. 点击 **"错题重练"** 可重新练习

### 第五步：复习计划

1. 点击 **"复习计划"** 菜单
2. 查看基于艾宾浩斯曲线生成的复习计划
3. **"待复习"** 标签页显示需要复习的题目
4. **"已完成"** 标签页显示已复习的题目
5. 系统会根据答题情况自动调整复习时间

### 第六步：统计分析

1. 点击 **"统计分析"** 菜单
2. 查看总答题数、正确率、平均耗时等统计数据
3. 查看各科目、知识点的掌握情况
4. 根据统计结果调整学习策略

---

## 核心功能说明

### 艾宾浩斯遗忘曲线算法

系统根据以下因素计算下次复习时间：

| 因素 | 权重 | 说明 |
|------|------|------|
| 答题正确率 | 60% | 正确性是主要评估指标 |
| 答题耗时 | 40% | 快速作答说明掌握熟练 |
| 连续正确次数 | 加成 | 连续答对可延长复习间隔 |

**复习间隔：** 1天 → 2天 → 4天 → 7天 → 15天

### 掌握度评分规则

```
掌握度 = 正确率权重 × 60% + 速度权重 × 40%

评分标准：
- 正确且快速（耗时 < 预期时间50%）: 80-100分
- 正确且正常（耗时 < 预期时间）    : 60-80分
- 正确但慢（耗时 > 预期时间）      : 50-60分
- 错误                            : 0-50分
```

### 优先级计算

```
优先级 = 超期天数 × 0.4 + (100 - 掌握度) × 0.4 + 难度 × 0.2

因素说明：
- 超期时间越长，优先级越高
- 掌握度越低，优先级越高
- 难度越高，优先级越高
```

### 智能调度策略

1. **首次答题**：答对后1天复习，答错后立即加入复习计划
2. **连续答对**：每次答对，复习间隔延长（1→2→4→7→15天）
3. **答错重置**：答错后重新从1天开始
4. **优先级排序**：按优先级从高到低展示待复习题目

---

<div align="center">
  <p style="color: #999; font-size: 12px;">
    © 2026 Smart Review System. All rights reserved.
  </p>
</div>
