-- =============================================================================
-- View: vw_forecast_baseline
-- Purpose:
--   Build a naive forecast baseline using previous-month demand (lag-1).
--   This serves as a benchmark to measure forecast bias and error.
--
-- Grain:
--   productkey × storekey × order_month
--
-- Key assumptions:
--   - Forecast = previous month's actual demand
--   - Only periods with a valid prior month are included
--
-- Downstream usage:
--   - Forecast bias analysis
--   - Risk profiling (systematic over/under-forecast)
--   - Inventory cash impact calculations
-- =============================================================================

CREATE OR REPLACE VIEW public.vw_forecast_baseline AS
WITH monthly_demand AS (
    -- Aggregate actual demand at monthly level
    SELECT
        v.productkey,
        v.storekey,
        v.order_month,
        SUM(v.quantity) AS actual_qty
    FROM vw_sales_enriched_v2 v
    GROUP BY
        v.productkey,
        v.storekey,
        v.order_month
),
lagged_forecast AS (
    -- Use previous month actuals as naive forecast
    SELECT
        m.productkey,
        m.storekey,
        m.order_month,
        m.actual_qty,
        LAG(m.actual_qty)
            OVER (
                PARTITION BY m.productkey, m.storekey
                ORDER BY m.order_month
            ) AS forecast_qty
    FROM monthly_demand m
)
SELECT
    productkey,
    storekey,
    order_month,
    forecast_qty,
    actual_qty,
    actual_qty - forecast_qty AS forecast_error,
    (actual_qty - forecast_qty) / NULLIF(forecast_qty, 0) AS forecast_bias_pct
FROM lagged_forecast
-- Exclude first observed month per product-store (no forecast available)
WHERE forecast_qty IS NOT NULL;
