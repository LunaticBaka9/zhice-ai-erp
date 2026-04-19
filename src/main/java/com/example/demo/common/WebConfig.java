package com.example.demo.common;

import java.io.File;
import java.io.IOException;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import jakarta.annotation.Resource;

@Configuration
public class WebConfig implements WebMvcConfigurer {
    @Resource
    private JwtInterceptor jwtInterceptor;

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(jwtInterceptor)
                .addPathPatterns("/**")
                .excludePathPatterns(
                        "/login",
                        "/register",
                        "/file/upload",
                        "/file/uploadAvatar",
                        "/error",
                        "/static/**",
                        "/favicon.ico",
                        "/index.html");
    }

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                .allowedOriginPatterns("*")
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                .allowedHeaders("*")
                .allowCredentials(true)
                .maxAge(3600);
    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        try {
            File appDir;
            try {
                java.net.URL url = getClass().getProtectionDomain().getCodeSource().getLocation();
                if (url != null) {
                    File jarFile = new File(url.toURI().getPath());
                    appDir = jarFile.getParentFile();
                } else {
                    appDir = null;
                }
            } catch (Exception ex) {
                appDir = null;
            }
            if (appDir == null) {
                appDir = new File(System.getProperty("user.dir"));
            }
            File uploadDir = new File(appDir, "static");
            if (uploadDir.exists()) {
                registry.addResourceHandler("/static/**")
                        .addResourceLocations("file:" + uploadDir.getAbsolutePath() + "/");
            }
        } catch (Exception e) {
            System.out.println("静态资源路径配置: " + e.getMessage());
        }
    }
}
