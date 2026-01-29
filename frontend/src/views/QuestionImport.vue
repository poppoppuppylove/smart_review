<template>
  <div class="question-import">
    <div class="import-card">
      <div class="card-header">
        <h2><el-icon class="header-icon"><Upload /></el-icon> 题目导入</h2>
        <el-tag type="info" effect="plain" size="large">支持JSON格式</el-tag>
      </div>

      <!-- 超级提示词部分 -->
      <div class="super-prompt-section">
        <el-alert
          title="超级提示词"
          type="success"
          :closable="false"
          class="prompt-alert"
        >
          <p>使用以下提示词在AI工具中将您的笔记转化为结构化的题目数据:</p>
        </el-alert>

        <div class="prompt-box">
          <pre class="prompt-text">{{ superPrompt }}</pre>
        </div>

        <el-button
          type="primary"
          @click="copySuperPrompt"
          class="copy-button"
        >
          <el-icon><DocumentCopy /></el-icon>
          复制超级提示词
        </el-button>
      </div>

      <el-divider />

      <!-- 使用说明 -->
      <div class="usage-section">
        <h3><el-icon><InfoFilled /></el-icon> 使用说明</h3>
        <div class="steps">
          <div class="step">
            <span class="step-number">1</span>
            <span class="step-text">点击"复制超级提示词",将提示词复制到剪贴板</span>
          </div>
          <div class="step">
            <span class="step-number">2</span>
            <span class="step-text">在AI工具(如ChatGPT等)中粘贴提示词并输入您的笔记内容</span>
          </div>
          <div class="step">
            <span class="step-number">3</span>
            <span class="step-text">将AI生成的JSON数据复制粘贴到下方文本框</span>
          </div>
          <div class="step">
            <span class="step-number">4</span>
            <span class="step-text">点击"导入题目"按钮完成导入</span>
          </div>
        </div>
      </div>

      <!-- JSON输入区 -->
      <div class="json-input-area">
        <div class="input-label">
          <span class="label-text"><el-icon><Edit /></el-icon> 粘贴JSON数据</span>
          <span class="label-hint">或点击下方按钮查看格式示例</span>
        </div>
        <el-input
          v-model="jsonInput"
          type="textarea"
          :rows="12"
          :placeholder="jsonPlaceholder"
          class="json-textarea"
        />
      </div>

      <!-- 操作按钮 -->
      <div class="action-buttons">
        <el-button
          type="primary"
          size="large"
          @click="handleImport"
          :loading="importing"
        >
          <el-icon><Upload /></el-icon>
          导入题目
        </el-button>
        <el-button
          size="large"
          @click="handleClear"
        >
          <el-icon><Delete /></el-icon>
          清空
        </el-button>
        <el-button
          size="large"
          @click="showExample"
        >
          <el-icon><Document /></el-icon>
          查看格式示例
        </el-button>
      </div>
    </div>

    <!-- 示例对话框 -->
    <el-dialog
      v-model="exampleVisible"
      title="JSON格式示例"
      width="700px"
    >
      <pre class="example-json">{{ exampleJson }}</pre>
      <template #footer>
        <el-button @click="exampleVisible = false">关闭</el-button>
        <el-button
          type="primary"
          @click="copyExample"
        >
          复制示例
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { ElMessage } from 'element-plus'
import { Upload, Delete, Document, DocumentCopy, InfoFilled, Edit } from '@element-plus/icons-vue'
import { questionApi } from '@/api'

const jsonInput = ref('')
const importing = ref(false)
const exampleVisible = ref(false)

