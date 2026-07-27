package com.lunabaka.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class SwaggerConfig {

    @Bean
    public OpenAPI openAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("乡链进销存系统")
                        .description("乡链 ERP REST API")
                        .version("1.0.0")
                        .contact(new Contact()
                                .name("Your Name")
                                .email("admin@example.com")));
    }

}
