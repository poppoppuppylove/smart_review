<template>
  <div id="app" class="app-container">
    <!-- 登录页不显示导航栏和页脚 -->
    <template v-if="!isLoginPage">
      <!-- 顶部导航栏 -->
      <header class="app-header">
        <div class="header-wrapper">
          <!-- Logo和标题 -->
          <div class="header-brand">
            <div class="logo-icon">
              <el-icon :size="32"><Reading /></el-icon>
            </div>
            <div class="brand-text">
              <h1 class="brand-title">智能错题复习系统</h1>
              <p class="brand-subtitle">基于艾宾浩斯遗忘曲线</p>
            </div>
          </div>

          <!-- 导航菜单 -->
          <nav class="nav-menu">
            <router-link
              v-for="item in menuItems"
              :key="item.path"
              :to="item.path"
              class="nav-item"
              :class="{ active: isActive(item.path) }"
            >
              <el-icon :size="20">
                <component :is="item.icon" />
              </el-icon>
              <span class="nav-text">{{ item.label }}</span>
              <div class="nav-indicator"></div>
            </router-link>
          </nav>

          <!-- 用户信息 -->
          <div class="header-actions">
            <el-tooltip content="查看待复习" placement="bottom">
              <el-badge :value="pendingReviewCount" :hidden="pendingReviewCount === 0">
                <button class="action-btn" @click="goToReview">
                  <el-icon :size="20"><Clock /></el-icon>
                </button>
              </el-badge>
            </el-tooltip>
            <el-dropdown trigger="click" @command="handleUserCommand">
              <div class="user-avatar">
                <el-icon :size="20"><User /></el-icon>
              </div>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item command="profile">
                    <el-icon><User /></el-icon>
                    个人信息
                  </el-dropdown-item>
                  <el-dropdown-item divided command="logout">
                    <el-icon><SwitchButton /></el-icon>
                    退出登录
                  </el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </div>
        </div>
      </header>

      <!-- 主内容区 -->
      <main class="app-main">
        <div class="main-wrapper">
          <transition name="page" mode="out-in">
            <router-view />
          </transition>
        </div>
      </main>

      <!-- 页脚 -->
      <footer class="app-footer">
        <div class="footer-wrapper">
          <p class="footer-text">
            © 2026 智能错题复习系统 | 让学习更高效
          </p>
          <div class="footer-links">
            <a href="#" class="footer-link" @click.prevent="showAbout">关于</a>
            <span class="footer-divider">•</span>
            <a href="#" class="footer-link" @click.prevent="showHelp">帮助</a>
            <span class="footer-divider">•</span>
            <a href="#" class="footer-link" @click.prevent="showFeedback">反馈</a>
          </div>
        </div>
      </footer>
    </template>

    <!-- 登录页直接显示 -->
    <router-view v-else />

    <!-- 对话框 -->
    <el-dialog
      v-model="aboutDialogVisible"
      title="关于"
      width="500px"
    >
      <div class="about-content">
        <h3>智能错题复习系统</h3>
        <p>版本: 1.0.0</p>
        <p>基于艾宾浩斯遗忘曲线的智能学习系统</p>
        <p>帮助您更高效地学习和复习</p>
      </div>
    </el-dialog>

    <el-dialog
      v-model="helpDialogVisible"
      title="帮助"
      width="600px"
    >
      <div class="help-content">
        <h4>使用说明</h4>
        <ol>
          <li>导入题目:将JSON格式的题目数据导入系统</li>
          <li>在线答题:在系统中进行练习和答题</li>
          <li>错题本:查看和复习做错的题目</li>
          <li>复习计划:根据遗忘曲线安排智能复习</li>
          <li>统计分析:查看学习进度和数据统计</li>
        </ol>
        <h4>常见问题</h4>
        <p>Q: 如何导入题目?</p>
        <p>A: 在"导入题目"页面,粘贴AI生成的JSON数据或上传JSON文件即可。</p>
        <p>Q: 错题如何复习?</p>
        <p>A: 系统会根据艾宾浩斯曲线自动安排复习计划,您也可以在错题本中手动复习。</p>
      </div>
    </el-dialog>

    <el-dialog
      v-model="feedbackDialogVisible"
      title="反馈"
      width="500px"
    >
      <el-form label-width="80px">
        <el-form-item label="标题">
          <el-input v-model="feedback.title" placeholder="请输入标题" />
        </el-form-item>
        <el-form-item label="内容">
          <el-input
            v-model="feedback.content"
            type="textarea"
            :rows="5"
            placeholder="请输入反馈内容"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="feedbackDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitFeedback">提交</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="notificationsVisible" title="待复习提醒" width="400px">
      <el-empty v-if="pendingReviewCount === 0" description="暂无待复习题目" />
      <div v-else class="review-notification">
        <div class="notification-content">
          <el-icon :size="48" color="#f56c6c"><Clock /></el-icon>
          <p class="notification-text">您有 <span class="count">{{ pendingReviewCount }}</span> 道题目待复习</p>
          <p class="notification-hint">及时复习有助于巩固记忆</p>
        </div>
        <el-button type="primary" @click="goToReviewAndClose" size="large" style="width: 100%; margin-top: 20px;">
          去复习
        </el-button>
      </div>
    </el-dialog>

    <el-dialog v-model="profileDialogVisible" title="个人信息" width="400px">
      <el-form label-width="80px">
        <el-form-item label="用户名">
          <el-input v-model="currentUser.username" disabled />
        </el-form-item>
        <el-form-item label="昵称">
          <el-input v-model="currentUser.nickname" />
        </el-form-item>
        <el-form-item label="邮箱">
          <el-input v-model="currentUser.email" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="profileDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="saveProfile">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { userApi, reviewApi } from '@/api'
