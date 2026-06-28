create table category
(
    id          int unsigned auto_increment comment '分类ID'
        primary key,
    parent_id   int unsigned default 0                   null comment '上级分类ID，0表示顶级',
    name        varchar(50)                              not null comment '分类名称',
    sort_order  int          default 0                   null comment '排序',
    create_time datetime     default current_timestamp() null comment '创建时间',
    update_time datetime     default current_timestamp() null on update current_timestamp() comment '更新时间'
)
    comment '商品分类表' collate = utf8mb4_general_ci
                         row_format = DYNAMIC;

create index idx_category_name
    on category (name);

create index idx_category_parent_id
    on category (parent_id);

create index idx_category_parent_sort
    on category (parent_id, sort_order);

create index idx_category_sort_order
    on category (sort_order);

create index idx_parent_id
    on category (parent_id);

create table customer
(
    id             int unsigned auto_increment comment '客户ID'
        primary key,
    code           varchar(50)                                not null comment '客户编码',
    name           varchar(100)                               not null comment '客户名称',
    contact_person varchar(50)                                null comment '联系人',
    phone          varchar(20)                                null comment '电话',
    email          varchar(100)                               null,
    address        varchar(200)                               null,
    price_level    tinyint        default 1                   null comment '价格等级（1-零售价 2-批发价 3-VIP价）',
    credit_limit   decimal(12, 2) default 0.00                null comment '信用额度',
    status         tinyint(1)     default 1                   null,
    create_time    datetime       default current_timestamp() null,
    update_time    datetime       default current_timestamp() null on update current_timestamp(),
    constraint uk_code
        unique (code)
)
    comment '客户表' collate = utf8mb4_general_ci
                     row_format = DYNAMIC;

create index idx_customer_contact_person
    on customer (contact_person);

create index idx_customer_name
    on customer (name);

create index idx_customer_name_status
    on customer (name, status);

create index idx_customer_phone
    on customer (phone);

create index idx_customer_status
    on customer (status);

create index idx_customer_status_id
    on customer (status, id);

create table dept
(
    id          bigint auto_increment comment '部门ID'
        primary key,
    name        varchar(255)  null comment '部门名称',
    code        varchar(255)  null comment '部门代码',
    intro       varchar(255)  null comment '部门简介',
    parent_id   bigint        null comment '父部门ID',
    parent_name varchar(255)  null comment '父部门名称',
    phone       varchar(100)  null comment '部门电话',
    address     varchar(100)  null comment '部门地址',
    create_time datetime      null comment '创建时间',
    status      int default 1 null comment '部门状态 0-禁用 1-启用',
    user_id     bigint        null comment '部门负责人ID',
    user_name   varchar(100)  null comment '部门负责人名称'
)
    comment '部门表';

create table goods
(
    id             int unsigned auto_increment comment '商品ID'
        primary key,
    sku_code       varchar(50)                                not null comment 'SKU编码，全局唯一',
    name           varchar(200)                               not null comment '商品名称',
    img            varchar(255)                               null comment '图片URL',
    category_id    int unsigned                               null comment '分类ID',
    brand          varchar(50)                                null comment '品牌',
    spec           varchar(200)                               null comment '规格型号',
    unit           varchar(20)    default '个'                not null comment '基本单位',
    barcode        varchar(50)                                null comment '主条码',
    purchase_price decimal(12, 2) default 0.00                null comment '参考采购价',
    sale_price     decimal(12, 2) default 0.00                null comment '标准售价',
    cost_price     decimal(12, 2) default 0.00                null comment '当前移动加权平均成本',
    stock_low      decimal(12, 2) default 0.00                null comment '库存预警下限',
    stock_high     decimal(12, 2) default 0.00                null comment '库存预警上限',
    create_time    datetime       default current_timestamp() null comment '创建时间',
    update_time    datetime       default current_timestamp() null on update current_timestamp() comment '更新时间',
    del_flag       int(255)       default 0                   null,
    constraint uk_sku_code
        unique (sku_code),
    constraint fk_product_category
        foreign key (category_id) references category (id)
            on delete set null
)
    comment '商品表' collate = utf8mb4_general_ci
                     row_format = DYNAMIC;

