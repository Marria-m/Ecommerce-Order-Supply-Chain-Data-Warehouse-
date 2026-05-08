USE Ecommerce_DWH
GO

CREATE SCHEMA DWH;
Go 

-- 1. Dim_Date
CREATE TABLE DWH.Dim_Date (
   [DateKey] [int] NOT NULL,
   [Date] [date] NOT NULL,
   [Day] [tinyint] NOT NULL,
   [DaySuffix] [char](2) NOT NULL,
   [Weekday] [tinyint] NOT NULL,
   [WeekDayName] [varchar](10) NOT NULL,
   [WeekDayName_Short] [char](3) NOT NULL,
   [WeekDayName_FirstLetter] [char](1) NOT NULL,
   [DOWInMonth] [tinyint] NOT NULL,
   [DayOfYear] [smallint] NOT NULL,
   [WeekOfMonth] [tinyint] NOT NULL,
   [WeekOfYear] [tinyint] NOT NULL,
   [Month] [tinyint] NOT NULL,
   [MonthName] [varchar](10) NOT NULL,
   [MonthName_Short] [char](3) NOT NULL,
   [MonthName_FirstLetter] [char](1) NOT NULL,
   [Quarter] [tinyint] NOT NULL,
   [QuarterName] [varchar](6) NOT NULL,
   [Year] [int] NOT NULL,
   [MMYYYY] [char](6) NOT NULL,
   [MonthYear] [char](7) NOT NULL,
   [IsWeekend] BIT NOT NULL,
   [IsHoliday] BIT NOT NULL,
   [HolidayName] VARCHAR(20) NULL,
   [SpecialDays] VARCHAR(20) NULL,
   [FinancialYear] [int] NULL,
   [FinancialQuater] [int] NULL,
   [FinancialMonth] [int] NULL,
   [FirstDateofYear] DATE NULL,
   [LastDateofYear] DATE NULL,
   [FirstDateofQuater] DATE NULL,
   [LastDateofQuater] DATE NULL,
   [FirstDateofMonth] DATE NULL,
   [LastDateofMonth] DATE NULL,
   [FirstDateofWeek] DATE NULL,
   [LastDateofWeek] DATE NULL,
   [CurrentYear] SMALLINT NULL,
   [CurrentQuater] SMALLINT NULL,
   [CurrentMonth] SMALLINT NULL,
   [CurrentWeek] SMALLINT NULL,
   [CurrentDay] SMALLINT NULL,
   PRIMARY KEY CLUSTERED ([DateKey] ASC)
);


-- 2. Dim_Time
CREATE TABLE DWH.Dim_Time (
    TimeKey INT PRIMARY KEY,
    Hour INT NOT NULL,
    Minute INT NOT NULL,
    Shift VARCHAR(20) NOT NULL
);


-- 3. Dim_Geography (Static)
CREATE TABLE DWH.Dim_Geography (
    GeoKey INT IDENTITY(1,1) PRIMARY KEY,
    customer_zip_code_prefix VARCHAR(20),
    customer_city VARCHAR(50),
    customer_state VARCHAR(50)
);


-- 4. Dim_Customer (SCD Type 2)
CREATE TABLE DWH.Dim_Customer (
    CustomerKey INT IDENTITY(1,1) PRIMARY KEY,
    customer_id VARCHAR(50),
    GeoKey INT REFERENCES DWH.Dim_Geography(GeoKey),
    EffectiveDate DATE,
    ExpirationDate DATE,
    IsCurrent BIT
);


-- 5. Dim_Product (SCD Type 1)

CREATE TABLE DWH.Dim_Product (
    ProductKey INT IDENTITY(1,1) PRIMARY KEY,
    product_id VARCHAR(50),
    product_category_name VARCHAR(100),
    product_weight_g FLOAT,
    product_length_cm FLOAT,
    product_height_cm FLOAT,
    product_width_cm FLOAT
);


