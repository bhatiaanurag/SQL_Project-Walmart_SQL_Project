# ================================
# CREATE DATABASE OF WALMART SALES
# ================================
CREATE DATABASE WALMART_SALES_DATA;


# ===============================
# USE WALMART_SALES_DATA DATABASE
# ===============================
USE WALMART_SALES_DATA;

SELECT * FROM walmartsalesdata;


# ---------------------------------------------------------- #
# ------------------- FEATURE ENGINEERING ------------------ #
# ---------------------------------------------------------- #


# ==============
# 1. TIME_OF_DAY
# ==============
SELECT Time,
	(CASE
		WHEN "Time" BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
		WHEN "Time" BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
		ELSE "Evening"
	END) AS TIME_OF_DAY
FROM walmartsalesdata;

ALTER TABLE walmartsalesdata ADD COLUMN TIME_OF_DAY VARCHAR(20);

UPDATE walmartsalesdata
SET TIME_OF_DAY=(
	CASE
		WHEN "Time" BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
		WHEN "Time" BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
		ELSE "Evening"
	END);
    

# ===========
# 2. Day_Name
# ===========
SELECT DATE,
	DAYNAME(DATE) AS DAY_NAME
FROM walmartsalesdata;

ALTER TABLE walmartsalesdata ADD COLUMN DAY_NAME VARCHAR(10);

UPDATE walmartsalesdata
SET DAY_NAME = DAYNAME(DATE);


# =============
# 3. MONTH_NAME
# =============

SELECT DATE,
	MONTHNAME(DATE) AS MONTH_NAME
FROM walmartsalesdata;

ALTER TABLE walmartsalesdata ADD COLUMN MONTH_NAME VARCHAR(10);

UPDATE walmartsalesdata
SET MONTH_NAME = MONTHNAME(DATE);


# --------------------------------------------------------------------- #
# ------------------ EXPLORATORY DATA ANALYSIS (EDA) ------------------ #
# --------------------------------------------------------------------- #


# ------------------------------------- #
# --------- GENERIC QUESTIONS --------- #
# ------------------------------------- #

# =======================================================
# 1. HOW MANY DISTINCT CITIES ARE PRESENT IN THE DATASET?
# =======================================================
SELECT
	DISTINCT CITY
FROM walmartsalesdata;


# =========================================
# 2. IN WHICH CITY IS EACH BRANCH SITUATED?
# =========================================
SELECT
	DISTINCT BRANCH,
    CITY
FROM walmartsalesdata;


# =========================================
# 3. WHAT IS THE MOST SELLING PRODUCT LINE?
# =========================================
SELECT
	PRODUCT_LINE,
    COUNT(PRODUCT_LINE) AS MOST_SELLING_PRODUCT
FROM walmartsalesdata
GROUP BY
	PRODUCT_LINE
ORDER BY
	MOST_SELLING_PRODUCT
    DESC LIMIT 1;


# ======================================
# 4. WHAT IS THE TOTAL REVENUE BY MONTH?
# ======================================
SELECT
	MONTH_NAME,
    SUM(TOTAL) AS TOTAL_REVENUE
FROM walmartsalesdata
GROUP BY
	MONTH_NAME
ORDER BY
	TOTAL_REVENUE
    DESC;


# ===============================================================    
# 5. WHICH MONTH RECORDED THE HIEGHEST COST OF GOODS SOLD (COGS)?
# ===============================================================
SELECT
	MONTH_NAME,
    SUM(COGS) AS TOTAL_COGS
FROM walmartsalesdata
GROUP BY
	MONTH_NAME
ORDER BY
	TOTAL_COGS
    DESC LIMIT 1;


# =====================================================    
# 6. WHICH PRODUCT LINE GENERATED THE HIGHEST REVENNUE?
# =====================================================
SELECT
	PRODUCT_LINE,
    SUM(TOTAL) AS TOTAL_REVENUE
FROM walmartsalesdata
GROUP BY
	PRODUCT_LINE
ORDER BY
	TOTAL_REVENUE
    DESC LIMIT 1;

# ======================================    
# 7. WHICH CITY HAS THE HIGHEST REVENUE?
# ======================================
SELECT
	CITY,
    SUM(TOTAL) AS TOTAL_REVENUE