// 超级提示词
const superPrompt = ref(`你是一个专业的教育内容结构化助手。你的任务是将用户提供的笔记内容转换为标准化的JSON格式题目数据。

  输入格式：
  用户会提供一段笔记内容,可能包含:
  - 题目描述
  - 选项(如果是选择题)
  - 答案
  - 解析说明
  - 难度评估
  - 知识点
  - 科目分类
  - 题目来源

  输出格式要求：
  严格按照以下JSON Schema输出:
  {
    "knowledgePoint": "知识点名称(如:二次函数)",
    "subject": "科目名称(如:数学/语文/英语/物理/化学/生物/地理/历史)",
    "questions": [
      {
        "type":
  "题型(单选:single_choice,多选:multiple_choice,判断:true_false,填空:fill_blank,问答:essay)",
        "title": "题干内容",
        "options": ["选项A", "选项B", "选项C", "选项D"],
        "correctAnswer": "正确答案(单选为A/B/C/D,多选为A,B,D,填空为完整答案)",
        "analysis": "答案解析说明",
        "difficulty": 1-5,
        "tags": ["标签1", "标签2", "标签3"],
        "source": "题目来源"
      }
    ]
  }

  字段说明：
  - knowledgePoint: 具体的知识点名称，如"二次函数"、"牛顿定律"等
  - subject: 主科目分类，如"数学"、"物理"、"英语"等
  - type: 题型类型，必须从以下选项中选择：
    - single_choice(单选题)
    - multiple_choice(多选题)
    - true_false(判断题)
    - fill_blank(填空题)
    - essay(问答题)
  - title: 完整的题干内容，包含所有必要的文字描述
  - options: 选项数组，仅选择题需要，按A、B、C、D顺序排列
  - correctAnswer: 标准格式答案
  - analysis: 详细的解题思路和答案解释
  - difficulty: 难度等级，1-5的整数
  - tags: 与题目相关的标签，便于分类和检索
  - source: 题目来源，如"人教版教材"、"2023年高考真题"等

  处理规则:
  1. 准确识别题型，type字段必须使用指定的英文值
  2. 对于选择题，确保选项完整、顺序正确且格式统一
  3. 答案必须准确无误，严格按照指定格式
  4. 解析要详细且易于理解，说明解题思路
  5. 难度等级: 1(非常简单) - 5(非常困难)，根据题目复杂度和学生常见错误率评估
  6. 准确识别科目(数学、语文、英语、物理、化学、生物、政治、历史、地理等)
  7. 准确识别知识点，使用学科内的标准术语
  8. 提取相关的标签信息，每个标签2-8个字
  9. 确保JSON格式正确，可以直接解析使用
  10. 选项内容不要包含"A."、"B."等前缀，只要选项本身的内容
  11. 多选题答案使用逗号分隔，如"A,B,D"，不要有空格
  12. 不要使用latex等特殊格式，用纯文本

  示例输入：
  数学题目：函数f(x)=x²+2x+1在x=1处的值是多少？
  选项：
  A. 2
  B. 3
  C. 4
  D. 5
  正确答案：C
  解析：将x=1代入函数f(1)=1²+2×1+1=4
  难度：简单
  标签：函数代数
  来源：人教版必修一

  示例输出：
  {
    "knowledgePoint": "函数求值",
    "subject": "数学",
    "questions": [
      {
        "type": "single_choice",
        "title": "函数f(x)=x²+2x+1在x=1处的值是多少？",
        "options": ["2", "3", "4", "5"],
        "correctAnswer": "C",
        "analysis": "将x=1代入函数计算：f(1)=1²+2×1+1=1+2+1=4",
        "difficulty": 1,
        "tags": ["函数", "代数", "求值"],
        "source": "人教版必修一"
      }
    ]
  }

  请处理以下笔记内容：`)

// JSON占位符文本
const jsonPlaceholder = ref(`请粘贴JSON数据,格式示例:
  {
    "knowledgePoint": "函数求值",
    "subject": "数学",
    "questions": [
      {
        "type": "single_choice",
        "title": "函数f(x)=x²+2x+1在x=1处的值是多少？",
        "options": ["2", "3", "4", "5"],
        "correctAnswer": "C",
        "analysis": "将x=1代入函数计算：f(1)=1²+2×1+1=1+2+1=4",
        "difficulty": 1,
        "tags": ["函数", "代数", "求值"],
        "source": "人教版必修一"
      }
    ]
  }`)

