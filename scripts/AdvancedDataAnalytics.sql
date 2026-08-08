-- Change Over Time Analysis

-- Analyze revenue over time

-- is revenue increasing / decresing?? best year?? gain customer??
select 
avg(revenue_growth_percent) total_revenue,
sum(ai_projects_active) total_project_active,
sum(num_employees) total_num_emp,
count(ai_primary_tool) total_ai,
survey_year,
quarter
from ai_company_adoption
group by survey_year,quarter
order by survey_year,quarter

-- Analyze jobs created / displaced over time
select 
survey_year,
sum(jobs_created) total_jobs_created,
sum(jobs_displaced) total_jobs_displaced
from ai_company_adoption 
group by survey_year
order by survey_year 
----------------------------------------------------------------------------------------------

-- Cumulative Analysis

-- Calculate the total jobs created and jobs displaced over time & running total jobs created / displaced
-- Find running total 



-------------------------------

select 
survey_year,
sum(jobs_created) total_jobs_created,
sum(sum(jobs_created)) over (order by survey_year) as running_total_jobs_created,
sum(jobs_displaced) total_jobs_displaced,
sum(sum(jobs_displaced)) over (order by survey_year) as running_total_jobs_displaced
from ai_company_adoption
group by survey_year

--

select 
survey_year,
ai_primary_tool,
avg(productivity_change_percent) avg_productivity,
avg(avg(productivity_change_percent)) over(partition by ai_primary_tool order by survey_year ) as running_avg
from  ai_company_adoption
group by survey_year ,ai_primary_tool
order by survey_year ,ai_primary_tool

--------------------------------------------
select 
survey_year,
total_jobs_created,
total_jobs_displaced,
avg_productivity,
sum(total_jobs_created) over (order by survey_year) as running_total_jobs_created,
sum(total_jobs_displaced) over (order by survey_year) as running_total_jobs_displaced,
avg(avg_productivity) over( order by survey_year ) as running_avg_productivity
from (
select
survey_year,
sum(jobs_created) total_jobs_created,
sum(jobs_displaced) total_jobs_displaced,
avg(productivity_change_percent) avg_productivity
from ai_company_adoption
group by survey_year
)t


-------------------------------------------------------------------------

-- Performance Analysis 

/*
Analyze the yearly performance of AI primary tools by:

- Calculating the total active AI projects for each AI primary tool every year.
- Comparing each year's total active AI projects with the average performance of the same AI primary tool.
- Comparing each year's total active AI projects with the previous year's performance for the same AI primary tool.
*/

with yearly_adoption_tools as(
select 
survey_year ,
ai_primary_tool,
sum(ai_projects_active) as total_project_active
from ai_company_adoption
group by survey_year , ai_primary_tool)

select * ,
AVG(total_project_active) over (partition by ai_primary_tool) avg_active,
total_project_active - AVG(total_project_active) over (partition by ai_primary_tool) as diff_avg,
case when total_project_active - AVG(total_project_active) over (partition by ai_primary_tool) > 0 then 'Above Avg'
	when total_project_active - AVG(total_project_active) over (partition by ai_primary_tool) < 0 then 'Below Avg'
	else 'Avg'
end as avg_change,
-- Year-over-year analysis
lag(total_project_active) over (partition by ai_primary_tool order by survey_year) previous_year_active_project,
total_project_active - lag(total_project_active) over (partition by ai_primary_tool order by survey_year) diff_previuos_year,
case when total_project_active - lag(total_project_active) over (partition by ai_primary_tool order by survey_year) > 0 then 'Increase'
	when total_project_active - lag(total_project_active) over (partition by ai_primary_tool order by survey_year) < 0 then 'Decrease'
	else 'No Change'
end as previous_year_change
from yearly_adoption_tools
order by ai_primary_tool,survey_year


---------------------------------------------------------------------------------------

-- Part To Whole Analysis

-- Which industries achieve the highest average AI-driven cost reduction percentage?
with industry_reduction as (
select 
industry,
sum(cost_reduction_percent) total_reduction
from ai_company_adoption
group by industry
)
select *, sum(total_reduction) over() overall_avg_reduction,
concat(round((total_reduction /sum(total_reduction) over()) * 100,2),'%')  as percentage_of_total_reduction
from industry_reduction
order by total_reduction desc


---------------
with industry_reduction as (
select 
[num_employees],
sum([ai_investment_per_employee]) totalInvestment
from ai_company_adoption
group by [num_employees]
)
select *, sum(totalInvestment) over() overall_avg_reduction,
concat(round((totalInvestment /sum(totalInvestment) over()) * 100,3),'%')  as percentage_of_total_Investment
from industry_reduction
order by totalInvestment desc
----------------------------------------------------------------

-- Data Segmantation

/*

Task for code:
Segmenting AI training hour into ranges,
analyze how AI project failure rates differ between training levels.
*/
with hours_segments as (
select 
ai_training_hours,
ai_failure_rate,
case when ai_training_hours < 20 then 'Below 20'
	when ai_training_hours between 21 and 50 then '21-50'
	else 'Above 50'
	end hours_training_range
from  ai_company_adoption
)
select
hours_training_range,
avg(ai_failure_rate) as avg_failure
from hours_segments
group by hours_training_range 
order by avg_failure desc

