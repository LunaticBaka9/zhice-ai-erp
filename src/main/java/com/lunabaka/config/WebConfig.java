package com.lunabaka.config;

import java.io.File;

import com.lunabaka.common.JwtInterceptor;
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
                        "/sendEmailCode",
                        "/emailLogin",
                        "/file/upload",
                        "/file/uploadAvatar",
                        "/error",
                        "/static/**",
                        "/favicon.ico",
                        "/index.html"
                );
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
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }
        registry.addResourceHandler("/static/**")
                .addResourceLocations("file:" + uploadDir.getAbsolutePath() + "/");
    }
}