-- 6. Dim_PaymentType (Junk Dimension)
CREATE TABLE DWH.Dim_PaymentType (
    PaymentTypeKey INT IDENTITY(1,1) PRIMARY KEY,
    payment_type VARCHAR(50),
    is_Installment_Flag BIT
);


-- 7. Fact_OrderItems
CREATE TABLE DWH.Fact_OrderItems (
    OrderItemKey INT IDENTITY(1,1) PRIMARY KEY,
    order_id VARCHAR(50),
    seller_id VARCHAR(50),
    DateKey INT REFERENCES DWH.Dim_Date(DateKey),
    TimeKey INT REFERENCES DWH.Dim_Time(TimeKey),
    CustomerKey INT REFERENCES DWH.Dim_Customer(CustomerKey),
    ProductKey INT REFERENCES DWH.Dim_Product(ProductKey),
    price FLOAT,
    shipping_charges FLOAT
);


-- 8. Fact_Order_Approvals
CREATE TABLE DWH.Fact_Order_Approvals (
    ApprovalKey INT IDENTITY(1,1) PRIMARY KEY,
    order_id VARCHAR(50),
    PurchaseDateKey INT REFERENCES DWH.Dim_Date(DateKey),
    PurchaseTimeKey INT REFERENCES DWH.Dim_Time(TimeKey),
    ApprovalDateKey INT REFERENCES DWH.Dim_Date(DateKey),
    ApprovalTimeKey INT REFERENCES DWH.Dim_Time(TimeKey),
    CustomerKey INT REFERENCES DWH.Dim_Customer(CustomerKey),
    Approval_Lead_Time_Hours FLOAT
);


-- 9. Fact_Payments
CREATE TABLE DWH.Fact_Payments (
    PaymentKey INT IDENTITY(1,1) PRIMARY KEY,
    order_id VARCHAR(50),
    DateKey INT REFERENCES DWH.Dim_Date(DateKey),
    TimeKey INT REFERENCES DWH.Dim_Time(TimeKey),
    CustomerKey INT REFERENCES DWH.Dim_Customer(CustomerKey),
    PaymentTypeKey INT REFERENCES DWH.Dim_PaymentType(PaymentTypeKey),
    payment_value FLOAT,
    payment_installments INT
);
GO


-- POPULATE STATIC DIMENSIONS (DATE & TIME)


-- A. Populate Dim_Date
SET NOCOUNT ON

DECLARE @CurrentDate DATE = '2000-01-01'
DECLARE @EndDate DATE = '2030-12-31'

