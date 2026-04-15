package com.example.demo.service;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.example.demo.entity.Category;
import com.example.demo.entity.CategoryTree;
import com.example.demo.exception.CustomerException;
import com.example.demo.mapper.CategoryMapper;

import jakarta.annotation.Resource;

@Service
public class CategoryService {
    @Resource
    private CategoryMapper categoryMapper;

    public List<Category> selectAll(String name) {
        return categoryMapper.selectAll(name);
    }

    public List<CategoryTree> selectTree(String name) {
        List<Category> allList = categoryMapper.selectAll(name);
        List<CategoryTree> treeList = allList.stream()
                .map(this::convertToTree)
                .collect(Collectors.toList());
        return buildTree(treeList, 0);
    }

    private CategoryTree convertToTree(Category category) {
        CategoryTree tree = new CategoryTree();
        tree.setId(category.getId());
        tree.setParentId(category.getParentId());
        tree.setName(category.getName());
        tree.setSortOrder(category.getSortOrder());
        tree.setCreateTime(category.getCreateTime());
        tree.setUpdateTime(category.getUpdateTime());
        return tree;
    }

    private List<CategoryTree> buildTree(List<CategoryTree> list, Integer parentId) {
        return list.stream()
                .filter(node -> node.getParentId().equals(parentId))
                .peek(node -> node.setChildren(buildTree(list, node.getId())))
                .collect(Collectors.toList());
    }

    public Category selectById(Integer id) {
        return categoryMapper.selectById(id);
    }

    public void insert(Category category) {
        if (category.getParentId() == null) {
            category.setParentId(0);
        }
        if (category.getSortOrder() == null) {
            category.setSortOrder(0);
        }
        categoryMapper.insert(category);
    }

    public void update(Category category) {
        Category dbCategory = categoryMapper.selectById(category.getId());
        if (dbCategory == null) {
            throw new CustomerException("找不到分类，无法更新");
        }
        categoryMapper.update(category);
    }

    public void deleteById(Integer id) {
        List<Category> children = categoryMapper.selectAll(null);
        boolean hasChildren = children.stream()
                .anyMatch(c -> c.getParentId().equals(id));
        if (hasChildren) {
            throw new CustomerException("该分类存在子分类，无法删除");
        }
        categoryMapper.deleteById(id);
    }
}
