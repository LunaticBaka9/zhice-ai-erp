# MyBatis 查询语句优化指南

## 1. GoodsMapper.xml 优化建议

### 当前问题：

1. `LIKE CONCAT('%', #{value}, '%')` 会导致全表扫描，即使有索引也无法使用
2. `GROUP BY g.id` 在分页查询中效率低
3. 左连接 inventory 表可能影响性能

### 优化方案：

```xml
<!-- 优化后的 selectAllGoods -->
<select id="selectAllGoods" resultType="com.example.demo.entity.Goods">
    SELECT
        g.*,
        (SELECT COALESCE(SUM(i.qty_on_hand), 0)
         FROM `inventory` i
         WHERE i.goods_id = g.id) as stockQuantity
    FROM `goods` g
    <where>
        <!-- 使用索引友好的 LIKE 条件 -->
        <if test="skuCode != null and skuCode != ''">
            and g.sku_code like #{skuCode} || '%'
        </if>
        <if test="name != null and name != ''">
            and g.name like #{name} || '%'
        </if>
        <if test="brand != null and brand != ''">
            and g.brand like #{brand} || '%'
        </if>
        <if test="unit != null and unit != ''">
            and g.unit = #{unit}
        </if>
        <!-- 精确匹配比 LIKE 更高效 -->
        <if test="categoryId != null and categoryId != ''">
            and g.category_id = #{categoryId}
        </if>
        <if test="barcode != null and barcode != ''">
            and g.barcode = #{barcode}
        </if>
        <if test="spec != null and spec != ''">
            and g.spec like #{spec} || '%'
        </if>
        and (g.del_flag IS NULL OR g.del_flag != 1)
    </where>
    ORDER BY g.id DESC
</select>
```

## 2. 添加分页专用查询（提高分页性能）

```xml
<!-- 分页专用查询，不计算库存 -->
<select id="selectPageGoods" resultType="com.example.demo.entity.Goods">
    SELECT g.*
    FROM `goods` g
    <where>
        <if test="skuCode != null and skuCode != ''">
            and g.sku_code like #{skuCode} || '%'
        </if>
        <if test="name != null and name != ''">
            and g.name like #{name} || '%'
        </if>
        <if test="brand != null and brand != ''">
            and g.brand like #{brand} || '%'
        </if>
        <if test="unit != null and unit != ''">
            and g.unit = #{unit}
        </if>
        <if test="categoryId != null and categoryId != ''">
            and g.category_id = #{categoryId}
        </if>
        and (g.del_flag IS NULL OR g.del_flag != 1)
    </where>
    ORDER BY g.id DESC
</select>

<!-- 获取商品详情时再查询库存 -->
<select id="selectGoodsWithStock" parameterType="long" resultType="com.example.demo.entity.Goods">
    SELECT
        g.*,
        COALESCE(SUM(i.qty_on_hand), 0) as stockQuantity
    FROM `goods` g
    LEFT JOIN `inventory` i ON g.id = i.goods_id
    WHERE g.id = #{id} AND (g.del_flag IS NULL OR g.del_flag != 1)
    GROUP BY g.id
</select>
```

## 3. WarehouseMapper.xml 优化建议

### 当前问题：

1. `LIKE CONCAT('%', #{value}, '%')` 效率低

### 优化方案：

```xml
<select id="selectAllWarehouse" resultType="com.example.demo.entity.Warehouse">
    SELECT * FROM `warehouse`
    <where>
        <!-- 使用前缀匹配提高索引利用率 -->
        <if test="code != null and code != ''">
            and code like #{code} || '%'
        </if>
        <if test="name != null and name != ''">
            and name like #{name} || '%'
        </if>
        and del_flag != 1
    </where>
    ORDER BY create_time DESC
</select>
```

## 4. CategoryMapper.xml 优化建议

### 当前问题：

1. 树形结构查询可以优化

### 优化方案：

```xml
<!-- 添加递归查询支持 -->
<select id="selectCategoryTree" resultType="com.example.demo.entity.CategoryTree">
    WITH RECURSIVE category_tree AS (
        -- 基础查询：顶级分类
        SELECT
            id,
            parent_id,
            name,
            sort_order,
            create_time,
            update_time,
            1 as level,
            CAST(id AS CHAR(255)) as path
        FROM `category`
        WHERE parent_id = 0

        UNION ALL

        -- 递归查询：子分类
        SELECT
            c.id,
            c.parent_id,
            c.name,
            c.sort_order,
            c.create_time,
            c.update_time,
            ct.level + 1 as level,
            CONCAT(ct.path, ',', c.id) as path
        FROM `category` c
        INNER JOIN category_tree ct ON c.parent_id = ct.id
    )
    SELECT * FROM category_tree
    ORDER BY path, sort_order
</select>
```

