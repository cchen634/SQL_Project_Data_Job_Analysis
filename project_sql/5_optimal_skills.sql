/*
Question: What are the most optimal skills to learn (high-demand and high_paying)
- identify skills high in demand and associated with high average salaries for Data Analyst roles
- concentrate on remote positions with specified salaries
- to target skills that offer job security (high demand) and financial benefits (high salaries),
offering strategic insights for career developement in data analysis
*/
WITH skills_demand AS (
    SELECT
        skills_job_dim.skill_id AS skill_id, --include to use as primary key
        skills_dim.skills AS skill,
        COUNT(skills_job_dim.job_id) AS demand_count
    FROM job_postings_fact
    INNER JOIN skills_job_dim on job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE
        salary_year_avg IS NOT NULL AND
        job_title_short = 'Data Analyst' AND
        job_work_from_home = TRUE
    GROUP BY 
        skills_job_dim.skill_id,
        skills_dim.skills
), average_salary AS (
    SELECT
        skills_job_dim.skill_id AS skill_id,
        skills_dim.skills AS skill,
        ROUND(AVG(salary_year_avg), 0) as avg_yearly_salary
    FROM
        job_postings_fact
    INNER JOIN skills_job_dim
    ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim
    ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE
        salary_year_avg IS NOT NULL AND
        job_title_short = 'Data Analyst' AND
        job_work_from_home = TRUE
    GROUP BY
        skills_job_dim.skill_id,
        skills_dim.skills
)
SELECT
    skills_demand.skill_id,
    skills_demand.skill,
    demand_count,
    avg_yearly_salary
FROM
    skills_demand
INNER JOIN average_salary
ON skills_demand.skill_id = average_salary.skill_id
WHERE
    demand_count > 10
ORDER BY
    avg_yearly_salary DESC,
    demand_count DESC
LIMIT 25;

-- rewriting the same query more precisely
SELECT
    skills_job_dim.skill_id AS skill_id,
    skills_dim.skills AS skill,
    COUNT(skills_job_dim.job_id) AS demand_count,
    ROUND(AVG(salary_year_avg), 0) as avg_yearly_salary
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    salary_year_avg IS NOT NULL AND
    job_title_short = 'Data Analyst' AND
    job_work_from_home = TRUE
GROUP BY
    skills_job_dim.skill_id,
    skills_dim.skills
HAVING 
    COUNT(skills_job_dim.job_id) > 10
ORDER BY
    avg_yearly_salary DESC,
    demand_count DESC
LIMIT 25;