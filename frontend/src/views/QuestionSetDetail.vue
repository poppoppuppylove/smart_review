<template>
  <div class="question-set-detail">
    <!-- 加载中 -->
    <div v-if="loading" class="loading-container">
      <el-icon class="is-loading" :size="48"><Loading /></el-icon>
      <p>加载题套详情中...</p>
    </div>

    <!-- 题套详情 -->
    <div v-else class="detail-content">
      <!-- 题套信息 -->
      <div class="set-header">
        <div class="set-info">
          <h2>
            <el-input
              v-if="editingName"
              v-model="editForm.name"
              size="large"
              @blur="saveName"
              @keyup.enter="saveName"
              ref="nameInput"
            />
            <span v-else @click="startEditName">{{ questionSet.name }}</span>
            <el-button
              v-if="!editingName"
              type="text"
              @click="startEditName"
              class="edit-btn"
            >
              <el-icon><Edit /></el-icon>
            </el-button>
          </h2>
          <p class="set-description">
            <el-input
              v-if="editingDescription"
              v-model="editForm.description"
              type="textarea"
              :rows="3"
              @blur="saveDescription"
              @keyup.enter="saveDescription"
              ref="descriptionInput"
            />
            <span v-else @click="startEditDescription">{{ questionSet.description || '暂无描述' }}</span>
            <el-button
              v-if="!editingDescription"
              type="text"
              @click="startEditDescription"
              class="edit-btn"
            >
              <el-icon><Edit /></el-icon>
            </el-button>
          </p>
          <div class="set-meta">
            <span>科目: {{ questionSet.subject || '-' }}</span>
            <span>创建时间: {{ formatDate(questionSet.createdAt) }}</span>
            <span>总题数: {{ questionSet.totalQuestions }}</span>
          </div>
        </div>
        <div class="set-stats">
          <div class="stats-grid">
            <div class="stat-card">
              <el-statistic title="已做" :value="questionSet.doneCount" />
            </div>
            <div class="stat-card correct">
              <el-statistic title="正确" :value="questionSet.correctCount" />
            </div>
            <div class="stat-card wrong">
              <el-statistic title="错误" :value="questionSet.wrongCount" />
            </div>
            <div class="stat-card">
              <el-statistic title="进度" :value="progressPercent" suffix="%" />
            </div>
          </div>
        </div>
      </div>

      <!-- 题目列表 -->
      <div class="questions-section">
        <div class="section-header">
          <h3>题目列表 ({{ questions.length }} 题)</h3>
          <div class="section-actions">
            <el-button @click="practiceAll">开始练习</el-button>
          </div>
        </div>

        <el-empty v-if="questions.length === 0" description="该题套下暂无题目" />

        <div v-else class="questions-list">
          <div
            v-for="(question, index) in questions"
            :key="question.id"
            class="question-item"
            :class="{ expanded: expandedQuestions.has(question.id) }"
          >
            <div class="question-header" @click="toggleQuestion(question.id)">
              <div class="question-basic">
                <span class="question-number">{{ index + 1 }}.</span>
                <span class="question-title">{{ question.title }}</span>
                <el-tag :type="getDifficultyType(question.difficulty)" size="small">
                  {{ getDifficultyText(question.difficulty) }}
                </el-tag>
              </div>
              <div class="question-actions">
                <el-tag
                  v-for="tag in question.tagsList"
                  :key="tag"
                  size="small"
                  type="info"
                  class="tag-item"
                >
                  {{ tag }}
                </el-tag>
                <el-icon class="expand-icon">
                  <ArrowDown v-if="!expandedQuestions.has(question.id)" />
                  <ArrowUp v-else />
                </el-icon>
              </div>
            </div>

            <div v-show="expandedQuestions.has(question.id)" class="question-detail">
              <!-- 选项 -->
              <div v-if="question.optionsList && question.optionsList.length > 0" class="question-options">
                <h4>选项</h4>
                <div class="options-list">
                  <div
                    v-for="(option, optIndex) in question.optionsList"
                    :key="optIndex"
                    class="option-item"
                  >
                    <span class="option-label">{{ String.fromCharCode(65 + optIndex) }}.</span>
                    <span class="option-text">{{ option }}</span>
                  </div>
                </div>
              </div>

              <!-- 答案 -->
              <div class="question-answer">
                <h4>答案</h4>
                <p class="answer-text">{{ formatAnswer(question.correctAnswer, question.type) }}</p>
              </div>

              <!-- 解析 -->
              <div v-if="question.analysis" class="question-analysis">
                <h4>解析</h4>
                <p class="analysis-text">{{ question.analysis }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, nextTick } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Loading, Edit, ArrowDown, ArrowUp } from '@element-plus/icons-vue'