create index idx_barcode
    on goods (barcode);

create index idx_category_id
    on goods (category_id);

create index idx_goods_barcode
    on goods (barcode);

create index idx_goods_brand
    on goods (brand);

create index idx_goods_category_id
    on goods (category_id);

create index idx_goods_category_status_time
    on goods (category_id, del_flag, create_time);

create index idx_goods_name
    on goods (name);

create index idx_goods_spec
    on goods (spec);

create table inventory
(
    id                 bigint unsigned auto_increment
        primary key,
    goods_id           int unsigned                               not null comment '商品ID',
    warehouse_id       int unsigned                               not null comment '仓库ID',
    location           varchar(10)                                null comment '默认库位',
    batch_no           varchar(50)    default ''                  null comment '批次号（非批次商品为空字符串）',
    qty_on_hand        decimal(12, 2) default 0.00                not null comment '在手量（实际物理库存）',
    qty_available      decimal(12, 2) default 0.00                not null comment '可用量（在手量 - 锁定量）',
    locked_qty         decimal(12, 2) default 0.00                not null comment '销售订单锁定数量',
    total_cost         decimal(12, 2) default 0.00                not null comment '库存总成本',
    last_inbound_time  datetime                                   null comment '最后入库时间',
    last_outbound_time datetime                                   null comment '最后出库时间',
    create_time        datetime       default current_timestamp() null,
    update_time        datetime       default current_timestamp() null on update current_timestamp(),
    create_by          int                                        null comment '创建人 ID',
    update_by          int                                        null comment '更新人 ID',
    constraint uk_inventory
        unique (goods_id, warehouse_id, batch_no),
    constraint uk_inventory_goods_warehouse
        unique (goods_id, warehouse_id)
)
    comment '库存快照表（实时库存）' collate = utf8mb4_general_ci
                                   row_format = DYNAMIC;

create index idx_inventory_goods_id
    on inventory (goods_id);

create index idx_inventory_qty_on_hand
    on inventory (qty_on_hand);

create index idx_inventory_warehouse_id
    on inventory (warehouse_id);

create table inventory_alert
(
    id                bigint unsigned auto_increment comment '预警ID'
        primary key,
    goods_id          bigint unsigned                            not null comment '商品ID',
    goods_name        varchar(200)                               not null comment '商品名称',
    sku_code          varchar(50)                                not null comment 'SKU编码',
    brand             varchar(50)                                null comment '品牌',
    spec              varchar(200)                               null comment '规格型号',
    unit              varchar(20)    default '个'                not null comment '单位',
    stock_quantity    decimal(12, 2) default 0.00                null comment '当前库存数量',
    stock_low         decimal(12, 2) default 0.00                null comment '库存预警下限',
    stock_high        decimal(12, 2) default 0.00                null comment '库存预警上限',
    alert_type        varchar(20)                                not null comment '预警类型：out_of_stock-缺货，low_stock-库存不足，high_stock-库存过多，expiring_soon-即将到期',
    alert_level       varchar(10)                                not null comment '预警级别：high-高，medium-中，low-低',
    acknowledged      tinyint(1)     default 0                   null comment '是否已确认：0-未确认，1-已确认',
    acknowledged_by   int                                        null comment '确认人ID',
    acknowledged_time datetime                                   null comment '确认时间',
    days_to_expiry    int                                        null comment '到期天数',
    create_time       datetime       default current_timestamp() null comment '创建时间',
    update_time       datetime       default current_timestamp() null on update current_timestamp() comment '更新时间'
)
    comment '库存预警表' collate = utf8mb4_general_ci
                         row_format = DYNAMIC;

