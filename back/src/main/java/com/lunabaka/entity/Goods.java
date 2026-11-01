package com.lunabaka.entity;

import cn.hutool.core.annotation.Alias;
import cn.hutool.core.annotation.PropIgnore;
import com.lunabaka.ProjectApplication;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.util.Date;

@EqualsAndHashCode(callSuper = true)
@Data
@AllArgsConstructor
@NoArgsConstructor
public class Goods extends ProjectApplication implements Serializable {
    @PropIgnore
    private Long id;

    @Alias("SKU编码")
    private String skuCode;

    @PropIgnore
    private String img;

    @Alias("商品名称")
    private String name;

    @PropIgnore
    private Long categoryId;

    @Alias("商品种类")
    private String categoryName;

    @Alias("品牌")
    private String brand;

    @Alias("规格型号")
    private String spec;

    @Alias("基础单位")
    private String unit;

    @Alias("参考采购价")
    private String purchasePrice;

    @Alias("标准售价")
    private double salePrice;

    @Alias("成本价格")
    private double costPrice;

    @Alias("主条码")
    private String barcode;

    @Alias("创建时间")
    private Date createTime;

    @Alias("更新时间")
    private Date updateTime;

    @Alias("库存数量")
    private double stockQuantity; // 实际库存数量（从inventory表计算得出）

    @Alias("库存预警上限")
    private int stockHigh; // 库存预警上限

    @Alias("库存预警下限")
    private int stockLow; // 库存预警下限

    @PropIgnore
    private int delFlag;
}
