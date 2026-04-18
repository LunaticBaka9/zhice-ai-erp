package com.example.demo.service.impl;

import cn.hutool.core.util.RandomUtil;
import com.example.demo.constants.PurchaseOrderStatus;
import com.example.demo.dto.PurchaseOrderSaveDTO;
import com.example.demo.entity.Purchase;
import com.example.demo.entity.PurchaseItem;
import com.example.demo.exception.CustomerException;
import com.example.demo.mapper.PurchaseInboundMapper;
import com.example.demo.mapper.PurchaseItemMapper;
import com.example.demo.mapper.PurchaseMapper;
import com.example.demo.service.PurchaseOrderService;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Date;
import java.util.List;

@Service
public class PurchaseOrderServiceImpl implements PurchaseOrderService {

    @Resource
    private PurchaseMapper purchaseMapper;
    @Resource
    private PurchaseItemMapper purchaseItemMapper;
    @Resource
    private PurchaseInboundMapper purchaseInboundMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long save(PurchaseOrderSaveDTO dto) {
        if (dto == null || dto.getPurchase() == null) {
            throw new CustomerException("参数错误");
        }
        Purchase p = dto.getPurchase();
        List<PurchaseItem> items = dto.getItems();
        if (p.getSupplierId() == null || p.getWarehouseId() == null) {
            throw new CustomerException("请选择供应商与入库仓库");
        }
        if (p.getId() == null) {
            if (p.getBillNo() == null || p.getBillNo().isBlank()) {
                p.setBillNo(genPoBillNo());
            }
            p.setStatus(PurchaseOrderStatus.DRAFT);
            p.setTotalAmount(calcTotalAmount(items));
            purchaseMapper.insert(p);
            saveItems(p.getId().intValue(), items);
            return p.getId();
        }
        Purchase db = purchaseMapper.selectById(p.getId());
        if (db == null) {
            throw new CustomerException("采购订单不存在");
        }
        if (db.getStatus() != PurchaseOrderStatus.DRAFT) {
            throw new CustomerException("仅草稿状态可修改");
        }
        p.setTotalAmount(calcTotalAmount(items));
        if (p.getBillNo() == null || p.getBillNo().isBlank()) {
            p.setBillNo(db.getBillNo());
        }
        purchaseMapper.update(p);
        purchaseItemMapper.deleteByPurchaseId(p.getId().intValue());
        saveItems(p.getId().intValue(), items);
        return p.getId();
    }

    private void saveItems(int purchaseId, List<PurchaseItem> items) {
        if (items == null || items.isEmpty()) {
            return;
        }
        int idx = 0;
        for (PurchaseItem it : items) {
            if (it.getGoodsId() == null || it.getQuantity() == null || it.getQuantity().compareTo(BigDecimal.ZERO) <= 0) {
                throw new CustomerException("明细存在无效商品或数量");
            }
            BigDecimal price = it.getUnitPrice() != null ? it.getUnitPrice() : BigDecimal.ZERO;
            BigDecimal amt = it.getQuantity().multiply(price).setScale(2, RoundingMode.HALF_UP);
            it.setPurchaseId(purchaseId);
            it.setUnitPrice(price);
            it.setAmount(amt);
            it.setSortNo(idx++);
            purchaseItemMapper.insert(it);
        }
    }

    private String calcTotalAmount(List<PurchaseItem> items) {
        if (items == null || items.isEmpty()) {
            return "0.00";
        }
        BigDecimal sum = BigDecimal.ZERO;
        for (PurchaseItem it : items) {
            if (it.getQuantity() != null && it.getUnitPrice() != null) {
                sum = sum.add(it.getQuantity().multiply(it.getUnitPrice()));
            }
        }
        return sum.setScale(2, RoundingMode.HALF_UP).toPlainString();
    }

    private String genPoBillNo() {
        return "PO" + System.currentTimeMillis() + RandomUtil.randomInt(1000, 9999);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void confirm(Long id) {
        Purchase db = purchaseMapper.selectById(id);
        if (db == null) {
            throw new CustomerException("采购订单不存在");
        }
        if (db.getStatus() != PurchaseOrderStatus.DRAFT) {
            throw new CustomerException("仅草稿可确认");
        }
        List<PurchaseItem> items = purchaseItemMapper.selectByPurchaseId(id.intValue());
        if (items == null || items.isEmpty()) {
            throw new CustomerException("请先维护采购明细后再确认");
        }
        db.setStatus(PurchaseOrderStatus.CONFIRMED);
        db.setConfirmTime(new Date());
        purchaseMapper.update(db);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void cancel(Long id) {
        Purchase db = purchaseMapper.selectById(id);
        if (db == null) {
            throw new CustomerException("采购订单不存在");
        }
        if (db.getStatus() == PurchaseOrderStatus.COMPLETED) {
            throw new CustomerException("已入库完成，不能作废");
        }
        if (db.getStatus() == PurchaseOrderStatus.CANCELLED) {
            return;
        }
        if (purchaseInboundMapper.countByPurchaseId(id.intValue()) > 0) {
            throw new CustomerException("已存在入库单，请先删除草稿入库单后再作废订单");
        }
        db.setStatus(PurchaseOrderStatus.CANCELLED);
        purchaseMapper.update(db);
    }

    @Override
    public Purchase detail(Long id) {
        Purchase p = purchaseMapper.selectById(id);
        if (p != null) {
            p.setItems(purchaseItemMapper.selectByPurchaseId(id.intValue()));
        }
        return p;
    }

    @Override
    public PageInfo<Purchase> page(int pageNum, int pageSize, Purchase query) {
        PageHelper.startPage(pageNum, pageSize);
        List<Purchase> list = purchaseMapper.selectList(query != null ? query : new Purchase());
        return PageInfo.of(list);
    }

    @Override
    public List<Purchase> listEligibleForInbound() {
        return purchaseMapper.selectEligibleForInbound();
    }
}
