/* What are the top paying data analyst jobs? 
- Identify top 10 highest paying roles that are remotely available
- Focus on job postings with specified salaries (remove NULLs)
*/
SELECT
    job_id,
    job_title,
    job_location,
    job_schedule_type,
    salary_year_avg,
    job_posted_date,
    name AS company_name
FROM   
    job_postings_fact
-- Get company names
LEFT JOIN company_dim on job_postings_fact.company_id = company_dim.company_id
WHERE
    job_title_short = 'Data Analyst' AND
    job_location = 'Anywhere' AND
    salary_year_avg IS NOT NULL
ORDER BY
    salary_year_avg DESC
LIMIT 10;