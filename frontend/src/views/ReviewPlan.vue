<template>
  <div class="review-plan">
    <el-card class="review-card">
      <template #header>
        <div class="card-header">
          <h2><el-icon><Clock /></el-icon> 复习计划</h2>
          <div class="header-actions">
            <el-tag type="warning" size="large">
              待复习: {{ pendingCount }} 题
            </el-tag>
            <el-button type="primary" @click="showAddDialog">
              <el-icon><Plus /></el-icon>
              新增计划
            </el-button>
          </div>
        </div>
      </template>

      <!-- 加载中 -->
      <div v-if="loading" class="loading-container">
        <el-icon class="is-loading"><Loading /></el-icon>
        <p>加载复习计划中...</p>
      </div>

      <!-- 无计划 -->
      <el-empty v-else-if="reviewPlans.length === 0" description="暂无复习计划">
        <el-button type="primary" @click="$router.push('/practice')">去答题</el-button>
      </el-empty>

      <!-- 复习计划列表 -->
      <div v-else class="plan-list">
        <el-tabs v-model="activeTab">
          <!-- 待复习 -->
          <el-tab-pane label="待复习" name="pending">
            <div v-if="pendingPlans.length === 0" class="empty-hint">
              <el-empty description="暂无待复习题目" />
            </div>
            <div v-else class="plan-items">
              <div
                v-for="plan in pendingPlansWithQuestions"
                :key="plan.id"
                class="plan-item pending"
                @click="startReview(plan)"
              >
                <div class="plan-header">
                  <el-tag type="danger" effect="dark">待复习</el-tag>
                  <el-tag>优先级: {{ plan.priority }}</el-tag>
                  <el-tag>级别: {{ plan.reviewLevel }}</el-tag>
                  <el-tag type="success">掌握度: {{ plan.masteryScore }}%</el-tag>
                </div>
                <div class="plan-content">
                  <h4>{{ plan.question?.title }}</h4>
                  <div class="plan-time">
                    <span>上次复习: {{ formatTime(plan.lastReviewTime) }}</span>
                    <span class="next-time">下次复习: {{ formatTime(plan.nextReviewTime) }}</span>
                  </div>
                </div>
                <div class="plan-actions" @click.stop>
                  <el-button type="primary" size="small" @click="startReview(plan)">
                    <el-icon><VideoPlay /></el-icon>
                    开始复习
                  </el-button>
                  <el-button size="small" @click="skipReview(plan)">
                    <el-icon><DArrowRight /></el-icon>
                    跳过
                  </el-button>
                  <el-button size="small" @click="editPlan(plan)">
                    <el-icon><Edit /></el-icon>
                    编辑
                  </el-button>
                  <el-button type="danger" size="small" @click="deletePlan(plan.id)">
                    <el-icon><Delete /></el-icon>
                    删除
                  </el-button>
                </div>
              </div>
            </div>
          </el-tab-pane>

          <!-- 全部计划 -->
          <el-tab-pane label="全部计划" name="all">
            <div class="plan-items">
              <div
                v-for="plan in allPlansWithQuestions"
                :key="plan.id"
                class="plan-item"
                :class="{ completed: plan.isCompleted }"
              >
                <div class="plan-header">
                  <el-tag :type="plan.isCompleted ? 'success' : 'warning'">
                    {{ plan.isCompleted ? '已完成' : '进行中' }}
                  </el-tag>
                  <el-tag>优先级: {{ plan.priority }}</el-tag>
                  <el-tag>级别: {{ plan.reviewLevel }}</el-tag>
                  <el-tag type="success">掌握度: {{ plan.masteryScore }}%</el-tag>
                </div>
                <div class="plan-content">
                  <h4>{{ plan.question?.title }}</h4>
                  <div class="plan-time">
                    <span>上次复习: {{ formatTime(plan.lastReviewTime) }}</span>
                    <span class="next-time">下次复习: {{ formatTime(plan.nextReviewTime) }}</span>
                  </div>
                </div>
                <div class="plan-actions" @click.stop>
                  <el-button size="small" @click="editPlan(plan)">
                    <el-icon><Edit /></el-icon>
                    编辑
                  </el-button>
                  <el-button type="danger" size="small" @click="deletePlan(plan.id)">
                    <el-icon><Delete /></el-icon>
                    删除
                  </el-button>
                </div>
              </div>
            </div>
          </el-tab-pane>
        </el-tabs>
      </div>
    </el-card>

    <!-- 编辑对话框 -->
    <el-dialog
      v-model="editDialogVisible"
      :title="isEditMode ? '编辑复习计划' : '新增复习计划'"
      width="800px"
    >
      <div class="dialog-content">
        <!-- 艾宾浩斯遗忘曲线 -->
        <div class="ebbinghaus-curve">
          <h3><el-icon><TrendCharts /></el-icon> 艾宾浩斯遗忘曲线参考</h3>
          <div class="curve-info">
            <div class="curve-intervals">
              <div class="interval-item" v-for="(interval, index) in ebbinghausIntervals" :key="index">
                <span class="interval-label">{{ interval.label }}</span>
                <span class="interval-time">{{ interval.time }}</span>
              </div>
            </div>
            <p class="curve-desc">
              艾宾浩斯遗忘曲线表明，遗忘在学习之后立即开始，而且遗忘的进程并不是均匀的。
              最初遗忘速度很快，以后逐渐缓慢。建议按照上述时间间隔进行复习，以达到最佳记忆效果。
            </p>
          </div>
        </div>

        <el-form :model="editForm" label-width="120px">
          <el-form-item label="选择题目" v-if="!isEditMode">
            <el-select
              v-model="editForm.questionId"
              placeholder="请选择题目"
              filterable
              style="width: 100%"
            >
              <el-option
                v-for="question in availableQuestions"
                :key="question.id"
                :label="question.title"
                :value="question.id"
              >
                <div class="question-option">
                  <span class="question-title">{{ question.title }}</span>
                  <el-tag size="small">{{ question.type }}</el-tag>
                </div>
              </el-option>
            </el-select>
          </el-form-item>

          <el-form-item label="题目信息" v-else>
            <div class="question-info">
              <p>{{ currentQuestion?.title }}</p>
            </div>
          </el-form-item>

          <el-form-item label="下次复习时间">
            <el-date-picker
              v-model="editForm.nextReviewTime"
              type="datetime"
              placeholder="选择下次复习时间"
              style="width: 100%"
              :shortcuts="dateShortcuts"
            />
          </el-form-item>

          <el-form-item label="复习级别">
            <el-select v-model="editForm.reviewLevel" placeholder="请选择复习级别">
              <el-option :value="1" label="级别1 (1天后)"></el-option>
              <el-option :value="2" label="级别2 (2天后)"></el-option>
              <el-option :value="3" label="级别3 (4天后)"></el-option>
              <el-option :value="4" label="级别4 (7天后)"></el-option>
              <el-option :value="5" label="级别5 (15天后)"></el-option>
            </el-select>
          </el-form-item>

          <el-form-item label="优先级">
            <el-slider
              v-model="editForm.priority"
              :min="1"
              :max="10"
              :marks="{ 1: '低', 5: '中', 10: '高' }"
              show-stops
            />
          </el-form-item>
        </el-form>
      </div>

      <template #footer>
        <el-button @click="editDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="savePlan">保存</el-button>
      </template>
    </el-dialog>

    <!-- 答题对话框 -->
    <el-dialog
      v-model="reviewDialogVisible"
      title="复习答题"
      width="700px"
      :close-on-click-modal="false"
    >
      <div v-if="currentReviewPlan" class="review-dialog-content">
        <div class="question-content">
          <h3>{{ currentReviewPlan.question?.title }}</h3>

          <!-- 选择题选项 -->
          <div v-if="currentReviewPlan.question?.optionsList || currentReviewPlan.question?.options" class="question-options">
            <el-radio-group v-model="userAnswer" v-if="currentReviewPlan.question.type === 'single_choice'">
              <el-radio
                v-for="(option, index) in (currentReviewPlan.question.optionsList || [])"
                :key="index"
                :label="String.fromCharCode(65 + index)"
                class="option-radio"
              >
                {{ String.fromCharCode(65 + index) }}. {{ option }}
              </el-radio>
            </el-radio-group>

            <el-checkbox-group v-model="userAnswerMultiple" v-else-if="currentReviewPlan.question.type === 'multiple_choice'">
              <el-checkbox
                v-for="(option, index) in (currentReviewPlan.question.optionsList || [])"
                :key="index"
                :label="String.fromCharCode(65 + index)"
                class="option-checkbox"
              >
                {{ String.fromCharCode(65 + index) }}. {{ option }}
              </el-checkbox>
            </el-checkbox-group>

            <el-radio-group v-model="userAnswer" v-else-if="currentReviewPlan.question.type === 'true_false'" class="tf-options">
              <el-radio label="正确" class="tf-option">正确</el-radio>
              <el-radio label="错误" class="tf-option">错误</el-radio>
            </el-radio-group>
          </div>

          <!-- 填空题/问答题 -->
          <div v-else class="question-input">
            <el-input
              v-model="userAnswer"
              type="textarea"
              :rows="4"
              placeholder="请输入你的答案"
            />
          </div>

          <div v-if="showAnswer" class="answer-section">
            <el-divider />
            <div class="correct-answer">
              <h4>正确答案:</h4>
              <p>{{ answerResult?.correctAnswer }}</p>
            </div>
            <div class="analysis" v-if="answerResult?.analysis">
              <h4>答案解析:</h4>
              <p>{{ answerResult.analysis }}</p>
            </div>
            <div class="review-count" v-if="answerResult?.reviewCount !== undefined">
              <h4>复习次数:</h4>
              <p>{{ answerResult.reviewCount }} 次</p>
            </div>
            <div class="consecutive-correct" v-if="answerResult?.consecutiveCorrect !== undefined">
              <h4>连续正确:</h4>
              <p>{{ answerResult.consecutiveCorrect }} 次</p>
            </div>
          </div>
        </div>

        <div class="review-timer">
          答题用时: {{ reviewTimer }} 秒
        </div>
      </div>

      <template #footer>
        <div v-if="!showAnswer">
          <el-button @click="reviewDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="submitAnswer">提交答案</el-button>
        </div>
        <div v-else>
          <el-button @click="finishReview(false)">答错了</el-button>
          <el-button type="success" @click="finishReview(true)">答对了</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Clock, Loading, Plus, Edit, Delete, VideoPlay, DArrowRight, TrendCharts
} from '@element-plus/icons-vue'
import { reviewApi, questionApi, answerApi } from '@/api'

