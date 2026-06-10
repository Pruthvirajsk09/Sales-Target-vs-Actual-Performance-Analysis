-- ============================================================
-- SALES TARGET VS ACTUAL PERFORMANCE ANALYSIS
-- Author: Pruthviraj Kadam
-- Dataset: 2,280 records | FMCG & Pharma Sales
-- ============================================================

CREATE TABLE sales_performance (
    Year            INT,
    Month           INT,
    MonthName       VARCHAR(15),
    Quarter         VARCHAR(5),
    Region          VARCHAR(20),
    State           VARCHAR(30),
    Product         VARCHAR(20),
    Category        VARCHAR(20),
    SalespersonID   VARCHAR(10),
    Target          DECIMAL(12,2),
    Actual          DECIMAL(12,2),
    Variance        DECIMAL(12,2),
    AchievementPct  DECIMAL(5,1),
    Status          VARCHAR(10)
);

-- ============================================================
-- SECTION 1: OVERALL KPIs
-- ============================================================

-- 1.1 Business summary
SELECT
    SUM(Target)                             AS total_target,
    SUM(Actual)                             AS total_actual,
    SUM(Variance)                           AS total_variance,
    ROUND(SUM(Actual)/SUM(Target)*100, 2)  AS overall_achievement_pct,
    COUNT(DISTINCT SalespersonID)           AS total_salespersons,
    COUNT(DISTINCT Region)                  AS total_regions,
    SUM(CASE WHEN Status='Achieved' THEN 1 ELSE 0 END) AS achieved_count,
    COUNT(*)                                AS total_records
FROM sales_performance;

-- 1.2 Year-over-year comparison
SELECT
    Year,
    ROUND(SUM(Target)/1e7, 2)             AS target_crores,
    ROUND(SUM(Actual)/1e7, 2)             AS actual_crores,
    ROUND(SUM(Actual)/SUM(Target)*100, 2) AS achievement_pct,
    SUM(CASE WHEN Status='Achieved' THEN 1 ELSE 0 END) AS achieved_rows
FROM sales_performance
GROUP BY Year
ORDER BY Year;


-- ============================================================
-- SECTION 2: REGIONAL ANALYSIS
-- ============================================================

-- 2.1 Target vs Actual by Region
SELECT
    Region,
    ROUND(SUM(Target)/1e6, 2)             AS target_millions,
    ROUND(SUM(Actual)/1e6, 2)             AS actual_millions,
    ROUND(SUM(Variance)/1e6, 2)           AS variance_millions,
    ROUND(SUM(Actual)/SUM(Target)*100, 2) AS achievement_pct,
    SUM(CASE WHEN Status='Achieved' THEN 1 ELSE 0 END) AS achieved,
    COUNT(*) AS total_records
FROM sales_performance
GROUP BY Region
ORDER BY achievement_pct DESC;

-- 2.2 State-level performance
SELECT
    Region,
    State,
    ROUND(SUM(Target)/1e6, 2)             AS target_M,
    ROUND(SUM(Actual)/1e6, 2)             AS actual_M,
    ROUND(SUM(Actual)/SUM(Target)*100, 2) AS achievement_pct,
    CASE
        WHEN SUM(Actual)/SUM(Target) >= 1.0 THEN 'On Track'
        WHEN SUM(Actual)/SUM(Target) >= 0.85 THEN 'Near Target'
        ELSE 'Needs Attention'
    END AS performance_status
FROM sales_performance
GROUP BY Region, State
ORDER BY achievement_pct DESC;


-- ============================================================
-- SECTION 3: PRODUCT & CATEGORY ANALYSIS
-- ============================================================

-- 3.1 Product performance
SELECT
    Category,
    Product,
    ROUND(SUM(Target)/1e6, 2)             AS target_M,
    ROUND(SUM(Actual)/1e6, 2)             AS actual_M,
    ROUND(SUM(Variance)/1e6, 2)           AS variance_M,
    ROUND(SUM(Actual)/SUM(Target)*100, 2) AS achievement_pct
FROM sales_performance
GROUP BY Category, Product
ORDER BY achievement_pct DESC;

-- 3.2 Best and worst performing product per region
WITH product_region AS (
    SELECT
        Region, Product,
        ROUND(SUM(Actual)/SUM(Target)*100, 2) AS achievement_pct,
        RANK() OVER (PARTITION BY Region ORDER BY SUM(Actual)/SUM(Target) DESC) AS best_rank,
        RANK() OVER (PARTITION BY Region ORDER BY SUM(Actual)/SUM(Target) ASC)  AS worst_rank
    FROM sales_performance
    GROUP BY Region, Product
)
SELECT Region, Product, achievement_pct,
    CASE WHEN best_rank = 1 THEN 'Best Performer'
         WHEN worst_rank = 1 THEN 'Worst Performer' END AS label
