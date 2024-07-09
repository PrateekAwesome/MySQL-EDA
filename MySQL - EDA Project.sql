-- Exploratory Data Analysis 

SELECT * 
FROM layoffs_staging2 ; 

SELECT MAX(total_laid_off) , MAX(percentage_laid_off)
FROM layoffs_staging2 ; 

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1 -- Percentage Laid off = 1 means whole company was laid off
ORDER BY total_laid_off DESC ; 

select *
from layoffs_staging2 
where percentage_laid_off = 1
order by funds_raised desc ; 

-- Which company has most laid offs 
SELECT company , SUM(total_laid_off)
from layoffs_staging2
group by company 
order by 2 desc ; 

-- From where to where do this data belongs 
SELECT MIN(`date`) , MAX(`date`) 
FROM layoffs_staging2 ; 

-- What industry has most laid off 
SELECT industry , SUM(total_laid_off)
from layoffs_staging2
group by industry  
order by 2 desc ; 
-- Looks like consumer and retail industry has most laid offs , which is understandable 
-- Jobs close down , then selling and buying of things decreases so they are laid offed 

-- Which Country is most affected by laid off 
SELECT country , SUM(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc ; 
-- United States is affected most by laid offs

-- Most Recent Laid offs 
SELECT `date` , SUM(total_laid_off)
from layoffs_staging2
group by `date`
order by 1 desc ; 

-- yearwise laid off
SELECT Year(`date`) , SUM(total_laid_off)
from layoffs_staging2
group by Year(`date`)
order by 1 desc ; 
-- this shows 2023 has very very high laid offs 

-- Laid Offs accourding to the stage of the company 
SELECT stage , SUM(total_laid_off)
from layoffs_staging2
group by stage
order by 2 desc ; 
-- Large companies post ipos have most laid offs 

-- Now analyzing with respect to percentage_laid_off - Although its not give us much reallisations , so just a few statements 
-- Companies having highest Avg Percentage Laid off

SELECT company , avg(percentage_laid_off)
from layoffs_staging2
group by company 
order by 2 desc ;




-- Progression of Layoffs , Rolling total layoffs
-- If do it on day , there will not be too many rows , month is good 

-- Pulling out month wise laid offs

SELECT SUBSTRING(`date`,1,7) as 'MONTH' , SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) is NOT NULL 
GROUP BY SUBSTRING(`date`,1,7)
ORDER BY SUBSTRING(`date`,1,7)
;
-- Error Code: 1055. Expression #1 of SELECT list is not in GROUP BY clause and contains nonaggregated column 'world_layoffs.layoffs_staging2.date' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by

-- Calculating rolling Sum 
WITH Rolling_Total as 
(
SELECT SUBSTRING(`date`,1,7) as 'Month' , SUM(total_laid_off) as Total_Off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) is NOT NULL 
GROUP BY SUBSTRING(`date`,1,7)
ORDER BY 1 ASC
)
SELECT `Month` ,total_off , 
 SUM(Total_Off) OVER(ORDER BY `Month`) as rolling_total 
from Rolling_Total;

-- Making total_off with rolling_total makes it visually better

-- A single company may have laid off multiple people in different years - Collecting data for that
SELECT company,YEAR(`date`) , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 desc ;

-- Who laid off most in that Year ? Getting Data for this 
WITH Company_Year (company , years , total_laid_offs) AS 
(
SELECT company,YEAR(`date`) , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)

)
SELECT * , DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_offs DESC  ) as Ranking 
FROM Company_Year
WHERE years IS NOT NULL
ORDER BY Ranking ASC ;

-- Year by Year Snapshot , top 5 per year , with Year wise ranking
WITH Company_Year (company , years , total_laid_offs) AS 
(
SELECT company,YEAR(`date`) , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
) , Company_Year_Rank AS 
(
SELECT * , DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_offs DESC  ) as Ranking 
FROM Company_Year
WHERE years IS NOT NULL
-- Unique Query indeed !! CTE made from another CTE 
)
SELECT *
FROM Company_Year_Rank 
WHERE Ranking  <= 5;

-- Summary : Exploratory Data Analysis
-- Total Laid offs w.r.t company , industry , country 
-- Starting and Ending Date
-- Most Recent Laid off 
-- Datewise and Yearwise Laid Off
-- Rolling Total 
-- Yearwise Maximum 5 laidoffs in compinies 