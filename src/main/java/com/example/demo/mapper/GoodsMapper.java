package com.example.demo.mapper;

import com.example.demo.entity.Goods;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

@Mapper
public interface GoodsMapper {

    void insertGoods(Goods goods);

    Goods selectById(@Param("id") Long id);

    List<Goods> selectAllGoods(Goods goods);

    void deleteGoods(@Param("id") Long id);
    
    void updateGoods(Goods goods);
}