create index idx_acknowledged
    on inventory_alert (acknowledged);

create index idx_alert_level
    on inventory_alert (alert_level);

create index idx_alert_type
    on inventory_alert (alert_type);

create index idx_create_time
    on inventory_alert (create_time);

create index idx_goods_id
    on inventory_alert (goods_id);

create index idx_sku_code
    on inventory_alert (sku_code);

create table inventory_operation
(
    id                  bigint unsigned auto_increment comment '作业 ID'
        primary key,
    operation_no        varchar(50)                                not null comment '作业单号',
    operation_type      varchar(20)                                not null comment '作业类型：inbound-入库，outbound-出库，transfer-调拨，adjustment-盘点',
    from_warehouse_id   int unsigned                               null comment '源仓库 ID（出库/调拨时有值）',
    from_warehouse_name varchar(100)                               null comment '源仓库名称（冗余字段，方便查询）',
    to_warehouse_id     int unsigned                               null comment '目标仓库 ID（入库/调拨时有值）',
    to_warehouse_name   varchar(100)                               null comment '目标仓库名称（冗余字段，方便查询）',
    goods_id            int unsigned                               not null comment '商品 ID',
    goods_name          varchar(200)                               not null comment '商品名称（冗余字段，方便查询）',
    sku_code            varchar(50)                                not null comment 'SKU 编码（冗余字段，方便查询）',
    quantity            decimal(12, 2) default 0.00                not null comment '作业数量',
    unit                varchar(20)                                null comment '单位',
    operator            varchar(50)                                null comment '操作员',
    status              varchar(20)    default 'pending'           not null comment '状态：pending-待处理，completed-已完成，cancelled-已取消',
    remark              varchar(500)                               null comment '备注',
    source_type         varchar(20)                                null comment '来源类型：purchase-采购，sales-销售，manual-手工',
    source_no           varchar(50)                                null comment '来源单号（关联采购单/销售单等）',
    create_time         datetime       default current_timestamp() null comment '创建时间',
    update_time         datetime       default current_timestamp() null on update current_timestamp() comment '更新时间',
    complete_time       datetime                                   null comment '完成时间',
    create_by           int                                        null comment '创建人 ID',
    update_by           int                                        null comment '更新人 ID',
    del_flag            tinyint(1)     default 0                   not null comment '删除标志：0-未删除，1-已删除',
    constraint uk_operation_no
        unique (operation_no)
)
    comment '库存作业表' collate = utf8mb4_general_ci
                         row_format = DYNAMIC;

create index idx_create_time
    on inventory_operation (create_time);

create index idx_from_warehouse
    on inventory_operation (from_warehouse_id);

create index idx_goods_id
    on inventory_operation (goods_id);

create index idx_inv_op_create_time
    on inventory_operation (create_time);

create index idx_inv_op_goods_id
    on inventory_operation (goods_id);

create index idx_inv_op_goods_warehouse_time
    on inventory_operation (goods_id, from_warehouse_id, create_time);

create index idx_inv_op_operation_no
    on inventory_operation (operation_no);

create index idx_inv_op_operation_type
    on inventory_operation (operation_type);

create index idx_inv_op_source_no
    on inventory_operation (source_no);

create index idx_inv_op_status
    on inventory_operation (status);

create index idx_operation_type
    on inventory_operation (operation_type);

create index idx_status
    on inventory_operation (status);

create index idx_to_warehouse
    on inventory_operation (to_warehouse_id);

create table meeting
(
    id           bigint auto_increment comment '会议ID'
        primary key,
    title        varchar(255) null comment '会议标题',
    content      text         null comment '会议内容',
    publish_time datetime     null comment '发布时间',
    start_time   datetime     null comment '开始时间',
    end_time     varchar(100) null comment '结束时间',
    status       int          null comment '会议状态 0:未开始 1:进行中 2:已结束',
    make_user    varchar(100) null comment '参加人员',
    address      varchar(100) null comment '会议地点',
    dept_name    varchar(100) null comment '部门名称',
    dept_id      int          null comment '部门ID',
    user_id      bigint       null comment '会议主持人ID',
    user_name    varchar(100) null comment '会议主持人名称'
);

