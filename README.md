# Forecast Bias → Financial Impact → Actionable Priorities

This project demonstrates how systematic forecast bias at product–store level can be translated into **financial impact**, **prioritised action lists**, and **scenario-based decision support**.

The focus is not on forecasting accuracy itself, but on answering a more practical business question:

> *Where does forecast bias actually cost the business money — and where should we act first?*

What this analysis enables:

![Prioritised targets overview](gifs/page3_prioritised_targets.gif)
*From forecast bias to prioritised product–store actions, based on financial impact.*

**TL;DR**
- Forecasts often make repeated mistakes
- These mistakes turn into real money impact
- A small number of products and stores cause most of the impact
- This analysis helps focus on what actually matters first


---

## Business Problem

In large retail and supply chain environments, forecast errors are often treated as a technical problem:
- model tuning,
- accuracy metrics,
- statistical improvements.

In practice, this creates a blind spot.

Not all forecast errors matter equally.

Some lead to:
- excess inventory and frozen working capital,
- lost revenue due to under-forecasting,
- operational noise with little financial consequence.

Without linking forecast bias to **financial impact**, teams struggle to:
- prioritise corrective actions,
- justify interventions,
- focus on what truly moves the P&L.

This case shows how to bridge that gap.

---

## What This Case Demonstrates

This project shows how to:

- classify **systematic forecast bias** at product–store level,
- translate bias into **estimated financial impact** (cash frozen and revenue at risk),
- prioritise targets based on **addressable impact**, not volume or noise,
- explore **what-if scenarios** to estimate potential value recovery.

The result is a set of dashboards designed for:
- decision support,
- prioritisation discussions,
- management-level trade-offs.

Not for model benchmarking.

---

## Dataset & Scope

The analysis is based on the Microsoft Contoso retail dataset.

Forecast values were reconstructed using a simple historical baseline approach, based on information available at the time of each period.
This mirrors a common real-world situation where perfect forecast data is not available, but decisions still need to be made.


- Granularity: **product–store**, monthly demand  
- Bias classification: based on observed historical bias patterns  
- Financial impact: **model-based estimates**, not realised savings  

Important:
- All monetary values represent **impact or risk**, not guaranteed savings.
- The goal is comparability and prioritisation, not precise accounting.

---

## Power BI Report (PBIX)

The interactive Power BI report (`.pbix`) file is not stored directly in the repository due to file size limitations.

You can download the full Power BI report from the **GitHub Releases** section:
👉 https://github.com/Q-Lesh/SQL_POWERBI_PROJECT_1/releases

The report contains all dashboards shown in this repository and can be explored locally using Power BI Desktop.


---

## How to Read the Dashboards

The dashboards are structured as a logical flow:

1. **Identify where systematic forecast bias exists**
2. **Understand the financial impact of that bias**
3. **Prioritise product–store targets for action**
4. **Explore scenario-based value recovery**

Each page builds on the previous one.

Short animations (GIFs) are included below to show how the dashboards are meant to be explored interactively.

---

## Page 1 — Systematic Forecast Bias

This page identifies **where forecast bias is systematic**, not random.

The goal is to separate:
- noise that can be ignored,
- from patterns that consistently distort decisions.

Systematic bias is classified at **product–store level** using historical monthly demand and a fixed bias threshold.

### What to look at

- **Systematic Under-forecast Share**  
  Share of product–store pairs where demand is consistently underestimated.

- **Systematic Over-forecast Share**  
  Share of product–store pairs where demand is consistently overestimated.

- **Risk Profile Distribution**  
  Products are grouped into:
  - Mixed / Stable forecast
  - Systematic under-forecasting
  - Systematic over-forecasting

This classification is the foundation for all further analysis.

![Systematic forecast bias overview](gifs/page1_systematic_bias.gif)

---

## Page 2 — Financial Impact of Forecast Bias

This page translates forecast bias into **estimated financial impact**.

The intent is not accounting precision, but **order-of-magnitude understanding**:
- where money is frozen,
- where revenue is missed,
- and where bias actually matters financially.

### Key metrics

- **Total Estimated Impact (€)**  
  Model-based estimate of financial exposure linked to systematic bias.

- **Cash Frozen (Excess Inventory)**  
  Capital tied up due to over-forecasting.

