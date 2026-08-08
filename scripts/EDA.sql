											/* Dimensions Exploration */

-- Explore all countries that adopt AI tools

select distinct country from ai_company_adoption;

-- What industries are adopting these tools most frequently?
select distinct industry from ai_company_adoption;

--What are the most popular AI tools listed?
select distinct ai_primary_tool from ai_company_adoption;


-- What size brackets exist (e.g.,Enterprise)?
select distinct company_size from ai_company_adoption;

-- What are the usecases that did they use AI ?
select distinct ai_use_case from ai_company_adoption

-- How are participating companies categorized across different levels?
select distinct [ai_adoption_stage] from ai_company_adoption
-------------------------------------------------------------------------------------
									/* Date Exploration */

-- Find the date of the first and last adoption

select 
	min(survey_year- years_using_ai) as first_adoption_year,
	max(survey_year-years_using_ai) as last_adotion_year
from ai_company_adoption;


-- How many years does this dataset being adopted AI?
--select MAX(years_using_ai) - MIN(years_using_ai) range_using_ai from ai_company_adoption 


------------------
select 
	min(survey_year) year_of_survey ,
	max(survey_year) last_of_survey,
	max(survey_year) - min(survey_year) years_of_survey
from ai_company_adoption;

select 
	min(company_founding_year) first_founding_year, 
	max(company_founding_year) last_founding_year,
	max(company_founding_year)-min(company_founding_year) years_of_working 
from ai_company_adoption;

-----------------------------------------------------------------------------------------------
								   /* Measures Exploration */

							select * from ai_company_adoption

-- what is the overall average productivity change ?
select round(AVG([productivity_change_percent]),0) avg_productivity_change from ai_company_adoption

-- what is the total number of jobs displaced versus total jobs created?

select sum(jobs_displaced) jobs_displaced ,sum(jobs_created) jobs_created from ai_company_adoption;


-- How many total employees have been reskilled across all organizations?
select sum(reskilled_employees) total_reskilled_emp from ai_company_adoption 

-- What is the average training hours provided to staff?
select round(avg(ai_training_hours),1) from ai_company_adoption

-- What is the total number of companies that uses AI?
select count(distinct company_id) from ai_company_adoption 


-- Total survey responses represented in the dataset?
select count(distinct response_id) total_respoces from ai_company_adoption 


-- What is the total revenue represented by all companies ?
select round(sum(annual_revenue_usd_millions),1) total_annual_revenue from ai_company_adoption


-- What are the highest and lowest AI failure rate + Avgerage of failure?
select  min([ai_failure_rate]) lowest_failure , max([ai_failure_rate]) highest_failure, round(avg([ai_failure_rate]),1) avg_fail_rate  from ai_company_adoption 


-- What is the average time saved per week ?
select round(avg([time_saved_per_week]),1) avg_time_saved from ai_company_adoption  

-- How many total unique companies have actually adopted AI?
select count(distinct company_id) total_company_using_AI from ai_company_adoption where ai_adoption_stage not in ('none','pilot')  or ai_projects_active > 0


-- Generate a Report that shows all key metrics of the business
-- name of measure , value of measure
select 'Avg Productivity Change' as  measure_name , round(AVG([productivity_change_percent]),0) as measure_value from ai_company_adoption
UNION ALL
select 'Total Jobs displaced' , sum(jobs_displaced)  from ai_company_adoption
UNION ALL
select 'Total jobs created' , sum(jobs_created)  from ai_company_adoption
union all
select 'Total Reskilled Emp ',sum(reskilled_employees)  from ai_company_adoption
union all
select 'Avg Training Hours', round(avg(ai_training_hours),1) from ai_company_adoption
union all
select 'Total Nr. Comanies',count(distinct company_id) from ai_company_adoption 
union all
select 'Total Responces',count(distinct response_id) from ai_company_adoption 
union all
select 'Total Annual Revenue',round(sum(annual_revenue_usd_millions),1) from ai_company_adoption 
union all
select 'Highest Failure' ,max([ai_failure_rate])  from ai_company_adoption 
union all
select'Avg Failure Rate' ,round(avg([ai_failure_rate]),1) from ai_company_adoption
union all
select 'Avg Time Saved',round(avg([time_saved_per_week]),1) from ai_company_adoption
union all
select 'Total Company Using AI',count(distinct company_id)  from ai_company_adoption where ai_adoption_stage not in ('none','pilot')  or ai_projects_active > 0

