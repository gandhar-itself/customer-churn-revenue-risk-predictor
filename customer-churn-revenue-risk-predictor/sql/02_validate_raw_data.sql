USE customer_churn_db;
GO
SELECT COUNT(*) AS total_rows FROM dbo.raw_customers;
SELECT TOP (10) * FROM dbo.raw_customers;
SELECT COALESCE(NULLIF(LTRIM(RTRIM(Churn)), ''), '(blank)') AS churn_value,
       COUNT(*) AS customer_count
FROM dbo.raw_customers
GROUP BY COALESCE(NULLIF(LTRIM(RTRIM(Churn)), ''), '(blank)')
ORDER BY customer_count DESC;
SELECT
 SUM(CASE WHEN NULLIF(LTRIM(RTRIM(customerID)), '') IS NULL THEN 1 ELSE 0 END) AS blank_customer_ids,
 SUM(CASE WHEN NULLIF(LTRIM(RTRIM(TotalCharges)), '') IS NULL THEN 1 ELSE 0 END) AS blank_total_charges,
 SUM(CASE WHEN TRY_CONVERT(DECIMAL(10,2), MonthlyCharges) IS NULL THEN 1 ELSE 0 END) AS invalid_monthly_charges,
 SUM(CASE WHEN TRY_CONVERT(INT, tenure) IS NULL THEN 1 ELSE 0 END) AS invalid_tenure
FROM dbo.raw_customers;
SELECT customerID, COUNT(*) AS duplicate_count
FROM dbo.raw_customers
GROUP BY customerID HAVING COUNT(*) > 1;
GO
