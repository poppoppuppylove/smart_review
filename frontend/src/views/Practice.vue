<template>
  <div class="practice">
    <el-card class="practice-card">
      <template #header>
        <div class="card-header">
          <h2><el-icon><Edit /></el-icon> 在线答题</h2>
          <div class="progress-info">
            <span>进度: {{ Math.min(currentIndex + 1, questions.length) }} / {{ questions.length }}</span>
            <el-checkbox v-model="autoNextQuestion" size="small">答完自动下一题</el-checkbox>
          </div>
        </div>
      </template>

      <!-- 加载中 -->
      <div v-if="loading" class="loading-container">
        <el-icon class="is-loading"><Loading /></el-icon>
        <p>加载题目中...</p>
      </div>

      <!-- 无题目 -->
      <el-empty v-else-if="questions.length === 0" description="暂无题目,请先导入题目">
        <el-button type="primary" @click="$router.push('/import')">去导入</el-button>
      </el-empty>

      <!-- 答题区域 -->
      <div v-else class="question-area">
        <!-- 题目信息 -->
        <div class="question-header">
          <el-tag :type="difficultyType">难度: {{ difficultyText }}</el-tag>
          <el-tag v-for="tag in currentQuestion.tagsList" :key="tag" class="tag-item">
            {{ tag }}
          </el-tag>
        </div>

        <!-- 题干 -->
        <div class="question-title">
          <h3>{{ currentIndex + 1 }}. {{ currentQuestion.title }}</h3>
        </div>

        <!-- 选项 -->
        <div class="question-options">
          <el-radio-group
            v-if="currentQuestion.type === 'single_choice'"
            v-model="userAnswer"
            class="option-group"
          >
            <el-radio
              v-for="(option, index) in currentQuestion.optionsList"
              :key="index"
              :label="String.fromCharCode(65 + index)"
              class="option-item"
              :disabled="answered"
            >
              {{ String.fromCharCode(65 + index) }}. {{ option }}
            </el-radio>
          </el-radio-group>

          <el-checkbox-group
            v-else-if="currentQuestion.type === 'multiple_choice'"
            v-model="userAnswerArray"
            class="option-group"
          >
            <el-checkbox
              v-for="(option, index) in currentQuestion.optionsList"
              :key="index"
              :label="String.fromCharCode(65 + index)"
              class="option-item"
              :disabled="answered"
            >
              {{ String.fromCharCode(65 + index) }}. {{ option }}
            </el-checkbox>
          </el-checkbox-group>

          <el-radio-group
            v-else-if="currentQuestion.type === 'true_false'"
            v-model="userAnswer"
            class="option-group tf-group"
          >
            <el-radio
              label="正确"
              class="option-item tf-option"
              :disabled="answered"
            >
              正确
            </el-radio>
            <el-radio
              label="错误"
              class="option-item tf-option"
              :disabled="answered"
            >
              错误
            </el-radio>
          </el-radio-group>

          <el-input
            v-else
            v-model="userAnswer"
            type="textarea"
            :rows="4"
            placeholder="请输入答案"
            :disabled="answered"
          />
        </div>

        <!-- 答案解析 -->
        <el-card v-if="answered" class="analysis-card" :class="{ correct: isCorrect, wrong: !isCorrect }">
          <div class="result-header">
            <el-icon v-if="isCorrect" class="success-icon"><SuccessFilled /></el-icon>
            <el-icon v-else class="error-icon"><CircleCloseFilled /></el-icon>
            <span class="result-text">{{ isCorrect ? '回答正确!' : '回答错误!' }}</span>
          </div>
          <div class="answer-info">
            <p><strong>正确答案:</strong> {{ answerResult.correctAnswer }}</p>
            <p><strong>答案解析:</strong> {{ answerResult.analysis }}</p>
            <p><strong>复习次数:</strong> {{ answerResult.reviewCount }}</p>
            <p><strong>连续正确:</strong> {{ answerResult.consecutiveCorrect }} 次</p>
          </div>
        </el-card>

        <!-- 操作按钮 -->
        <div class="action-buttons">
          <el-button
            v-if="!answered"
            type="primary"
            size="large"
            @click="submitAnswer"
            :disabled="!canSubmit"
          >
            提交答案
          </el-button>
          <template v-else>
            <el-button type="primary" size="large" @click="nextQuestion">
              下一题
            </el-button>
            <el-button size="large" @click="resetAnswer">
              重新作答
            </el-button>
          </template>
        </div>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { questionApi, answerApi, questionSetApi } from '@/api'

