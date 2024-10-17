-- Exploratory Data Analysis 

SELECT * 
FROM layoffs_staging2; 

-- highest no./percentage of layoffs

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

SELECT * 
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC; 

-- date range of layoffs 

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2; 

-- total number of layoffs by each company 
-- 2 represents column no.2

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC; 

-- total number of layoffs by industry  

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC; 

-- total number of layoffs by country   

SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC; 

-- total number of layoffs by year 

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC; 

-- total number of layoffs by stage   

SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC; 

-- rolling total of layoffs by month,year 

SELECT SUBSTRING(`date`, 1, 7) AS `month`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL 
GROUP BY `month`
ORDER BY 1 ASC; 

WITH Rolling_Total AS
	(
SELECT SUBSTRING(`date`, 1, 7) AS `month`, SUM(total_laid_off) AS total_off 
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL 
GROUP BY `month`
ORDER BY 1 ASC
	) 
SELECT `month`, total_off ,
SUM(total_off) OVER(ORDER BY `month`) AS rolling_total 
FROM Rolling_Total; 

-- total layoffs by company per year 

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC; 

-- identifying year with highest total layoffs per company 

WITH Company_Year (company, years, total_laid_off) AS
	(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
	) 
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year 
WHERE years IS NOT NULL
ORDER BY Ranking ASC; 

-- identifying top 5 companies with highest total layoffs per year 

WITH Company_Year (company, years, total_laid_off) AS
	(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
	), Company_Year_Rank AS
    (
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year 
WHERE years IS NOT NULL 
	)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5; 