const loading = ref(false)
const activeTab = ref('pending')
const reviewPlans = ref([])
const pendingPlans = ref([])
const pendingPlansWithQuestions = ref([])
const allPlansWithQuestions = ref([])

const editDialogVisible = ref(false)
const isEditMode = ref(false)
const editForm = ref({
  id: null,
  questionId: null,
  nextReviewTime: null,
  reviewLevel: 1,
  priority: 5
})

const availableQuestions = ref([])
const currentQuestion = ref(null)

const reviewDialogVisible = ref(false)
const currentReviewPlan = ref(null)
const userAnswer = ref('')
const userAnswerMultiple = ref([])
const showAnswer = ref(false)
const answerResult = ref(null)
const reviewTimer = ref(0)
let reviewTimerInterval = null

const pendingCount = computed(() => pendingPlans.value.length)

// 艾宾浩斯遗忘曲线时间间隔
const ebbinghausIntervals = [
  { label: '第1次', time: '学习后5分钟' },
  { label: '第2次', time: '学习后30分钟' },
  { label: '第3次', time: '学习后12小时' },
  { label: '第4次', time: '学习后1天' },
  { label: '第5次', time: '学习后2天' },
  { label: '第6次', time: '学习后4天' },
  { label: '第7次', time: '学习后7天' },
  { label: '第8次', time: '学习后15天' }
]

