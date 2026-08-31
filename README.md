# Introduction
This project explores the highest paying data analyst jobs to identify the top in-demand skills to have for job-seekers pursuing data analysis.
SQL Queries: [project_sql folder](/project_sql/)
# Background
Looking to gain experience with SQL, I followed along with Luke Barousse's open-source SQL Data Analytics course (https://www.youtube.com/watch?v=7mz73uXD9DA&t=6102s). 
Through this project, I examined the top-paying remote data analysis jobs as well as the top in-demand skills across these job postings.
The data used for this project is from (https://lukebarousse.com/sql), which contains records of job titles, salaries, location, and required skills.
### The questions I sought to answer are as follows:
1. What are the top-paying data analyst jobs?
2. What skills are required for these top-paying jobs?
3. What skills are most in demand for data analysts?
4. Which skills are assocciated with higher salaries?
5. What are the most optimal skills to learn?

# Tools I Used
To answer these questions about the data analyst job market, I used the following key tools:
- **SQL:** To query the database, allowing me to clean, filter, and sort the data to pinpoint top-reoccuring skills and highest salary job postings.
- **PostgreSQL:** This database management system was at the core of handling the relational job posting data.
- **Visual Studio Code:** The code editor for running SQL queries and database management.
- **Git & Github:** For version control and sharing my workflow, ensuring changes are tracked and smooth collaboration.
# The Analysis
Each query for this project served to investigate a specific aspect of the data analyst job market. Here's my approach to tackling each question:

### 1. Top-Paying Data Analyst Jobs
I selected relevant columns such as the title, average salary, location, and schedule type to filter the highest-paying remote data analyst jobs. Then using the job identifier, I joined another table to match these jobs to the company name that posted them. This query supplied job-seekers with both insight into which roles to apply to as well as to which companies.

```sql
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
```
Breakdown of top-paying data analyst jobs in 2023:
- **Wide Salary Range:** The salary difference between the most well-paid job and the 10th most well-paid is about $450k indicating significant pay variation depending on company, experience level, and other factors as well as revealing great earning potential in the field.
- **Remote Opportunities:** Given the diversity of companies within these top-10 results, we see that there are many companies offering work-from-home options with substantial pay within the data analytics job field.
- **Job Specialty:** Unsurprisingly, the highest paying jobs within data analytics are supervisory and management roles such as Director or Principal Data Analysts or more specialized roles such as risk management (ERM). Within the data analytics job market, we also see many diverse levels and sub-fields. 

### 2. Top-Paying Skills
I built on top of my query for the first question to create a common table expression (CTE) which contained the information on the top-paying, remote data analyst jobs. Then, I used innner joins to join [skill_job_dim.csv](../csv_files/skills_job_dim.csv), to match the job ID to skill ID and [skills_dim.csv](../csv_files/skills_dim.csv) to match the skill ID to skill name to identify the skills belonging to the top-paying jobs.

```sql
-- Create a CTE
WITH top_paying_jobs AS (
    SELECT
        job_id,
        job_title,
        salary_year_avg,
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
    LIMIT 10
)
SELECT 
    top_paying_jobs.*,
    skills_dim.skills
FROM top_paying_jobs
-- Join to match job id to skill id
INNER JOIN skills_job_dim
ON skills_job_dim.job_id = top_paying_jobs.job_id
-- Join to match skill id to skill name
INNER JOIN skills_dim
ON skills_job_dim.skill_id = skills_dim.skill_id
ORDER BY
    salary_year_avg DESC;
```
Breakdown of top-paying skills:
- **Skill Popularity:** Among the top 10 highest paying jobs, SQL and Python appear the most followed by Tableau. The bar graph below illustrates the demand for each skill among the highest-paying jobs.
- **Core Technical Stack:** Beyond the four most demanded skills, secondary data manipulation and management skills remain essential. This includes proficiency in libraries (Pandas), spreadsheets (Excel), and cloud data warehouses (Snowflake), underscoring the importance of a well-rounded skillset.
- **Specialized Skills:** Many skills appear only once or twice revealing that focused domain knowledge is a trend among these highest-paid positions.

<div align="center">
  <img src="visualizations/2_top_paying_skills.png" alt="Top-Paying Skills">
</div>

*Bar graph visualizing the skill frequency for the top-10 highest-paying data analyst jobs. I created this visualization using python (pandas and matplotlib)*

### 3. Top-Demanded Skills
I inner joined [skill_job_dim.csv](../csv_files/skills_job_dim.csv) and [skills_dim.csv](../csv_files/skills_dim.csv) to link jobs to their skills. I then used the COUNT function to count the sum total of jobs assocciated with each skill, grouping on skill. To identify the most frequently occuring skills, I sorted the data in descending order, identifying the most relevant skills for data analyst job-seekers to acquire and build upon.

```sql
SELECT
    skills,
    COUNT(skills_job_dim.job_id) AS demand_count
FROM job_postings_fact
INNER JOIN skills_job_dim on job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst' AND
    job_work_from_home = TRUE
GROUP BY 
    skills
ORDER BY
    demand_count DESC
LIMIT 5;
```
Breakdown of top-demanded skills:
- **Programming Proficiency:** Two of the top five most demanded skills for data analysts are related to programming, highlighting the importance of coding skills—particularly in SQL and Python.
- **Spreadsheet Software:** Coming in second for the most in-demand skill is Excel, reflecting the importance of data management skills and showing that Excel is the most widely preferred application for doing so.
- **Visualization Tools:** Tableau and Power BI, which are both data visualization tools are the fourth and fifth highest-demanded skills, reinforcing the importance of not just being able to wrangle data but effectively illustrating why those numbers matter.

|Skills   | Demand Count |
|---------|--------------|
|SQL      | 7291         |
|Excel    | 4611         |
|Python   | 4330         |
|Tableau  | 3745         |
|Power BI | 2609         |

*Table containing the counts of the top-5 demanded skills among data analyst job postings*

### 4. Top-Paying Skills
This question is similar to a mix of questions two and three, likewise, my approach to this was also a mix of my approach to those two. I joined tables to link essential data and for each skill, found the average yearly salaries of the jobs that required that skill. Examining these skills in descending order provides guidance to job-seekers on the most financially rewarding and promising skills to learn, regardless of job location.
```sql
SELECT
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
    skill
ORDER BY
    avg_yearly_salary DESC
LIMIT 25;
```
Breakdown of the top-paying skills:
- **Distributed Computing & Big Data:** PySpark holds the spot for highest-earning skill, revealing that being able to process and analyze large datasets is a common attribute among the highest-compensated roles.
- **Specialized Expertise:** Many of the highest skill-specific average salaries are tied to more focused technologies, like Couchbase for NoSQL databases as well as IBM Watson and DataRobot for machine learning. Compared to widely used analyst frameworks, these specific tools command higher pay due to talent scarcity.
- **Python Ecosystem:** Essential Python libraries like pandas, numpy, and scikit-learn dominate high-paying programming skills, underscoring that statistical programming tools are still core requirements in high-paying positions.

|Top 10 Skills  | Average Salary ($) |Top 20 Skills   | Average Salary ($) |
|---------|--------------|---------|--------------|
|pyspark    | 208,172  |golang	|145,000|
|bitbucket    | 189,155 |numpy	|143,513|
|couchbase|	160,515|databricks	|141,907|
|watson	|160,515|linux	|136,508|
|datarobot	|155,486|kubernetes	|132,500|
|gitlab	|154,500|atlassian	|131,162|
|swift	|153,750|twilio	|127,000|
|jupyter	|152,777|airflow	|126,103|
|pandas	|151,821|scikit-learn	|125,781|
|elasticsearch	|145,000|jenkins	|125,436|

*Table of the top 20 highest earning skills and their average salary for data analysts*
### 5. Optimal Skills
After joining the necessary tables to relate the job to skills I found the number of jobs under each skill (labeled *demand_count*) and the overall average salary for the average annual salaries of those jobs per skill (labeled *avg_yearly_salary*). To find a balance between most sought after skills and skills required for the top-paying jobs, I then filtered the data to skills that have a *demand_count* of at least 10. Finally, I ordered by the *avg_yearly_salary* followed by *demand_count*—both in descending order. 
```sql
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
```
Breakdown of the optimal skills to acquire:
- **Optimal High-Value Skills:** When filtering for a minimum demand count of 11, the highest-earning skills shift noticeably. Go, Confluence, and Hadoop occupy the top three spots, demonstrating strong compensation for specialized tools while accounting for realistic job availability.
- **Cloud & Big Data Infrastructure:** Aligning with the results of querying for the top-paying skills, Snowflake, Azure, and BigQuery reinforce that cloud data infrastructure expertise remains one of the most reliable paths to higher data analyst compensation.
- **Volume vs. Pay Tradeoff:** Skills like Python and Tableau dominate job availability (with 236 and 230 postings respectively) by far, while still mainting six figure average salaries. In contrast, skills like Confluence and BigQuery pay slightly more but only open up only a fraction of total job opportunites (with 11 and 13 postings respectively).

|Skill ID| Skill| Demand Count| Average Salary ($)|
|---|---|---|---|
|8	|go	|27	|115,320
|234	|confluence	|11	|114,210
|97	|hadoop	|22	|113,193
|80	|snowflake	|37	|112,948
|74	|azure	|34	|111,225
|77	|bigquery	|13	|109,654
|76	|aws	|32	|108,317
|4	|java	|17	|106,906
|194	|ssis	|12	|106,683
|233	|jira	|20	|104,918
|79	|oracle	|37	|104,534
|185	|looker	|49	|103,795
|2	|nosql	|13	|101,414
|1	|python	|236	|101,397
|5	|r	|148	|100,499
|78	|redshift	|16	|99,936
|187	|qlik	|13	|99,631
|182	|tableau	|230	|99,288
|197	|ssrs	|14	|99,171
|92	|spark	|13	|99,077
|13	|c++	|11	|98,958
|186	|sas	|63	|98,902

*Table of the top-20 optimal skills for data analysts, including skill ID, demand count, and average salary, sorted by salary*

# Conclusions
1. **Top-Paying Data Analyst Jobs**: The top-paying data analyst roles are specialized senior positions with wide pay range—the highest being $650,000—posted from diverse industries.
2. **Skills for Top-Paying Jobs**: SQL is the most demanded skill among the top-paying postings, indicating that it is a key skill in well-compensated data analyst roles.
3. **Most In-Demand Skills:** SQL remains the most sought after skill when considering the whole data analyst job market.
4. **Skills that Drive Greater Pay:** Specialized skills such as SVN and Solidity hold the top spots for skill-specific salaries, revealing greater compensation due to talent-scarcity.
5. **Skills for Optimal Job Market Value:** Python and Tableau are optimal skills to acquire because they land within the top-20 highest skill-specific salaries while garnering substantially more market demand—with over 200 job postings!

# What I Learned
- **Data Analysis Toolkit:** Built an end-to-end workflow by connecting PostgreSQL VS Code, gaining experience with managing VS Code extensions, environment setup, and query execution within a unified editor.
- **Multi-Table Querying:** Strengthened proficiency in using SQL joins to filter and query relational data across multiple tables for complex analysis.
- **Comprehensive Data Storytelling:** Developed critical analysis skills to translate raw numbers into actionable market insights—connecting metrics like demand count and average salary to help data analyst job-seekers identify high-value skills.