import { Upload, Edit, Warning, Clock, DataAnalysis, Reading, ElementPlus, User, SwitchButton } from '@element-plus/icons-vue'

const router = useRouter()
const route = useRoute()
const pendingReviewCount = ref(0)

// 判断是否为登录页
const isLoginPage = computed(() => route.path === '/login')

// 菜单项配置
const menuItems = [
  { path: '/import', label: '导入题目', icon: 'Upload' },
  { path: '/question-sets', label: '我的题套', icon: 'Folder' },
  { path: '/practice', label: '在线答题', icon: 'Edit' },
  { path: '/wrong', label: '错题本', icon: 'Warning' },
  { path: '/review', label: '复习计划', icon: 'Clock' },
  { path: '/statistics', label: '统计分析', icon: 'DataAnalysis' }
]

// 对话框状态
const aboutDialogVisible = ref(false)
const helpDialogVisible = ref(false)
const feedbackDialogVisible = ref(false)
const notificationsVisible = ref(false)
const profileDialogVisible = ref(false)

// 反馈表单
const feedback = ref({
  title: '',
  content: ''
})

// 当前用户
const currentUser = ref({
  username: 'test',
  nickname: '测试用户',
  email: 'test@example.com'
})

// 判断菜单项是否激活
const isActive = (path) => {
  return route.path === path
}

// 处理用户菜单命令
const handleUserCommand = async (command) => {
  if (command === 'logout') {
    try {
      await ElMessageBox.confirm('确定要退出登录吗?', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      })

      // 清除用户相关数据
      localStorage.removeItem('isLoggedIn')
      localStorage.removeItem('currentUser')

      ElMessage.success('已退出登录')
      router.push('/login')
    } catch {
      // 用户取消
    }
  } else if (command === 'profile') {
    profileDialogVisible.value = true
  }
}

// 页脚链接功能
const showAbout = () => {
  aboutDialogVisible.value = true
}

const showHelp = () => {
  helpDialogVisible.value = true
}

const showFeedback = () => {
  feedbackDialogVisible.value = true
}

const submitFeedback = () => {
  if (!feedback.value.title || !feedback.value.content) {
    ElMessage.warning('请填写完整的反馈信息')
    return
  }
  // 模拟提交
  ElMessage.success('感谢您的反馈!')
  feedbackDialogVisible.value = false
  feedback.value = { title: '', content: '' }
}


// 跳转到复习计划页面
const goToReview = () => {
  notificationsVisible.value = true
}

// 跳转到复习并关闭对话框
const goToReviewAndClose = () => {
  notificationsVisible.value = false
  router.push('/review')
}

