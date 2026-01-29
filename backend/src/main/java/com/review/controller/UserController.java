package com.review.controller;

import com.review.dto.Result;
import com.review.entity.User;
import com.review.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 用户控制器
 */
@RestController
@RequestMapping("/api/users")
public class UserController {

    @Autowired
    private UserService userService;

    /**
     * 用户注册
     */
    @PostMapping("/register")
    public Result<User> register(@RequestBody RegisterRequest request) {
        try {
            User user = userService.register(
                request.getUsername(),
                request.getPassword(),
                request.getNickname(),
                request.getEmail()
            );
            return Result.success("注册成功", user);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 用户登录
     */
    @PostMapping("/login")
    public Result<User> login(@RequestBody LoginRequest request) {
        try {
            User user = userService.login(
                request.getUsername(),
                request.getPassword()
            );
            return Result.success("登录成功", user);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 获取当前用户信息
     */
    @GetMapping("/current")
    public Result<User> getCurrentUser(@RequestParam Long userId) {
        try {
            User user = userService.getUserById(userId);
            if (user == null) {
                return Result.error("用户不存在");
            }
            return Result.success("查询成功", user);
        } catch (Exception e) {
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    /**
     * 登录请求DTO
     */
    public static class LoginRequest {
        private String username;
        private String password;

        public String getUsername() {
            return username;
        }

        public void setUsername(String username) {
            this.username = username;
        }

        public String getPassword() {
            return password;
        }

        public void setPassword(String password) {
            this.password = password;
        }
    }

    /**
     * 注册请求DTO
     */
    public static class RegisterRequest {
        private String username;
        private String password;
        private String nickname;
        private String email;

        public String getUsername() {
            return username;
        }

        public void setUsername(String username) {
            this.username = username;
        }

        public String getPassword() {
            return password;
        }

        public void setPassword(String password) {
            this.password = password;
        }

        public String getNickname() {
            return nickname;
        }

        public void setNickname(String nickname) {
            this.nickname = nickname;
        }

        public String getEmail() {
            return email;
        }

        public void setEmail(String email) {
            this.email = email;
        }
    }
}