## 5. InventoryOperationMapper.xml 优化建议

### 当前问题：

1. 多条件查询可能效率低

### 优化方案：

```xml
<select id="selectList" parameterType="com.example.demo.entity.InventoryOperation" resultMap="inventoryOperationMap">
    SELECT *
    FROM `inventory_operation`
    <where>
        <!-- 使用精确匹配或前缀匹配 -->
        <if test="operationNo != null and operationNo != ''">
            AND operation_no like #{operationNo} || '%'
        </if>
        <if test="goodsName != null and goodsName != ''">
            AND goods_name like #{goodsName} || '%'
        </if>
        <!-- 精确匹配更高效 -->
        <if test="operationType != null and operationType != ''">
            AND operation_type = #{operationType}
        </if>
        <if test="status != null and status != ''">
            AND status = #{status}
        </if>
        <if test="fromWarehouseId != null">
            AND from_warehouse_id = #{fromWarehouseId}
        </if>
        <if test="toWarehouseId != null">
            AND to_warehouse_id = #{toWarehouseId}
        </if>
        AND del_flag != 1
    </where>
    ORDER BY create_time DESC
    <!-- 添加分页限制 -->
    <if test="pageSize != null and pageSize > 0">
        LIMIT #{pageSize}
        <if test="offset != null and offset >= 0">
            OFFSET #{offset}
        </if>
    </if>
</select>
```

## 6. 通用优化技巧

### 6.1 使用 `<sql>` 片段避免重复

```xml
<sql id="goodsBaseColumns">
    id, sku_code as skuCode, name, category_id as categoryId,
    brand, spec, unit, barcode, purchase_price as purchasePrice,
    sale_price as salePrice, cost_price as costPrice,
    stock_low as stockLow, stock_high as stockHigh,
    create_time as createTime, update_time as updateTime
</sql>

<select id="selectById" parameterType="long" resultType="com.example.demo.entity.Goods">
    SELECT <include refid="goodsBaseColumns"/>
    FROM `goods`
    WHERE id = #{id} AND (del_flag IS NULL OR del_flag != 1)
</select>
```

### 6.2 添加查询提示

```xml
<select id="selectAllGoods" resultType="com.example.demo.entity.Goods">
    /*+ INDEX(g idx_goods_name) */
    SELECT g.*
    FROM `goods` g
    WHERE g.name like #{name} || '%'
    AND (g.del_flag IS NULL OR g.del_flag != 1)
</select>
```

### 6.3 使用批处理提高性能

```xml
<!-- 批量插入 -->
<insert id="batchInsert" parameterType="java.util.List">
    INSERT INTO `goods` (sku_code, name, category_id, brand, spec, unit, barcode)
    VALUES
    <foreach collection="list" item="item" separator=",">
        (#{item.skuCode}, #{item.name}, #{item.categoryId},
         #{item.brand}, #{item.spec}, #{item.unit}, #{item.barcode})
    </foreach>
</insert>
```

## 7. 性能监控配置

### 7.1 MyBatis 配置优化

```yaml
mybatis:
    configuration:
        # 启用缓存
        cache-enabled: true
        # 启用懒加载
        lazy-loading-enabled: true
        # 设置默认获取大小
        default-fetch-size: 100
        # 设置默认语句超时时间
        default-statement-timeout: 30
        # 使用列标签而不是列名
        use-column-label: true
        # 返回自动生成的主键
        use-generated-keys: true
```

### 7.2 连接池配置

```yaml
spring:
    datasource:
        hikari:
            maximum-pool-size: 20
            minimum-idle: 10
            connection-timeout: 30000
            idle-timeout: 600000
            max-lifetime: 1800000
            connection-test-query: SELECT 1
```

## 8. 实施步骤

1. **第一阶段**：执行数据库索引优化脚本
2. **第二阶段**：优化关键查询语句（Goods、InventoryOperation）
3. **第三阶段**：添加查询缓存和批处理支持
4. **第四阶段**：监控和调优

## 9. 预期效果

- 查询响应时间减少 50-80%
- 数据库 CPU 使用率降低 30-50%
- 支持更大的数据量（百万级记录）
- 系统稳定性提升
