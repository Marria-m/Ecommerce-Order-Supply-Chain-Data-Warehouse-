CREATE DATABASE Ecommerce_DWH
GO

USE Ecommerce_DWH
GO

CREATE SCHEMA STG
GO


-- STG.Customer
CREATE TABLE STG.Customer (
    customer_id              varchar(50),
    customer_zip_code_prefix varchar(10),
    customer_city            varchar(50),
    customer_state           varchar(10),
    create_timestamp         datetime
);


-- STG.Product
CREATE TABLE STG.Product (
    product_id            varchar(50),
    product_category_name varchar(100),
    product_weight_g      float,
    product_length_cm     float,
    product_height_cm     float,
    product_width_cm      float,
    create_timestamp      datetime
);


-- STG.Orders
CREATE TABLE STG.Orders (
    order_id                 varchar(50),
    customer_id              varchar(50),
    order_purchase_timestamp datetime,
    order_approved_at        datetime,
    create_timestamp         datetime
);


-- STG.OrderItems
CREATE TABLE STG.OrderItems (
    order_id         varchar(50),
    product_id       varchar(50),
    seller_id        varchar(50),
    price            float,
    shipping_charges float,
    create_timestamp datetime
);


-- STG.Payments
CREATE TABLE STG.Payments (
    order_id              varchar(50),
    payment_sequential    int,
    payment_type          varchar(30),
    payment_installments  int,
    payment_value         float,
    create_timestamp      datetime
);

-- 6. Watermark Table
CREATE TABLE STG.etl_watermark
(
  table_name                 VARCHAR(30),
  last_extract_date          DATETIME
);

INSERT INTO STG.etl_watermark VALUES
    ('Customers', '1900-01-01'),
    ('Orders', '1900-01-01'),
    ('Products', '1900-01-01'),
    ('Payments', '1900-01-01'),
    ('Order_Items', '1900-01-01');
GO

select * from STG.etl_watermark