const loading = ref(false)
const questions = ref([])
const currentIndex = ref(0)
const questionSetId = ref(null)
const showAll = ref(false)  // 标记是否显示全部题目
const answeredQuestionIds = ref(new Set())  // 记录已答过的题目ID
const autoNextQuestion = ref(true)  // 答完自动进入下一题

// 用于显示的当前题目（不会因为数组变化而改变）
const displayQuestion = ref(null)

// 监听题目数组变化，确保索引在有效范围内
watch(questions, (newQuestions) => {
  if (newQuestions.length > 0) {
    currentIndex.value = Math.max(0, Math.min(currentIndex.value, newQuestions.length - 1))
  } else {
    currentIndex.value = 0
  }
}, { deep: true })
const userAnswer = ref('')
const userAnswerArray = ref([])
const answered = ref(false)
const answerResult = ref(null)
const startTime = ref(null)

const currentQuestion = computed(() => {
  // 如果已经回答了，显示用于展示的题目（防止题目数组变化后显示错乱）
  if (answered.value && displayQuestion.value) {
    return displayQuestion.value
  }
  // 确保索引在有效范围内
  const index = Math.max(0, Math.min(currentIndex.value, questions.value.length - 1))
  return questions.value[index] || {}
})

const difficultyText = computed(() => {
  const levels = ['', '非常简单', '简单', '中等', '困难', '非常困难']
  return levels[currentQuestion.value.difficulty] || '中等'
})

const difficultyType = computed(() => {
  const types = ['', 'success', 'success', '', 'warning', 'danger']
  return types[currentQuestion.value.difficulty] || ''
})

const canSubmit = computed(() => {
  if (currentQuestion.value.type === 'multiple_choice') {
    return userAnswerArray.value.length > 0
  }
  return userAnswer.value.trim() !== ''
})

const isCorrect = computed(() => answerResult.value?.isCorrect || false)

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

// 加载题目
const loadQuestions = async () => {
  // 从路由参数获取questionSetId和showAll
  const route = useRoute()
  if (route.query.questionSetId) {
    questionSetId.value = route.query.questionSetId
  }
  showAll.value = route.query.showAll === 'true'

  // 清除已答题目记录（每次重新加载时）
  answeredQuestionIds.value.clear()

  try {
    loading.value = true
    let result

    // 获取userId
    const userId = getUserId()

    if (questionSetId.value) {
      if (showAll.value) {
        // 获取题套的所有题目
        result = await questionSetApi.getAll(questionSetId.value, { userId })
      } else {
        // 获取题套的未完成题目
        result = await questionApi.getQuestions({ questionSetId: questionSetId.value, userId })
      }
    } else {
      // 获取最新题套的未完成题目
      const setsResult = await questionSetApi.getList({ userId })
      if (setsResult.data && setsResult.data.length > 0) {
        result = await questionApi.getQuestions({ questionSetId: setsResult.data[0].id, userId })
      } else {
        result = await questionApi.getQuestions({ userId })
      }
    }

    questions.value = result.data || []

    if (questions.value.length === 0) {
      ElMessage.info('该题套下没有未完成的题目')
    }

    // 重置索引
    currentIndex.value = 0
    resetAnswer()
    if (questions.value.length > 0) {
      startTimer()
    }
  } catch (error) {
    ElMessage.error('加载题目失败: ' + (error.message || '网络错误'))
  } finally {
    loading.value = false
  }
}

// 开始计时
const startTimer = () => {
  startTime.value = Date.now()
}

// 页面卸载时清除已答题目记录
onUnmounted(() => {
  answeredQuestionIds.value.clear()
})

// 提交答案
const submitAnswer = async () => {
  // 确保当前题目存在
  if (!currentQuestion.value || !currentQuestion.value.id) {
    ElMessage.error('当前题目不存在')
    return
  }

  const timeSpent = Math.floor((Date.now() - startTime.value) / 1000)

  let answer = userAnswer.value
  if (currentQuestion.value.type === 'multiple_choice') {
    answer = userAnswerArray.value.sort().join(',')
  }

  try {
    // 保存当前题目用于展示（防止答题后题目被移除导致显示错乱）
    displayQuestion.value = { ...currentQuestion.value }

    // 记录已答过的题目
    if (currentQuestion.value.id) {
      answeredQuestionIds.value.add(currentQuestion.value.id)
    }

    // 获取userId
    const userId = getUserId()

    const result = await answerApi.submitAnswer({
      questionId: currentQuestion.value.id,
      userAnswer: answer,
      timeSpent
    }, userId)

    answerResult.value = result.data
    answered.value = true

    // 如果启用自动下一题，则自动进入下一题
    if (autoNextQuestion.value) {
      setTimeout(() => {
        nextQuestion()
      }, 1500) // 1.5秒后自动进入下一题
    }
  } catch (error) {
    ElMessage.error('提交失败: ' + (error.message || '网络错误'))
  }
}

