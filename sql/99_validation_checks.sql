/*
File: 99_validation_checks.sql

Purpose:
- Logic checks for derived views
- Intended to be run after all views are created

*/

-- =========================================================
-- 1. Row count overview
-- =========================================================

SELECT 'vw_sales_enriched_v2' AS source, COUNT(*) AS rows
FROM vw_sales_enriched_v2
UNION ALL
SELECT 'vw_forecast_baseline', COUNT(*)
FROM vw_forecast_baseline
UNION ALL
SELECT 'vw_forecast_bias_summary', COUNT(*)
FROM vw_forecast_bias_summary
UNION ALL
SELECT 'vw_inventory_cash_impact', COUNT(*)
FROM vw_inventory_cash_impact
UNION ALL
SELECT 'vw_management_action_targets', COUNT(*)
FROM vw_management_action_targets;


-- =========================================================
-- 2. Forecast baseline integrity 
-- =========================================================
-- Checks:
-- - No NULL forecast where it should exist
-- - No division by zero artifacts

SELECT
    COUNT(*) FILTER (WHERE forecast_qty IS NULL)      AS null_forecast_qty,
    COUNT(*) FILTER (WHERE forecast_qty = 0)          AS zero_forecast_qty,
    COUNT(*) FILTER (WHERE forecast_bias_pct IS NULL) AS null_bias_pct
FROM vw_forecast_baseline;


-- =========================================================
-- 3. Bias percentage outliers
-- =========================================================
-- Extreme values usually indicate data issues or edge cases

SELECT
    COUNT(*) FILTER (WHERE forecast_bias_pct >  1)  AS over_100pct_bias,
    COUNT(*) FILTER (WHERE forecast_bias_pct < -1)  AS below_minus_100pct_bias
FROM vw_forecast_baseline;


-- =========================================================
-- 4. Risk profile distribution check
-- =========================================================
-- Ensures classification logic behaves as expected

SELECT
    risk_profile,
    COUNT(*) AS combinations
FROM vw_forecast_bias_summary
GROUP BY risk_profile
ORDER BY combinations DESC;


-- =========================================================
-- 5. Financial impact check
-- =========================================================
-- Checks:
-- - No negative monetary values
-- - Cash frozen only for over-forecast
-- - Lost revenue only for under-forecast

SELECT
    COUNT(*) FILTER (WHERE excess_inventory_value < 0) AS negative_excess_inventory,
    COUNT(*) FILTER (WHERE lost_revenue_value < 0)     AS negative_lost_revenue
FROM vw_inventory_cash_impact;


-- =========================================================
-- 6. Total estimated impact cross-check
-- =========================================================
-- Simple aggregation to confirm numbers are reasonable

SELECT
    ROUND(SUM(excess_inventory_value)) AS total_cash_frozen,
    ROUND(SUM(lost_revenue_value))     AS total_lost_revenue,
    ROUND(SUM(excess_inventory_value + lost_revenue_value)) AS total_estimated_impact
FROM vw_inventory_cash_impact;


-- =========================================================
-- 7. Action target selection sanity
-- =========================================================
-- Ensures only top impact buckets are selected

SELECT
    impact_bucket,
    COUNT(*) AS targets
FROM vw_management_action_targets
GROUP BY impact_bucket
ORDER BY impact_bucket;