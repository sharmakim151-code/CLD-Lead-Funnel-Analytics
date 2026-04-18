Create Table Leads (lead_id Varchar(50) Primary Key,
created_date Date,
source Varchar(100),
city Varchar(100),
course_interest Varchar(100)
);

Create table Funnel (lead_id Varchar(50) REFERENCES leads(lead_id),
stage Varchar(50),
stage_date Date
);

Create table counselors (Counselor_id Varchar(50) Primary Key,
first_name Varchar(100) NOT NULL,
last_name Varchar(100) NOT NULL,
email Varchar(100),
Phone_Number Varchar(100),
Counselor_department Varchar(100),
salary Numeric(10,2),
joining_date Date,
age INT	
);

Create table conversions (lead_id Varchar(50) REFERENCES leads(lead_id),
counselor_id Varchar(50) REFERENCES counselors(counselor_id),
conversion_date	DATE,	
revenue Numeric(10,2)
);

Copy
Leads (lead_id, created_date, source, city, course_interest)
From 'D:\Desktop\CLD Funnel Project\Leads.csv'
Delimiter ','
CSV Header;

Copy
Funnel (lead_id, stage, stage_date)
From 'D:\Desktop\CLD Funnel Project\Funnel.csv'
Delimiter ','
CSV Header;

Copy
Counselors (Counselor_id, first_name, last_name, email, Phone_Number, Counselor_department, salary, joining_date, age)
From 'D:\Desktop\CLD Funnel Project\Counselors.csv'
Delimiter ','
CSV Header;

Copy
Conversions (lead_id, counselor_id, conversion_date, revenue)
From 'D:\Desktop\CLD Funnel Project\Conversions.csv'
Delimiter ','
CSV Header;

Select * from Leads;
Select * from Counselors;
Select * from Conversions;
Select * from Funnel;

Select DISTINCT stage from Funnel;

-- Count Leads at each stage

Select stage, count(lead_id) As Stage_wise_leads
From Funnel
Group by stage;

--Drop off calculations (Where are we losing the most students?)

SELECT stage, COUNT(lead_id) AS Stage_wise_leads, 
CASE WHEN stage = 'Lead' THEN 1 
WHEN stage = 'Contacted' THEN 2 
WHEN stage = 'Interested' THEN 3 
WHEN stage = 'Applied' THEN 4 
WHEN stage = 'Converted' THEN 5 
ELSE 99 
END AS Stage_order 
FROM Funnel 
GROUP BY stage; 

----The highest drop-off is between Lead and Contacted stage with 12 leads lost. This indicates a major issue in initial lead engagement or response time from counselors, meaning many leads are not being followed up effectively at the earliest stage.

--percent drop calculation

With Stage_count AS (
Select stage, count(lead_id) As Stage_wise_leads,
CASE
WHEN Stage='Lead' THEN 1
WHEN Stage='Contacted' THEN 2
WHEN Stage='Interested' THEN 3
WHEN Stage='Applied' THEN 4
WHEN Stage='Converted' THEN 5
END AS Stage_order
From Funnel
Group by stage
)

Select stage, Stage_wise_leads,
LAG(Stage_wise_leads) OVER (Order by Stage_order) AS Previous_stage_data,
(LAG(Stage_wise_leads) OVER (Order by Stage_order) - Stage_wise_leads) AS Drop_offs,

Round ((LAG(Stage_wise_leads) OVER (Order by Stage_order) - Stage_wise_leads) * 100
/LAG(Stage_wise_leads) OVER (Order by Stage_order)) AS Percentage_dropoff
From Stage_count
Order by stage_order;

-- Conversion rate analysis (Out of total leads, how many actually converted?)
--Total leads → from leads JOIN Converted leads → from conversions, Divide → gives %

Select count(distinct c.lead_id)*100/count(distinct l.lead_id) AS Conversion_rate
From Leads l
LEFT JOIN
Conversions c
ON l.lead_id=c.lead_id;

-- Total revenue analysis (How much money did we make?)

Select sum(revenue) AS Total_revenue
From Conversions;

-- Revenue by Counselor (How much each counselor made?)

Select c.first_name, c.last_name, sum(conv.revenue) AS Total_revenue
From counselors c
JOIN conversions conv
ON c.counselor_id=conv.counselor_id
Group by c.counselor_id
Order by Total_revenue DESC;

-- Which counselor made the highest revenue?

Select c.first_name, c.last_name, sum(conv.revenue) AS Total_revenue
From counselors c
JOIN conversions conv
ON c.counselor_id=conv.counselor_id
Group by c.counselor_id
Order by Total_revenue DESC
Limit 1;

-- Lead Source Analysis (which source gives best conversion?)

-- Step 1: Calculate lead per source

Select source, count(lead_id) as Total_leads
from Leads
Group by source;

--Step 2: Conversion per source

Select l.source, count(c.lead_id) as conversion_made
From Leads l
LEFT JOIN Conversions c
ON l.lead_id=c.lead_id
Group by l.source
Order by conversion_made DESC;

--Step 3: Conversion rate per source

Select l.source, count(c.lead_id)*100/count(l.lead_id) AS Conversion_rate
From Leads l
LEFT JOIN Conversions c
ON l.lead_id=c.lead_id
Group by l.source
Order by Conversion_rate DESC;