create table menu
(
    id          int          not null
        primary key,
    name        varchar(255) null,
    path        varchar(255) null,
    icon        varchar(255) null,
    description varchar(255) null,
    pid         int          null,
    page_path   varchar(255) null,
    sort_num    int          null,
    status      int          null comment '菜单状态'
)
    comment '系统菜单表' engine = MyISAM
                         collate = utf8mb4_general_ci
                         row_format = DYNAMIC;

create table message
(
    msg_id       int auto_increment
        primary key,
    sender_id    int               null,
    receiver_id  int               null,
    type         varchar(255)      null,
    content      varchar(255)      null,
    attachments  varchar(255)      null,
    publish_date datetime          null,
    is_read      tinyint           null,
    del_flag     tinyint default 0 null
)
    comment '消息表' collate = utf8mb4_general_ci
                     row_format = DYNAMIC;

create table notice
(
    nid         int auto_increment
        primary key,
    uid         int                null,
    title       varchar(255)       null,
    author      varchar(255)       null,
    type        varchar(255)       null,
    summary     varchar(255)       null,
    content     text               null,
    publishDate datetime           null,
    views       int(255) default 0 null,
    status      varchar(255)       null,
    attachments text               null
)
    comment '公告表' collate = utf8mb4_general_ci
                     row_format = DYNAMIC;

create index idx_publishDate_status
    on notice (publishDate, status);

create table notice_read_record
(
    id        int auto_increment
        primary key,
    notice_id int      not null comment '公告ID',
    user_id   int      not null comment '用户ID',
    read_time datetime null comment '阅读时间',
    constraint unique_notice_user
        unique (notice_id, user_id)
)
    comment '公告阅读记录表' collate = utf8mb4_general_ci
                             row_format = DYNAMIC;

create index idx_user_id
    on notice_read_record (user_id);

create table operation_log
(
    id          int auto_increment
        primary key,
    username    varchar(255) null comment '操作用户',
    operation   varchar(255) null comment '操作描述',
    method      varchar(255) null comment '方法名',
    params      text         null comment '参数',
    time        bigint       null comment '执行时间(ms)',
    ip          varchar(255) null comment 'IP地址',
    create_time datetime     null comment '创建时间',
    module      varchar(255) null comment '模块名称',
    type        varchar(255) null comment '操作类型'
)
    comment '系统操作日志表' collate = utf8mb4_general_ci
                             row_format = DYNAMIC;

create index idx_create_time
    on operation_log (create_time);

create index idx_username
    on operation_log (username);

create table purchase
(
    id            int auto_increment comment '自增主键'
        primary key,
    bill_no       varchar(255)                         null comment '单据编号（规则如 PO + 日期 + 流水）',
    supplier_id   bigint                               null comment '关联供应商ID',
    warehouse_id  int                                  null comment '入库目标仓库',
    total_amount  varchar(255)                         null comment '含税总金额',
    status        tinyint                              null comment '状态：0-草稿，1-待审核，2-已完成，3-已作废',
    in_stock_time datetime                             null comment '实际入库时间（用于成本核算的截止点）',
    remark        varchar(500)                         null comment '备注',
    create_time   datetime default current_timestamp() null comment '创建时间',
    update_time   datetime default current_timestamp() null on update current_timestamp() comment '更新时间',
    confirm_time  datetime                             null comment '确认时间'
)
    comment '采购订单表' collate = utf8mb4_general_ci
                         row_format = DYNAMIC;

