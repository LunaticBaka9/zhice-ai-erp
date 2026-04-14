package com.example.demo.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.example.demo.entity.Goods;
import com.example.demo.exception.CustomerException;
import com.example.demo.mapper.GoodsMapper;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;

import jakarta.annotation.Resource;

@Service
public class GoodsService {
    @Resource
    private GoodsMapper goodsMapper;

    public List<Goods> selectAllGoods() {
        return goodsMapper.selectAllGoods(null);
    }

    public PageInfo<Goods> selectPage(int pageNum, int pageSize, Goods goods) {
        PageHelper.startPage(pageNum, pageSize);
        List<Goods> list = goodsMapper.selectAllGoods(goods);
        return PageInfo.of(list);
    }

    public Goods selectById(Long id) {
        return goodsMapper.selectById(id);
    }

    public void insert(Goods goods) {
        goodsMapper.insertGoods(goods);
    }

    public void deleteById(Long id) {
        Goods dbGoods = goodsMapper.selectById(id);
        if (dbGoods == null) {
            throw new CustomerException("找不到商品，无法删除");
        }
        goodsMapper.deleteGoods(id);
    }

    public void deleteById(Goods goods) {
        this.deleteById(goods.getId());
    }

    public void deleteBatch(List<Goods> list) {
        for (Goods goods : list) {
            this.deleteById(goods.getId());
        }
    }

    public void updateGoods(Goods goods) {
        Goods dbGoods = goodsMapper.selectById(goods.getId());
        if (dbGoods == null) {
            throw new CustomerException("找不到商品，无法更新");
        }
        goodsMapper.updateGoods(goods);
    }
}
