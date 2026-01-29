<template>
  <div class="login-container">
    <div class="login-card">
      <div class="login-header">
        <div class="logo">
          <el-icon :size="48" color="#1976d2"><Reading /></el-icon>
        </div>
        <h1 class="title">智能错题复习系统</h1>
        <p class="subtitle">基于艾宾浩斯遗忘曲线的学习助手</p>
      </div>

      <el-form
        ref="loginFormRef"
        :model="loginForm"
        :rules="loginRules"
        class="login-form"
        @submit.prevent="handleLogin"
      >
        <el-form-item prop="username">
          <el-input
            v-model="loginForm.username"
            placeholder="请输入用户名"
            size="large"
            prefix-icon="User"
            clearable
          />
        </el-form-item>

        <el-form-item prop="password">
          <el-input
            v-model="loginForm.password"
            type="password"
            placeholder="请输入密码"
            size="large"
            prefix-icon="Lock"
            show-password
            @keyup.enter="handleLogin"
          />
        </el-form-item>

        <el-form-item>
          <el-button
            type="primary"
            size="large"
            class="login-button"
            :loading="loading"
            @click="handleLogin"
          >
            {{ loading ? '登录中...' : '登录' }}
          </el-button>
        </el-form-item>
      </el-form>

      <div class="login-footer">
        <p class="hint">默认测试账号: test / test</p>
        <p class="register-link">
          还没有账户?
          <el-button type="primary" link @click="$router.push('/register')">立即注册</el-button>
        </p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Reading, User, Lock } from '@element-plus/icons-vue'
import { userApi } from '@/api'

const router = useRouter()
const loginFormRef = ref()

const loginForm = reactive({
  username: '',
  password: ''
})

const loginRules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 20, message: '用户名长度应在3-20个字符之间', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 4, max: 20, message: '密码长度应在4-20个字符之间', trigger: 'blur' }
  ]
}

const loading = ref(false)

const handleLogin = async () => {
  if (!loginFormRef.value) return

  await loginFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        loading.value = true

        // 调用登录API
        const result = await userApi.login({
          username: loginForm.username,
          password: loginForm.password
        })

        if (result.code === 200) {
          // 保存登录状态(简化处理,实际应该用Vuex或Pinia)
          localStorage.setItem('isLoggedIn', 'true')
          localStorage.setItem('currentUser', JSON.stringify(result.data))

          ElMessage.success('登录成功')
          router.push('/import')
        } else {
          ElMessage.error(result.message || '登录失败')
        }
      } catch (error) {
        ElMessage.error('登录失败: ' + (error.message || '网络错误'))
      } finally {
        loading.value = false
      }
    }
  })
}

// 如果已经登录,直接跳转到导入页面
if (localStorage.getItem('isLoggedIn') === 'true') {
  router.push('/import')
}
</script>

<style scoped>
.login-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--bg-secondary);
  padding: 20px;
}

.login-card {
  width: 100%;
  max-width: 400px;
  background: #ffffff;
  border-radius: 12px;
  padding: 40px 30px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
}

.login-header {
  text-align: center;
  margin-bottom: 30px;
}

.logo {
  margin-bottom: 20px;
}

.title {
  font-size: 24px;
  font-weight: 700;
  color: #333;
  margin: 0 0 8px 0;
}

.subtitle {
  font-size: 14px;
  color: #666;
  margin: 0;
}

.login-form {
  margin-bottom: 20px;
}

.login-button {
  width: 100%;
  background: var(--primary-color);
  border: none;
  font-weight: 600;
}

.login-button:hover {
  background: var(--primary-dark);
}

.login-footer {
  text-align: center;
}

.hint {
  font-size: 12px;
  color: #999;
  margin: 0 0 10px 0;
}

.register-link {
  font-size: 14px;
  color: #666;
  margin: 0;
}

.register-link .el-button {
  font-weight: 600;
}
</style>