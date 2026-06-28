# Adtech Campaign Performance Dashboard 2023

An analysis of programmatic advertising campaign performance across formats, devices, and advertiser categories. Built with BigQuery and Looker Studio using a synthetic dataset modeled on real-world programmatic advertising data structures.

---

## Project Overview

This project simulates the kind of campaign performance analysis used by demand-side platforms (DSPs) and media buying teams to evaluate advertising efficiency, format ROI, and audience reach. The dataset covers 12 months of campaign activity (January to December 2023) across four ad formats, four device types, twelve advertiser categories, and twenty-one publisher networks.

The dashboard was built end-to-end: from synthetic data generation in Python, to storage and querying in BigQuery, to visualization in Looker Studio.

---

## Tools and Technologies

- **Python** — synthetic dataset generation
- **Google BigQuery** — data storage, transformation, and SQL analysis
- **Looker Studio** — interactive dashboard and data visualization
- **SQL** — aggregation, KPI calculation, and data preparation queries

---

## Dataset

**File:** `adtech_campaign_performance_2023.csv`

**Rows:** 20,749
**Period:** January 2023 to December 2023

### Schema

| Field | Type | Description |
|---|---|---|
| month | STRING | Month and year of campaign activity (e.g. Jan-2023) |
| month_date | DATE | Parsed date field for chronological sorting |
| format | STRING | Ad format: display, native, video, ctv |
| device_type | STRING | Device: desktop, mobile-app, mobile-web, tablet |
| bid_type | STRING | Bidding model: cpm, cpc, cpcv |
| network_id | INTEGER | Publisher network identifier |
| advertiser_category | STRING | Advertiser vertical (e.g. Travel, Shopping, Business) |
| spend | FLOAT | Total ad spend in USD |
| impressions | INTEGER | Total impressions served |
| clicks | INTEGER | Total clicks |
| measurable_imps | INTEGER | Impressions eligible for viewability measurement |
| viewable_imps | INTEGER | Impressions confirmed viewable |
| engagements | INTEGER | Total engagements |
| video_start | INTEGER | Video impressions that began playing |
| video_complete | INTEGER | Video impressions that completed playback |
| conversions | INTEGER | Total conversion events |
| CPM | FLOAT | Cost per thousand impressions |
| clickthrough_rate | FLOAT | Raw CTR (clicks / impressions) |
| viewability | FLOAT | Viewability rate (viewable / measurable impressions) |
| engagement_rate | FLOAT | Engagement rate (engagements / clicks) |
| video_completion_rate | FLOAT | VCR (video completions / video starts) |
| conversion_rate | FLOAT | Conversion rate (conversions / clicks) |

---

## SQL Queries

All queries are available in `queries.sql`. Below is a summary of each:

**Query 0 — Data Preparation**
Adds a properly formatted DATE field to enable chronological sorting in Looker Studio.

**Query 1 — Monthly Spend Trend**
Aggregates total spend, impressions, and clicks by month with blended CPM and CTR.

**Query 2 — Format Performance**
Compares spend, CPM, CTR, and conversion rate across display, native, video, and CTV formats.

**Query 3 — Advertiser Category Performance**
Ranks advertiser categories by spend and calculates cost per conversion and conversion efficiency.

**Query 4 — Device Type and Format Efficiency**
Breaks down viewability, CTR, and CPC by device type and format combination.

**Query 5 — Video Completion Rate**
Filters to video and CTV formats and calculates VCR by format and device type.

---

## Dashboard

The Looker Studio dashboard contains five pages:

| Page | Description |
|---|---|
| Overview | Project title and description |
| Spend & Volume Trends | KPI scorecards, monthly spend trend, spend by format |
| Format Performance | CPM and conversion rate by format, format summary table |
| Category Insights | Spend by advertiser category across all 12 verticals |
| Device & Viewability | Viewability and CPM comparison by device type |

**Key Findings:**
- Total ad spend reached $35.5M across 3.4B impressions in 2023
- Video drove the highest total spend ($15.3M) while CTV commanded the highest CPM ($25.83)
- Native format delivered the strongest conversion rate (26.32%) despite lower overall spend
- Business and News categories led advertiser spend while Shopping achieved the lowest cost per conversion
- Desktop delivered the highest viewability (68%) and CPM among device types

---

## Files

| File | Description |
|---|---|
| `adtech_campaign_performance_2023.csv` | Synthetic campaign performance dataset |
| `queries.sql` | All BigQuery SQL queries with comments |
| `Adtech_Campaign_Performance_Dashboard_2023.pdf` | Dashboard export |

---

## Author

**Sandra Igboanugo**
[GitHub](https://github.com/sandrai05)
