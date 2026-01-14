-- =============================================================================
-- View: vw_management_action_targets
-- Purpose:
--   Produce a prioritized target list (product-store pairs) for management action,
--   based on forecast bias risk profile and estimated financial impact.
--
-- What this view does:
--   1) Summarizes impact per product-store:
--      - total_cash_frozen (excess inventory valued at unit cost)
--      - total_lost_revenue (missed sales valued at net price)
--      - total_estimated_impact (combined)
--   2) Buckets targets into impact tiers (NTILE(5))
--   3) Keeps only the top impact tiers (bucket 1–2) as the actionable shortlist
--   4) Adds a recommended action based on risk profile
--
-- Grain:
--   productkey × storekey
--
-- Key assumptions:
--   - All monthly impacts are additive across the observed horizon
--   - NTILE(5) creates relative ranking (works best with enough combinations)
--   - "Top 40%" rule: impact_bucket <= 2 (buckets 1–2 out of 5)
--   - Recommended actions are intentionally simple and executive-friendly
--
-- Downstream usage:
--   - Executive "where to act first" dashboard
--   - Ops / replenishment backlog prioritization
-- =============================================================================

CREATE OR REPLACE VIEW public.vw_management_action_targets AS
WITH impact_summary AS (
    /*
    Step 1: Aggregate financial impact for each product-store pair
    - Join bias profile (risk type) with monthly cash impact
    - Collapse time dimension -> one row per product-store
    */
    SELECT
        s.productkey,
        s.storekey,
        s.risk_profile,

        SUM(i.excess_inventory_value) AS total_cash_frozen,
        SUM(i.lost_revenue_value) AS total_lost_revenue,
        SUM(i.excess_inventory_value + i.lost_revenue_value) AS total_estimated_impact

    FROM vw_forecast_bias_summary s
    JOIN vw_inventory_cash_impact i
        ON i.productkey = s.productkey
       AND i.storekey   = s.storekey

    GROUP BY
        s.productkey,
        s.storekey,
        s.risk_profile
),
prioritized AS (
    /*
    Step 2: Rank targets by impact using 5-tier bucketing
    - impact_bucket = 1 means highest impact group
    - impact_bucket = 5 means lowest impact group
    */
    SELECT
        productkey,
        storekey,
        risk_profile,
        total_cash_frozen,
        total_lost_revenue,
        total_estimated_impact,
        NTILE(5) OVER (ORDER BY total_estimated_impact DESC) AS impact_bucket
    FROM impact_summary
)
SELECT
    p.productkey,
    p.storekey,
    p.risk_profile,
    p.total_cash_frozen,
    p.total_lost_revenue,
    p.total_estimated_impact,
    p.impact_bucket,

    /*
    Step 3: Translate risk into an operational recommendation
    - Over-forecast -> reduce buffers / tighten replenishment
    - Under-forecast -> replenish earlier / protect high-margin SKUs
    - Mixed/stable -> monitor only
    */
    CASE
        WHEN p.risk_profile = 'systematic_overforecast'
            THEN 'Reduce safety buffers and tighten replenishment thresholds'
        WHEN p.risk_profile = 'systematic_underforecast'
            THEN 'Prioritize earlier replenishment and protect high-margin SKUs'
        ELSE 'No action – monitor only'
    END AS recommended_action

FROM prioritized p
-- Keep only highest-impact targets (top 2 buckets out of 5)
WHERE p.impact_bucket <= 2;
