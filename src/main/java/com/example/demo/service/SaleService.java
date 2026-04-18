package com.example.demo.service;

import java.math.BigDecimal;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.demo.constants.SaleOrderStatus;
import com.example.demo.entity.Goods;
import com.example.demo.entity.Sale;
import com.example.demo.entity.SaleItem;
import com.example.demo.exception.CustomerException;
import com.example.demo.mapper.GoodsMapper;
import com.example.demo.mapper.SaleItemMapper;
import com.example.demo.mapper.SaleMapper;
import com.example.demo.mapper.SaleOutboundMapper;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;

import jakarta.annotation.Resource;

@Service
public class SaleService {

    @Resource
    private SaleMapper saleMapper;

    @Resource
    private SaleItemMapper saleItemMapper;

    @Resource
    private SaleOutboundMapper saleOutboundMapper;

    @Resource
    private GoodsMapper goodsMapper;

    public List<Sale> selectAll() {
        return saleMapper.selectAll(null);
    }

    public PageInfo<Sale> selectPage(int pageNum, int pageSize, Sale sale) {
        PageHelper.startPage(pageNum, pageSize);
        List<Sale> list = saleMapper.selectAll(sale);
        return PageInfo.of(list);
    }

    public Sale selectById(Long id) {
        Sale sale = saleMapper.selectById(id);
        if (sale != null) {
            List<SaleItem> items = saleItemMapper.selectByOrderId(id);
            sale.setItems(items);
        }
        return sale;
    }

    @Transactional(rollbackFor = Exception.class)
    public Long insert(Sale sale) {
        if (sale.getCustomerId() == null) {
            throw new RuntimeException("客户不能为空");
        }
        if (sale.getWarehouseId() == null) {
            throw new RuntimeException("请选择出库仓库");
        }
        if (sale.getOrderDate() == null) {
            throw new RuntimeException("下单日期不能为空");
        }
        if (sale.getItems() == null || sale.getItems().isEmpty()) {
            throw new RuntimeException("订单明细不能为空");
        }

        if (sale.getOrderNo() == null || sale.getOrderNo().trim().isEmpty()) {
            sale.setOrderNo(generateOrderNo());
        }

        BigDecimal totalAmount = BigDecimal.ZERO;
        for (SaleItem item : sale.getItems()) {
            if (item.getPrice() == null || item.getQuantity() == null) {
                throw new RuntimeException("明细单价和数量不能为空");
            }
            if (item.getProductId() == null) {
                throw new RuntimeException("明细商品不能为空");
            }
            fillProductSnapshot(item);
            BigDecimal subtotal = item.getPrice().multiply(BigDecimal.valueOf(item.getQuantity()));
            item.setSubtotal(subtotal);
            totalAmount = totalAmount.add(subtotal);
        }
        sale.setTotalAmount(totalAmount);

        if (sale.getDiscountAmount() == null) {
            sale.setDiscountAmount(BigDecimal.ZERO);
        }
        sale.setFinalAmount(totalAmount.subtract(sale.getDiscountAmount()));

        if (sale.getStatus() == null) {
            sale.setStatus(SaleOrderStatus.DRAFT);
        }

        saleMapper.insert(sale);

        if (sale.getId() != null) {
            saleItemMapper.insertBatch(sale.getItems(), sale.getId());
        }
        return sale.getId();
    }

    private void fillProductSnapshot(SaleItem item) {
        if (item.getProductNameSnapshot() != null && !item.getProductNameSnapshot().isBlank()) {
            return;
        }
        Goods g = goodsMapper.selectById(item.getProductId());
        item.setProductNameSnapshot(g != null && g.getName() != null ? g.getName() : "");
    }