create table purchase_inbound
(
    id           bigint unsigned auto_increment comment '入库单ID'
        primary key,
    purchase_id  int                                  not null comment '关联采购订单ID',
    bill_no      varchar(50)                          not null comment '入库单号',
    warehouse_id int unsigned                         null comment '入库仓库ID',
    status       tinyint  default 0                   null comment '状态：0-待确认，1-已确认',
    remark       varchar(500)                         null comment '备注',
    create_time  datetime default current_timestamp() null comment '创建时间',
    confirm_time datetime                             null comment '确认时间',
    constraint uk_bill_no
        unique (bill_no)
)
    comment '采购入库单表' collate = utf8mb4_general_ci
                           row_format = DYNAMIC;

create index idx_purchase_id
    on purchase_inbound (purchase_id);

create index idx_status
    on purchase_inbound (status);

create index idx_warehouse_id
    on purchase_inbound (warehouse_id);

create table purchase_inbound_item
(
    id               bigint unsigned auto_increment comment '入库明细ID'
        primary key,
    inbound_id       bigint unsigned             not null comment '入库单ID',
    purchase_item_id bigint unsigned             null comment '采购明细ID',
    goods_id         int unsigned                not null comment '商品ID',
    quantity         decimal(12, 2) default 0.00 not null comment '入库数量',
    unit_price       decimal(12, 2) default 0.00 not null comment '入库单价'
)
    comment '采购入库明细表' collate = utf8mb4_general_ci
                             row_format = DYNAMIC;

create index idx_goods_id
    on purchase_inbound_item (goods_id);

create index idx_inbound_id
    on purchase_inbound_item (inbound_id);

create table purchase_item
(
    id          bigint unsigned auto_increment comment '明细ID'
        primary key,
    purchase_id int                         not null comment '采购订单ID',
    goods_id    int unsigned                not null comment '商品ID',
    quantity    decimal(12, 2) default 0.00 not null comment '数量',
    unit_price  decimal(12, 2) default 0.00 not null comment '单价',
    amount      decimal(12, 2) default 0.00 not null comment '金额',
    sort_no     int            default 0    null comment '排序号'
)
    comment '采购明细表' collate = utf8mb4_general_ci
                         row_format = DYNAMIC;

create index idx_goods_id
    on purchase_item (goods_id);

create index idx_purchase_id
    on purchase_item (purchase_id);

create table role
(
    id     bigint auto_increment comment '角色ID'
        primary key,
    name   char(255)    null comment '角色名称',
    bio    varchar(255) null comment '角色简介',
    status int          null comment '角色状态 0-停用/1-启用'
)
    comment '用户角色表' engine = MyISAM
                         collate = utf8mb4_0900_ai_ci
                         row_format = DYNAMIC;

create table role_menu
(
    id      bigint not null comment '角色菜单关联ID'
        primary key,
    role_id bigint null comment '角色ID',
    menu_id int    null comment '菜单ID',
    constraint uk_role_menu
        unique (role_id, menu_id)
)
    comment '用户角色菜单关联表' engine = MyISAM
                                 collate = utf8mb4_0900_ai_ci
                                 row_format = FIXED;

create table sal_order
(
    id              bigint unsigned auto_increment comment '订单ID'
        primary key,
    order_no        varchar(50)                                not null comment '订单编号',
    customer_id     bigint unsigned                            null comment '客户ID',
    warehouse_id    int unsigned                               null comment '出库仓库ID',
    order_date      datetime                                   null comment '订单日期',
    total_amount    decimal(12, 2) default 0.00                null comment '订单总额',
    discount_amount decimal(12, 2) default 0.00                null comment '折扣金额',
    final_amount    decimal(12, 2) default 0.00                null comment '最终金额',
    status          tinyint        default 0                   null comment '状态：0-草稿，1-已确认，2-已完成，3-已作废',
    remark          varchar(500)                               null comment '备注',
    created_by      varchar(50)                                null comment '创建人',
    created_at      datetime       default current_timestamp() null comment '创建时间',
    updated_at      datetime       default current_timestamp() null on update current_timestamp() comment '更新时间',
    confirm_time    datetime                                   null comment '确认时间',
    deliver_time    datetime                                   null comment '发货时间',
    constraint uk_order_no
        unique (order_no)
)
    comment '销售订单表' collate = utf8mb4_general_ci
                         row_format = DYNAMIC;