const showNotifications = () => {
  notificationsVisible.value = true
}

const saveProfile = () => {
  localStorage.setItem('currentUser', JSON.stringify(currentUser.value))
  ElMessage.success('个人信息已保存')
  profileDialogVisible.value = false
}

// 加载待复习数量
const loadPendingReviewCount = async () => {
  try {
    const currentUser = JSON.parse(localStorage.getItem('currentUser') || '{}')
    const userId = currentUser.id
    if (userId) {
      const result = await reviewApi.getPendingReviews({ userId })
      pendingReviewCount.value = result.data?.length || 0
    }
  } catch (error) {
    console.error('加载待复习数量失败:', error)
  }
}

// 加载用户设置
onMounted(() => {
  const savedUser = localStorage.getItem('currentUser')
  if (savedUser) {
    try {
      Object.assign(currentUser.value, JSON.parse(savedUser))
    } catch (e) {
      console.error('解析用户信息失败:', e)
    }
  }

  // 加载待复习数量
  loadPendingReviewCount()

  // 每分钟更新一次待复习数量
  const interval = setInterval(() => {
    loadPendingReviewCount()
  }, 60000)

  // 清理定时器
  onBeforeUnmount(() => {
    clearInterval(interval)
  })
})
</script>

<style scoped>
/* ==================== 应用容器 ==================== */
.app-container {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background: var(--bg-secondary);
  position: relative;
}

/* ==================== 顶部导航栏 ==================== */
.app-header {
  background: rgba(255, 255, 255, 0.98);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  box-shadow: 0 4px 24px rgba(0, 0, 0, 0.06);
  position: sticky;
  top: 0;
  z-index: var(--z-sticky);
  border-bottom: 1px solid rgba(255, 255, 255, 0.2);
}

.header-wrapper {
  max-width: var(--container-max-width);
  margin: 0 auto;
  padding: 0 var(--space-6);
  display: flex;
  align-items: center;
  gap: var(--space-8);
  height: 72px;
}

/* Logo区域 */
.header-brand {
  display: flex;
  align-items: center;
  gap: var(--space-4);
  margin-right: var(--space-4);
}

.logo-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 48px;
  height: 48px;
  background: var(--primary-color);
  border-radius: var(--radius-md);
  color: white;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
}

.brand-text {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.brand-title {
  font-size: var(--font-size-xl);
  font-weight: var(--font-weight-bold);
  color: var(--primary-color);
  margin: 0;
  line-height: 1.2;
}

.brand-subtitle {
  font-size: var(--font-size-xs);
  color: var(--text-secondary);
  margin: 0;
  font-weight: var(--font-weight-medium);
}

/* 导航菜单 */
.nav-menu {
  flex: 1;
  display: flex;
  align-items: center;
  gap: var(--space-2);
}

.nav-item {
  position: relative;
  display: flex;
  align-items: center;
  gap: var(--space-2);
  padding: var(--space-3) var(--space-5);
  color: var(--text-secondary);
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-medium);
  text-decoration: none;
  border-radius: var(--radius-base);
  transition: all var(--duration-base) var(--ease-out);
  overflow: hidden;
}

.nav-item:hover {
  background: rgba(67, 97, 238, 0.08);
  color: #4361ee;
}

.nav-item.active {
  color: #4361ee;
  background: rgba(67, 97, 238, 0.1);
}

.nav-item.active .nav-indicator {
  transform: scaleX(1);
}

.nav-text {
  font-size: var(--font-size-sm);
  white-space: nowrap;
}

.nav-indicator {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 3px;
  background: var(--primary-color);
  border-radius: var(--radius-full);
  transform: scaleX(0);
  transition: transform var(--duration-base) var(--ease-spring);
}

/* 头部操作按钮 */
.header-actions {
  display: flex;
  align-items: center;
  gap: var(--space-3);
}

.action-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  background: transparent;
  border: none;
  border-radius: var(--radius-base);
  color: var(--text-secondary);
  cursor: pointer;
  transition: all var(--duration-base) var(--ease-out);
}

.action-btn:hover {
  background: rgba(67, 97, 238, 0.1);
  color: #4361ee;
}

