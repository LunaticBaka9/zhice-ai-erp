package com.example.demo.mapper;

import com.example.demo.entity.Category;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

@Mapper
public interface CategoryMapper {

    List<Category> selectAll(@Param("name") String name);

    Category selectById(@Param("id") Integer id);

    void insert(Category category);

    void update(Category category);

    void deleteById(@Param("id") Integer id);
}