create index idx_created_at
    on sal_order (created_at);

create index idx_customer_id
    on sal_order (customer_id);

create index idx_status
    on sal_order (status);

create index idx_warehouse_id
    on sal_order (warehouse_id);

create table sal_order_item
(
    id                    bigint unsigned auto_increment comment '明细ID'
        primary key,
    order_id              bigint unsigned                            not null comment '订单ID',
    product_id            bigint unsigned                            null comment '商品ID',
    product_name_snapshot varchar(200)                               null comment '商品名称快照',
    price                 decimal(12, 2) default 0.00                null comment '单价',
    quantity              int            default 0                   null comment '数量',
    subtotal              decimal(12, 2) default 0.00                null comment '小计',
    created_at            datetime       default current_timestamp() null comment '创建时间'
)
    comment '销售订单明细表' collate = utf8mb4_general_ci
                             row_format = DYNAMIC;

create index idx_order_id
    on sal_order_item (order_id);

create index idx_product_id
    on sal_order_item (product_id);

create table sale_outbound
(
    id            bigint unsigned auto_increment comment '出库单ID'
        primary key,
    sale_order_id bigint unsigned                      not null comment '关联销售订单ID',
    bill_no       varchar(50)                          not null comment '出库单号',
    warehouse_id  int unsigned                         null comment '出库仓库ID',
    status        tinyint  default 0                   null comment '状态：0-待确认，1-已确认',
    remark        varchar(500)                         null comment '备注',
    create_time   datetime default current_timestamp() null comment '创建时间',
    confirm_time  datetime                             null comment '确认时间',
    constraint uk_bill_no
        unique (bill_no)
)
    comment '销售出库单表' collate = utf8mb4_general_ci
                           row_format = DYNAMIC;

create index idx_sale_order_id
    on sale_outbound (sale_order_id);

create index idx_status
    on sale_outbound (status);

create index idx_warehouse_id
    on sale_outbound (warehouse_id);

create table sale_outbound_item
(
    id                 bigint unsigned auto_increment comment '出库明细ID'
        primary key,
    outbound_id        bigint unsigned             not null comment '出库单ID',
    sale_order_item_id bigint unsigned             null comment '订单明细ID',
    product_id         bigint unsigned             null comment '商品ID',
    quantity           int            default 0    null comment '出库数量',
    price              decimal(12, 2) default 0.00 null comment '出库单价'
)
    comment '销售出库明细表' collate = utf8mb4_general_ci
                             row_format = DYNAMIC;

create index idx_outbound_id
    on sale_outbound_item (outbound_id);

create index idx_product_id
    on sale_outbound_item (product_id);

create table sign_record
(
    sid             int auto_increment
        primary key,
    uid             int                                  not null comment '用户ID',
    sign_in_time    datetime                             null comment '签到时间',
    sign_out_time   datetime                             null comment '签退时间',
    remark          varchar(255)                         null comment '备注',
    create_time     datetime default current_timestamp() null,
    sign_in_status  varchar(255)                         null,
    sign_out_status varchar(255)                         null
)
    comment '签到记录表' collate = utf8mb4_general_ci
                         row_format = DYNAMIC;

create index idx_user_id
    on sign_record (uid);

