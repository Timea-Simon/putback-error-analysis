-- =========================================================================
-- Warehouse Putback Error Analysis (16-Week Performance)
-- Author: Timea Simon
-- Description: Analyzing 6,000 rows of operational quality data to find 
--              the main drivers behind putback errors.
-- =========================================================================

-- =========================================================================
-- Step 1: Database & Table Setup
-- =========================================================================

CREATE DATABASE IF NOT EXISTS putback_errors;
USE putback_errors;

-- Creating the staging table. 
-- Date is kept as VARCHAR for now to avoid format issues during the wizard import.
CREATE TABLE raw_data (
    Error_ID VARCHAR(50),
    Date VARCHAR(50),
    Week INT,
    Associate_ID VARCHAR(50),
    Department VARCHAR(50),
    Shift VARCHAR(50),
    Manager_ID VARCHAR(50),
    Bin_ID VARCHAR(50)
);


-- =========================================================================
-- Step 2: Data Quality & Integrity Checks
-- =========================================================================

-- Quick preview to make sure columns and rows aligned properly
SELECT * FROM raw_data LIMIT 10;

-- Checking total row count against the source CSV (Should be exactly 6,000)
SELECT COUNT(*) AS total_rows FROM raw_data;

-- Verifying table structure and data types
DESCRIBE raw_data;

-- Checking if there are any missing (NULL) values across the columns
SELECT COUNT(*) AS total_null_rows
FROM raw_data
WHERE 
    Error_ID IS NULL 
    OR Date IS NULL 
    OR Week IS NULL 
    OR Associate_ID IS NULL 
    OR Department IS NULL 
    OR Shift IS NULL 
    OR Manager_ID IS NULL 
    OR Bin_ID IS NULL;

-- Checking for any typos in the Department and Shift columns
SELECT DISTINCT Department FROM raw_data;
SELECT DISTINCT Shift FROM raw_data;


-- =========================================================================
-- Step 3: Business Insights
-- =========================================================================

-- Query 1: Total errors and percentage share by department
-- This will be a good baseline for a donut chart in Power BI.
SELECT 
    Department, 
    COUNT(*) AS total_errors,
    ROUND(COUNT(*) * 100.0 / 6000, 2) AS percentage_of_total
FROM 
    raw_data
GROUP BY 
    Department
ORDER BY 
    total_errors DESC;

/* Results:
   The Pick department is responsible for more than half of the issues (54.77%),
   followed by Stow at 34.73%. ICQA has the lowest error rate with 10.50%. 
   Process improvement and coaching should prioritize the Pick process.
*/
  
  
-- Query 2: Error distribution by department and shift
-- Helps us see if a specific shift is struggling more in Pick, Stow, or ICQA.
SELECT 
    Department,
    Shift,
    COUNT(*) AS total_errors,
    ROUND(COUNT(*) * 100.0 / 6000, 2) AS percentage_of_total
FROM 
    raw_data
GROUP BY 
    Department, 
    Shift
ORDER BY 
    Department, 
    total_errors DESC;
    
/* Results:
   Errors are distributed almost evenly across all shifts within each department.
   In Pick, every shift is responsible for around 18% of total errors. 
   This suggests that putback errors are a systemic process issue rather than a shift-specific problem.
*/


-- =========================================================================
-- Query 3: Weekly Top 10 Offender Lists by Department and Shift
-- These queries generate the exact targeted lists used for weekly associate retraining.
-- =========================================================================

-- --- PICK DEPARTMENT ---
-- Top 10 - Pick - Morning Shift
SELECT Associate_ID, Manager_ID, COUNT(*) AS total_errors FROM raw_data WHERE Department = 'Pick' AND Shift = 'Morning' GROUP BY Associate_ID, Manager_ID ORDER BY total_errors DESC LIMIT 10;

-- Top 10 - Pick - Mid Shift
SELECT Associate_ID, Manager_ID, COUNT(*) AS total_errors FROM raw_data WHERE Department = 'Pick' AND Shift = 'Mid' GROUP BY Associate_ID, Manager_ID ORDER BY total_errors DESC LIMIT 10;

-- Top 10 - Pick - Night Shift
SELECT Associate_ID, Manager_ID, COUNT(*) AS total_errors FROM raw_data WHERE Department = 'Pick' AND Shift = 'Night' GROUP BY Associate_ID, Manager_ID ORDER BY total_errors DESC LIMIT 10;


-- --- STOW DEPARTMENT ---
-- Top 10 - Stow - Morning Shift
SELECT Associate_ID, Manager_ID, COUNT(*) AS total_errors FROM raw_data WHERE Department = 'Stow' AND Shift = 'Morning' GROUP BY Associate_ID, Manager_ID ORDER BY total_errors DESC LIMIT 10;

-- Top 10 - Stow - Mid Shift
SELECT Associate_ID, Manager_ID, COUNT(*) AS total_errors FROM raw_data WHERE Department = 'Stow' AND Shift = 'Mid' GROUP BY Associate_ID, Manager_ID ORDER BY total_errors DESC LIMIT 10;

-- Top 10 - Stow - Night Shift
SELECT Associate_ID, Manager_ID, COUNT(*) AS total_errors FROM raw_data WHERE Department = 'Stow' AND Shift = 'Night' GROUP BY Associate_ID, Manager_ID ORDER BY total_errors DESC LIMIT 10;


-- --- ICQA DEPARTMENT ---
-- Top 10 - ICQA - Morning Shift
SELECT Associate_ID, Manager_ID, COUNT(*) AS total_errors FROM raw_data WHERE Department = 'ICQA' AND Shift = 'Morning' GROUP BY Associate_ID, Manager_ID ORDER BY total_errors DESC LIMIT 10;

-- Top 10 - ICQA - Mid Shift
SELECT Associate_ID, Manager_ID, COUNT(*) AS total_errors FROM raw_data WHERE Department = 'ICQA' AND Shift = 'Mid' GROUP BY Associate_ID, Manager_ID ORDER BY total_errors DESC LIMIT 10;

-- Top 10 - ICQA - Night Shift
SELECT Associate_ID, Manager_ID, COUNT(*) AS total_errors FROM raw_data WHERE Department = 'ICQA' AND Shift = 'Night' GROUP BY Associate_ID, Manager_ID ORDER BY total_errors DESC LIMIT 10;

/* Results:
   These targeted queries separate the top 10 offenders for every individual shift 
   and department. This provides actionable, ready-to-use lists for area managers 
   to conduct precise associate retraining.
*/

-- =========================================================================
-- Query 4: Total errors by week
-- This provides the data for a line chart in Power BI.
-- =========================================================================

SELECT 
    Week,
    COUNT(*) AS total_errors
FROM 
    raw_data
GROUP BY 
    Week
ORDER BY 
    Week ASC;
    
/* Results:
   There is a steady downward trend in total errors, decreasing from 465 in Week 1 to 294 in Week 16.
   This improvement reflects the impact of weekly quality reviews, where the top 10 offenders 
   were identified for each department to trigger targeted associate retraining.
*/