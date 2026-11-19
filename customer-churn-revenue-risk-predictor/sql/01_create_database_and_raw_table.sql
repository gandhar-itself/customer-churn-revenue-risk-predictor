IF DB_ID(N'customer_churn_db') IS NULL
    CREATE DATABASE customer_churn_db;
GO
USE customer_churn_db;
GO
IF OBJECT_ID(N'dbo.raw_customers', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.raw_customers
    (
        customerID VARCHAR(50) NULL, gender VARCHAR(20) NULL,
        SeniorCitizen VARCHAR(10) NULL, Partner VARCHAR(10) NULL,
        Dependents VARCHAR(10) NULL, tenure VARCHAR(20) NULL,
        PhoneService VARCHAR(10) NULL, MultipleLines VARCHAR(30) NULL,
        InternetService VARCHAR(30) NULL, OnlineSecurity VARCHAR(30) NULL,
        OnlineBackup VARCHAR(30) NULL, DeviceProtection VARCHAR(30) NULL,
        TechSupport VARCHAR(30) NULL, StreamingTV VARCHAR(30) NULL,
        StreamingMovies VARCHAR(30) NULL, Contract VARCHAR(30) NULL,
        PaperlessBilling VARCHAR(10) NULL, PaymentMethod VARCHAR(60) NULL,
        MonthlyCharges VARCHAR(30) NULL, TotalCharges VARCHAR(30) NULL,
        Churn VARCHAR(10) NULL
    );
END;
GO
SELECT DB_NAME() AS active_database,
       OBJECT_ID(N'dbo.raw_customers', N'U') AS raw_table_object_id;
GO
