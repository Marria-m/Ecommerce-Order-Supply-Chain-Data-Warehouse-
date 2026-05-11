-- 1. DELETE THE FACTS (The Children)
DELETE FROM DWH.Fact_OrderItems;
DELETE FROM DWH.Fact_Payments;
DELETE FROM DWH.Fact_Order_Approvals;

-- 2. DELETE DEPENDENT DIMENSIONS (The Middle Child)
DELETE FROM DWH.Dim_Customer;

-- 3. DELETE INDEPENDENT DIMENSIONS (The Parents)
DELETE FROM DWH.Dim_Geography;
DELETE FROM DWH.Dim_Product;
DELETE FROM DWH.Dim_PaymentType;
DELETE FROM DWH.Dim_Date;
DELETE FROM DWH.Dim_Time;