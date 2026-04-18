package com.example.demo.service.impl;

import cn.hutool.core.util.RandomUtil;
import com.example.demo.constants.PurchaseInboundStatus;
import com.example.demo.constants.PurchaseOrderStatus;
import com.example.demo.entity.*;
import com.example.demo.exception.CustomerException;
import com.example.demo.mapper.*;
import com.example.demo.service.PurchaseInboundService;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.Date;
import java.util.List;

@Service
public class PurchaseInboundServiceImpl implements PurchaseInboundService {

    @Resource
    private PurchaseMapper purchaseMapper;
    @Resource
    private PurchaseItemMapper purchaseItemMapper;
    @Resource
    private PurchaseInboundMapper purchaseInboundMapper;
    @Resource
    private PurchaseInboundItemMapper purchaseInboundItemMapper;
    @Resource
    private InventoryMapper inventoryMapper;
    @Resource
    private GoodsMapper goodsMapper;
    @Resource
    private WarehouseMapper warehouseMapper;
    @Resource
    private InventoryOperationMapper inventoryOperationMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long createFromPurchaseId(Integer purchaseId, String remark) {
        Purchase p = purchaseMapper.selectById(Long.valueOf(purchaseId));
        if (p == null) {
            throw new CustomerException("采购订单不存在");
        }
        if (p.getStatus() != PurchaseOrderStatus.CONFIRMED) {
            throw new CustomerException("请先确认采购订单后再生成入库单");
        }
        if (purchaseInboundMapper.countByPurchaseId(purchaseId) > 0) {
            throw new CustomerException("该采购订单已生成入库单，每单仅允许入库一次");
        }
        List<PurchaseItem> lines = purchaseItemMapper.selectByPurchaseId(purchaseId);
        if (lines == null || lines.isEmpty()) {
            throw new CustomerException("采购订单无明细");
        }
        PurchaseInbound inbound = new PurchaseInbound();
        inbound.setPurchaseId(purchaseId);
        inbound.setBillNo(genInboundBillNo());
        inbound.setWarehouseId(p.getWarehouseId());
        inbound.setStatus(PurchaseInboundStatus.DRAFT);
        inbound.setRemark(remark);
        purchaseInboundMapper.insert(inbound);
        for (PurchaseItem line : lines) {
            PurchaseInboundItem row = new PurchaseInboundItem();
            row.setInboundId(inbound.getId());
            row.setPurchaseItemId(line.getId());
            row.setGoodsId(line.getGoodsId());
            row.setQuantity(line.getQuantity());
            row.setUnitPrice(line.getUnitPrice() != null ? line.getUnitPrice() : BigDecimal.ZERO);
            purchaseInboundItemMapper.insert(row);
        }
        return inbound.getId();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void confirm(Long inboundId) {
        PurchaseInbound inbound = purchaseInboundMapper.selectById(inboundId);
        if (inbound == null) {
            throw new CustomerException("入库单不存在");
        }
        if (inbound.getStatus() != PurchaseInboundStatus.DRAFT) {
            throw new CustomerException("仅草稿入库单可确认入账");
        }
        List<PurchaseInboundItem> rows = purchaseInboundItemMapper.selectByInboundId(inboundId);
        if (rows == null || rows.isEmpty()) {
            throw new CustomerException("入库明细为空");
        }
        Warehouse wh = warehouseMapper.selectById(inbound.getWarehouseId().longValue());
        String whName = wh != null ? wh.getName() : "";
        Integer wid = inbound.getWarehouseId();

        for (PurchaseInboundItem row : rows) {
            Goods g = goodsMapper.selectById(row.getGoodsId().longValue());
            if (g == null) {
                throw new CustomerException("商品不存在: " + row.getGoodsId());
            }
            BigDecimal qty = row.getQuantity();
            BigDecimal unitPrice = row.getUnitPrice() != null ? row.getUnitPrice() : BigDecimal.ZERO;
            BigDecimal costDelta = qty.multiply(unitPrice);

            Inventory inv = inventoryMapper.selectByGoodsAndWarehouse(row.getGoodsId(), wid);
            if (inv == null) {
                Inventory n = new Inventory();
                n.setGoodsId(row.getGoodsId());
                n.setWarehouseId(wid);
                n.setBatchNo("");
                n.setQtyOnHand(qty);
                n.setQtyAvailable(qty);
                n.setLockedQty(BigDecimal.ZERO);
                n.setTotalCost(costDelta);
                n.setLastInboundTime(new Date());
                inventoryMapper.insert(n);
            } else {
                inventoryMapper.addQty(inv.getId(), qty, costDelta);
            }

            InventoryOperation op = new InventoryOperation();
            op.setOperationNo(genOperationNo());
            op.setOperationType("inbound");
            op.setToWarehouseId(wid);
            op.setToWarehouseName(whName);
            op.setGoodsId(row.getGoodsId());
            op.setGoodsName(g.getName());
            op.setSkuCode(g.getSkuCode() != null ? g.getSkuCode() : "");
            op.setQuantity(qty.doubleValue());
            op.setUnit(g.getUnit());
            op.setOperator("系统");
            op.setStatus("completed");
            op.setRemark("采购入库");
            op.setSourceType("purchase");
            op.setSourceNo(inbound.getBillNo());
            op.setCompleteTime(new Date());
            inventoryOperationMapper.insert(op);
        }

        inbound.setStatus(PurchaseInboundStatus.CONFIRMED);
        inbound.setConfirmTime(new Date());
        purchaseInboundMapper.update(inbound);

        Purchase p = purchaseMapper.selectById(Long.valueOf(inbound.getPurchaseId()));
        if (p != null) {
            p.setStatus(PurchaseOrderStatus.COMPLETED);
            p.setInStockTime(new Date());
            purchaseMapper.update(p);
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteDraft(Long inboundId) {
        PurchaseInbound inbound = purchaseInboundMapper.selectById(inboundId);
        if (inbound == null) {
            throw new CustomerException("入库单不存在");
        }
        if (inbound.getStatus() != PurchaseInboundStatus.DRAFT) {
            throw new CustomerException("仅草稿可删除");
        }
        purchaseInboundItemMapper.deleteByInboundId(inboundId);
        purchaseInboundMapper.deleteById(inboundId);
    }

    @Override
    public PurchaseInbound detail(Long id) {
        PurchaseInbound inbound = purchaseInboundMapper.selectById(id);
        if (inbound != null) {
            inbound.setItems(purchaseInboundItemMapper.selectByInboundId(id));
        }
        return inbound;
    }

    @Override
    public PageInfo<PurchaseInbound> page(int pageNum, int pageSize, PurchaseInbound query) {
        PageHelper.startPage(pageNum, pageSize);
        List<PurchaseInbound> list = purchaseInboundMapper.selectList(query != null ? query : new PurchaseInbound());
        return PageInfo.of(list);
    }

    private String genInboundBillNo() {
        return "RK" + System.currentTimeMillis() + RandomUtil.randomInt(1000, 9999);
    }

    private String genOperationNo() {
        return "PI" + System.currentTimeMillis() + RandomUtil.randomInt(100, 999);
    }
}
