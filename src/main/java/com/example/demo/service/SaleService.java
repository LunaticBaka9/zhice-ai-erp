package com.example.demo.service;

import java.math.BigDecimal;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.demo.entity.Sale;
import com.example.demo.entity.SaleItem;
import com.example.demo.mapper.SaleItemMapper;
import com.example.demo.mapper.SaleMapper;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;

import jakarta.annotation.Resource;

@Service
public class SaleService {

    @Resource
    private SaleMapper saleMapper;

    @Resource
    private SaleItemMapper saleItemMapper;

    /**
     * 查询所有销售订单（不分页）
     */
    public List<Sale> selectAll() {
        return saleMapper.selectAll(null);
    }

    /**
     * 分页查询销售订单
     */
    public PageInfo<Sale> selectPage(int pageNum, int pageSize, Sale sale) {
        PageHelper.startPage(pageNum, pageSize);
        List<Sale> list = saleMapper.selectAll(sale);
        return PageInfo.of(list);
    }

    /**
     * 根据ID查询销售订单（含明细）
     */
    public Sale selectById(Long id) {
        Sale sale = saleMapper.selectById(id);
        if (sale != null) {
            List<SaleItem> items = saleItemMapper.selectByOrderId(id);
            sale.setItems(items);
        }
        return sale;
    }

    /**
     * 新增销售订单（含明细，事务）
     */
    @Transactional(rollbackFor = Exception.class)
    public void insert(Sale sale) {
        // 参数校验
        if (sale.getCustomerId() == null) {
            throw new RuntimeException("客户不能为空");
        }
        if (sale.getOrderDate() == null) {
            throw new RuntimeException("下单日期不能为空");
        }
        if (sale.getItems() == null || sale.getItems().isEmpty()) {
            throw new RuntimeException("订单明细不能为空");
        }

        // 生成订单编号（若前端未传）
        if (sale.getOrderNo() == null || sale.getOrderNo().trim().isEmpty()) {
            sale.setOrderNo(generateOrderNo());
        }

        // 计算金额
        BigDecimal totalAmount = BigDecimal.ZERO;
        for (SaleItem item : sale.getItems()) {
            if (item.getPrice() == null || item.getQuantity() == null) {
                throw new RuntimeException("明细单价和数量不能为空");
            }
            BigDecimal subtotal = item.getPrice().multiply(BigDecimal.valueOf(item.getQuantity()));
            item.setSubtotal(subtotal);
            totalAmount = totalAmount.add(subtotal);
        }
        sale.setTotalAmount(totalAmount);

        // 优惠金额默认0
        if (sale.getDiscountAmount() == null) {
            sale.setDiscountAmount(BigDecimal.ZERO);
        }
        // 实收 = 总额 - 优惠
        sale.setFinalAmount(totalAmount.subtract(sale.getDiscountAmount()));

        // 默认状态：10-待发货
        if (sale.getStatus() == null) {
            sale.setStatus(10);
        }

        // 插入主表
        saleMapper.insert(sale);

        // 插入明细
        if (sale.getId() != null) {
            saleItemMapper.insertBatch(sale.getItems(), sale.getId());
        }
    }

    /**
     * 更新销售订单（含明细，事务）
     */
    @Transactional(rollbackFor = Exception.class)
    public void update(Sale sale) {
        Sale dbSale = saleMapper.selectById(sale.getId());
        if (dbSale == null) {
            throw new RuntimeException("找不到该销售订单，无法更新");
        }
        // 已完成或已取消的订单不允许修改
        if (dbSale.getStatus() != null && (dbSale.getStatus() == 40 || dbSale.getStatus() == 50)) {
            throw new RuntimeException("已完成或已取消的订单不允许修改");
        }

        // 若传入了明细，则重新计算金额并替换明细
        if (sale.getItems() != null && !sale.getItems().isEmpty()) {
            BigDecimal totalAmount = BigDecimal.ZERO;
            for (SaleItem item : sale.getItems()) {
                if (item.getPrice() == null || item.getQuantity() == null) {
                    throw new RuntimeException("明细单价和数量不能为空");
                }
                BigDecimal subtotal = item.getPrice().multiply(BigDecimal.valueOf(item.getQuantity()));
                item.setSubtotal(subtotal);
                totalAmount = totalAmount.add(subtotal);
            }
            sale.setTotalAmount(totalAmount);
            if (sale.getDiscountAmount() == null) {
                sale.setDiscountAmount(dbSale.getDiscountAmount() != null ? dbSale.getDiscountAmount() : BigDecimal.ZERO);
            }
            sale.setFinalAmount(totalAmount.subtract(sale.getDiscountAmount()));

            // 删除旧明细，插入新明细
            saleItemMapper.deleteByOrderId(sale.getId());
            saleItemMapper.insertBatch(sale.getItems(), sale.getId());
        }

        saleMapper.update(sale);
    }

    /**
     * 更新订单状态
     */
    public void updateStatus(Long id, Integer status) {
        Sale dbSale = saleMapper.selectById(id);
        if (dbSale == null) {
            throw new RuntimeException("找不到该销售订单");
        }
        Sale sale = new Sale();
        sale.setId(id);
        sale.setStatus(status);
        saleMapper.update(sale);
    }

    /**
     * 删除销售订单（含明细，事务）
     */
    @Transactional(rollbackFor = Exception.class)
    public void deleteById(Long id) {
        Sale sale = saleMapper.selectById(id);
        if (sale == null) {
            throw new RuntimeException("找不到该销售订单，无法删除");
        }
        // 已完成的订单不允许删除
        if (sale.getStatus() != null && sale.getStatus() == 40) {
            throw new RuntimeException("已完成的订单不允许删除");
        }
        saleItemMapper.deleteByOrderId(id);
        saleMapper.deleteById(id);
    }

    /**
     * 统计订单总数
     */
    public long count() {
        return saleMapper.count();
    }

    /**
     * 生成订单编号：SO + 时间戳
     */
    private String generateOrderNo() {
        return "SO" + System.currentTimeMillis();
    }
}
