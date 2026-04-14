package com.example.demo.service;

import com.example.demo.entity.Goods;
import com.example.demo.entity.InventoryAlert;
import com.example.demo.entity.InventoryOperation;
import com.example.demo.exception.CustomerException;
import com.example.demo.mapper.InventoryAlertMapper;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

@Service
public class InventoryAlertService {

    @Resource
    private InventoryAlertMapper inventoryAlertMapper;

    @Resource
    private GoodsService goodsService;

    @Resource
    private InventoryOperationService inventoryOperationService;

    /**
     * 根据条件查询预警列表（分页）
     *
     * @param pageNum      页码
     * @param pageSize     页大小
     * @param inventoryAlert 查询条件
     * @return 预警分页列表
     */
    public PageInfo<InventoryAlert> selectPage(int pageNum, int pageSize, InventoryAlert inventoryAlert) {
        PageHelper.startPage(pageNum, pageSize);
        List<InventoryAlert> list = inventoryAlertMapper.selectList(inventoryAlert);
        return PageInfo.of(list);
    }

    /**
     * 根据 ID 查询预警
     *
     * @param id 预警 ID
     * @return 预警实体
     */
    public InventoryAlert selectById(Long id) {
        InventoryAlert alert = inventoryAlertMapper.selectById(id);
        if (alert == null) {
            throw new CustomerException("找不到预警记录");
        }
        return alert;
    }

    /**
     * 根据商品 ID 查询预警
     *
     * @param goodsId 商品 ID
     * @return 预警实体列表
     */
    public List<InventoryAlert> selectByGoodsId(Long goodsId) {
        return inventoryAlertMapper.selectByGoodsId(goodsId);
    }

    /**
     * 生成库存预警（扫描所有商品，生成预警记录）
     *
     * @return 生成的预警数量
     */
    @Transactional
    public int generateAlerts() {
        // 获取所有商品
        List<Goods> goodsList = goodsService.selectAllGoods();
        List<InventoryAlert> alertList = new ArrayList<>();

        Date now = new Date();

        for (Goods goods : goodsList) {
            InventoryAlert alert = new InventoryAlert();
            alert.setGoodsId(goods.getId());
            alert.setGoodsName(goods.getName());
            alert.setSkuCode(goods.getSkuCode());
            alert.setBrand(goods.getBrand());
            alert.setSpec(goods.getSpec());
            alert.setUnit(goods.getUnit());
            alert.setStockQuantity(goods.getStockQuantity());
            alert.setStockLow(goods.getStockLow());
            alert.setStockHigh(goods.getStockHigh());

            // 计算预警类型和级别
            String alertType = calculateAlertType(goods);
            String alertLevel = calculateAlertLevel(goods);

            // 只有存在预警时才创建记录
            if (alertType != null) {
                alert.setAlertType(alertType);
                alert.setAlertLevel(alertLevel);
                alert.setAcknowledged(0); // 未确认
                alert.setCreateTime(now);
                alert.setUpdateTime(now);
                alertList.add(alert);
            }
        }

        // 批量插入预警记录
        if (!alertList.isEmpty()) {
            inventoryAlertMapper.insertBatch(alertList);
        }

        return alertList.size();
    }

    /**
     * 计算预警类型
     *
     * @param goods 商品实体
     * @return 预警类型
     */
    public String calculateAlertType(Goods goods) {
        double stock = goods.getStockQuantity();
        int low = goods.getStockLow();
        int high = goods.getStockHigh();

        if (stock <= 0) {
            return "out_of_stock"; // 缺货
        } else if (stock < low) {
            return "low_stock"; // 库存不足
        } else if (stock > high) {
            return "high_stock"; // 库存过多
        }
        // 注意：即将到期预警需要批次信息，这里暂不处理
        return null;
    }

    /**
     * 计算预警级别
     *
     * @param goods 商品实体
     * @return 预警级别
     */
    public String calculateAlertLevel(Goods goods) {
        double stock = goods.getStockQuantity();
        int low = goods.getStockLow();
        int high = goods.getStockHigh();

        if (stock <= 0) {
            return "high"; // 缺货是最高级别
        } else if (stock < low * 0.5) {
            return "high"; // 库存远低于下限
        } else if (stock < low) {
            return "medium"; // 库存低于下限
        } else if (stock > high * 1.5) {
            return "high"; // 库存远高于上限
        } else if (stock > high) {
            return "medium"; // 库存高于上限
        }
        return "low";
    }

