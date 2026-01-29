<template>
  <div class="statistics">
    <div class="stats-card">
      <!-- 加载中 -->
      <div v-if="loading" class="loading-container">
        <el-icon class="is-loading" :size="48"><Loading /></el-icon>
        <p>加载统计数据中...</p>
      </div>

      <!-- 统计数据 -->
      <div v-else class="stats-content">
        <!-- 总体统计 -->
        <div class="stats-grid">
          <div class="stat-card total">
            <div class="stat-icon">
              <el-icon :size="40"><Document /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.totalCount }}</div>
              <div class="stat-label">总答题数</div>
            </div>
          </div>
          <div class="stat-card correct">
            <div class="stat-icon">
              <el-icon :size="40"><SuccessFilled /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.correctCount }}</div>
              <div class="stat-label">正确题数</div>
            </div>
          </div>
          <div class="stat-card wrong">
            <div class="stat-icon">
              <el-icon :size="40"><CircleCloseFilled /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.wrongCount }}</div>
              <div class="stat-label">错误题数</div>
            </div>
          </div>
          <div class="stat-card accuracy">
            <div class="stat-icon">
              <el-icon :size="40"><TrendCharts /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ accuracyPercent }}%</div>
              <div class="stat-label">正确率</div>
            </div>
          </div>
        </div>

        <!-- 进度条 -->
        <div class="progress-section">
          <h3>答题正确率</h3>
          <el-progress
            :percentage="accuracyPercent"
            :color="progressColor"
            :stroke-width="20"
            text-inside
          />
        </div>

        <!-- 操作按钮 -->
        <div class="action-section">
          <el-button
            type="primary"
            size="large"
            @click="showAnswerHistory"
            :disabled="stats.totalCount === 0"
          >
            <el-icon><List /></el-icon>
            查看答题历史
          </el-button>
          <el-button
            v-if="stats.wrongCount > 0"
            type="danger"
            size="large"
            @click="goToWrongBook"
          >
            <el-icon><Warning /></el-icon>
            错题本复习
          </el-button>
        </div>

        <!-- 提示信息 -->
        <el-alert
          v-if="stats.totalCount === 0"
          title="暂无答题数据"
          type="info"
          :closable="false"
          class="no-data-alert"
        >
          开始答题后,这里将显示您的学习统计数据
          <el-button type="primary" link @click="$router.push('/practice')">去答题</el-button>
        </el-alert>

        <el-alert
          v-else-if="accuracyPercent >= 80"
          title="表现优秀!"
          type="success"
          :closable="false"
          class="achievement-alert"
        >
          <p>您的正确率已达到 {{ accuracyPercent }}%,继续保持!</p>
        </el-alert>

        <el-alert
          v-else-if="accuracyPercent >= 60"
          title="继续努力!"
          type="warning"
          :closable="false"
          class="achievement-alert"
        >
          <p>您的正确率为 {{ accuracyPercent }}%,多加练习可以进一步提高哦!</p>
        </el-alert>

        <el-alert
          v-else-if="stats.totalCount > 0"
          title="需要加强"
          type="error"
          :closable="false"
          class="achievement-alert"
        >
          <p>您的正确率为 {{ accuracyPercent }}%,建议重点复习错题</p>
        </el-alert>
      </div>
    </div>

    <!-- 答题历史对话框 -->
    <el-dialog
      v-model="historyDialogVisible"
      title="答题历史记录"
      width="90%"
      top="5vh"
    >
      <div class="history-header">
        <div class="history-summary">
          <span class="summary-item">总计: {{ answerHistory.length }} 条记录</span>
          <span class="summary-item correct-text">正确: {{ correctHistoryCount }} 次</span>
          <span class="summary-item wrong-text">错误: {{ wrongHistoryCount }} 次</span>
        </div>
        <el-input
          v-model="searchKeyword"
          placeholder="搜索题目..."
          suffix-icon="Search"
          style="width: 250px"
          clearable
          @input="handleSearch"
        />
      </div>

      <el-table
        :data="paginatedHistory"
        style="width: 100%"
        :max-height="500"
        stripe
        class="history-table"
      >
        <el-table-column type="index" label="序号" width="60" />
        <el-table-column prop="question_title" label="题目" min-width="300" show-overflow-tooltip />
        <el-table-column prop="subject" label="科目" width="100">
          <template #default="{ row }">
            <el-tag size="small" type="info">{{ row.subject || '-' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="topic_name" label="知识点" width="150" show-overflow-tooltip />
        <el-table-column label="结果" width="80">
          <template #default="{ row }">
            <el-tag :type="row.is_correct ? 'success' : 'danger'" size="small">
              {{ row.is_correct ? '正确' : '错误' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="user_answer" label="我的答案" width="100" />
        <el-table-column prop="correct_answer" label="正确答案" width="100" />
        <el-table-column label="耗时" width="80">
          <template #default="{ row }">
            {{ row.time_spent ? row.time_spent + 's' : '-' }}
          </template>
        </el-table-column>
        <el-table-column label="答题时间" width="180">
          <template #default="{ row }">
            {{ formatTime(row.answer_time) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="120" fixed="right">
          <template #default="{ row }">
            <el-button
              type="primary"
              size="small"
              link
              @click="viewDetail(row)"
            >
              查看详情
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="history-pagination">
        <el-pagination
          v-model:current-page="currentPage"
          :page-size="pageSize"
          :total="totalFiltered"
          layout="total, prev, pager, next"
          @current-change="handlePageChange"
        />
      </div>
    </el-dialog>

    <!-- 答题详情对话框 -->
    <el-dialog
      v-model="detailDialogVisible"
      title="答题详情"
      width="600px"
    >
      <div v-if="currentDetail" class="detail-content">
        <div class="detail-section">
          <h4>题目内容</h4>
          <p class="question-text">{{ currentDetail.question_title }}</p>
        </div>

        <div class="detail-section">
          <el-descriptions :column="2" border>
            <el-descriptions-item label="科目">
              {{ currentDetail.subject || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="知识点">
              {{ currentDetail.topic_name || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="你的答案">
              <el-tag :type="currentDetail.is_correct ? 'success' : 'danger'" size="small">
                {{ currentDetail.user_answer }}
              </el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="正确答案">
              <el-tag type="success" size="small">{{ currentDetail.correct_answer }}</el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="答题耗时">
              {{ currentDetail.time_spent ? currentDetail.time_spent + ' 秒' : '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="答题时间">
              {{ formatTime(currentDetail.answer_time) }}
            </el-descriptions-item>
            <el-descriptions-item label="复习次数" :span="2">
              {{ currentDetail.review_count || 0 }} 次
            </el-descriptions-item>
            <el-descriptions-item label="连续正确" :span="2">
              {{ currentDetail.consecutive_correct || 0 }} 次
            </el-descriptions-item>
          </el-descriptions>
        </div>

        <div v-if="currentDetail.analysis" class="detail-section">
          <h4>答案解析</h4>
          <p class="analysis-text">{{ currentDetail.analysis }}</p>
        </div>
      </div>
      <template #footer>
        <el-button @click="detailDialogVisible = false">关闭</el-button>
        <el-button
          v-if="!currentDetail?.is_correct"
          type="primary"
          @click="goToWrongBook"
        >
          查看错题
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Loading, Document, SuccessFilled, CircleCloseFilled, TrendCharts, List, Warning, Search } from '@element-plus/icons-vue'
import { answerApi } from '@/api'

const router = useRouter()
const loading = ref(false)
const historyDialogVisible = ref(false)
const detailDialogVisible = ref(false)
const answerHistory = ref([])
const currentDetail = ref(null)
const searchKeyword = ref('')
const currentPage = ref(1)
const pageSize = ref(10)

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

const stats = ref({
  totalCount: 0,
  correctCount: 0,
  wrongCount: 0,
  accuracy: 0
})

const accuracyPercent = computed(() => {
  return stats.value.totalCount > 0
    ? Math.round((stats.value.correctCount / stats.value.totalCount) * 100)
    : 0
})

const progressColor = computed(() => {
  const percent = accuracyPercent.value
  if (percent >= 80) return '#10b981'
  if (percent >= 60) return '#f59e0b'
  return '#ef4444'
})

const correctHistoryCount = computed(() =>
  answerHistory.value.filter(h => h.is_correct).length
)

const wrongHistoryCount = computed(() =>
  answerHistory.value.filter(h => !h.is_correct).length
)

const filteredHistory = computed(() => {
  if (!searchKeyword.value) {
    return answerHistory.value
  }
  const keyword = searchKeyword.value.toLowerCase()
  return answerHistory.value.filter(h =>
    h.question_title?.toLowerCase().includes(keyword) ||
    h.subject?.toLowerCase().includes(keyword) ||
    h.topic_name?.toLowerCase().includes(keyword)
  )
})

// 分页相关计算属性
const paginatedHistory = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value
  const end = start + pageSize.value
  return filteredHistory.value.slice(start, end)
})

const totalFiltered = computed(() => {
  return filteredHistory.value.length
})

// 加载统计数据
const loadStatistics = async () => {
  try {
    loading.value = true
    const userId = getUserId()
    const result = await answerApi.getStatistics({ userId })
    stats.value = result.data || {
      totalCount: 0,
      correctCount: 0,
      wrongCount: 0,
      accuracy: 0
    }
  } catch (error) {
    ElMessage.error('加载统计数据失败')
  } finally {
    loading.value = false
  }
}

// 查看答题历史
const showAnswerHistory = async () => {
  try {
    loading.value = true
    const userId = getUserId()
    const result = await answerApi.getAnswerHistory({ userId })
    // 直接使用后端返回的字段名（snake_case）
    answerHistory.value = (result.data || []).map(item => ({
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
    historyDialogVisible.value = true
  } catch (error) {
    ElMessage.error('加载答题历史失败')
  } finally {
    loading.value = false
  }
}

// 搜索
const handleSearch = () => {
  currentPage.value = 1
}

// 分页变化
const handlePageChange = (page) => {
  currentPage.value = page
  // 滚动到表格顶部
  const tableElement = document.querySelector('.history-table')
  if (tableElement) {
    tableElement.scrollIntoView({ behavior: 'smooth', block: 'start' })
  }
}

// 格式化时间
const formatTime = (time) => {
  if (!time) return '-'
  return new Date(time).toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// 查看详情
const viewDetail = (row) => {
  currentDetail.value = row
  detailDialogVisible.value = true
}

// 跳转到错题本
const goToWrongBook = () => {
  router.push('/wrong')
}

onMounted(() => {
  loadStatistics()
})
</script>

<style scoped>
.statistics {
  max-width: 1200px;
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

.stats-card {
  background: #ffffff;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  border: 1px solid var(--border-light);
}

.stats-content h2 {
  font-size: 24px;
  color: #333;
  display: flex;
  align-items: center;
  gap: 10px;
  margin: 0 0 20px 0;
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

/* 统计卡片网格 */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.stat-card {
  display: flex;
  align-items: center;
  padding: 24px;
  border-radius: 12px;
  background: #ffffff;
  border: 1px solid var(--border-light);
  color: var(--text-primary);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
  transition: box-shadow var(--duration-base) var(--ease-out);
  cursor: pointer;
}

.stat-card:hover {
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
}

.stat-card.total .stat-value { color: var(--primary-color); }
.stat-card.correct .stat-value { color: var(--success-color); }
.stat-card.wrong .stat-value { color: var(--danger-color); }
.stat-card.accuracy .stat-value { color: var(--warning-color); }

.stat-icon {
  font-size: 48px;
  margin-right: 20px;
}

.stat-icon .el-icon {
  color: var(--text-secondary);
}

.stat-card.total .stat-icon .el-icon { color: var(--primary-color); }
.stat-card.correct .stat-icon .el-icon { color: var(--success-color); }
.stat-card.wrong .stat-icon .el-icon { color: var(--danger-color); }
.stat-card.accuracy .stat-icon .el-icon { color: var(--warning-color); }

.stat-info {
  flex: 1;
}

.stat-value {
  font-size: 32px;
  font-weight: 600;
  line-height: 1;
  margin-bottom: 8px;
}

.stat-label {
  font-size: 14px;
  color: var(--text-secondary);
  font-weight: 500;
}

/* 进度条部分 */
.progress-section {
  margin: 30px 0;
  padding: 25px;
  background: #f5f7fa;
  border-radius: 16px;
}

.progress-section h3 {
  margin: 0 0 20px 0;
  color: #333;
  font-size: 18px;
}

/* 操作按钮部分 */
.action-section {
  display: flex;
  gap: 15px;
  justify-content: center;
  margin: 30px 0;
}

.action-section .el-button {
  height: 45px;
  padding: 0 30px;
  font-size: 16px;
  font-weight: 600;
}

.action-section .el-button--primary {
  background: var(--primary-color);
  border: none;
}

.action-section .el-button--primary:hover {
  background: var(--primary-dark);
}

/* 提示信息 */
.no-data-alert,
.achievement-alert {
  margin-top: 20px;
}

.no-data-alert p,
.achievement-alert p {
  margin: 10px 0 0 0;
  line-height: 1.6;
}

/* 答题历史对话框 */
.history-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding-bottom: 15px;
  border-bottom: 1px solid #e5e7eb;
}

.history-summary {
  display: flex;
  gap: 20px;
}

.summary-item {
  font-size: 14px;
  color: #666;
}

.correct-text {
  color: #10b981;
  font-weight: 600;
}

.wrong-text {
  color: #ef4444;
  font-weight: 600;
}

.history-table {
  margin-top: 20px;
}

.history-pagination {
  margin-top: 20px;
  display: flex;
  justify-content: center;
}

/* 答题详情对话框 */
.detail-content {
  line-height: 1.8;
}

.detail-section {
  margin-bottom: 20px;
}

.detail-section h4 {
  color: #4361ee;
  margin: 0 0 12px 0;
  font-size: 16px;
}

.question-text {
  background: #f5f7fa;
  padding: 15px;
  border-radius: 8px;
  margin: 0;
  color: #333;
}

.analysis-text {
  color: #666;
  line-height: 1.8;
  margin: 0;
}

/* 响应式 */
@media (max-width: 768px) {
  .stats-grid {
    grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
    gap: 15px;
  }

  .stat-card {
    padding: 20px;
  }

  .stat-value {
    font-size: 28px;
  }

  .action-section {
    flex-direction: column;
  }

  .action-section .el-button {
    width: 100%;
  }

  .history-header {
    flex-direction: column;
    gap: 15px;
  }

  .history-summary {
    flex-wrap: wrap;
    gap: 10px;
  }
}
</style>