use bank_analytics;

CREATE TABLE loan_data (
    Account_ID VARCHAR(50),
    Age VARCHAR(20),
    BH_Code INT,
    BH_Name VARCHAR(100),
    BankCode INT,
    BankName VARCHAR(100),
    BranchName VARCHAR(100),
    Caste VARCHAR(30),
    City VARCHAR(50),
    Client_id INT,
    Client_Name VARCHAR(100),
    Closed_Date VARCHAR(20),
    Credit_Officer_Name VARCHAR(100),
    Disb_By VARCHAR(50),
    Disbursement_Date VARCHAR(20),
    Disbursement_Years VARCHAR(20),
    Gender VARCHAR(10),
    Home_Ownership VARCHAR(30),
    Loan_Status VARCHAR(30),
    Product_Code VARCHAR(30),
    Grade VARCHAR(10),
    Product_Id VARCHAR(30),
    Purpose_Category VARCHAR(50),
    Region VARCHAR(50),
    Religion VARCHAR(30),
    Verification_Status VARCHAR(30),
    State VARCHAR(50),
    Is_Delinquent_Loan VARCHAR(5),
    Is_Default_Loan VARCHAR(5),
    Delinq_2_Yrs INT,
    Loan_Amount DECIMAL(15,2),
    Funded_Amount DECIMAL(15,2),
    Funded_Amount_Inv DECIMAL(15,2),
    Term VARCHAR(20),
    Int_Rate DECIMAL(6,4),
    Total_Pymnt DECIMAL(15,2),
    Total_Pymnt_inv DECIMAL(15,2),
    Total_Rec_Prncp DECIMAL(15,2),
    Total_Fees DECIMAL(15,2),
    Total_Rec_int DECIMAL(15,2),
    Total_Rec_Late_fee DECIMAL(15,2),
    Recoveries DECIMAL(15,2),
    Collection_Recovery_fee DECIMAL(15,2)
);
select count(*) from loan_data;
select * from loan_data;

set sql_safe_updates=0;
UPDATE loan_data
SET Disbursement_Date =
STR_TO_DATE(Disbursement_Date, '%d-%m-%Y')
WHERE Disbursement_Date IS NOT NULL
  AND Disbursement_Date <> '';
  
ALTER TABLE loan_data
MODIFY Disbursement_Date DATE;


-- 1. Total Loan Amount Funded
SELECT sum(Funded_Amount) AS Total_Loan_Amount_Funded
FROM loan_data;

-- 2. Total Loans
SELECT COUNT(DISTINCT Account_ID) AS Total_Loans
FROM loan_data;

-- 3. Total Collection
SELECT SUM(Total_Rec_Prncp + Total_Rec_int) AS Total_Collection
FROM loan_data;

-- 4. Total Interest
SELECT SUM(Total_Rec_int) AS Total_Interest
FROM loan_data;

-- 5. Branch-Wise (Interest, Fees, Total Revenue)

SELECT BranchName,SUM(Total_Rec_int) AS Interest_Revenue,
    SUM(
        Total_Fees +
        Total_Rec_Late_fee +
        Collection_Recovery_fee
    ) AS Fee_Revenue,
    SUM(
        Total_Rec_int +
        Total_Fees+
        Total_Rec_Late_fee+
        Collection_Recovery_fee
    ) AS Total_Revenue
FROM loan_data
GROUP BY BranchName
ORDER BY Total_Revenue DESC;

-- 6. State-Wise Loan
SELECT State,SUM(Loan_Amount) AS Total_Loan_Amount
FROM loan_data
GROUP BY State
ORDER BY Total_Loan_Amount DESC;

-- 7. Religion-Wise Loan
SELECT Religion,SUM(Loan_Amount) AS Total_Loan_Amount
FROM loan_data
GROUP BY Religion
ORDER BY Total_Loan_Amount DESC ;

-- 8. Product Group-Wise Loan
SELECT Product_Code AS Product_Group,SUM(Loan_Amount) AS Total_Loan_Amount
FROM loan_data
GROUP BY Product_Code
ORDER BY Total_Loan_Amount DESC;

-- 9. Disbursement Trend
-- disbursement trend over month
SELECT monthname(Disbursement_Date) AS Disbursement_Month,SUM(Loan_Amount) AS Total_Amount
FROM loan_data
GROUP BY MONTH(Disbursement_Date), monthname(Disbursement_Date)
ORDER BY MONTH(Disbursement_Date);

-- Disbursement trend over year
SELECT YEAR(Disbursement_Date) AS Disbursement_Year,SUM(Loan_Amount) AS Total_Funded_Amount
FROM loan_data
GROUP BY YEAR(Disbursement_Date)
ORDER BY Disbursement_Year;

--
SELECT Grade,SUM(Loan_Amount) AS Total_Loan_Amount
FROM loan_data
GROUP BY Grade
ORDER BY Grade;

-- 11. Count of Default Loan
SELECT COUNT(*) AS Default_Loan_Count
FROM loan_data
WHERE Is_Default_Loan='Yes';

-- 12. Count of Delinquent Clients
SELECT COUNT(*) AS Delinquent_Loan_Count
FROM loan_data
WHERE Is_Delinquent_Loan='Yes';

-- 13. Delinquent Loans Rate
SELECT concat(ROUND((SUM(CASE WHEN Is_Delinquent_Loan = 'Yes' THEN 1 ELSE 0 END) * 100.0)/ COUNT(*),2),"%")
AS Delinquent_Loan_Rate_Percent
FROM loan_data;

-- 14. Default Loan Rate
SELECT concat(ROUND((SUM(CASE WHEN Is_Default_Loan = 'Yes' THEN 1 ELSE 0 END) * 100.0)/ COUNT(*),2),"%")
AS Default_Loan_Rate_Percent
FROM loan_data;

-- 15. Loan Status-Wise Loan
SELECT Loan_Status ,count(*) AS Loan_count,sum(Loan_Amount)Loan_Amount
FROM loan_data
GROUP BY Loan_Status
ORDER BY Loan_Count DESC;


-- 16. Age Group-Wise Loan
SELECT Age,sum(Loan_Amount)Loan_Amount
FROM loan_data
GROUP BY Age
ORDER BY Loan_Amount DESC ;

-- 17. No Verified Loan
SELECT COUNT(*) AS Non_Verified_Loan_Count
FROM loan_data
WHERE Verification_Status='Not Verified';

--
SELECT
AVG(CAST(Term AS UNSIGNED))AS Avg_Loan_Term_Months
FROM loan_data
WHERE Term IS NOT NULL;