WHILE @CurrentDate <= @EndDate
BEGIN
   INSERT INTO DWH.Dim_Date (
      [DateKey], [Date], [Day], [DaySuffix], [Weekday], [WeekDayName], [WeekDayName_Short], 
      [WeekDayName_FirstLetter], [DOWInMonth], [DayOfYear], [WeekOfMonth], [WeekOfYear], 
      [Month], [MonthName], [MonthName_Short], [MonthName_FirstLetter], [Quarter], [QuarterName], 
      [Year], [MMYYYY], [MonthYear], [IsWeekend], [IsHoliday], [FirstDateofYear], [LastDateofYear], 
      [FirstDateofQuater], [LastDateofQuater], [FirstDateofMonth], [LastDateofMonth], 
      [FirstDateofWeek], [LastDateofWeek]
      )
   SELECT DateKey = YEAR(@CurrentDate) * 10000 + MONTH(@CurrentDate) * 100 + DAY(@CurrentDate),
      DATE = @CurrentDate,
      Day = DAY(@CurrentDate),
      [DaySuffix] = CASE 
         WHEN DAY(@CurrentDate) IN (1, 21, 31) THEN 'st'
         WHEN DAY(@CurrentDate) IN (2, 22) THEN 'nd'
         WHEN DAY(@CurrentDate) IN (3, 23) THEN 'rd'
         ELSE 'th'
         END,
      WEEKDAY = DATEPART(dw, @CurrentDate),
      WeekDayName = DATENAME(dw, @CurrentDate),
      WeekDayName_Short = UPPER(LEFT(DATENAME(dw, @CurrentDate), 3)),
      WeekDayName_FirstLetter = LEFT(DATENAME(dw, @CurrentDate), 1),
      [DOWInMonth] = DAY(@CurrentDate),
      [DayOfYear] = DATENAME(dy, @CurrentDate),
      [WeekOfMonth] = DATEPART(WEEK, @CurrentDate) - DATEPART(WEEK, DATEADD(MM, DATEDIFF(MM, 0, @CurrentDate), 0)) + 1,
      [WeekOfYear] = DATEPART(wk, @CurrentDate),
      [Month] = MONTH(@CurrentDate),
      [MonthName] = DATENAME(mm, @CurrentDate),
      [MonthName_Short] = UPPER(LEFT(DATENAME(mm, @CurrentDate), 3)),
      [MonthName_FirstLetter] = LEFT(DATENAME(mm, @CurrentDate), 1),
      [Quarter] = DATEPART(q, @CurrentDate),
      [QuarterName] = CASE 
         WHEN DATENAME(qq, @CurrentDate) = 1 THEN 'First'
         WHEN DATENAME(qq, @CurrentDate) = 2 THEN 'second'
         WHEN DATENAME(qq, @CurrentDate) = 3 THEN 'third'
         WHEN DATENAME(qq, @CurrentDate) = 4 THEN 'fourth'
         END,
      [Year] = YEAR(@CurrentDate),
      [MMYYYY] = RIGHT('0' + CAST(MONTH(@CurrentDate) AS VARCHAR(2)), 2) + CAST(YEAR(@CurrentDate) AS VARCHAR(4)),
      [MonthYear] = CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + UPPER(LEFT(DATENAME(mm, @CurrentDate), 3)),
      [IsWeekend] = CASE 
         WHEN DATENAME(dw, @CurrentDate) IN ('Sunday', 'Saturday') THEN 1
         ELSE 0
         END,
      [IsHoliday] = 0,
      [FirstDateofYear] = CAST(CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + '-01-01' AS DATE),
      [LastDateofYear] = CAST(CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + '-12-31' AS DATE),
      [FirstDateofQuater] = DATEADD(qq, DATEDIFF(qq, 0, @CurrentDate), 0),
      [LastDateofQuater] = DATEADD(dd, - 1, DATEADD(qq, DATEDIFF(qq, 0, @CurrentDate) + 1, 0)),
      [FirstDateofMonth] = CAST(CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + '-' + CAST(MONTH(@CurrentDate) AS VARCHAR(2)) + '-01' AS DATE),
      [LastDateofMonth] = EOMONTH(@CurrentDate),
      [FirstDateofWeek] = DATEADD(dd, - (DATEPART(dw, @CurrentDate) - 1), @CurrentDate),
      [LastDateofWeek] = DATEADD(dd, 7 - (DATEPART(dw, @CurrentDate)), @CurrentDate)

   SET @CurrentDate = DATEADD(DD, 1, @CurrentDate)
END
GO

-- B. Populate Dim_Time (00:00 to 23:59)
SET NOCOUNT ON

DECLARE @Hour INT = 0
DECLARE @Minute INT = 0
DECLARE @TimeKey INT
DECLARE @Shift VARCHAR(20)

WHILE @Hour < 24
BEGIN
    SET @Minute = 0
    WHILE @Minute < 60
    BEGIN
        SET @TimeKey = (@Hour * 100) + @Minute
        
        SET @Shift = CASE
            WHEN @Hour >= 0 AND @Hour < 6 THEN 'Night'
            WHEN @Hour >= 6 AND @Hour < 12 THEN 'Morning'
            WHEN @Hour >= 12 AND @Hour < 18 THEN 'Afternoon'
            ELSE 'Evening'
        END

        INSERT INTO DWH.Dim_Time (TimeKey, Hour, Minute, Shift)
        VALUES (@TimeKey, @Hour, @Minute, @Shift)

        SET @Minute = @Minute + 1
    END
    SET @Hour = @Hour + 1
END
GO