// 日期快捷选项
const dateShortcuts = [
  {
    text: '1天后',
    value: () => {
      const date = new Date()
      date.setDate(date.getDate() + 1)
      return date
    }
  },
  {
    text: '2天后',
    value: () => {
      const date = new Date()
      date.setDate(date.getDate() + 2)
      return date
    }
  },
  {
    text: '4天后',
    value: () => {
      const date = new Date()
      date.setDate(date.getDate() + 4)
      return date
    }
  },
  {
    text: '7天后',
    value: () => {
      const date = new Date()
      date.setDate(date.getDate() + 7)
      return date
    }
  },
  {
    text: '15天后',
    value: () => {
      const date = new Date()
      date.setDate(date.getDate() + 15)
      return date
    }
  }
]

// 加载复习计划
const loadReviewPlans = async () => {
  try {
    loading.value = true

    // 获取当前用户ID
    const currentUser = JSON.parse(localStorage.getItem('currentUser') || '{}')
    const userId = currentUser.id

    // 加载待复习
    const pendingResult = await reviewApi.getPendingReviews({ userId })
    pendingPlans.value = pendingResult.data || []

    // 加载全部计划
    const allResult = await reviewApi.getAllReviewPlans({ userId })
    reviewPlans.value = allResult.data || []

    // 加载题目详情
    await loadQuestionDetails()
  } catch (error) {
    ElMessage.error('加载复习计划失败')
  } finally {
    loading.value = false
  }
}