// 下一题
const nextQuestion = () => {
  // 检查是否还有题目
  if (questions.value.length === 0) {
    ElMessage.success('恭喜！所有题目已完成！')
    return
  }

  // 查找下一个未答过的题目
  let startIndex = currentIndex.value
  do {
    currentIndex.value = (currentIndex.value + 1) % questions.value.length
    // 如果回到起点，说明所有题目都答过了
    if (currentIndex.value === startIndex) {
      ElMessage.success('恭喜！所有题目已完成！')
      return
    }
  } while (answeredQuestionIds.value.has(questions.value[currentIndex.value].id))

  resetAnswer()
  startTimer()
}

// 重置答案
const resetAnswer = () => {
  userAnswer.value = ''
  userAnswerArray.value = []
  answered.value = false
  answerResult.value = null
  displayQuestion.value = null
  // 不清除answeredQuestionIds，保持已答过的题目记录

  // 确保索引在有效范围内，并且指向未答过的题目
  if (questions.value.length > 0) {
    let startIndex = currentIndex.value
    do {
      // 检查当前题目是否已答过
      if (!answeredQuestionIds.value.has(questions.value[currentIndex.value].id)) {
        break // 找到未答过的题目
      }
      // 移动到下一题
      currentIndex.value = (currentIndex.value + 1) % questions.value.length
      // 如果回到起点，说明所有题目都答过了
      if (currentIndex.value === startIndex) {
        break
      }
    } while (true)
  } else {
    currentIndex.value = 0
  }
}

onMounted(() => {
  loadQuestions()
})
</script>

<style scoped>
.practice {
  max-width: 900px;
  margin: 0 auto;
}

.practice-card {
  background: #ffffff;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  border: 1px solid var(--border-light);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-header h2 {
  font-size: 24px;
  color: #333;
  display: flex;
  align-items: center;
  gap: 10px;
  margin: 0;
}

.progress-info {
  font-size: 16px;
  color: #666;
  font-weight: 600;
}

.loading-container {
  text-align: center;
  padding: 60px 0;
  color: #666;
}

.loading-container .el-icon {
  font-size: 48px;
  margin-bottom: 15px;
}

.question-header {
  display: flex;
  gap: 10px;
  margin-bottom: 20px;
  flex-wrap: wrap;
}

.tag-item {
  margin-left: 0;
}

.question-title {
  margin: 20px 0;
  padding: 20px;
  background: #f5f7fa;
  border-radius: 8px;
}

.question-title h3 {
  font-size: 18px;
  line-height: 1.8;
  color: #333;
  margin: 0;
}

.question-options {
  margin: 30px 0;
}

.option-group {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

/* 判断题选项组 */
.tf-group {
  display: flex;
  gap: 20px;
  justify-content: center;
  margin: 20px 0;
}

.option-item {
  display: flex;
  align-items: center;
  text-align: left;
  padding: 15px;
  background: #fff;
  border: 2px solid #e4e7ed;
  border-radius: 8px;
  transition: all 0.3s;
  cursor: pointer;
}

.option-item.tf-option {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 12px 30px;
  margin-right: 0;
  min-width: 120px;
  text-align: center;
}

.option-item:hover:not(.is-disabled) {
  border-color: #409eff;
  background: #ecf5ff;
}

.analysis-card {
  margin: 20px 0;
  border-radius: 8px;
}

.analysis-card.correct {
  border-left: 4px solid #67c23a;
  background: #f0f9ff;
}

.analysis-card.wrong {
  border-left: 4px solid #f56c6c;
  background: #fef0f0;
}

.result-header {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 15px;
  font-size: 18px;
  font-weight: 600;
}

.success-icon {
  color: #67c23a;
  font-size: 24px;
}

.error-icon {
  color: #f56c6c;
  font-size: 24px;
}

.answer-info p {
  margin: 10px 0;
  line-height: 1.8;
}

.action-buttons {
  display: flex;
  gap: 15px;
  justify-content: center;
  margin-top: 30px;
}
</style>
