package com.review.service;

import com.review.entity.User;
import com.review.mapper.UserMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 用户服务类
 */
@Service
public class UserService {

    @Autowired
    private UserMapper userMapper;

    /**
     * 用户注册
     * 密码明文存储
     */
    public User register(String username, String password, String nickname, String email) {
        // 检查用户名是否已存在
        User existingUser = userMapper.findByUsername(username);
        if (existingUser != null) {
            throw new RuntimeException("用户名已存在");
        }

        // 创建新用户
        User user = new User();
        user.setUsername(username);
        user.setPassword(password); // 明文存储
        user.setNickname(nickname != null ? nickname : username);
        user.setEmail(email);
        user.setCreatedAt(LocalDateTime.now());
        user.setUpdatedAt(LocalDateTime.now());

        userMapper.insert(user);
        return user;
    }

    /**
     * 用户登录
     * 密码明文比对
     */
    public User login(String username, String password) {
        User user = userMapper.findByUsername(username);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }

        if (!user.getPassword().equals(password)) {
            throw new RuntimeException("密码错误");
        }

        return user;
    }

    /**
     * 根据ID获取用户
     */
    public User getUserById(Long userId) {
        return userMapper.findById(userId);
    }

    /**
     * 获取所有用户
     */
    public List<User> getAllUsers() {
        return userMapper.findAll();
    }
}