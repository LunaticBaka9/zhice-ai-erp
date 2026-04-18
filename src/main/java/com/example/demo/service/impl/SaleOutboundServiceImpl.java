package com.example.demo.service.impl;

import cn.hutool.core.util.RandomUtil;
import com.example.demo.constants.SaleOrderStatus;
import com.example.demo.constants.SaleOutboundStatus;
import com.example.demo.entity.*;
import com.example.demo.exception.CustomerException;
import com.example.demo.mapper.*;
import com.example.demo.service.SaleOutboundService;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class SaleOutboundServiceImpl implements SaleOutboundService {

    @Resource
    private SaleMapper saleMapper;
    @Resource
    private SaleItemMapper saleItemMapper;
    @Resource
    private SaleOutboundMapper saleOutboundMapper;
    @Resource
    private SaleOutboundItemMapper saleOutboundItemMapper;
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
    public Long createFromSaleOrderId(Long saleOrderId, String remark) {
        Sale order = saleMapper.selectById(saleOrderId);
        if (order == null) {
            throw new CustomerException("销售订单不存在");
        }
        if (order.getStatus() == null || order.getStatus() != SaleOrderStatus.CONFIRMED) {
            throw new CustomerException("请先确认销售订单后再生成出库单");
        }
        if (saleOutboundMapper.countBySaleOrderId(saleOrderId) > 0) {
            throw new CustomerException("该销售订单已生成出库单，每单仅允许出库一次");
        }
        if (order.getWarehouseId() == null) {
            throw new CustomerException("销售订单未指定出库仓库");
        }
        List<SaleItem> lines = saleItemMapper.selectByOrderId(saleOrderId);
        if (lines == null || lines.isEmpty()) {
            throw new CustomerException("销售订单无明细");
        }
        SaleOutbound ob = new SaleOutbound();
        ob.setSaleOrderId(saleOrderId);
        ob.setBillNo(genOutboundBillNo());
        ob.setWarehouseId(order.getWarehouseId());
        ob.setStatus(SaleOutboundStatus.DRAFT);
        ob.setRemark(remark);
        saleOutboundMapper.insert(ob);
        for (SaleItem line : lines) {
            SaleOutboundItem row = new SaleOutboundItem();
            row.setOutboundId(ob.getId());
            row.setSaleOrderItemId(line.getId());
            row.setProductId(line.getProductId());
            row.setQuantity(line.getQuantity());
            row.setPrice(line.getPrice() != null ? line.getPrice() : BigDecimal.ZERO);
            saleOutboundItemMapper.insert(row);
        }
        return ob.getId();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void confirm(Long outboundId) {
        SaleOutbound outbound = saleOutboundMapper.selectById(outboundId);
        if (outbound == null) {
            throw new CustomerException("出库单不存在");
        }
        if (outbound.getStatus() == null || outbound.getStatus() != SaleOutboundStatus.DRAFT) {
            throw new CustomerException("仅草稿出库单可确认出库");
        }
        List<SaleOutboundItem> rows = saleOutboundItemMapper.selectByOutboundId(outboundId);
        if (rows == null || rows.isEmpty()) {
            throw new CustomerException("出库明细为空");
        }
        Warehouse wh = warehouseMapper.selectById(outbound.getWarehouseId().longValue());
        String whName = wh != null ? wh.getName() : "";
        Integer wid = outbound.getWarehouseId();

        for (SaleOutboundItem row : rows) {
            Goods g = goodsMapper.selectById(row.getProductId());
            if (g == null) {
                throw new CustomerException("商品不存在: " + row.getProductId());
            }
            BigDecimal qtyBd = BigDecimal.valueOf(row.getQuantity());
            Inventory inv = inventoryMapper.selectByGoodsAndWarehouse(row.getProductId().intValue(), wid);
            if (inv == null) {
                throw new CustomerException("仓库中无该商品库存: " + g.getName());
            }
            if (inv.getQtyAvailable().compareTo(qtyBd) < 0) {
                throw new CustomerException("库存不足: " + g.getName() + "，可用 " + inv.getQtyAvailable());
            }
            BigDecimal qh = inv.getQtyOnHand();
            BigDecimal tc = inv.getTotalCost() != null ? inv.getTotalCost() : BigDecimal.ZERO;
            BigDecimal costDelta = BigDecimal.ZERO;
            if (qh != null && qh.compareTo(BigDecimal.ZERO) > 0) {
                costDelta = tc.multiply(qtyBd).divide(qh, 2, RoundingMode.HALF_UP);
            }
            int updated = inventoryMapper.subtractQty(inv.getId(), qtyBd, costDelta);
            if (updated == 0) {
                throw new CustomerException("扣减库存失败（可能并发占用）: " + g.getName());
            }

            InventoryOperation op = new InventoryOperation();
            op.setOperationNo(genOperationNo());
            op.setOperationType("outbound");
            op.setFromWarehouseId(wid);
            op.setFromWarehouseName(whName);
            op.setGoodsId(row.getProductId().intValue());
            op.setGoodsName(g.getName());
            op.setSkuCode(g.getSkuCode() != null ? g.getSkuCode() : "");
            op.setQuantity(qtyBd.doubleValue());
            op.setUnit(g.getUnit());
            op.setOperator("系统");
            op.setStatus("completed");
            op.setRemark("销售出库");
            op.setSourceType("sales");
            op.setSourceNo(outbound.getBillNo());
            op.setCompleteTime(new Date());
            inventoryOperationMapper.insert(op);
        }

        outbound.setStatus(SaleOutboundStatus.CONFIRMED);
        outbound.setConfirmTime(new Date());
        saleOutboundMapper.update(outbound);

        Sale order = saleMapper.selectById(outbound.getSaleOrderId());
        if (order != null) {
            order.setStatus(SaleOrderStatus.COMPLETED);
            order.setDeliverTime(new Date());
            saleMapper.update(order);
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteDraft(Long outboundId) {
        SaleOutbound outbound = saleOutboundMapper.selectById(outboundId);
        if (outbound == null) {
            throw new CustomerException("出库单不存在");
        }
        if (outbound.getStatus() == null || outbound.getStatus() != SaleOutboundStatus.DRAFT) {
            throw new CustomerException("仅草稿可删除");
        }
        saleOutboundItemMapper.deleteByOutboundId(outboundId);
        saleOutboundMapper.deleteById(outboundId);
    }

    @Override
    public SaleOutbound detail(Long id) {
        SaleOutbound ob = saleOutboundMapper.selectById(id);
        if (ob != null) {
            ob.setItems(saleOutboundItemMapper.selectByOutboundId(id));
        }
        return ob;
    }

    @Override
    public PageInfo<SaleOutbound> page(int pageNum, int pageSize, SaleOutbound query) {
        PageHelper.startPage(pageNum, pageSize);
        List<SaleOutbound> list = saleOutboundMapper.selectList(query != null ? query : new SaleOutbound());
        return PageInfo.of(list);
    }

    private String genOutboundBillNo() {
        return "CK" + System.currentTimeMillis() + RandomUtil.randomInt(1000, 9999);
    }

    private String genOperationNo() {
        return "XO" + System.currentTimeMillis() + RandomUtil.randomInt(100, 999);
    }

    @Override
    public Map<String, Object> getStatistics() {
        Long total = saleOutboundMapper.countAll();
        Long draft = saleOutboundMapper.countByStatus(SaleOutboundStatus.DRAFT);
        Long confirmed = saleOutboundMapper.countByStatus(SaleOutboundStatus.CONFIRMED);
        Map<String, Object> data = new HashMap<>();
        data.put("total", total != null ? total : 0L);
        data.put("draft", draft != null ? draft : 0L);
        data.put("confirmed", confirmed != null ? confirmed : 0L);
        return data;
    }
}
