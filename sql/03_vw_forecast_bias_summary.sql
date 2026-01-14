/*
View: vw_forecast_bias_summary

Purpose:
- Summarize forecast bias patterns per product x store
- Identify systematic over- and under-forecasting behaviour
- Serve as the main input for inventory risk and cash impact analysis

Business logic:
- Forecast bias is evaluated monthly
- Bias direction is classified using a ±10% threshold
- Risk profile is assigned based on consistency of bias over time

Grain:
- One row per (productkey, storekey)

Key assumptions:
- ±10% bias threshold reflects material planning deviation
- A risk is considered "systematic" if it occurs in >= 60% of observed months
- All months are weighted equally (no seasonality correction at this stage)

Owner:
- Analytics / Decision Support
*/

CREATE OR REPLACE VIEW public.vw_forecast_bias_summary AS
WITH bias_flags AS (
    /*
    Step 1: Classify monthly forecast bias direction
    - under_forecast  -> actual demand significantly higher than forecast
    - over_forecast   -> actual demand significantly lower than forecast
    - balanced        -> within acceptable planning tolerance
    */
    SELECT
        fb.productkey,
        fb.storekey,
        fb.order_month,
        fb.forecast_qty,
        fb.actual_qty,
        fb.forecast_error,
        fb.forecast_bias_pct,
        CASE
            WHEN fb.forecast_bias_pct > 0.10 THEN 'under_forecast'
            WHEN fb.forecast_bias_pct < -0.10 THEN 'over_forecast'
            ELSE 'balanced'
        END AS bias_direction
    FROM vw_forecast_baseline fb
),
aggregated AS (
    /*
    Step 2: Aggregate bias behaviour across time
    - Measure consistency, not individual month noise
    - Median bias used to reduce impact of outliers
    */
    SELECT
        bf.productkey,
        bf.storekey,
        COUNT(*) AS months_count,
        AVG(bf.forecast_bias_pct) AS avg_bias_pct,
        percentile_cont(0.5) 
            WITHIN GROUP (ORDER BY bf.forecast_bias_pct::double precision) AS median_bias_pct,

        /* Share of months with systematic over / under forecast */
        COUNT(*) FILTER (WHERE bf.bias_direction = 'over_forecast')::numeric / COUNT(*)::numeric
            AS overforecast_rate,
        COUNT(*) FILTER (WHERE bf.bias_direction = 'under_forecast')::numeric / COUNT(*)::numeric
            AS underforecast_rate
    FROM bias_flags bf
    GROUP BY
        bf.productkey,
        bf.storekey
)
SELECT
    productkey,
    storekey,
    months_count,
    avg_bias_pct,
    median_bias_pct,
    overforecast_rate,
    underforecast_rate,

    /*
    Final risk classification:
    - systematic_overforecast  -> excess inventory / cash freeze risk
    - systematic_underforecast -> lost sales / service level risk
    - mixed_or_stable          -> no clear structural issue
    */
    CASE
        WHEN overforecast_rate >= 0.6 THEN 'systematic_overforecast'
        WHEN underforecast_rate >= 0.6 THEN 'systematic_underforecast'
        ELSE 'mixed_or_stable'
    END AS risk_profile
FROM aggregated;