    @Transactional(rollbackFor = Exception.class)
    public void update(Sale sale) {
        Sale dbSale = saleMapper.selectById(sale.getId());
        if (dbSale == null) {
            throw new RuntimeException("找不到该销售订单，无法更新");
        }
        if (dbSale.getStatus() == null || dbSale.getStatus() != SaleOrderStatus.DRAFT) {
            throw new RuntimeException("仅草稿状态可修改");
        }

        if (sale.getItems() != null && !sale.getItems().isEmpty()) {
            BigDecimal totalAmount = BigDecimal.ZERO;
            for (SaleItem item : sale.getItems()) {
                if (item.getPrice() == null || item.getQuantity() == null) {
                    throw new RuntimeException("明细单价和数量不能为空");
                }
                if (item.getProductId() == null) {
                    throw new RuntimeException("明细商品不能为空");
                }
                fillProductSnapshot(item);
                BigDecimal subtotal = item.getPrice().multiply(BigDecimal.valueOf(item.getQuantity()));
                item.setSubtotal(subtotal);
                totalAmount = totalAmount.add(subtotal);
            }
            sale.setTotalAmount(totalAmount);
            if (sale.getDiscountAmount() == null) {
                sale.setDiscountAmount(dbSale.getDiscountAmount() != null ? dbSale.getDiscountAmount() : BigDecimal.ZERO);
            }
            sale.setFinalAmount(totalAmount.subtract(sale.getDiscountAmount()));

            saleItemMapper.deleteByOrderId(sale.getId());
            saleItemMapper.insertBatch(sale.getItems(), sale.getId());
        }

        saleMapper.update(sale);
    }

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

    @Transactional(rollbackFor = Exception.class)
    public void deleteById(Long id) {
        Sale sale = saleMapper.selectById(id);
        if (sale == null) {
            throw new RuntimeException("找不到该销售订单，无法删除");
        }
        if (sale.getStatus() != null && sale.getStatus() != SaleOrderStatus.DRAFT) {
            throw new RuntimeException("仅草稿订单可删除");
        }
        if (saleOutboundMapper.countBySaleOrderId(id) > 0) {
            throw new RuntimeException("已存在出库单，请先删除草稿出库单");
        }
        saleItemMapper.deleteByOrderId(id);
        saleMapper.deleteById(id);
    }

    @Transactional(rollbackFor = Exception.class)
    public void confirmOrder(Long id) {
        Sale db = saleMapper.selectById(id);
        if (db == null) {
            throw new CustomerException("销售订单不存在");
        }
        if (db.getStatus() == null || db.getStatus() != SaleOrderStatus.DRAFT) {
            throw new CustomerException("仅草稿可确认");
        }
        if (db.getWarehouseId() == null) {
            throw new CustomerException("请先指定出库仓库");
        }
        List<SaleItem> items = saleItemMapper.selectByOrderId(id);
        if (items == null || items.isEmpty()) {
            throw new CustomerException("请先维护订单明细后再确认");
        }
        db.setStatus(SaleOrderStatus.CONFIRMED);
        db.setConfirmTime(new Date());
        saleMapper.update(db);
    }

    @Transactional(rollbackFor = Exception.class)
    public void cancelOrder(Long id) {
        Sale db = saleMapper.selectById(id);
        if (db == null) {
            throw new CustomerException("销售订单不存在");
        }
        if (db.getStatus() != null && db.getStatus() == SaleOrderStatus.COMPLETED) {
            throw new CustomerException("已出库完成，不能作废");
        }
        if (db.getStatus() != null && db.getStatus() == SaleOrderStatus.CANCELLED) {
            return;
        }
        if (saleOutboundMapper.countBySaleOrderId(id) > 0) {
            throw new CustomerException("已存在出库单，请先删除草稿出库单后再作废订单");
        }
        db.setStatus(SaleOrderStatus.CANCELLED);
        saleMapper.update(db);
    }

    public List<Sale> listEligibleForOutbound() {
        return saleMapper.selectEligibleForOutbound();
    }

    public long count() {
        return saleMapper.count();
    }

    public Map<String, Object> getStatistics() {
        long total = saleMapper.count();
        long draft = saleMapper.countByStatus(0);
        long pending = saleMapper.countByStatus(1);
        long completed = saleMapper.countByStatus(2);
        long cancelled = saleMapper.countByStatus(3);
        Map<String, Object> data = new HashMap<>();
        data.put("totalCount", total);
        data.put("draftCount", draft);
        data.put("pendingCount", pending);
        data.put("completedCount", completed);
        data.put("cancelledCount", cancelled);
        return data;
    }

    private String generateOrderNo() {
        return "SO" + System.currentTimeMillis();
    }
}
