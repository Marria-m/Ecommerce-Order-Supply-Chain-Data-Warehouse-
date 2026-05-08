USE Ecommerce_DWH;
GO

SELECT 'Customer' AS TableName, COUNT(*) AS TotalRows FROM STG.Customer
UNION ALL
SELECT 'Product', COUNT(*) FROM STG.Product
UNION ALL
SELECT 'Orders', COUNT(*) FROM STG.Orders
UNION ALL
SELECT 'OrderItems', COUNT(*) FROM STG.OrderItems
UNION ALL
SELECT 'Payments', COUNT(*) FROM STG.Payments;

SELECT TOP 10 * FROM STG.Customer;

SELECT * FROM STG.etl_watermark;