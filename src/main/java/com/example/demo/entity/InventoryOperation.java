package com.example.demo.entity;

import cn.hutool.core.annotation.Alias;
import cn.hutool.core.annotation.PropIgnore;
import lombok.Data;

import java.util.Date;

/**
 * 库存作业实体类
 */
@Data
public class InventoryOperation {
    
    /**
     * 作业 ID
     */
    @PropIgnore
    private Long id;
    
    /**
     * 作业单号
     */
    @Alias("作业单号")
    private String operationNo;
    
    /**
     * 作业类型：inbound-入库，outbound-出库，transfer-调拨，adjustment-盘点
     */
    @Alias("作业类型")
    private String operationType;
    
    /**
     * 源仓库 ID（出库/调拨时有值）
     */
    @PropIgnore
    private Integer fromWarehouseId;
    
    /**
     * 源仓库名称（用于显示）
     */
    @Alias("源仓库")
    private String fromWarehouseName;
    
    /**
     * 目标仓库 ID（入库/调拨时有值）
     */
    @PropIgnore
    private Integer toWarehouseId;
    
    /**
     * 目标仓库名称（用于显示）
     */
    @Alias("目标仓库")
    private String toWarehouseName;
    
    /**
     * 商品 ID
     */
    @PropIgnore
    private Integer goodsId;
    
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
     * 作业数量
     */
    @Alias("数量")
    private Double quantity;
    
    /**
     * 单位
     */
    @Alias("单位")
    private String unit;
    
    /**
     * 操作员
     */
    @Alias("操作员")
    private String operator;
    
    /**
     * 状态：pending-待处理，completed-已完成，cancelled-已取消
     */
    @Alias("状态")
    private String status;
    
    /**
     * 备注
     */
    @Alias("备注")
    private String remark;
    
    /**
     * 来源类型：purchase-采购，sales-销售，manual-手工
     */
    @PropIgnore
    private String sourceType;
    
    /**
     * 来源单号（关联采购单/销售单等）
     */
    @PropIgnore
    private String sourceNo;
    
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
    
    /**
     * 完成时间
     */
    @Alias("完成时间")
    private Date completeTime;
    
    /**
     * 创建人 ID
     */
    @PropIgnore
    private Integer createBy;
    
    /**
     * 更新人 ID
     */
    @PropIgnore
    private Integer updateBy;
}