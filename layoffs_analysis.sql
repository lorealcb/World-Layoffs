# Exploratory Data Analysis
# 11 March 2020 to 03 November 2024

SELECT *
FROM layoffs_staging2;

# MAX total_laid_off = 15000, MAX percentage_laid_off = 1.0
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

# Company Layoffs
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC

#Check date range. Covid is a factor in the for the time range)
# MIN 2020-03-11  MAX 2024-11-03
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

# Industry Layoffs
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC

# Country layoffs
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC

# Date of layoffs grouped by year
SELECT YEAR( `date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC

# Stage of layoffs
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC

# Progression of layoff, world wide rolling total layoffs, by month
SELECT *
FROM layoffs_staging2;

SELECT SUBSTRING(`date`, 1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
GROUP BY  `MONTH`
ORDER BY 1 ASC;

WITH Rolling_Total AS 
(
SELECT SUBSTRING(`date`, 1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
GROUP BY  `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off,
 SUM(total_off) OVER(ORDER BY `MONTH`) as rolling_total
FROM Rolling_Total;

# Company layoff by year
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC

SELECT company,`date`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, `date`

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY company ASC;

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

# Multiple CTEs to Rank the top 5 Companys in terms of total layoffs

WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <=5
;

