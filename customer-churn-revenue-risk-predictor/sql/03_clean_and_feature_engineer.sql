USE customer_churn_db;
GO
CREATE OR ALTER VIEW dbo.vw_customer_churn_model_data
AS
SELECT
 LTRIM(RTRIM(customerID)) AS customerID,
 LTRIM(RTRIM(gender)) AS gender,
 TRY_CONVERT(BIT, NULLIF(LTRIM(RTRIM(SeniorCitizen)), '')) AS SeniorCitizen,
 LTRIM(RTRIM(Partner)) AS Partner,
 LTRIM(RTRIM(Dependents)) AS Dependents,
 TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(tenure)), '')) AS tenure,
 LTRIM(RTRIM(PhoneService)) AS PhoneService,
 LTRIM(RTRIM(MultipleLines)) AS MultipleLines,
 LTRIM(RTRIM(InternetService)) AS InternetService,
 LTRIM(RTRIM(OnlineSecurity)) AS OnlineSecurity,
 LTRIM(RTRIM(OnlineBackup)) AS OnlineBackup,
 LTRIM(RTRIM(DeviceProtection)) AS DeviceProtection,
 LTRIM(RTRIM(TechSupport)) AS TechSupport,
 LTRIM(RTRIM(StreamingTV)) AS StreamingTV,
 LTRIM(RTRIM(StreamingMovies)) AS StreamingMovies,
 LTRIM(RTRIM(Contract)) AS Contract,
 LTRIM(RTRIM(PaperlessBilling)) AS PaperlessBilling,
 LTRIM(RTRIM(PaymentMethod)) AS PaymentMethod,
 TRY_CONVERT(DECIMAL(10,2), NULLIF(LTRIM(RTRIM(MonthlyCharges)), '')) AS MonthlyCharges,
 TRY_CONVERT(DECIMAL(10,2), NULLIF(LTRIM(RTRIM(TotalCharges)), '')) AS TotalCharges,
 LTRIM(RTRIM(Churn)) AS Churn,
 CASE WHEN LTRIM(RTRIM(Churn)) = 'Yes' THEN 1
      WHEN LTRIM(RTRIM(Churn)) = 'No' THEN 0 ELSE NULL END AS ChurnFlag,
 CASE WHEN TRY_CONVERT(INT, tenure) = 0 THEN 1 ELSE 0 END AS IsNewCustomer,
 CASE WHEN LTRIM(RTRIM(Contract)) = 'Month-to-month' THEN 1 ELSE 0 END AS IsMonthToMonth
FROM dbo.raw_customers
WHERE NULLIF(LTRIM(RTRIM(customerID)), '') IS NOT NULL;
GO
SELECT TOP (20) * FROM dbo.vw_customer_churn_model_data;
-- Export this view to data/processed/telco_churn_model_data.csv for Python.
