import request from '@/utils/request'

// 用户相关API
export const userApi = {
  // 用户注册
  register(data) {
    return request({
      url: '/users/register',
      method: 'post',
      data
    })
  },

  // 用户登录
  login(data) {
    return request({
      url: '/users/login',
      method: 'post',
      data
    })
  },

  // 获取当前用户信息
  getCurrentUser(userId) {
    return request({
      url: '/users/current',
      method: 'get',
      params: { userId }
    })
  }
}