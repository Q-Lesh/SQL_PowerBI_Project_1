/*
View: vw_sales_enriched_v2

Purpose:
- Sales fact table in EUR
- Base layer for forecast bias, inventory risk and cash impact analysis

Key assumptions:
- Rows without valid exchange rate are excluded
- Revenue and COGS are normalized to base currency (EUR)

Grain:
- One row per order line (orderkey + linenumber)
*/

CREATE OR REPLACE VIEW public.vw_sales_enriched_v2
AS WITH base_sales AS (
         SELECT s.orderkey,
            s.linenumber,
            s.orderdate,
            s.deliverydate,
            s.customerkey,
            s.storekey,
            s.productkey,
            s.currencycode,
            s.quantity::numeric AS quantity,
            s.unitprice::numeric AS unitprice,
            s.netprice::numeric AS netprice,
            s.unitcost::numeric AS unitcost,
            COALESCE(NULLIF(s.exchangerate::numeric, 0::numeric), NULLIF(ce.exchange::numeric, 0::numeric)) AS exchangerate_safe
           FROM sales s
             LEFT JOIN currencyexchange ce ON ce.date = s.orderdate AND ce.fromcurrency::text = s.currencycode::text AND ce.tocurrency::text = 'EUR'::text
        ), 
    
          finance AS (
        SELECT b.orderkey,
            b.linenumber,
            b.orderdate,
            b.deliverydate,
            b.customerkey,
            b.storekey,
            b.productkey,
            b.currencycode,
            b.quantity,
            b.unitprice,
            b.netprice,
            b.unitcost,
            b.exchangerate_safe,
            b.deliverydate - b.orderdate AS lead_time_days,
            date_trunc('month'::text, b.orderdate::timestamp with time zone)::date AS order_month,
            -- Net revenue in EUR
            b.netprice * b.quantity / b.exchangerate_safe AS net_revenue_base,
            b.unitcost * b.quantity / b.exchangerate_safe AS cogs_base
           FROM base_sales b
          WHERE b.exchangerate_safe IS NOT NULL
        )
    
 SELECT f.orderkey,
    f.linenumber,
    f.orderdate,
    f.deliverydate,
    f.customerkey,
    f.storekey,
    f.productkey,
    f.currencycode,
    f.quantity,
    f.unitprice,
    f.netprice,
    f.unitcost,
    f.exchangerate_safe,
    f.lead_time_days,
    f.order_month,
    f.net_revenue_base,
    f.cogs_base,
    p.productcode,
    p.productname,
    p.manufacturer,
    p.brand,
    p.categoryname,
    p.subcategoryname,
    st.storecode,
    st.countryname AS store_country,
    st.state AS store_state,
    st.status AS store_status,
    st.squaremeters,
    d.year,
    d.yearquarter,
    d.yearmonthnumber,
    d.monthnumber,
    d.dayofweek,
    d.workingday,
    c.continent AS customer_continent,
    c.countryfull AS customer_country,
    c.statefull AS customer_state
   FROM finance f
     LEFT JOIN product p ON p.productkey = f.productkey
     LEFT JOIN store st ON st.storekey = f.storekey
     LEFT JOIN date d ON d.date = f.orderdate
     LEFT JOIN customer c ON c.customerkey = f.customerkey;