// 加载题目详情
const loadQuestionDetails = async () => {
  // 待复习题目详情
  const pendingPromises = pendingPlans.value.map(async (plan) => {
    try {
      if (!plan.questionId) {
        console.warn('计划缺少questionId:', plan)
        return {
          ...plan,
          question: null
        }
      }
      const result = await questionApi.getQuestionById(plan.questionId)
      return {
        ...plan,
        question: result.data
      }
    } catch (error) {
      console.error(`加载题目详情失败 (questionId: ${plan.questionId}):`, error)
      return {
        ...plan,
        question: null
      }
    }
  })
  pendingPlansWithQuestions.value = await Promise.all(pendingPromises)
  console.log('待复习计划（含题目详情）:', pendingPlansWithQuestions.value)

  // 全部计划题目详情
  const allPromises = reviewPlans.value.map(async (plan) => {
    try {
      if (!plan.questionId) {
        console.warn('计划缺少questionId:', plan)
        return {
          ...plan,
          question: null
        }
      }
      const result = await questionApi.getQuestionById(plan.questionId)
      return {
        ...plan,
        question: result.data
      }
    } catch (error) {
      console.error(`加载题目详情失败 (questionId: ${plan.questionId}):`, error)
      return {
        ...plan,
        question: null
      }
    }
  })
  allPlansWithQuestions.value = await Promise.all(allPromises)
  console.log('全部计划（含题目详情）:', allPlansWithQuestions.value)
}

// 加载可用题目列表
const loadAvailableQuestions = async () => {
  try {
    // 获取当前用户ID
    const currentUser = JSON.parse(localStorage.getItem('currentUser') || '{}')
    const userId = currentUser.id
    const result = await questionApi.getQuestions({ userId })
    availableQuestions.value = result.data || []
  } catch (error) {
    ElMessage.error('加载题目列表失败')
  }
}

// 格式化时间
const formatTime = (time) => {
  if (!time) return '未设置'
  return new Date(time).toLocaleString('zh-CN')
}

// 显示新增对话框
const showAddDialog = async () => {
  isEditMode.value = false
  editForm.value = {
    id: null,
    questionId: null,
    nextReviewTime: new Date(Date.now() + 86400000), // 默认1天后
    reviewLevel: 1,
    priority: 5
  }
  await loadAvailableQuestions()
  editDialogVisible.value = true
}

// 编辑计划
const editPlan = async (plan) => {
  // 确保plan对象包含所有必要字段
  if (!plan || !plan.id) {
    ElMessage.error('复习计划数据不完整')
    return
  }

  isEditMode.value = true
  currentQuestion.value = plan.question

  // 确保所有必要字段都被正确设置
  editForm.value = {
    id: plan.id,
    questionId: plan.questionId,
    nextReviewTime: plan.nextReviewTime ? new Date(plan.nextReviewTime) : null,
    reviewLevel: plan.reviewLevel || 1,
    priority: plan.priority || 5
  }

  console.log('编辑计划数据:', editForm.value)  // 调试日志
  editDialogVisible.value = true
}

// 保存计划
const savePlan = async () => {
  try {
    if (!isEditMode.value && !editForm.value.questionId) {
      ElMessage.warning('请选择题目')
      return
    }

    if (!editForm.value.nextReviewTime) {
      ElMessage.warning('请选择下次复习时间')
      return
    }

    // 获取当前用户ID
    const currentUser = JSON.parse(localStorage.getItem('currentUser') || '{}')
    const userId = currentUser.id

    const data = {
      questionId: editForm.value.questionId,
      nextReviewTime: editForm.value.nextReviewTime,
      reviewLevel: editForm.value.reviewLevel,
      priority: editForm.value.priority,
      lastReviewTime: new Date(),
      masteryScore: 0,
      isCompleted: false
    }

    if (isEditMode.value) {
      // 编辑模式：保留现有数据，只更新用户指定的字段
      await reviewApi.updateReviewPlan(editForm.value.id, data, { userId })
      ElMessage.success('更新成功')
    } else {
      // 新增时将userId放在data中
      data.userId = userId
      await reviewApi.createReviewPlan(data)
      ElMessage.success('创建成功')
    }

    editDialogVisible.value = false
    await loadReviewPlans()
  } catch (error) {
    ElMessage.error(error.message || '操作失败')
  }
}