--------------

/* Group companies into three segments based on their AI adoption behavior:
   - AI Leaders: maturity score >= 0.60 AND adoption rate >= 60.
   - AI Adopters: maturity score between 0.30 and 0.599 AND adoption rate between 30 and 59.9.
   - AI Beginners: maturity score < 0.30 OR adoption rate < 30.
   and find total number of companies by each group.
*/

with full_segment as (
select 	
company_id,
ai_maturity_score,
ai_adoption_rate 
from ai_company_adoption
)
, semegnt as (
SELECT
       company_id,
		case when ai_maturity_score > = 0.6 and ai_adoption_rate > = 60 then 'AI Leaders'
			when ai_maturity_score between 0.3 and 0.599 and ai_adoption_rate between 30 and 59.9 then 'AI Adopters'
			else 'AI begniers'
		end adoption_segment
	FROM full_segment) ,

final_segment as (
	select 
	adoption_segment,
	count(company_id) as total_companies
	from semegnt
	group by adoption_segment
	)
	select * from final_segment order by total_companies desc

-------------------------------------------------------------------------------------------------------------------------

-- Reporting 

/*
====================================================================
AI Adoption Report
====================================================================
Report Purpose:
This report performs a comprehensive AI adoption performance analysis at the company level.

Highlights:
    It first creates a base dataset containing key company information, AI adoption metrics,
    investment data, and business performance indicators.

Then, it aggregates data for each company to calculate:
        - Latest survey year and AI usage duration
        - Total AI projects and training hours
        - Average AI adoption rate and maturity score
        - Average AI budget and AI investment per employee
        - Average productivity improvement, revenue growth, and cost reduction
        - Average employee and customer satisfaction
        - Average company revenue and employee count

Finally, it calculates additional efficiency metrics:
    - Training hours per AI project: Measures investment in employee AI training for each project
    - Revenue per employee: Measures workforce productivity and business efficiency
    - AI projects per employee: Measures AI project intensity relative to company size
    - Productivity improvement per AI project: Measures the productivity impact of each AI project
    - Cost reduction per AI project: Measures cost-saving effectiveness of AI initiatives
====================================================================
*/

create view report_ai_adoption as 
WITH base_query AS (
SELECT
    company_id,
    survey_year,
    quarter,
    CONCAT(country,' - ',region) AS country_region,
    industry,
    company_size,
    company_age_group,
    num_employees,
    annual_revenue_usd_millions,
    years_using_ai,
    ai_primary_tool,
    ai_adoption_rate,
    ai_projects_active,
    ai_training_hours,
    ai_maturity_score,
    ai_budget_percentage,
    ai_investment_per_employee,
    productivity_change_percent,
    revenue_growth_percent,
    cost_reduction_percent,
    employee_satisfaction_score,
    customer_satisfaction
FROM ai_company_adoption
),
company_metrics AS (
SELECT
    company_id,
    MAX(survey_year) AS latest_survey,
    MAX(years_using_ai) AS years_using_ai,
    SUM(ai_projects_active) AS total_ai_projects,
    SUM(ai_training_hours) AS total_training_hours,
    AVG(ai_adoption_rate) AS avg_ai_adoption,
    AVG(ai_maturity_score) AS avg_maturity_score,
    AVG(ai_budget_percentage) AS avg_ai_budget,
    AVG(ai_investment_per_employee) AS avg_ai_investment,
    AVG(productivity_change_percent) AS avg_productivity,
    AVG(revenue_growth_percent) AS avg_revenue_growth,
    AVG(cost_reduction_percent) AS avg_cost_reduction,
    AVG(employee_satisfaction_score) AS avg_employee_satisfaction,
    AVG(customer_satisfaction) AS avg_customer_satisfaction,
    AVG(annual_revenue_usd_millions) AS avg_revenue,
    AVG(num_employees) AS avg_employees
FROM base_query
GROUP BY company_id
)
SELECT
    company_id,
    latest_survey,
    years_using_ai,
    total_ai_projects,
    total_training_hours,
    avg_ai_adoption,
    avg_maturity_score,
    avg_ai_budget,
    avg_ai_investment,
    avg_productivity,
    avg_revenue_growth,
    avg_cost_reduction,
    avg_employee_satisfaction,
    avg_customer_satisfaction,
    avg_revenue,
    avg_employees,
    total_training_hours / NULLIF(total_ai_projects,0) AS training_hours_per_project,
    avg_revenue / nullif(avg_employees,0) AS revenue_per_employee,
    total_ai_projects / nullif(avg_employees,0) AS projects_per_employee,
    avg_productivity / nullif(total_ai_projects,0) AS productivity_per_project,
    avg_cost_reduction / nullif(total_ai_projects,0) AS cost_reduction_per_project
from  company_metrics;


