<template>
  <div class="register-container">
    <div class="register-card">
      <div class="register-header">
        <div class="logo">
          <el-icon :size="48" color="#1976d2"><Reading /></el-icon>
        </div>
        <h1 class="title">用户注册</h1>
        <p class="subtitle">创建您的智能错题复习账户</p>
      </div>

      <el-form
        ref="registerFormRef"
        :model="registerForm"
        :rules="registerRules"
        class="register-form"
        @submit.prevent="handleRegister"
      >
        <el-form-item prop="username">
          <el-input
            v-model="registerForm.username"
            placeholder="请输入用户名"
            size="large"
            prefix-icon="User"
            clearable
          />
        </el-form-item>

        <el-form-item prop="password">
          <el-input
            v-model="registerForm.password"
            type="password"
            placeholder="请输入密码"
            size="large"
            prefix-icon="Lock"
            show-password
          />
        </el-form-item>

        <el-form-item prop="confirmPassword">
          <el-input
            v-model="registerForm.confirmPassword"
            type="password"
            placeholder="请确认密码"
            size="large"
            prefix-icon="Lock"
            show-password
          />
        </el-form-item>

        <el-form-item prop="nickname">
          <el-input
            v-model="registerForm.nickname"
            placeholder="请输入昵称(可选)"
            size="large"
            prefix-icon="User"
            clearable
          />
        </el-form-item>

        <el-form-item prop="email">
          <el-input
            v-model="registerForm.email"
            placeholder="请输入邮箱(可选)"
            size="large"
            prefix-icon="Message"
            clearable
          />
        </el-form-item>

        <el-form-item>
          <el-button
            type="primary"
            size="large"
            class="register-button"
            :loading="loading"
            @click="handleRegister"
          >
            {{ loading ? '注册中...' : '注册' }}
          </el-button>
        </el-form-item>
      </el-form>

      <div class="register-footer">
        <p class="login-link">
          已有账户?
          <el-button type="primary" link @click="$router.push('/login')">立即登录</el-button>
        </p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Reading, User, Lock, Message } from '@element-plus/icons-vue'
import { userApi } from '@/api'

const router = useRouter()
const registerFormRef = ref()

const registerForm = reactive({
  username: '',
  password: '',
  confirmPassword: '',
  nickname: '',
  email: ''
})

const registerRules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 20, message: '用户名长度应在3-20个字符之间', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 4, max: 20, message: '密码长度应在4-20个字符之间', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请确认密码', trigger: 'blur' },
    {
      validator: (rule, value, callback) => {
        if (value !== registerForm.password) {
          callback(new Error('两次输入的密码不一致'))
        } else {
          callback()
        }
      },
      trigger: 'blur'
    }
  ],
  email: [
    { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' }
  ]
}

const loading = ref(false)

const handleRegister = async () => {
  if (!registerFormRef.value) return

  await registerFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        loading.value = true

        // 调用注册API
        const result = await userApi.register({
          username: registerForm.username,
          password: registerForm.password,
          nickname: registerForm.nickname || registerForm.username,
          email: registerForm.email
        })

        if (result.code === 200) {
          ElMessage.success('注册成功')
          // 注册成功后跳转到登录页面
          router.push('/login')
        } else {
          ElMessage.error(result.message || '注册失败')
        }
      } catch (error) {
        ElMessage.error('注册失败: ' + (error.message || '网络错误'))
      } finally {
        loading.value = false
      }
    }
  })
}
</script>

<style scoped>
.register-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--bg-secondary);
  padding: 20px;
}

.register-card {
  width: 100%;
  max-width: 400px;
  background: #ffffff;
  border-radius: 12px;
  padding: 40px 30px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
}

.register-header {
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

.register-form {
  margin-bottom: 20px;
}

.register-button {
  width: 100%;
  background: var(--primary-color);
  border: none;
  font-weight: 600;
}

.register-button:hover {
  background: var(--primary-dark);
}

.register-footer {
  text-align: center;
}

.login-link {
  font-size: 14px;
  color: #666;
  margin: 0;
}

.login-link .el-button {
  font-weight: 600;
}
</style>