create table supplier
(
    id             int unsigned auto_increment comment '供应商ID'
        primary key,
    code           varchar(50)                            not null comment '供应商编码',
    name           varchar(100)                           not null comment '供应商名称',
    type           varchar(255)                           null comment '供应商类型',
    contact_person varchar(50)                            null comment '联系人',
    phone          varchar(20)                            null comment '联系电话',
    email          varchar(100)                           null comment '邮箱',
    address        varchar(200)                           null comment '地址',
    bank_account   varchar(50)                            null comment '银行账号',
    bank_name      varchar(255)                           null comment '开户银行',
    tax_number     varchar(50)                            null comment '税人识别号',
    status         tinyint(1) default 1                   null comment '状态',
    create_time    datetime   default current_timestamp() null,
    update_time    datetime   default current_timestamp() null on update current_timestamp(),
    constraint uk_code
        unique (code),
    constraint uk_supplier_code
        unique (code)
)
    comment '供应商表' collate = utf8mb4_general_ci
                       row_format = DYNAMIC;

create index idx_supplier_contact_person
    on supplier (contact_person);

create index idx_supplier_name
    on supplier (name);

create index idx_supplier_phone
    on supplier (phone);

create index idx_supplier_status
    on supplier (status);

create table user
(
    uid        int auto_increment
        primary key,
    username   varchar(255)                null,
    password   varchar(255)                null,
    name       varchar(255)                null,
    email      varchar(255)                null,
    role       varchar(255)                null,
    department varchar(255)                null,
    phone      varchar(255)                null,
    bio        varchar(255)                null,
    joinDate   datetime                    null,
    status     varchar(255) default '启用' null,
    createTime datetime                    null,
    updateTime datetime                    null on update current_timestamp(),
    avatar     varchar(255)                null,
    del_flag   int          default 0      null,
    constraint unique_id
        unique (uid)
)
    comment '用户表' collate = utf8mb4_general_ci
                     row_format = DYNAMIC;

create table user_role
(
    id      bigint auto_increment comment '用户角色关联ID'
        primary key,
    user_id bigint null comment '用户ID',
    role_id bigint null comment '角色ID',
    constraint uk_user_role
        unique (user_id, role_id)
)
    comment '用户角色关联表' engine = MyISAM
                             collate = utf8mb4_0900_ai_ci
                             row_format = FIXED;

create table warehouse
(
    id          int unsigned auto_increment comment '仓库ID'
        primary key,
    code        varchar(20)                            not null comment '仓库编码',
    name        varchar(50)                            not null comment '仓库名称',
    kind        varchar(255)                           null comment '仓库类型',
    address     varchar(200)                           null comment '仓库地址',
    manager     varchar(50)                            null comment '负责人',
    phone       varchar(255)                           null comment '负责人电话',
    status      tinyint(1) default 1                   null comment '状态 0-停用 1-启用',
    create_time datetime   default current_timestamp() null,
    del_flag    int        default 0                   null,
    constraint uk_code
        unique (code),
    constraint uk_warehouse_code
        unique (code)
)
    comment '仓库表' collate = utf8mb4_general_ci
                     row_format = DYNAMIC;

create index idx_warehouse_kind
    on warehouse (kind);

create index idx_warehouse_name
    on warehouse (name);

create index idx_warehouse_status
    on warehouse (status);

create index idx_warehouse_status_time
    on warehouse (status, create_time);

create
    definer = root@localhost procedure UpdateNoticeStatusByDate()
BEGIN
    -- 将所有 publishDate 小于或等于当前时间，且 status 还不是 '已发布'(或你的目标状态) 的记录更新
    -- 假设：目标状态值设为 'PUBLISHED'，你的初始状态可能是 'PENDING' 或 'DRAFT'
    UPDATE notice
    SET status = '已发布'  -- 替换成你想要修改成的状态值
    WHERE publishDate <= NOW()
      AND status = '定时发布'; -- 避免重复更新，提高效率
END;

create definer = root@localhost event updateStatus_evnet on schedule
    every '5' MINUTE
        starts '2026-04-03 09:40:00'
    enable
    do
    CALL UpdateNoticeStatusByDate();