// 删除计划
const deletePlan = async (id) => {
  try {
    await ElMessageBox.confirm('确定要删除这个复习计划吗?', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })

    // 获取当前用户ID
const currentUser = JSON.parse(localStorage.getItem('currentUser') || '{}')
const userId = currentUser.id
await reviewApi.deleteReviewPlan(id, { userId })
    ElMessage.success('删除成功')
    await loadReviewPlans()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

// 跳过复习
const skipReview = async (plan) => {
  try {
    await ElMessageBox.confirm('确定要跳过本次复习，进入下一周期吗?', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'info'
    })

    // 确保plan.id存在
    if (!plan || !plan.id) {
      ElMessage.error('复习计划数据不完整')
      return
    }

    // 获取当前用户ID
const currentUser = JSON.parse(localStorage.getItem('currentUser') || '{}')
const userId = currentUser.id
await reviewApi.skipReview(plan.id, { userId })
    ElMessage.success('已跳过')
    await loadReviewPlans()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '操作失败: 复习计划不存在')
    }
  }
}

// 开始复习
const startReview = (plan) => {
  // 确保plan对象包含必要的数据
  if (!plan || !plan.id || !plan.question) {
    ElMessage.error('复习计划数据不完整')
    return
  }

  currentReviewPlan.value = plan
  userAnswer.value = ''
  userAnswerMultiple.value = []
  showAnswer.value = false
  answerResult.value = null
  reviewTimer.value = 0
  reviewDialogVisible.value = true

  // 启动计时器
  reviewTimerInterval = setInterval(() => {
    reviewTimer.value++
  }, 1000)
}

// 提交答案
const submitAnswer = async () => {
  try {
    // 停止计时器
    if (reviewTimerInterval) {
      clearInterval(reviewTimerInterval)
      reviewTimerInterval = null
    }

    // 处理用户答案
    let answer = userAnswer.value
    if (currentReviewPlan.value.question.type === 'multiple_choice') {
      answer = userAnswerMultiple.value.sort().join(',')
    }

    // 获取userId
    const currentUser = JSON.parse(localStorage.getItem('currentUser') || '{}')
    const userId = currentUser.id

    // 提交答案到后端
    const result = await answerApi.submitAnswer({
      questionId: currentReviewPlan.value.question.id,
      userAnswer: answer,
      timeSpent: reviewTimer.value
    }, userId)

    // 更新答案结果显示
    answerResult.value = result.data
    showAnswer.value = true
  } catch (error) {
    ElMessage.error('提交答案失败: ' + (error.message || '网络错误'))
  }
}

// 完成复习
const finishReview = async (isCorrect) => {
  try {
    // 确保currentReviewPlan存在且有id
    if (!currentReviewPlan.value || !currentReviewPlan.value.id) {
      ElMessage.error('复习计划数据不完整')
      return
    }

    // 获取当前用户ID
const currentUser = JSON.parse(localStorage.getItem('currentUser') || '{}')
const userId = currentUser.id
await reviewApi.completeReview(
      currentReviewPlan.value.id,
      isCorrect,
      reviewTimer.value,
      { userId }
    )

    ElMessage.success('复习完成，已更新下次复习时间')
    reviewDialogVisible.value = false
    currentReviewPlan.value = null
    answerResult.value = null

    await loadReviewPlans()
  } catch (error) {
    ElMessage.error(error.message || '操作失败')
  }
}

onMounted(() => {
  loadReviewPlans()
})

onBeforeUnmount(() => {
  if (reviewTimerInterval) {
    clearInterval(reviewTimerInterval)
  }
})
</script>