import { questionSetApi } from '@/api'

const route = useRoute()
const router = useRouter()
const loading = ref(false)
const questionSet = ref({})
const questions = ref([])
const expandedQuestions = ref(new Set())

// 编辑状态
const editingName = ref(false)
const editingDescription = ref(false)
const editForm = ref({
  name: '',
  description: ''
})
const nameInput = ref(null)
const descriptionInput = ref(null)

// 计算属性
const progressPercent = ref(0)

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

// 格式化时间
const formatDate = (date) => {
  if (!date) return '-'
  return new Date(date).toLocaleString('zh-CN')
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

// 格式化答案
const formatAnswer = (answer, type) => {
  if (!answer) return '-'

  if (type === 'single_choice') {
    return answer
  } else if (type === 'multiple_choice') {
    return answer.split(',').join(', ')
  } else {
    return answer
  }
}

// 切换题目展开/收起
const toggleQuestion = (questionId) => {
  if (expandedQuestions.value.has(questionId)) {
    expandedQuestions.value.delete(questionId)
  } else {
    expandedQuestions.value.add(questionId)
  }
}

// 开始编辑名称
const startEditName = () => {
  editingName.value = true
  editForm.value.name = questionSet.value.name
  nextTick(() => {
    nameInput.value?.focus()
  })
}

// 保存名称
const saveName = async () => {
  try {
    const userId = getUserId()
    await questionSetApi.update(questionSet.value.id, { name: editForm.value.name }, { userId })
    questionSet.value.name = editForm.value.name
    ElMessage.success('题套名称已更新')
  } catch (error) {
    ElMessage.error('更新失败: ' + (error.message || '网络错误'))
  } finally {
    editingName.value = false
  }
}

// 开始编辑描述
const startEditDescription = () => {
  editingDescription.value = true
  editForm.value.description = questionSet.value.description || ''
  nextTick(() => {
    descriptionInput.value?.focus()
  })
}

// 保存描述
const saveDescription = async () => {
  try {
    const userId = getUserId()
    await questionSetApi.update(questionSet.value.id, { description: editForm.value.description }, { userId })
    questionSet.value.description = editForm.value.description
    ElMessage.success('题套描述已更新')
  } catch (error) {
    ElMessage.error('更新失败: ' + (error.message || '网络错误'))
  } finally {
    editingDescription.value = false
  }
}

// 开始练习
const practiceAll = () => {
  router.push({
    path: '/practice',
    query: { questionSetId: questionSet.value.id, showAll: 'true' }
  })
}

// 加载题套详情
const loadQuestionSetDetail = async () => {
  try {
    loading.value = true
    const setId = route.params.id
    const userId = getUserId()

    // 获取题套详情
    const detailResult = await questionSetApi.getDetail(setId, { userId })
    const data = detailResult.data

    questionSet.value = data.questionSet
    questions.value = data.allQuestions || []

    // 计算进度百分比
    progressPercent.value = data.questionSet.totalQuestions > 0
      ? Math.round((data.questionSet.doneCount / data.questionSet.totalQuestions) * 100)
      : 0
  } catch (error) {
    ElMessage.error('加载题套详情失败: ' + (error.message || '网络错误'))
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadQuestionSetDetail()
})
</script>

<style scoped>
.question-set-detail {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
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

.loading-container {
  text-align: center;
  padding: 60px 0;
  color: #666;
}

.loading-container .el-icon {
  font-size: 48px;
  margin-bottom: 15px;
  color: #4361ee;
}

/* 题套信息 */
.set-header {
  background: #ffffff;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  border: 1px solid var(--border-light);
  margin-bottom: 20px;
}

.set-info h2 {
  font-size: 24px;
  color: #333;
  margin: 0 0 15px 0;
  display: flex;
  align-items: center;
  gap: 10px;
}

.set-info h2 span {
  cursor: pointer;
  padding: 5px 10px;
  border-radius: 6px;
  transition: background-color 0.2s;
}

.set-info h2 span:hover {
  background-color: #f5f7fa;
}

.set-description {
  color: #666;
  line-height: 1.6;
  margin: 0 0 15px 0;
  cursor: pointer;
  padding: 10px;
  border-radius: 6px;
  transition: background-color 0.2s;
}

.set-description:hover {
  background-color: #f5f7fa;
}

.set-meta {
  display: flex;
  gap: 20px;
  color: #999;
  font-size: 14px;
  margin-bottom: 20px;
}

.set-stats {
  padding-top: 20px;
  border-top: 1px solid #e5e7eb;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
  gap: 15px;
}

.stat-card {
  text-align: center;
  padding: 15px;
  background: #f5f7fa;
  border-radius: 8px;
}

.stat-card.correct {
  background: #f0fdf4;
  border-left: 4px solid #10b981;
}

.stat-card.wrong {
  background: #fef2f2;
  border-left: 4px solid #ef4444;
}

/* 题目列表 */
.questions-section {
  background: #ffffff;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  border: 1px solid var(--border-light);
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.section-header h3 {
  margin: 0;
  font-size: 20px;
  color: #333;
}

.question-item {
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  margin-bottom: 15px;
  overflow: hidden;
  transition: all 0.3s;
}

.question-item:hover {
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.question-item.expanded {
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
}

.question-header {
  padding: 15px 20px;
  cursor: pointer;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: #ffffff;
  transition: background-color 0.2s;
}

.question-header:hover {
  background: #f5f7fa;
}

.question-basic {
  display: flex;
  align-items: center;
  gap: 10px;
  flex: 1;
}

.question-number {
  font-weight: 600;
  color: #4361ee;
}

.question-title {
  flex: 1;
  color: #333;
  line-height: 1.5;
}

.question-actions {
  display: flex;
  align-items: center;
  gap: 10px;
}

.tag-item {
  margin-left: 0;
}

.expand-icon {
  color: #999;
  transition: transform 0.3s;
}

.question-detail {
  padding: 20px;
  background: #f9fafb;
  border-top: 1px solid #e5e7eb;
}

.question-options {
  margin-bottom: 20px;
}

.question-options h4 {
  margin: 0 0 10px 0;
  color: #4361ee;
  font-size: 16px;
}

.options-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.option-item {
  display: flex;
  gap: 10px;
  padding: 8px 12px;
  background: #ffffff;
  border-radius: 6px;
  border: 1px solid #e5e7eb;
}

.option-label {
  font-weight: 600;
  color: #4361ee;
}

.option-text {
  flex: 1;
  color: #333;
}

.question-answer, .question-analysis {
  margin-bottom: 20px;
}

.question-answer h4, .question-analysis h4 {
  margin: 0 0 10px 0;
  color: #4361ee;
  font-size: 16px;
}

.answer-text, .analysis-text {
  padding: 12px;
  background: #ffffff;
  border-radius: 6px;
  border: 1px solid #e5e7eb;
  color: #333;
  line-height: 1.6;
}

.edit-btn {
  margin-left: 10px;
  color: #4361ee;
}

.edit-btn:hover {
  color: #3b82f6;
}

/* 响应式 */
@media (max-width: 768px) {
  .question-set-detail {
    padding: 15px;
  }

  .set-header {
    padding: 20px;
  }

  .set-info h2 {
    font-size: 20px;
  }

  .set-meta {
    flex-direction: column;
    gap: 5px;
  }

  .section-header {
    flex-direction: column;
    gap: 15px;
    align-items: flex-start;
  }

  .question-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 10px;
  }

  .question-actions {
    width: 100%;
    justify-content: space-between;
  }
}
</style>
