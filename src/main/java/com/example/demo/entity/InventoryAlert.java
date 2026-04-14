package com.example.demo.entity;

import cn.hutool.core.annotation.Alias;
import cn.hutool.core.annotation.PropIgnore;
import lombok.Data;

import java.util.Date;

/**
 * 库存预警实体类
 */
@Data
public class InventoryAlert {
    
    /**
     * 预警 ID
     */
    @PropIgnore
    private Long id;
    
    /**
     * 商品 ID
     */
    @PropIgnore
    private Long goodsId;
    
    /**
     * 商品名称
     */
    @Alias("商品名称")
    private String goodsName;
    
    /**
     * SKU 编码
     */
    @Alias("SKU 编码")
    private String skuCode;
    
    /**
     * 品牌
     */
    @Alias("品牌")
    private String brand;
    
    /**
     * 规格型号
     */
    @Alias("规格型号")
    private String spec;
    
    /**
     * 单位
     */
    @Alias("单位")
    private String unit;
    
    /**
     * 当前库存数量
     */
    @Alias("当前库存")
    private Double stockQuantity;
    
    /**
     * 库存预警下限
     */
    @Alias("预警下限")
    private Integer stockLow;
    
    /**
     * 库存预警上限
     */
    @Alias("预警上限")
    private Integer stockHigh;
    
    /**
     * 预警类型：out_of_stock-缺货，low_stock-库存不足，high_stock-库存过多，expiring_soon-即将到期
     */
    @Alias("预警类型")
    private String alertType;
    
    /**
     * 预警级别：high-高，medium-中，low-低
     */
    @Alias("预警级别")
    private String alertLevel;
    
    /**
     * 是否已确认：0-未确认，1-已确认
     */
    @Alias("已确认")
    private Integer acknowledged;
    
    /**
     * 确认人 ID
     */
    @PropIgnore
    private Integer acknowledgedBy;
    
    /**
     * 确认时间
     */
    @Alias("确认时间")
    private Date acknowledgedTime;
    
    /**
     * 到期天数（用于即将到期预警）
     */
    @Alias("到期天数")
    private Integer daysToExpiry;
    
    /**
     * 创建时间
     */
    @Alias("创建时间")
    private Date createTime;
    
    /**
     * 更新时间
     */
    @Alias("更新时间")
    private Date updateTime;
}
