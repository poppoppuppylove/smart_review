<template>
  <div class="question-set-list">
    <h2><el-icon><Folder /></el-icon> 我的题套</h2>

    <el-empty v-if="questionSets.length === 0" description="暂无题套">
      <el-button type="primary" @click="$router.push('/import')">导入题目</el-button>
    </el-empty>

    <div v-else class="set-grid">
      <div
        v-for="set in questionSets"
        :key="set.id"
        class="set-card"
        @click="selectSet(set)"
      >
        <div class="set-header">
          <h3>{{ set.name }}</h3>
          <el-tag :type="set.isFinished ? 'success' : 'warning'">
            {{ set.isFinished ? '已完成' : '进行中' }}
          </el-tag>
        </div>
        <p class="set-description">{{ set.description || '暂无描述' }}</p>
        <p class="set-meta">
          <span>科目: {{ set.subject || '-' }}</span>
          <span>创建时间: {{ formatDate(set.createdAt) }}</span>
        </p>
        <div class="set-progress">
          <div class="progress-stats">
            <el-statistic title="总题数" :value="set.totalQuestions" />
            <el-statistic title="已做" :value="set.doneCount" />
            <el-statistic title="正确" :value="set.correctCount" class="correct" />
            <el-statistic title="错误" :value="set.wrongCount" class="wrong" />
          </div>
          <el-progress
            :percentage="getProgress(set)"
            :color="getProgressColor(set)"
          />
        </div>
        <div class="set-actions">
        <el-button type="primary" @click.stop="selectSet(set)">
          {{ set.doneCount === 0 ? '开始答题' : '继续练习' }}
        </el-button>
        <el-button @click.stop="viewAllQuestions(set)">
          查看全部题目
        </el-button>
      </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { questionSetApi } from '@/api'
import { Folder } from '@element-plus/icons-vue'

const router = useRouter()
const questionSets = ref([])

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

const loadQuestionSets = async () => {
  const userId = getUserId()
  const result = await questionSetApi.getList({ userId })
  questionSets.value = result.data || []
}

const selectSet = (set) => {
  router.push({
    path: '/practice',
    query: { questionSetId: set.id }
  })
}

const viewAllQuestions = (set) => {
  router.push({
    name: 'QuestionSetDetail',
    params: { id: set.id }
  })
}

const getProgress = (set) => {
  if (set.totalQuestions === 0) return 0
  return Math.round((set.doneCount / set.totalQuestions) * 100)
}

const getProgressColor = (set) => {
  const progress = getProgress(set)
  if (progress === 100) return '#10b981'
  if (progress >= 60) return '#f59e0b'
  return '#ef4444'
}

const formatDate = (date) => {
  return new Date(date).toLocaleString('zh-CN')
}

onMounted(() => {
  loadQuestionSets()
})
</script>

<style scoped>
.question-set-list {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.set-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
  gap: 20px;
  margin-top: 20px;
}

.set-card {
  background: #ffffff;
  border: 1px solid #e0e0e0;
  border-radius: 12px;
  padding: 24px;
  cursor: pointer;
  transition: all 0.3s;
}

.set-card:hover {
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
  transform: translateY(-2px);
}

.set-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.set-header h3 {
  margin: 0;
  font-size: 18px;
  color: #333;
}

.set-description {
  color: #666;
  line-height: 1.6;
  margin: 0 0 12px 0;
}

.set-meta {
  display: flex;
  gap: 20px;
  color: #999;
  font-size: 14px;
  margin: 0 0 20px 0;
}

.set-progress {
  margin: 20px 0;
}

.set-actions {
  display: flex;
  gap: 10px;
  margin-top: 20px;
}

.set-actions .el-button {
  flex: 1;
}

.progress-stats {
  display: flex;
  justify-content: space-around;
  margin-bottom: 16px;
}

.progress-stats .correct .el-statistic__head {
  color: #10b981;
}

.progress-stats .wrong .el-statistic__head {
  color: #ef4444;
}

.start-btn {
  width: 100%;
}
</style>
