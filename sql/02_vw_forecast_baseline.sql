/*
View: vw_forecast_baseline

Purpose:
- Create a baseline forecast vs actual at monthly grain (product x store x month)
- Feeds downstream bias classification and business impact (cash frozen / lost revenue)

Why this matters:
- Shows the decision-support workflow: establish a defensible baseline, quantify bias, translate to € impact
- Avoids "data science showcase" while still producing actionable risk signals

Grain:
- One row per (productkey, storekey, order_month)

Key assumptions / limitations:
- Baseline forecast = lagged actual.
- If forecast_qty is NULL (first month per product-store), row is excluded.
- forecast_bias_pct uses forecast_qty as denominator (NULLIF to avoid divide-by-zero).
  Note: when forecast_qty = 0, bias_pct becomes NULL. Keep as-is to prevent misleading infinities.
*/

CREATE OR REPLACE VIEW public.vw_forecast_baseline AS
WITH monthly_demand AS (
    /*
    Step 1: Aggregate sales to monthly demand
    - Converts transaction-level order lines into demand signal per month
    - Keeps grain consistent for planning / forecasting discussions
    */
    SELECT
        s.productkey,
        s.storekey,
        s.order_month,
        SUM(s.quantity) AS actual_qty
    FROM vw_sales_enriched_v2 s
    GROUP BY
        s.productkey,
        s.storekey,
        s.order_month
),
lagged_forecast AS (
    /*
    Step 2: Build baseline forecast using lagged actual
    - Forecast for month T = actual demand of month T-1
    - Simple, explainable benchmark to detect systematic bias
    */
    SELECT
        md.productkey,
        md.storekey,
        md.order_month,
        md.actual_qty,
        LAG(md.actual_qty) OVER (
            PARTITION BY md.productkey, md.storekey
            ORDER BY md.order_month
        ) AS forecast_qty
    FROM monthly_demand md
)
SELECT
    productkey,
    storekey,
    order_month,
    forecast_qty,
    actual_qty,

    /* Absolute error (units) */
    actual_qty - forecast_qty AS forecast_error,

    /*
    Relative bias vs forecast (pct)
    - Positive => under-forecast (actual > forecast)
    - Negative => over-forecast (actual < forecast)
    */
    (actual_qty - forecast_qty) / NULLIF(forecast_qty, 0::numeric) AS forecast_bias_pct
FROM lagged_forecast
WHERE forecast_qty IS NOT NULL;