<style scoped>
.review-plan {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.review-card {
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

.header-actions {
  display: flex;
  gap: 15px;
  align-items: center;
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

.empty-hint {
  padding: 40px 0;
}

.plan-items {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.plan-item {
  padding: 20px;
  background: #fff;
  border: 2px solid #e4e7ed;
  border-radius: 12px;
  transition: all 0.3s;
  cursor: pointer;
}

.plan-item:hover {
  border-color: #409eff;
  box-shadow: 0 4px 12px rgba(64, 158, 255, 0.2);
}

.plan-item.pending {
  border-left: 4px solid #f56c6c;
}

.plan-item.completed {
  opacity: 0.7;
  border-left: 4px solid #67c23a;
}

.plan-header {
  display: flex;
  gap: 10px;
  margin-bottom: 15px;
  flex-wrap: wrap;
}

.plan-content h4 {
  font-size: 16px;
  line-height: 1.8;
  color: #333;
  margin: 10px 0;
}

.plan-time {
  display: flex;
  justify-content: space-between;
  color: #666;
  font-size: 13px;
  margin-top: 10px;
}

.next-time {
  color: #f56c6c;
  font-weight: 600;
}

.plan-actions {
  display: flex;
  gap: 10px;
  margin-top: 15px;
  padding-top: 15px;
  border-top: 1px solid #e4e7ed;
}

/* 艾宾浩斯遗忘曲线样式 */
.ebbinghaus-curve {
  margin-bottom: 25px;
  padding: 20px;
  background: #f5f7fa;
  border-radius: 12px;
}

.ebbinghaus-curve h3 {
  display: flex;
  align-items: center;
  gap: 8px;
  margin: 0 0 15px 0;
  color: #333;
  font-size: 18px;
}

.curve-intervals {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 12px;
  margin-bottom: 20px;
}

.interval-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;
  background: white;
  border-radius: 8px;
  border-left: 3px solid #409eff;
  transition: all 0.3s;
}

.interval-item:hover {
  transform: translateX(5px);
  box-shadow: 0 2px 8px rgba(64, 158, 255, 0.2);
}

.interval-label {
  color: #409eff;
  font-weight: 600;
  font-size: 14px;
}

.interval-time {
  color: #666;
  font-size: 13px;
}

.curve-desc {
  color: #666;
  font-size: 13px;
  line-height: 1.8;
  margin: 0;
  padding: 15px;
  background: white;
  border-radius: 8px;
  border-left: 3px solid #67c23a;
}

/* 对话框样式 */
.dialog-content {
  max-height: 70vh;
  overflow-y: auto;
}

.question-option {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
}

.question-title {
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.question-info {
  padding: 15px;
  background: #f5f7fa;
  border-radius: 8px;
}

.question-info p {
  margin: 0;
  color: #333;
  font-size: 14px;
}

/* 答题对话框样式 */
.review-dialog-content {
  padding: 10px 0;
}

.question-content h3 {
  font-size: 18px;
  color: #333;
  margin-bottom: 20px;
  line-height: 1.6;
}

.question-options {
  margin: 20px 0;
}

.option-radio,
.option-checkbox {
  display: flex;
  align-items: center;
  margin-bottom: 15px;
  padding: 12px;
  border: 2px solid #e4e7ed;
  border-radius: 8px;
  transition: all 0.3s;
  min-height: 50px;
}

.option-radio:hover,
.option-checkbox:hover {
  border-color: #409eff;
  background: #f0f7ff;
}

/* 判断题选项 */
.tf-options {
  display: flex;
  gap: 20px;
  margin: 20px 0;
  justify-content: center;
}

.tf-option {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 12px 30px;
  border: 2px solid #e4e7ed;
  border-radius: 8px;
  transition: all 0.3s;
  cursor: pointer;
  min-width: 120px;
  text-align: center;
}

.tf-option:hover {
  border-color: #409eff;
  background: #f0f7ff;
}

.question-input {
  margin: 20px 0;
}

.answer-section {
  margin-top: 20px;
}

.correct-answer,
.analysis,
.review-count,
.consecutive-correct {
  margin-bottom: 15px;
}

.correct-answer h4,
.analysis h4,
.review-count h4,
.consecutive-correct h4 {
  font-size: 16px;
  color: #409eff;
  margin-bottom: 10px;
}

.correct-answer p,
.analysis p,
.review-count p,
.consecutive-correct p {
  font-size: 14px;
  color: #333;
  line-height: 1.6;
  margin: 0;
}

.review-timer {
  text-align: center;
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px solid #e4e7ed;
  color: #666;
  font-size: 14px;
}

/* 响应式 */
@media (max-width: 768px) {
  .card-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 15px;
  }

  .plan-actions {
    flex-wrap: wrap;
  }

  .curve-intervals {
    grid-template-columns: 1fr;
  }
}
</style>