    /**
     * 确认预警
     *
     * @param id           预警 ID
     * @param acknowledgedBy 确认人 ID
     * @return 影响行数
     */
    @Transactional
    public int acknowledge(Long id, Integer acknowledgedBy) {
        InventoryAlert alert = inventoryAlertMapper.selectById(id);
        if (alert == null) {
            throw new CustomerException("找不到预警记录");
        }
        return inventoryAlertMapper.acknowledge(id, acknowledgedBy);
    }

    /**
     * 删除预警记录
     *
     * @param id 预警 ID
     * @return 影响行数
     */
    @Transactional
    public int deleteById(Long id) {
        return inventoryAlertMapper.deleteById(id);
    }

    /**
     * 批量删除预警记录
     *
     * @param ids 预警 ID 列表
     * @return 影响行数
     */
    @Transactional
    public int deleteBatch(List<Long> ids) {
        return inventoryAlertMapper.deleteBatch(ids);
    }

    /**
     * 统计预警数量
     *
     * @param inventoryAlert 查询条件
     * @return 数量
     */
    public int count(InventoryAlert inventoryAlert) {
        return inventoryAlertMapper.count(inventoryAlert);
    }

    /**
     * 统计各类型预警数量
     *
     * @return 统计结果 Map
     */
    public Map<String, Integer> countByAlertType() {
        return inventoryAlertMapper.countByAlertType();
    }

    /**
     * 获取预警统计信息
     *
     * @return 统计信息 Map
     */
    public Map<String, Object> getStatistics() {
        Map<String, Object> statistics = new HashMap<>();

        // 获取所有预警
        List<InventoryAlert> allAlerts = inventoryAlertMapper.selectAllAlerts();

        int outOfStock = 0;
        int lowStock = 0;
        int highStock = 0;
        int expiringSoon = 0;

        for (InventoryAlert alert : allAlerts) {
            String type = alert.getAlertType();
            if ("out_of_stock".equals(type)) {
                outOfStock++;
            } else if ("low_stock".equals(type)) {
                lowStock++;
            } else if ("high_stock".equals(type)) {
                highStock++;
            } else if ("expiring_soon".equals(type)) {
                expiringSoon++;
            }
        }

        statistics.put("outOfStock", outOfStock);
        statistics.put("lowStock", lowStock);
        statistics.put("highStock", highStock);
        statistics.put("expiringSoon", expiringSoon);
        statistics.put("totalAlerts", outOfStock + lowStock + highStock + expiringSoon);

        return statistics;
    }

    /**
     * 提交补货申请
     *
     * @param alertId      预警 ID
     * @param actualQty    实际补货数量
     * @param operator     操作员
     * @param remarks      备注
     * @return 库存作业 ID
     */
    @Transactional
    public Long submitReplenishment(Long alertId, Integer actualQty, String operator, String remarks) {
        // 获取预警记录
        InventoryAlert alert = inventoryAlertMapper.selectById(alertId);
        if (alert == null) {
            throw new CustomerException("找不到预警记录");
        }

        // 创建入库作业
        InventoryOperation operation = new InventoryOperation();
        operation.setOperationNo(generateOperationNo());
        operation.setOperationType("inbound");
        operation.setGoodsId(alert.getGoodsId().intValue());
        operation.setGoodsName(alert.getGoodsName());
        operation.setSkuCode(alert.getSkuCode());
        operation.setQuantity(actualQty.doubleValue());
        operation.setUnit(alert.getUnit());
        operation.setOperator(operator);
        operation.setStatus("completed");
        operation.setRemark(remarks != null ? remarks : "库存预警补货");
        operation.setSourceType("inventory_alert");
        operation.setCreateTime(new Date());
        operation.setUpdateTime(new Date());

        // 插入库存作业
        inventoryOperationService.insert(operation);

        // 更新商品库存
        Goods goods = goodsService.selectById(alert.getGoodsId());
        if (goods != null) {
            double newStock = goods.getStockQuantity() + actualQty;
            goods.setStockQuantity(newStock);
            goodsService.updateGoods(goods);
        }

        // 确认预警
        acknowledge(alertId, null);

        return operation.getId();
    }

    /**
     * 生成作业单号
     *
     * @return 作业单号
     */
    private String generateOperationNo() {
        Date now = new Date();
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(now);
        String year = String.valueOf(calendar.get(Calendar.YEAR)).substring(2);
        String month = String.format("%02d", calendar.get(Calendar.MONTH) + 1);
        String day = String.format("%02d", calendar.get(Calendar.DAY_OF_MONTH));
        String random = String.format("%04d", new Random().nextInt(10000));
        return "IN" + year + month + day + random;
    }
}
