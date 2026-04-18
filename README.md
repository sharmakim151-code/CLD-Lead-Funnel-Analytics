# CLD Lead Funnel Analytics — SQL + Power BI

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=flat&logo=postgresql&logoColor=white)
![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=flat&logo=powerbi&logoColor=black)
![DAX](https://img.shields.io/badge/DAX-0078D4?style=flat)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen)

An end-to-end lead funnel analytics project built using PostgreSQL and Power BI — analysing how 25 student leads moved through the admission journey at an EdTech platform, identifying drop-off points, measuring counselor revenue performance, and optimising marketing channel spend.


---

## The business question

Out of 25 student leads, only 2 converted end-to-end. *Where exactly were students dropping off — and what should the business do about it?*

---

## Key findings at a glance

| Metric | Value |
|---|---|
| Total leads | 25 |
| Overall conversion rate | 44% |
| Total revenue tracked | $6,75,000 |
| Instagram conversion rate | 75% |
| Google conversion rate | 11% |
| Top counselor revenue | $1,85,000 (Varun) |

---

## Insights by dashboard page

### Page 1 — Funnel overview (the problem)
- 47% of leads were never contacted — biggest single drop-off in the funnel
- 66% of interested students never completed their application — worst mid-funnel leak
- Root cause: delayed counselor follow-up at first touchpoint + friction at application stage

### Page 2 — Conversion & revenue (business impact)
- Overall conversion rate: 44% — significant room to improve with better follow-up processes
- Top counselor Varun generated $1,85,000 — 27% of total revenue alone
- Counselor-wise breakdown enables targeted performance coaching and incentive planning

### Page 3 — Source analysis (the solution)
- Google: 9 leads, only 11% conversion rate — high volume, low quality
- Instagram: 8 leads, 75% conversion rate — low volume, highest quality
- **Recommendation:** Reallocate marketing budget from Google to Instagram for better ROI

---

## Dashboard preview

### Page 1 — Funnel overview
<img width="673" height="353" alt="Screenshot 2026-04-18 130455" src="https://github.com/user-attachments/assets/fd8eb86d-b1e7-4498-af17-51f7d0ccc404" />

### Page 2 — Conversion & revenue
<img width="616" height="356" alt="Screenshot 2026-04-18 130523" src="https://github.com/user-attachments/assets/5e86ab54-9c82-4333-8a11-98e35b4c9508" />

### Page 3 — Source analysis
<img width="596" height="356" alt="Screenshot 2026-04-18 130536" src="https://github.com/user-attachments/assets/549ec3b5-f09e-4bbb-a566-1f90deaba2d2" />

---

## Database schema

4 tables joined across the analysis:

```sql
Leads        (lead_id, created_date, source, city, course_interest)
Funnel       (lead_id, stage, stage_date)
Counselors   (counselor_id, first_name, last_name, email, salary, joining_date)
Conversions  (lead_id, counselor_id, conversion_date, revenue)
```

---

## SQL techniques used

- CTEs (Common Table Expressions) for multi-step funnel calculations
- LAG() window function for stage-to-stage drop-off comparison
- CASE statements for custom stage ordering
- Multi-table JOINs (LEFT JOIN across 4 tables)
- Aggregations — COUNT, SUM, GROUP BY, ORDER BY
- Percentage drop-off calculations with ROUND()

---

## Key SQL queries

### Funnel drop-off analysis

```sql
WITH Stage_count AS (
  SELECT stage, COUNT(lead_id) AS Stage_wise_leads,
    CASE
      WHEN stage = 'Lead'       THEN 1
      WHEN stage = 'Contacted'  THEN 2
      WHEN stage = 'Interested' THEN 3
      WHEN stage = 'Applied'    THEN 4
      WHEN stage = 'Converted'  THEN 5
    END AS Stage_order
  FROM Funnel
  GROUP BY stage
)
SELECT stage, Stage_wise_leads,
  LAG(Stage_wise_leads) OVER (ORDER BY Stage_order) AS Previous_stage,
  (LAG(Stage_wise_leads) OVER (ORDER BY Stage_order) - Stage_wise_leads) AS Drop_offs,
  ROUND((LAG(Stage_wise_leads) OVER (ORDER BY Stage_order) - Stage_wise_leads) * 100
    / LAG(Stage_wise_leads) OVER (ORDER BY Stage_order)) AS Pct_dropoff
FROM Stage_count
ORDER BY stage_order;
```

### Conversion rate by source

```sql
SELECT l.source,
  COUNT(l.lead_id) AS total_leads,
  COUNT(c.lead_id) AS converted_leads,
  ROUND(COUNT(c.lead_id) * 100.0 / COUNT(l.lead_id)) AS conversion_rate_pct
FROM Leads l
LEFT JOIN Conversions c ON l.lead_id = c.lead_id
GROUP BY l.source
ORDER BY conversion_rate_pct DESC;
```

### Top performing counselor

```sql
SELECT c.first_name, c.last_name, SUM(conv.revenue) AS total_revenue
FROM Counselors c
JOIN Conversions conv ON c.counselor_id = conv.counselor_id
GROUP BY c.counselor_id, c.first_name, c.last_name
ORDER BY total_revenue DESC
LIMIT 1;
```

---

## Power BI DAX measures

```dax
Total_Revenue   = SUM(Conversions[revenue])
Conversion_Rate = DIVIDE(COUNTROWS(Conversions), COUNTROWS(Leads))
Drop_Off_Pct    = DIVIDE([Previous_Stage] - [Current_Stage], [Previous_Stage])
Stage_Order     = SWITCH(Funnel[stage],
                    "Lead",1, "Contacted",2,
                    "Interested",3, "Applied",4, "Converted",5)
```

---

## Tools & technologies

- **PostgreSQL** — data modelling, querying, window functions
- **Power BI Desktop** — 3-page interactive dashboard
- **DAX** — custom measures for KPIs and drop-off calculations
- **Excel / CSV** — raw data preparation

---

## Files in this repo

```
CLD-Lead-Funnel-Analytics/
├── README.md
├── sql/
│   └── funnel_analysis.sql          ← all SQL queries
├── screenshots/
│   ├── page1_funnel_overview.png
│   ├── page2_conversion_revenue.png
│   └── page3_source_analysis.png
└── dashboard/
    └── CLD_Funnel_Dashboard.pbix    ← Power BI file
```

---

## How to run

1. Clone this repo or download the files
2. Import the CSV files into PostgreSQL and run `funnel_analysis.sql`
3. Open `CLD_Funnel_Dashboard.pbix` in Power BI Desktop
4. Use slicers (stage, city, source, lead_id) to explore insights interactively

---

## What I learned

- Using LAG() window functions for sequential stage comparison in funnel analysis
- Structuring a dashboard as Problem → Business Impact → Solution for stakeholder storytelling
- DAX measures over calculated columns for better model performance
- How to use Sort by Column in Power BI to enforce custom ordering on categorical data
- Translating SQL findings directly into Power BI visuals for a seamless data pipeline

---

## Future improvements

- Add time-based analysis — which month had the best conversion rates?
- Build a lead scoring model to predict which leads are most likely to convert
- Add city-wise funnel performance breakdown
- Connect to a live database for real-time dashboard refresh

---

## About me

I'm a Data Analyst with 7+ years of experience in EdTech analytics, transitioning into a full-time Data / Business Analyst role. This project is built on real business logic from my experience at CollegeDekho.

Currently open to **Data Analyst / Business Analyst** roles in Bengaluru or remote.

Connect with me on [LinkedIn](https://linkedin.com/in/diksha-sharma-ab2081127)
  