.user-avatar {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  background: var(--primary-color);
  border-radius: var(--radius-full);
  color: white;
  cursor: pointer;
  transition: background-color var(--duration-base) var(--ease-out);
}

.user-avatar:hover {
  background: var(--primary-dark);
}

/* ==================== 主内容区 ==================== */
.app-main {
  flex: 1;
  padding: var(--space-8) 0;
  position: relative;
  z-index: 1;
}

.main-wrapper {
  max-width: var(--container-max-width);
  margin: 0 auto;
  padding: 0 var(--space-6);
}

/* 页面切换动画 */
.page-enter-active,
.page-leave-active {
  transition: all var(--duration-base) var(--ease-out);
}

.page-enter-from {
  opacity: 0;
  transform: translateY(20px);
}

.page-leave-to {
  opacity: 0;
  transform: translateY(-20px);
}

/* ==================== 页脚 ==================== */
.app-footer {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border-top: 1px solid rgba(255, 255, 255, 0.2);
  position: relative;
  z-index: 1;
}

.footer-wrapper {
  max-width: var(--container-max-width);
  margin: 0 auto;
  padding: var(--space-6);
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--space-4);
}

.footer-text {
  font-size: var(--font-size-sm);
  color: var(--text-secondary);
  margin: 0;
}

.footer-links {
  display: flex;
  align-items: center;
  gap: var(--space-3);
}

.footer-link {
  font-size: var(--font-size-sm);
  color: var(--text-secondary);
  text-decoration: none;
  transition: color var(--duration-base) var(--ease-out);
  cursor: pointer;
}

.footer-link:hover {
  color: #4361ee;
}

.footer-divider {
  color: var(--text-tertiary);
}

/* 对话框内容 */
.about-content h3,
.help-content h4 {
  color: #4361ee;
  margin-bottom: 16px;
}

.about-content p,
.help-content p {
  color: var(--text-secondary);
  line-height: 1.8;
  margin: 8px 0;
}

.help-content ol {
  padding-left: 20px;
  line-height: 2;
  margin: 16px 0;
}

.help-content li {
  color: var(--text-secondary);
}

.notifications-list {
  max-height: 400px;
  overflow-y: auto;
}

.notification-item {
  padding: 12px;
  border-bottom: 1px solid var(--border-light);
}

.notification-item:last-child {
  border-bottom: none;
}

.notification-title {
  margin: 0 0 4px 0;
  color: var(--text-primary);
}

.notification-time {
  margin: 0;
  font-size: 12px;
  color: var(--text-tertiary);
}

.review-notification {
  text-align: center;
  padding: 20px 0;
}

.notification-content {
  margin-bottom: 20px;
}

.notification-content .el-icon {
  margin-bottom: 16px;
}

.notification-text {
  font-size: 18px;
  color: var(--text-primary);
  margin: 10px 0;
  line-height: 1.6;
}

.notification-text .count {
  font-size: 32px;
  font-weight: bold;
  color: #f56c6c;
  margin: 0 8px;
}

.notification-hint {
  color: var(--text-secondary);
  font-size: 14px;
  margin: 8px 0 0 0;
}

/* ==================== 响应式设计 ==================== */
@media (max-width: 1024px) {
  .header-wrapper {
    padding: 0 var(--space-4);
  }

  .main-wrapper {
    padding: 0 var(--space-4);
  }
}

@media (max-width: 768px) {
  .header-wrapper {
    height: 64px;
    gap: var(--space-4);
  }

  .brand-title {
    font-size: var(--font-size-lg);
  }

  .brand-subtitle {
    display: none;
  }

  .logo-icon {
    width: 40px;
    height: 40px;
  }

  .nav-text {
    display: none;
  }

  .nav-item {
    padding: var(--space-3);
    gap: 0;
  }

  .nav-menu {
    gap: var(--space-1);
  }

  .footer-wrapper {
    flex-direction: column;
    text-align: center;
    gap: var(--space-2);
  }

  .app-main {
    padding: var(--space-4) 0;
  }
}

@media (max-width: 480px) {
  .header-actions {
    gap: var(--space-2);
  }

  .action-btn {
    width: 36px;
    height: 36px;
  }

  .user-avatar {
    width: 36px;
    height: 36px;
  }
}
</style>