- **Lost Revenue (Under-forecasting)**  
  Missed sales opportunities due to insufficient supply.

Important:
- These values represent **impact and risk**, not guaranteed savings.
- They are meant for **comparison and prioritisation**, not financial reporting.

The page also allows impact breakdowns by:
- product category,
- country,
- channel (online vs physical stores).

![Financial impact breakdown](gifs/page2_financial_impact.gif)

---

## Page 3 — Prioritised Product–Store Targets

This page answers the core operational question:

> *Where should we act first?*

Not all biased forecasts are worth fixing.
This page prioritises product–store pairs based on **addressable financial impact**.

### How prioritisation works

Each target is evaluated on:
- estimated total impact,
- share of impact that is realistically addressable,
- type of risk (cash vs revenue).

Targets are grouped into **priority buckets**, allowing teams to:
- focus effort where it matters,
- avoid overreacting to low-impact noise.

### Why these KPIs are shown

- **Impact at Stake (€)**  
  Total financial exposure linked to prioritised targets  
  *(Cash at Risk + Revenue at Risk; model-based estimate)*

- **Cash at Risk (€)**  
  Shown separately because it directly affects **working capital and liquidity**,  
  which often carries higher short-term business urgency.

This distinction is intentional and discussed explicitly to support decision-making.

![Prioritised targets](gifs/page3_prioritised_targets.gif)

---

## Page 4 — Scenario-based Estimate

This page explores **what-if scenarios**.

It answers:
> *If we partially reduce forecast bias, how much value could be recovered?*

A bias reduction rate can be adjusted to simulate:
- process improvements,
- forecasting enhancements,
- targeted interventions.

### How to interpret this page

- **Estimated Recoverable Value (€)**  
  Hypothetical value recovery under a given bias reduction scenario.

- This is **not a forecast**.
- This is **not a commitment**.
- This is a **decision support tool** for comparing scenarios.

It helps frame conversations like:
- “Is this improvement worth the effort?”
- “Where do we get the biggest return on attention?”

![Scenario-based estimate](gifs/page4_scenario_estimate.gif)

---

## Important Notes & Limitations

- All financial figures are **model-based estimates**.
- No guaranteed savings are implied.
- Results depend on historical patterns and simplifying assumptions.
- The framework is designed to support **prioritisation**, not replace detailed financial analysis.

The strength of this approach lies in **directional clarity**, not false precision.

---

## How to Use the Dashboards

This report is designed to be explored **top-down**.

### Suggested workflow

1. **Start with Page 1 — Systematic Forecast Bias**  
   Identify whether forecast bias is:
   - random and acceptable,
   - or systematic and worth attention.

2. **Move to Page 2 — Financial Impact**  
   Translate bias into money:
   - where cash is frozen,
   - where revenue is missed,
   - and which dimensions drive most of the impact.

3. **Use Page 3 — Prioritised Targets**  
   Focus on product–store pairs where:
   - impact is material,
   - action is realistically addressable,
   - effort is justified.

   Filters allow narrowing down by:
   - priority bucket,
   - store scope.

4. **Explore Page 4 — Scenario-based Estimate**  
   Test “what-if” assumptions:
   - adjust bias reduction rate,
   - observe how potential recoverable value changes,
   - use this to support prioritisation discussions.

This flow mirrors how such analysis is typically used in practice:
from **diagnosis → impact → prioritisation → decision support**.

---

## Limitations & Next Steps

### Key limitations

- All results are based on **historical data**.
- Financial figures represent **estimated exposure**, not realised losses.
- Recoverable value scenarios are **illustrative**, not guarantees.
- The model does not account for:
  - operational constraints,
  - supplier lead times,
  - demand shaping actions,
  - pricing elasticity.

This is intentional: the goal is **clarity and prioritisation**, not false precision.

### Possible next steps

- Integrate service level targets to refine under-forecast impact.
- Introduce lead-time variability into inventory risk estimates.
- Add trend detection to distinguish structural vs temporary bias.
- Extend prioritisation logic with operational effort estimates.
- Validate assumptions against actual intervention outcomes.

---

## Final Remark

This project demonstrates how relatively simple analytical building blocks can be combined into a **decision-oriented framework**.

The value lies not in complex models, but in:
- asking the right questions,
- quantifying trade-offs,
- and focusing attention where it matters most.