/*

select 
case 
when sum(reskilled_employees) > 1000000  then concat(cast( round(sum(reskilled_employees)/1000000,0) as nvarchar) ,'M')
when  sum(reskilled_employees) > 1000 then concat( cast( round(sum(reskilled_employees)/1000 ,0) as nvarchar) ,'k')
else cast(sum(reskilled_employees) as nvarchar)

end total_reskilled_emp from ai_company_adoption

*/

----------------------------------------------------------------------------------------------------------

-- Magnitude Analysis

-- What is the total revenue by industry?
select industry, sum(annual_revenue_usd_millions) total_revenue from ai_company_adoption group by industry order by total_revenue desc


-- what is the average budget percentage by company size?
select company_size, avg(ai_budget_percentage) avg_budget from ai_company_adoption group by company_size order by avg_budget desc

-- what is total investment per employee by country
select [country] ,sum([ai_investment_per_employee]) total_investment from ai_company_adoption group by [country] order by total_investment desc

-- What is total number of jobs displaced by region?
select region,sum(jobs_displaced) total_jobs_displaced from ai_company_adoption group by region order by total_jobs_displaced desc

-- what is the total number of reskilled employees by industry?
select industry,sum(reskilled_employees) total_reskilled_emp from ai_company_adoption group by industry order by total_reskilled_emp desc


-- What is the average time saved per week by primary AI tool?
select ai_primary_tool,sum(time_saved_per_week) avg_time_saved from ai_company_adoption group by ai_primary_tool order by avg_time_saved desc

-- What is the average productivity change by AI adoption stage?
select ai_adoption_stage,avg(productivity_change_percent) avg_productivity_change from ai_company_adoption group by ai_adoption_stage order by avg_productivity_change desc

-- what is the total number of active AI projects by industry?
select industry,sum(ai_projects_active) total_project_active from ai_company_adoption group by industry order by total_project_active desc

-- What is the avgerage task automation rate by company size?
select company_size,avg(task_automation_rate) avg_task_automation from ai_company_adoption group by company_size order by avg_task_automation desc

-- What is the total AI training hours by region?
select region,sum(ai_training_hours) total_training_hours from ai_company_adoption group by region order by total_training_hours desc

-- what is the average risk managment score by data privacy level?
select data_privacy_level,avg(ai_risk_management_score) avg_risk from ai_company_adoption group by data_privacy_level order by avg_risk desc


----------------------------------------------------------------------------------------------------------------
-- Ranking Analysis

-- What are the the top 3 industries with the highest total annual revenue?
select top 3 industry,sum(annual_revenue_usd_millions) total_annual from ai_company_adoption group by industry order by total_annual desc

-- What are the top 3 primary AI tools achieving the highest average hours saved per week?
select top 3 ai_primary_tool,avg(time_saved_per_week) avg_time_saved from ai_company_adoption group by ai_primary_tool order by avg_time_saved desc

-- What are the the top 5 countries with the highest total number of reskilled employee?
select top 5 country , sum(reskilled_employees) total_reskilled_emp from ai_company_adoption group by country order by total_reskilled_emp desc

-- What are the top 3 industries experiencing the highest average AI failure rate?
select top 3 industry,avg(ai_failure_rate) avg_failure_rate  from ai_company_adoption group by industry order by avg_failure_rate desc
 
-- What are the bottom 5 with the lowest avearge risk managment score?
select top 5 region , round(avg(ai_risk_management_score),3)  avg_risk_managment_score from ai_company_adoption group by region order by avg_risk_managment_score

-- Which company size have the lowest average AI investment per employee?
select company_size , AVG(ai_investment_per_employee) avg_inevestment from ai_company_adoption group by company_size order by avg_inevestment asc

-- what is the top 2 primary AI tools with the highest average time saved per week within each company size?
SELECT * 
FROM (
    SELECT  
        company_size,
        ai_primary_tool, 
        AVG(time_saved_per_week) AS avg_time_saved,
        DENSE_RANK() OVER (PARTITION BY company_size ORDER BY AVG(time_saved_per_week) DESC) AS ranking_saved
    FROM ai_company_adoption  
    GROUP BY company_size, ai_primary_tool
) t
WHERE ranking_saved <= 2;


------------------------------------------------------------------------------------------------------

