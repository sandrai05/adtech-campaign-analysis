-- Query 0: Data Preparation
-- Adds a properly formatted date field (month_date) to the campaign_performance table
-- by parsing the month text field into a DATE type.
-- Required for correct chronological sorting in Looker Studio visualizations.

CREATE OR REPLACE TABLE `adtech-campaign-analysis.campaign_data.campaign_performance` AS
SELECT
  *,
  PARSE_DATE('%b-%Y', month) AS month_date
FROM `adtech-campaign-analysis.campaign_data.campaign_performance`

-- Query 1: Monthly Spend Trend
-- Aggregates total spend, impressions, and clicks by month.
-- Calculates blended CPM and CTR to track campaign volume
-- and efficiency trends across the full year (Jan to Dec 2023).

SELECT
  month,
  SUM(spend) AS total_spend,
  SUM(impressions) AS total_impressions,
  SUM(clicks) AS total_clicks,
  ROUND(SUM(spend) / SUM(impressions) * 1000, 2) AS blended_CPM,
  ROUND(SUM(clicks) / SUM(impressions), 6) AS blended_CTR
FROM `adtech-campaign-analysis.campaign_data.campaign_performance`
GROUP BY month
ORDER BY PARSE_DATE('%b-%Y', month)


-- Query 2: Format Performance
-- Aggregates spend, impressions, clicks, and conversions by ad format.
-- Calculates CPM, CTR, and conversion rate to compare performance efficiency
-- across display, native, video, and CTV formats.

SELECT
  format,
  CONCAT('$', FORMAT('%.2f', SUM(spend))) AS total_spend,
  SUM(impressions) AS total_impressions,
  SUM(clicks) AS total_clicks,
  SUM(conversions) AS total_conversions,
  ROUND(SUM(spend) / SUM(impressions) * 1000, 2) AS CPM,
  ROUND(SUM(clicks) / SUM(impressions) * 100, 4) AS CTR_percent,
  ROUND(SUM(conversions) / NULLIF(SUM(clicks), 0) * 100, 4) AS conversion_rate_percent
FROM `adtech-campaign-analysis.campaign_data.campaign_performance`
GROUP BY format
ORDER BY SUM(spend) DESC

-- Query 3: Advertiser Category Performance
-- Aggregates spend, impressions, clicks, and conversions by advertiser category.
-- Calculates cost per conversion, CTR, and conversion rate to identify
-- which categories drive the most efficient performance.

SELECT
  advertiser_category,
  ROUND(SUM(spend), 2) AS total_spend,
  SUM(impressions) AS total_impressions,
  SUM(clicks) AS total_clicks,
  SUM(conversions) AS total_conversions,
  ROUND(SUM(spend) / NULLIF(SUM(conversions), 0), 2) AS cost_per_conversion,
  ROUND(SUM(clicks) / SUM(impressions) * 100, 4) AS CTR_percent,
  ROUND(SUM(conversions) / NULLIF(SUM(clicks), 0) * 100, 4) AS conversion_rate_percent
FROM `adtech-campaign-analysis.campaign_data.campaign_performance`
GROUP BY advertiser_category
ORDER BY total_spend DESC

-- Query 4: Device Type and Format Efficiency
-- Breaks down spend, impressions, viewability, CTR, and CPC by device type and format.
-- Identifies which device and format combinations deliver the best viewability
-- and cost efficiency for media planning decisions.

SELECT
  device_type,
  format,
  ROUND(SUM(spend), 2) AS total_spend,
  SUM(impressions) AS total_impressions,
  ROUND(AVG(viewability) * 100, 2) AS avg_viewability_percent,
  ROUND(SUM(clicks) / SUM(impressions) * 100, 4) AS CTR_percent,
  ROUND(SUM(spend) / NULLIF(SUM(clicks), 0), 2) AS CPC
FROM `adtech-campaign-analysis.campaign_data.campaign_performance`
GROUP BY device_type, format
ORDER BY device_type, total_spend DESC


-- Query 5: Video Completion Rate by Format and Device
-- Filters to video and CTV formats only.
-- Calculates total video starts, completions, and video completion rate (VCR)
-- by format and device type to identify which combinations drive
-- the strongest video engagement.

SELECT
  format,
  device_type,
  SUM(video_start) AS total_video_starts,
  SUM(video_complete) AS total_video_completions,
  ROUND(SUM(video_complete) / NULLIF(SUM(video_start), 0) * 100, 2) AS VCR_percent
FROM `adtech-campaign-analysis.campaign_data.campaign_performance`
WHERE format IN ('video', 'ctv')
GROUP BY format, device_type
ORDER BY VCR_percent DESC


-- Query 6: Cumulative Spend by Format Over Time
-- Uses a CTE to calculate monthly spend per format, then computes
-- a running cumulative spend across the year to show how each format's
-- investment grew over time — supporting media budget pacing decisions.

WITH monthly_format_spend AS (
  SELECT
    month_date,
    format,
    ROUND(SUM(spend), 2) AS monthly_spend
  FROM `adtech-campaign-analysis.campaign_data.campaign_performance`
  GROUP BY month_date, format
)
SELECT
  month_date,
  format,
  monthly_spend,
  ROUND(SUM(monthly_spend) OVER (
    PARTITION BY format
    ORDER BY month_date
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ), 2) AS cumulative_spend
FROM monthly_format_spend
ORDER BY format, month_date

-- Query 7: Advertiser Category Conversion Efficiency Ranking
-- Uses a window function to rank advertiser categories by conversion rate
-- within each format, identifying which category and format combinations
-- drive the strongest conversion performance for campaign optimization.

SELECT
  format,
  advertiser_category,
  SUM(clicks) AS total_clicks,
  SUM(conversions) AS total_conversions,
  ROUND(SUM(conversions) / NULLIF(SUM(clicks), 0) * 100, 4) AS conversion_rate_percent,
  RANK() OVER (
    PARTITION BY format
    ORDER BY SUM(conversions) / NULLIF(SUM(clicks), 0) DESC
  ) AS conversion_rank
FROM `adtech-campaign-analysis.campaign_data.campaign_performance`
GROUP BY format, advertiser_category
ORDER BY format, conversion_rank