FROM product_region
WHERE best_rank = 1 OR worst_rank = 1
ORDER BY Region, best_rank;


-- ============================================================
-- SECTION 4: TIME-BASED ANALYSIS
-- ============================================================

-- 4.1 Monthly trend
SELECT
    Year, Month, MonthName, Quarter,
    ROUND(SUM(Target)/1e6, 2)             AS target_M,
    ROUND(SUM(Actual)/1e6, 2)             AS actual_M,
    ROUND(SUM(Actual)/SUM(Target)*100, 2) AS achievement_pct
FROM sales_performance
GROUP BY Year, Month, MonthName, Quarter
ORDER BY Year, Month;

-- 4.2 Quarterly summary
SELECT
    Year, Quarter,
    ROUND(SUM(Target)/1e6, 2)             AS target_M,
    ROUND(SUM(Actual)/1e6, 2)             AS actual_M,
    ROUND(SUM(Variance)/1e6, 2)           AS variance_M,
    ROUND(SUM(Actual)/SUM(Target)*100, 2) AS achievement_pct
FROM sales_performance
GROUP BY Year, Quarter
ORDER BY Year, Quarter;

-- 4.3 Best months for sales (seasonality)
SELECT
    MonthName, Month,
    ROUND(AVG(AchievementPct), 2)  AS avg_achievement_pct,
    ROUND(SUM(Actual)/1e6, 2)      AS total_actual_M
FROM sales_performance
GROUP BY MonthName, Month
ORDER BY avg_achievement_pct DESC;


-- ============================================================
-- SECTION 5: SALESPERSON PERFORMANCE
-- ============================================================

-- 5.1 Salesperson ranking
WITH sp_perf AS (
    SELECT
        SalespersonID,
        ROUND(SUM(Target)/1e6, 2)             AS target_M,
        ROUND(SUM(Actual)/1e6, 2)             AS actual_M,
        ROUND(SUM(Actual)/SUM(Target)*100, 2) AS achievement_pct,
        SUM(CASE WHEN Status='Achieved' THEN 1 ELSE 0 END) AS months_achieved,
        COUNT(*) AS total_months
    FROM sales_performance
    GROUP BY SalespersonID
)
SELECT *,
    RANK() OVER (ORDER BY achievement_pct DESC) AS performance_rank,
    CASE
        WHEN achievement_pct >= 100 THEN 'Star Performer'
        WHEN achievement_pct >= 90  THEN 'Good'
        WHEN achievement_pct >= 80  THEN 'Average'
        ELSE 'Needs Improvement'
    END AS performance_band
FROM sp_perf
ORDER BY achievement_pct DESC;

-- 5.2 Consistent achievers (hit target 8+ months)
SELECT
    SalespersonID,
    COUNT(*) AS total_records,
    SUM(CASE WHEN Status='Achieved' THEN 1 ELSE 0 END) AS months_achieved,
    ROUND(SUM(Actual)/SUM(Target)*100, 2) AS overall_achievement_pct
FROM sales_performance
GROUP BY SalespersonID
HAVING months_achieved >= 8
ORDER BY months_achieved DESC;


-- ============================================================
-- SECTION 6: ADVANCED — CTEs & WINDOW FUNCTIONS
-- ============================================================

-- 6.1 Running cumulative actual vs target by month
WITH monthly AS (
    SELECT Year, Month, MonthName,
        SUM(Target) AS monthly_target,
        SUM(Actual) AS monthly_actual
    FROM sales_performance
    GROUP BY Year, Month, MonthName
)
SELECT Year, Month, MonthName,
    ROUND(monthly_target/1e6, 2) AS target_M,
    ROUND(monthly_actual/1e6, 2) AS actual_M,
    ROUND(SUM(monthly_target) OVER (PARTITION BY Year ORDER BY Month)/1e6, 2) AS cum_target_M,
    ROUND(SUM(monthly_actual) OVER (PARTITION BY Year ORDER BY Month)/1e6, 2) AS cum_actual_M
FROM monthly
ORDER BY Year, Month;

-- 6.2 Region gap analysis — how much shortfall to fix
WITH region_summary AS (
    SELECT Region,
        SUM(Target) AS total_target,
        SUM(Actual) AS total_actual,
        SUM(Target) - SUM(Actual) AS shortfall
    FROM sales_performance
    WHERE Status = 'Missed'
    GROUP BY Region
)
SELECT *,
    ROUND(shortfall/1e6, 2) AS shortfall_millions,
    ROUND(shortfall * 100.0 / total_target, 2) AS shortfall_pct,
    RANK() OVER (ORDER BY shortfall DESC) AS priority_rank
FROM region_summary
ORDER BY shortfall DESC;