FROM walmartsalesdata
GROUP BY
	CITY
ORDER BY
	TOTAL_REVENUE
    DESC LIMIT 1;


# ===============================================
# 8. WHICH PRODUCT LINE INCURRED THE HIGHEST VAT?
# ===============================================
SELECT
	PRODUCT_LINE,
    SUM(TAX_5) AS VAT
FROM walmartsalesdata
GROUP BY
	PRODUCT_LINE
ORDER BY
	VAT
    DESC;


# ==============================================================================================================================================
# 9. RETRIEVE EACH PRODUCT LINE AND ADD A COLUMN PRODUCT_CATEGORY, INDICATE 'GOOD' OR 'BAD', 'BASED ON WHETHER ITS SALES ARE ABOVE THE AVERAGE.'
# ==============================================================================================================================================
ALTER TABLE walmartsalesdata ADD COLUMN PRODUCT_CATEGORY VARCHAR(20);

SET @avg_total = (SELECT AVG(TOTAL) FROM walmartsalesdata);

UPDATE walmartsalesdata
SET PRODUCT_CATEGORY =( 
    CASE
        WHEN TOTAL >= @avg_total THEN 'GOOD'
        ELSE 'BAD'
    END);


# =============================================================    
# 10. WHICH BRAND SOLD MORE PRODUCTS THAN AVERAGE PRODUCT SOLD?
# =============================================================
SET @SUM_TOTAL = (SELECT SUM(QUANTITY) FROM walmartsalesdata);
SET @AVG_TOTAL = (SELECT AVG(QUANTITY) FROM walmartsalesdata);

SELECT
	BRANCH,
    SUM(QUANTITY) AS QUANTITY
FROM walmartsalesdata
GROUP BY
	BRANCH
HAVING
	@SUM_TOTAL > @AVG_TOTAL
ORDER BY
	QUANTITY
    DESC LIMIT 1;


# ===================================================    
# 11. WHAT IS THE MOST COMMON PRODUCT LINE BY GENDER?
# ===================================================
SELECT
	GENDER,
    PRODUCT_LINE,
    COUNT(GENDER) AS TOTAL_COUNT
FROM walmartsalesdata
GROUP BY
	GENDER,
    PRODUCT_LINE
ORDER BY
	TOTAL_COUNT
    DESC;


# ====================================================    
# 12. WHAT IS THE AVERAGE RATING OF EACH PRODUCT LINE?
# ====================================================
SELECT
	PRODUCT_LINE,
    ROUND(AVG(RATING),2) AS AVERAGE_RATING
FROM walmartsalesdata
GROUP BY
	PRODUCT_LINE
ORDER BY
	AVERAGE_RATING
    DESC;


# ---------------------------------- #    
# --------- SALES ANALYSIS --------- #
# ---------------------------------- #

# ===========================================================
# 1. NUMBER OF SALES MADE IN EACH TIME OF THE DAY PER WEEKDAY
# ===========================================================
SELECT
	DAY_NAME,
    TIME_OF_DAY,
    COUNT(INVOICE_ID) AS TOTAL_SALES
FROM walmartsalesdata
GROUP BY
	DAY_NAME,
    TIME_OF_DAY
HAVING
	DAY_NAME
    NOT IN ('SUNDAY','SATURDAY');
    

# ===============================================================
# 2. IDENTIFY THE CUSTOMER TYPE THAT GENERATES THE HOGEST REVENUE
# ===============================================================
SELECT
	CUSTOMER_TYPE,
    SUM(TOTAL) AS TOTAL_SALES
FROM walmartsalesdata
GROUP BY
	CUSTOMER_TYPE
ORDER BY
	TOTAL_SALES
    DESC LIMIT 1;
    

# =================================================================    
# 3. WHICH CITY HAS THE LARGEST TAX PERCENT/ VAT (VALUE ADDED TAX)?
# =================================================================
SELECT
	CITY,
    SUM(TAX_5) AS TOTAL_VAT
FROM walmartsalesdata
GROUP BY
	CITY
ORDER BY
	TOTAL_VAT
    DESC LIMIT 1;
    

