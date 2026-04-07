package com.example.demo.common;

import com.example.demo.exception.CustomerException;
import io.jsonwebtoken.Claims;
import jakarta.annotation.Resource;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

@Component
public class JwtInterceptor implements HandlerInterceptor {
    @Resource
    private JwtConfig jwtConfig;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        // 放行OPTIONS请求
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            return true;
        }

        // 放行登录请求
        String uri = request.getRequestURI();
        if (uri.contains("/login") || uri.contains("/register")) {
            return true;
        }

        // 获取token
        String token = request.getHeader("token");
        if (token == null || token.isEmpty()) {
            token = request.getParameter("token");
        }

        if (token == null || token.isEmpty()) {
            throw new CustomerException("请先登录");
        }

        // 验证token
        Claims claims = jwtConfig.getClaimsByToken(token);
        if (claims == null) {
            throw new CustomerException("token无效，请重新登录");
        }

        if (jwtConfig.isTokenExpired(claims)) {
            throw new CustomerException("token已过期，请重新登录");
        }

        // 将用户ID存入request属性
        request.setAttribute("userId", claims.getSubject());
        return true;
    }
}
