package com.example.demo.entity;

import java.util.ArrayList;
import java.util.List;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true) // 显式告诉 Lombok 要调用父类的 equals/hashCode
public class CategoryTree extends Category {
    private List<CategoryTree> children = new ArrayList<>();
}
