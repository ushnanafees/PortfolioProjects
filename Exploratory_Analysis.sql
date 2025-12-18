-- Exploratory Analysis

USE world_laysoff;

Select MAX(total_laid_off), MAX(percentage_laid_off) From layoffs_staging2;

Select * From layoffs_staging2
Where percentage_laid_off = 1;

Select * From layoffs_staging2
Where Company = 'Google';

Select Company , Sum(total_laid_off) 
From layoffs_staging2
Group by Company
Order by 2 Desc;

Select industry , Sum(total_laid_off) 
From layoffs_staging2
Group by industry
Order by 2 Desc;

Select country , Sum(total_laid_off) 
From layoffs_staging2
Group by country
Order by 2 Desc;

Select `date` , SUM(total_laid_off) 
From layoffs_staging2
Group by `date`
Order by 2 Desc;

Select YEAR(`date`) , SUM(total_laid_off) 
From layoffs_staging2
Group by YEAR(`date`)
Order by 1 Desc;

Select MONTH(`date`) , SUM(total_laid_off) 
From layoffs_staging2
Group by MONTH(`date`)
Order by 1 Desc;

WITH Rolling_total AS
( Select SUBSTRING(`date`,1,7) As `Month`, SUM(total_laid_off) As total_off
From layoffs_staging2
Where SUBSTRING(`date`,1,7) IS NOT NULL
Group by `Month`
Order by 1 ASC )
Select `Month`, total_off, SUM(total_off) OVER(ORDER By `Month`) As rolling_total
From Rolling_total ;

select `date` from layoffs_staging2;

Select Company, YEAR(`date`), Sum(total_laid_off) 
From layoffs_staging2
Group by Company, YEAR(`date`)
Order by 3 DESC;

WITH company_year(company,years,laid_off) AS (
Select Company, YEAR(`date`), Sum(total_laid_off) 
From layoffs_staging2
Group by Company, YEAR(`date`)
), Company_Year_Rank AS 
(Select *, dense_rank() OVER(PARTITION BY years ORDER BY laid_off DESC) AS Ranking
From company_year
Where years is not null)
Select * From Company_Year_Rank
Where Ranking <=5;