const exampleJson = `{
  "knowledgePoint": "数学-代数",
  "subject": "数学",
  "questions": [
    {
      "type": "single_choice",
      "title": "下列哪个是一元二次方程的标准形式?",
      "options": [
        "ax² + bx + c = 0",
        "ax + b = 0",
        "ax³ + bx² + cx + d = 0",
        "ax² + bx = 0"
      ],
      "correctAnswer": "A",
      "analysis": "一元二次方程的标准形式是ax² + bx + c = 0,其中a≠0",
      "difficulty": 2,
      "tags": ["一元二次方程", "基础概念"],
      "source": "教材第三章"
    },
    {
      "type": "multiple_choice",
      "title": "以下哪些是质数?",
      "options": ["2", "3", "4", "5"],
      "correctAnswer": "A,B,D",
      "analysis": "质数是只能被1和自身整除的大于1的自然数。2是唯一的偶质数,3和5都是质数,4不是。",
      "difficulty": 1,
      "tags": ["质数", "数论"],
      "source": "习题集"
    },
    {
      "type": "fill_blank",
      "title": "∫x dx = ____",
      "options": null,
      "correctAnswer": "1/2x² + C",
      "analysis": "根据不定积分定义,∫x dx = 1/2x² + C,其中C为积分常数。",
      "difficulty": 2,
      "tags": ["不定积分", "基本积分"],
      "source": "教材例题"
    }
  ]
}`

// 复制超级提示词
const copySuperPrompt = async () => {
  try {
    // 确保有值可以复制
    if (!superPrompt.value || superPrompt.value.trim() === '') {
      ElMessage.warning('提示词内容为空')
      return
    }

    // 尝试使用现代 Clipboard API
    if (navigator.clipboard && window.isSecureContext) {
      await navigator.clipboard.writeText(superPrompt.value)
      ElMessage.success('超级提示词已复制到剪贴板')
    } else {
      // 降级方案：使用传统的 document.execCommand
      const textArea = document.createElement('textarea')
      textArea.value = superPrompt.value
      textArea.style.position = 'fixed'
      textArea.style.left = '-999999px'
      textArea.style.top = '-999999px'
      document.body.appendChild(textArea)
      textArea.focus()
      textArea.select()

      try {
        const successful = document.execCommand('copy')
        if (successful) {
          ElMessage.success('超级提示词已复制到剪贴板')
        } else {
          ElMessage.error('复制失败,请手动复制')
        }
      } finally {
        document.body.removeChild(textArea)
      }
    }
  } catch (error) {
    console.error('复制失败:', error)
    ElMessage.error('复制失败,请手动复制')
  }
}

// 获取用户ID
const getUserId = () => {
  const currentUser = localStorage.getItem('currentUser')
  if (currentUser) {
    try {
      const user = JSON.parse(currentUser)
      return user.id
    } catch (error) {
      console.error('解析用户信息失败:', error)
      return null
    }
  }
  return null
}

// 导入题目
const handleImport = async () => {
  if (!jsonInput.value.trim()) {
    ElMessage.warning('请输入JSON数据')
    return
  }

  try {
    importing.value = true
    const data = JSON.parse(jsonInput.value)

    // 验证数据格式
    if (!data.questions || !Array.isArray(data.questions) || data.questions.length === 0) {
      ElMessage.error('JSON格式错误:questions字段缺失或不是数组')
      return
    }

    // 获取userId并传递
    const userId = getUserId()
    const result = await questionApi.importQuestions(data, userId)
    ElMessage.success(result.message || '导入成功')
    jsonInput.value = ''
  } catch (error) {
    if (error instanceof SyntaxError) {
      ElMessage.error('JSON格式错误,请检查格式')
    } else {
      ElMessage.error(error.message || '导入失败')
    }
  } finally {
    importing.value = false
  }
}

// 清空输入
const handleClear = () => {
  jsonInput.value = ''
  ElMessage.info('已清空')
}

// 显示示例
const showExample = () => {
  exampleVisible.value = true
}

// 复制示例
const copyExample = async () => {
  try {
    if (navigator.clipboard && window.isSecureContext) {
      await navigator.clipboard.writeText(exampleJson)
      ElMessage.success('示例代码已复制到剪贴板')
    } else {
      const textArea = document.createElement('textarea')
      textArea.value = exampleJson
      textArea.style.position = 'fixed'
      textArea.style.left = '-999999px'
      textArea.style.top = '-999999px'
      document.body.appendChild(textArea)
      textArea.focus()
      textArea.select()

      try {
        const successful = document.execCommand('copy')
        if (successful) {
          ElMessage.success('示例代码已复制到剪贴板')
        } else {
          ElMessage.error('复制失败,请手动复制')
        }
      } finally {
        document.body.removeChild(textArea)
      }
    }
  } catch (error) {
    console.error('复制失败:', error)
    ElMessage.error('复制失败,请手动复制')
  }
}
</script>

