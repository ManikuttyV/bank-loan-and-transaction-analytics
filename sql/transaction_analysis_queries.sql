use bank_analytics;

CREATE TABLE bank_transactions (
    Customer_ID VARCHAR(50),
    Customer_Name VARCHAR(100),
    Account_Number VARCHAR(50),
    Transaction_Date VARCHAR(20),     -- TEMPORARY
    Transaction_Type VARCHAR(20),
    Amount DECIMAL(15,2),
    Balance DECIMAL(15,2),
    Description VARCHAR(255),
    Branch VARCHAR(100),
    Transaction_Method VARCHAR(50),
    Currency VARCHAR(10),
    Bank_Name VARCHAR(100),
    High_Value_Flag VARCHAR(5)
);

SELECT COUNT(*) FROM bank_transactions;
SELECT * FROM bank_transactions LIMIT 5;

set sql_safe_updates=0;
UPDATE bank_transactions
SET Transaction_Date = STR_TO_DATE(Transaction_Date, '%d-%m-%Y');

ALTER TABLE bank_transactions
MODIFY Transaction_Date DATE;

CREATE TABLE bank_transactions_clean AS
SELECT DISTINCT *
FROM bank_transactions;

SELECT COUNT(*) FROM bank_transactions_clean;

-- 1. Total Credit Amount 
SELECT SUM(Amount) AS Total_Credit_Amount
FROM bank_transactions_clean
WHERE Transaction_Type = 'Credit';

-- 2.Total Debit Amount
SELECT SUM(Amount) AS Total_Credit_Amount
FROM bank_transactions_clean
WHERE Transaction_Type = 'Debit';

-- 3.Credit to Debit Ratio
SELECT
    SUM(CASE WHEN Transaction_Type = 'Credit' THEN Amount ELSE 0 END) /
    NULLIF(SUM(CASE WHEN Transaction_Type = 'Debit' THEN Amount ELSE 0 END), 0)
    AS Credit_to_Debit_Ratio
FROM bank_transactions_clean;

-- 4.Net Transaction Amount
SELECT
    SUM(CASE WHEN Transaction_Type = 'Credit' THEN Amount ELSE 0 END) -
    NULLIF(SUM(CASE WHEN Transaction_Type = 'Debit' THEN Amount ELSE 0 END), 0)
    AS Net_Transaction_Amount
FROM bank_transactions_clean;

-- 5.Account Activity Ratio
SELECT
    COUNT(*) AS Number_of_Transactions,
    SUM(Balance) AS Account_Balance,
    COUNT(*) * 1.0 / SUM(Balance) AS Account_Activity_Ratio
FROM bank_transactions_clean;


-- 6-Transactions per Day/Week/Month:
-- Number of Transactions Per Month
SELECT DATE_FORMAT(Transaction_Date, '%Y-%m') AS Month,
    COUNT(*) AS Transactions_Per_Month
FROM bank_transactions_clean
GROUP BY Month
ORDER BY Month;

-- 7-Total Transaction Amount by Branch:
SELECT Branch,SUM(Amount)Total_Transactions
FROM bank_transactions_clean
GROUP BY Branch
ORDER BY Total_Transactions DESC;

-- 8-Transaction Volume by Bank:
SELECT Bank_Name,SUM(Amount)Total_Transactions
FROM bank_transactions_clean
GROUP BY Bank_Name
ORDER BY Total_Transactions DESC;


-- 9-Transaction Method Distribution:
SELECT Transaction_Method,COUNT(*) AS Transaction_Count,
   concat( ROUND(COUNT(*) * 100.0 /(SELECT COUNT(*) FROM bank_transactions_clean),2),"%") AS Transaction_Percentage
FROM bank_transactions_clean
GROUP BY Transaction_Method
ORDER BY Transaction_Percentage DESC;

-- 10-Branch Transaction Growth:
WITH task AS (SELECT Branch,
        monthname(Transaction_Date) AS Month_Name,
        SUM(Amount) AS Current_Month_Amount,
        LAG(SUM(Amount)) OVER (PARTITION BY Branch ORDER BY DATE_FORMAT(Transaction_Date, '%m')
        ) AS Previous_Month_Amount FROM bank_transactions_clean
    GROUP BY Branch, Month_name)
    SELECT Branch,Month_Name,Current_Month_Amount,Previous_Month_Amount,
    Current_Month_Amount - Previous_Month_Amount AS Difference,
    CONCAT(ROUND((Current_Month_Amount - Previous_Month_Amount) / Previous_Month_Amount * 100, 2),'%') AS MOM_Growth
FROM Task;


-- 11-High-Risk Transaction Flag:
SELECT COUNT(*) AS High_Risk_Transaction_Count
FROM bank_transactions_clean
WHERE High_Value_Flag = 'Yes';
 
 -- 12-Suspicious Transaction Frequency:
SELECT 
    monthname(Transaction_Date) AS Month,
    COUNT(*) AS Transactions_Per_Month
FROM bank_transactions_clean
WHERE High_Value_Flag = 'Yes'
GROUP BY Month
ORDER BY Month;