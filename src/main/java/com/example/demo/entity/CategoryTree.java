package com.example.demo.entity;

import java.util.ArrayList;
import java.util.List;

import lombok.Data;

@Data
public class CategoryTree extends Category {
    private List<CategoryTree> children = new ArrayList<>();
}