# ============================================    
# 4. WHICH CUSTOMER TYPE PAYS THE MOST IN VAT?
# ============================================
SELECT
	CUSTOMER_TYPE,
    SUM(TAX_5) AS TOTAL_VAT
FROM walmartsalesdata
GROUP BY
	CUSTOMER_TYPE
ORDER BY
	TOTAL_VAT
    DESC LIMIT 1;
    

# ------------------------------------- #    
# --------- CUSTOMER ANALYSIS --------- #
# ------------------------------------- #

# ===========================================================
# 1. NUMBER OF SALES MADE IN EACH TIME OF THE DAY PER WEEKDAY
# ===========================================================
SELECT
	COUNT(DISTINCT CUSTOMER_TYPE)
FROM walmartsalesdata;


# =====================================================
# 2. HOW MANY UNIQUE PAYMENT METHOS DOES THE DATA HAVE?
# =====================================================
SELECT
	COUNT(DISTINCT PAYMENT)
FROM walmartsalesdata;


# ==========================================
# 3. WHICH IS THE MOST COMMON CUSTOMER TYPE?
# ==========================================
SELECT
	CUSTOMER_TYPE,
	COUNT(CUSTOMER_TYPE) AS COMMON_CUSTOMER
FROM walmartsalesdata
GROUP BY
	CUSTOMER_TYPE
ORDER BY
	COMMON_CUSTOMER
    DESC LIMIT 1;
    

# =====================================    
# 4. WHICH CUSTOMER TYPE BUYS THE MOST?
# =====================================
SELECT
	CUSTOMER_TYPE,
    SUM(TOTAL) AS TOTAL_SALES
FROM walmartsalesdata
GROUP BY
	CUSTOMER_TYPE
ORDER BY
	TOTAL_SALES
    DESC LIMIT 1;


# ==============================================
# 5. WHAT IS THE GENDER OF MOST OF THE CUSTOMER?
# ==============================================
SELECT
	GENDER,
    COUNT(*) AS ALL_GENDERS
FROM walmartsalesdata
GROUP BY
	GENDER
ORDER BY
	ALL_GENDERS
    DESC LIMIT 1;
    

# ==============================================
# 6. WHAT IS THE GENDER DISTRIBUTION PER BRANCH?
# ==============================================
SELECT
	BRANCH,
	GENDER,
    COUNT(GENDER) AS GENDER_DISTRIBUTION
FROM walmartsalesdata
GROUP BY
	BRANCH,
	GENDER
ORDER BY
	BRANCH;
    

# ======================================================    
# 7. WHICH TIME OF THE DAY DO CUSOTMER GIVE MOST RATING?
# ======================================================
SELECT
	TIME_OF_DAY,
    AVG(RATING) AS AVERAGE_RATING
FROM walmartsalesdata
GROUP BY
	TIME_OF_DAY
ORDER BY
	AVERAGE_RATING
    DESC LIMIT 1;
    

# ==================================================================    
# 8. WHICH TIME OF THE DAY DO CUSTOMER GIVE MOST RATINGS PER BRANCH?
# ==================================================================
SELECT
	TIME_OF_DAY,
    BRANCH,
    AVG(RATING) AS AVERAGE_RATING
FROM walmartsalesdata
GROUP BY
	BRANCH,
    TIME_OF_DAY
ORDER BY
	AVERAGE_RATING
    DESC;
    
    
# =================================================    
# 9. WHICH DAY OF THE WEEK HAS THE BEST AVG RATING?
# =================================================
SELECT
	DAY_NAME,
    AVG(RATING) AS AVERAGE_RATING
FROM walmartsalesdata
GROUP BY
	DAY_NAME
ORDER BY
	AVERAGE_RATING
    DESC LIMIT 1;
    

# ==================================================================    
# 10. WHICH DAY OF THE WEEK HAS THE BEST AVERAGE RATINGS PER BRANCH?
# ==================================================================
SELECT
	BRANCH,
    DAY_NAME,
    AVG(RATING) AS AVERAGE_RATING
FROM walmartsalesdata
GROUP BY
	BRANCH,
    DAY_NAME
ORDER BY
	AVERAGE_RATING
    DESC LIMIT 1;