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