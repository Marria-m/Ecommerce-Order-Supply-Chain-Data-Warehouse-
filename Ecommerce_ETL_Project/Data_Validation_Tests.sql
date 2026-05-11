-- Total Customers Loaded
SELECT COUNT(*) AS Total_Customers 
FROM DWH.Dim_Customer;

-- Cartesian Product Check (Should return 0 rows)
SELECT customer_id, COUNT(*) AS Duplicate_Count
FROM DWH.Dim_Customer
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Star Schema Integrity Check
SELECT TOP 10 
    f.order_id, 
    c.customer_id, 
    g.customer_city, 
    g.customer_state
FROM DWH.Fact_Order_Approvals f
JOIN DWH.Dim_Customer c ON f.CustomerKey = c.CustomerKey
JOIN DWH.Dim_Geography g ON c.GeoKey = g.GeoKey;