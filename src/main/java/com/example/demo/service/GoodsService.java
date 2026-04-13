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

    public List<Goods> selectAllUsers(){
        return goodsMapper.selectAllGoods(null);
    }

    public PageInfo<Goods> selectPage(int pageNum, int pageSize, Goods goods){
        PageHelper.startPage(pageNum, pageSize);
        List<Goods> list = goodsMapper.selectAllGoods(goods);
        return PageInfo.of(list);
    }
    
    public Goods selectById(Long uid){
        return goodsMapper.selectById(uid);
    }

    public void insert(Goods goods){
        goodsMapper.insertGoods(goods);
    }
    
    public void deleteById(Goods goods){
        Goods dbGoods = goodsMapper.selectById(goods.getId());
        if(dbGoods == null){
            throw new CustomerException("找不到用户，无法删除");
        }
        goodsMapper.deleteById(goods);
    }

    public void deleteBatch(List<Goods> list){
        for(Goods user: list){
            this.deleteById(user);
        }
    }
}