<style scoped>
.question-import {
  max-width: 1000px;
  margin: 0 auto;
  animation: slideInUp 0.5s ease-out;
}

@keyframes slideInUp {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.import-card {
  background: #ffffff;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  border: 1px solid var(--border-light);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
  padding-bottom: 20px;
  border-bottom: 2px solid #e5e7eb;
}

.card-header h2 {
  font-size: 24px;
  font-weight: 700;
  color: #333;
  display: flex;
  align-items: center;
  gap: 12px;
  margin: 0;
}

.header-icon {
  font-size: 32px;
  color: #4361ee;
}

/* 超级提示词部分 */
.super-prompt-section {
  margin-bottom: 30px;
}

.prompt-alert {
  margin-bottom: 15px;
}

.prompt-alert p {
  margin: 5px 0;
  line-height: 1.6;
}

.prompt-box {
  background: #f5f7fa;
  border: 2px solid #e5e7eb;
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 15px;
  max-height: 300px;
  overflow-y: auto;
}

.prompt-text {
  font-family: 'Consolas', 'Monaco', monospace;
  font-size: 13px;
  line-height: 1.6;
  color: #2c3e50;
  margin: 0;
  white-space: pre-wrap;
  word-wrap: break-word;
}

.copy-button {
  width: 100%;
  font-weight: 600;
  height: 45px;
  font-size: 16px;
  background: var(--primary-color);
  border: none;
}

.copy-button:hover {
  background: var(--primary-dark);
}

/* 使用说明 */
.usage-section {
  margin-bottom: 30px;
}

.usage-section h3 {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 18px;
  color: #333;
  margin: 0 0 15px 0;
}

.usage-section h3 .el-icon {
  color: #4361ee;
}

.steps {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.step {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  background: #f8f9fa;
  border-radius: 10px;
  transition: all 0.3s;
}

.step:hover {
  background: #e9ecef;
  transform: translateX(5px);
}

.step-number {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  background: var(--primary-color);
  color: white;
  border-radius: 50%;
  font-weight: 700;
  font-size: 14px;
  flex-shrink: 0;
}

.step-text {
  color: #555;
  font-size: 14px;
  line-height: 1.5;
}

/* JSON输入区 */
.json-input-area {
  margin: 25px 0;
}

.input-label {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.label-text {
  display: flex;
  align-items: center;
  gap: 6px;
  font-weight: 600;
  color: #333;
  font-size: 15px;
}

.label-text .el-icon {
  color: #4361ee;
}

.label-hint {
  color: #999;
  font-size: 12px;
}

.json-textarea {
  font-family: 'Consolas', 'Monaco', monospace;
  font-size: 13px;
}

.json-textarea :deep(textarea) {
  font-family: 'Consolas', 'Monaco', monospace;
  line-height: 1.6;
}

/* 操作按钮 */
.action-buttons {
  display: flex;
  gap: 12px;
  justify-content: center;
  margin-top: 25px;
  padding-top: 25px;
  border-top: 2px solid #e5e7eb;
}

.action-buttons .el-button {
  height: 45px;
  padding: 0 30px;
  font-size: 15px;
  font-weight: 600;
}

.action-buttons .el-button--primary {
  background: var(--primary-color);
  border: none;
}

.action-buttons .el-button--primary:hover {
  background: var(--primary-dark);
}

/* 示例对话框 */
.example-json {
  background: #f5f7fa;
  padding: 20px;
  border-radius: 10px;
  font-family: 'Consolas', 'Monaco', monospace;
  font-size: 13px;
  line-height: 1.6;
  overflow-x: auto;
  max-height: 500px;
  overflow-y: auto;
  margin: 0;
}

/* 响应式 */
@media (max-width: 768px) {
  .import-card {
    padding: 20px;
    border-radius: 15px;
  }

  .card-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 15px;
  }

  .action-buttons {
    flex-direction: column;
  }

  .action-buttons .el-button {
    width: 100%;
  }
}
</style>