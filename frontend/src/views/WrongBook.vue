<template>
  <div class="wrong-book">
    <el-card class="wrong-card">
      <template #header>
        <div class="card-header">
          <h2><el-icon><Warning /></el-icon> 错题本</h2>
        </div>
      </template>

      <!-- 加载中 -->
      <div v-if="loading" class="loading-container">
        <el-icon class="is-loading"><Loading /></el-icon>
        <p>加载错题中...</p>
      </div>

      <!-- 无错题 -->
      <el-empty v-else-if="wrongAnswers.length === 0" description="暂无错题,继续加油!">
        <el-button type="primary" @click="$router.push('/practice')">去答题</el-button>
      </el-empty>

      <!-- 错题列表 -->
      <div v-else class="wrong-list">
        <el-collapse v-model="activeNames">
          <el-collapse-item
            v-for="(record, index) in wrongAnswersWithQuestions"
            :key="record.id"
            :name="record.id"
          >
            <template #title>
              <div class="wrong-item-title">
                <el-tag type="danger" size="small">错题</el-tag>
                <span class="question-preview">{{ index + 1 }}. {{ record.question?.title }}</span>
                <el-tag v-if="record.retryCount > 0" type="warning" size="small">
                  重练: {{ record.retryCount }} 次
                </el-tag>
                <span class="answer-time">{{ formatTime(record.answerTime) }}</span>
                <el-button
                  size="small"
                  type="primary"
                  link
                  @click.stop="showHistory(record.questionId)"
                >
                  历史记录
                </el-button>
              </div>
            </template>

            <div class="wrong-detail">
              <!-- 题目信息 -->
              <div class="question-info">
                <el-tag :type="getDifficultyType(record.question?.difficulty)">
                  难度: {{ getDifficultyText(record.question?.difficulty) }}
                </el-tag>
                <el-tag v-for="tag in record.question?.tagsList" :key="tag" class="tag-item">
                  {{ tag }}
                </el-tag>
              </div>

              <!-- 题干 -->
              <div class="question-title">
                <h4>{{ record.question?.title }}</h4>
              </div>

              <!-- 选项 -->
              <div v-if="record.question?.optionsList" class="question-options">
                <div
                  v-for="(option, idx) in record.question.optionsList"
                  :key="idx"
                  class="option-item"
                >
                  {{ String.fromCharCode(65 + idx) }}. {{ option }}
                </div>
              </div>

              <!-- 判断题特有 -->
              <div v-else-if="record.question?.type === 'true_false'" class="question-options tf-options">
                <div class="option-item">正确</div>
                <div class="option-item">错误</div>
              </div>

              <!-- 答案信息 -->
              <div class="answer-section">
                <el-descriptions :column="1" border>
                  <el-descriptions-item label="我的答案">
                    <el-text type="danger">{{ record.userAnswer }}</el-text>
                  </el-descriptions-item>
                  <el-descriptions-item label="正确答案">
                    <el-text type="success">{{ record.question?.correctAnswer }}</el-text>
                  </el-descriptions-item>
                  <el-descriptions-item label="答案解析">
                    {{ record.question?.analysis }}
                  </el-descriptions-item>
                  <el-descriptions-item label="答题耗时">
                    {{ record.timeSpent }} 秒
                  </el-descriptions-item>
                  <el-descriptions-item label="我的笔记">
                    <div class="notes-section">
                      <el-input
                        v-model="record.notes"
                        type="textarea"
                        :rows="3"
                        placeholder="添加笔记备注..."
                        @blur="saveNotes(record.id, record.notes)"
                      />
                    </div>
                  </el-descriptions-item>
                </el-descriptions>
              </div>

              <!-- 操作按钮 -->
              <div class="wrong-actions">
                <el-button
                  type="danger"
                  size="small"
                  @click="removeFromWrongBook(record.id)"
                >
                  <el-icon><Delete /></el-icon>
                  移出错题本
                </el-button>
              </div>
            </div>
          </el-collapse-item>
        </el-collapse>
      </div>
    </el-card>

    <!-- 历史记录对话框 -->
    <el-dialog
      v-model="historyDialogVisible"
      title="答题历史记录"
      width="600px"
    >
      <div v-if="historyLoading" class="history-loading">
        <el-icon class="is-loading"><Loading /></el-icon>
        <p>加载历史记录中...</p>
      </div>
      <div v-else-if="historyRecords.length === 0" class="history-empty">
        <el-empty description="暂无历史记录" />
      </div>
      <div v-else class="history-list">
        <el-table :data="historyRecords" style="width: 100%" max-height="400">
          <el-table-column prop="answer_time" label="答题时间" width="180">
            <template #default="scope">
              {{ formatTime(scope.row.answer_time) }}
            </template>
          </el-table-column>
          <el-table-column prop="user_answer" label="我的答案" width="120">
            <template #default="scope">
              <el-tag :type="scope.row.is_correct ? 'success' : 'danger'">
                {{ scope.row.user_answer }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="is_correct" label="结果" width="80">
            <template #default="scope">
              <el-tag :type="scope.row.is_correct ? 'success' : 'danger'">
                {{ scope.row.is_correct ? '正确' : '错误' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="time_spent" label="耗时(秒)" width="100" />
        </el-table>
      </div>
      <template #footer>
        <el-button @click="historyDialogVisible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { answerApi, questionApi } from '@/api'
import { useRouter } from 'vue-router'
import { Delete } from '@element-plus/icons-vue'

const router = useRouter()
const loading = ref(false)
const wrongAnswers = ref([])
const wrongAnswersWithQuestions = ref([])
const activeNames = ref([])
const historyDialogVisible = ref(false)
const historyLoading = ref(false)
const historyRecords = ref([])
const currentQuestionId = ref(null)

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

// 加载错题
const loadWrongAnswers = async () => {
  try {
    loading.value = true
    const userId = getUserId()
    const result = await answerApi.getWrongAnswers({ userId })
    wrongAnswers.value = result.data || []

    // 加载每道错题的详细信息
    await loadQuestionDetails()
  } catch (error) {
    ElMessage.error('加载错题失败')
  } finally {
    loading.value = false
  }
}

// 加载题目详情
const loadQuestionDetails = async () => {
  const promises = wrongAnswers.value.map(async (record) => {
    try {
      const result = await questionApi.getQuestionById(record.questionId)
      return {
        ...record,
        question: result.data
      }
    } catch (error) {
      return {
        ...record,
        question: null
      }
    }
  })

  wrongAnswersWithQuestions.value = await Promise.all(promises)
}

// 格式化时间
const formatTime = (time) => {
  if (!time) return ''
  return new Date(time).toLocaleString('zh-CN')
}

// 获取难度文本
const getDifficultyText = (difficulty) => {
  const levels = ['', '非常简单', '简单', '中等', '困难', '非常困难']
  return levels[difficulty] || '中等'
}

// 获取难度类型
const getDifficultyType = (difficulty) => {
  const types = ['', 'success', 'success', '', 'warning', 'danger']
  return types[difficulty] || ''
}


// 显示历史记录
const showHistory = async (questionId) => {
  try {
    historyLoading.value = true
    historyDialogVisible.value = true
    currentQuestionId.value = questionId

    // 获取该题的所有答题记录
    const userId = getUserId()
    const result = await answerApi.getAnswerHistory({ userId })
    // 直接使用后端返回的字段名（snake_case）
    const allRecords = (result.data || []).map(item => ({
      id: item.id,
      user_id: item.user_id,
      question_id: item.question_id,
      user_answer: item.user_answer,
      is_correct: item.is_correct,
      time_spent: item.time_spent,
      answer_time: item.answer_time,
      review_count: item.review_count,
      consecutive_correct: item.consecutive_correct,
      retry_count: item.retry_count,
      notes: item.notes,
      is_in_wrongbook: item.is_in_wrongbook,
      correct_answer: item.correct_answer,
      analysis: item.analysis,
      question_title: item.question_title,
      subject: item.subject,
      topic_name: item.topic_name
    }))

    // 过滤出当前题目的记录
    historyRecords.value = allRecords.filter(record => record.question_id === questionId)
  } catch (error) {
    ElMessage.error('加载历史记录失败')
  } finally {
    historyLoading.value = false
  }
}

// 保存笔记
const saveNotes = async (recordId, notes) => {
  try {
    await answerApi.updateNotes(recordId, notes)
    ElMessage.success('笔记保存成功')
  } catch (error) {
    ElMessage.error('保存笔记失败')
  }
}

// 移出错题本
const removeFromWrongBook = async (recordId) => {
  try {
    await answerApi.removeFromWrongBook(recordId)
    ElMessage.success('已移出错题本')

    // 重新加载错题列表
    await loadWrongAnswers()
  } catch (error) {
    ElMessage.error('移出错题本失败')
  }
}

onMounted(() => {
  loadWrongAnswers()
})
</script>

<style scoped>
.wrong-book {
  max-width: 1000px;
  margin: 0 auto;
}

.wrong-card {
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

.loading-container {
  text-align: center;
  padding: 60px 0;
  color: #666;
}

.loading-container .el-icon {
  font-size: 48px;
  margin-bottom: 15px;
}

.wrong-item-title {
  display: flex;
  align-items: center;
  gap: 15px;
  width: 100%;
}

.question-preview {
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.answer-time {
  color: #999;
  font-size: 13px;
}

/* 重练次数颜色区分 */
.wrong-item-title :deep(.el-tag--warning) {
  background-color: #fff7e6;
  border-color: #ffd591;
  color: #fa8c16;
}

.wrong-item-title :deep(.el-tag--warning.is-hit) {
  border-color: #fa8c16;
}

.wrong-detail {
  padding: 15px;
}

.question-info {
  display: flex;
  gap: 10px;
  margin-bottom: 15px;
  flex-wrap: wrap;
}

.tag-item {
  margin-left: 0;
}

.question-title {
  margin: 15px 0;
  padding: 15px;
  background: #f5f7fa;
  border-radius: 8px;
}

.question-title h4 {
  font-size: 16px;
  line-height: 1.8;
  color: #333;
  margin: 0;
}

.question-options {
  margin: 15px 0;
}

.option-item {
  padding: 10px 15px;
  margin: 8px 0;
  background: #fff;
  border: 1px solid #e4e7ed;
  border-radius: 6px;
}

/* 判断题选项 */
.tf-options {
  display: flex;
  gap: 15px;
  justify-content: center;
}

.tf-options .option-item {
  min-width: 100px;
  text-align: center;
}

.answer-section {
  margin-top: 20px;
}

.notes-section {
  width: 100%;
}

.wrong-actions {
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px solid #e4e7ed;
  text-align: right;
}

.history-loading {
  text-align: center;
  padding: 30px 0;
}

.history-loading .el-icon {
  font-size: 32px;
  margin-bottom: 10px;
}
</style>