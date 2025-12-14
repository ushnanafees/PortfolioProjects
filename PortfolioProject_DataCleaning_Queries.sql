-- Dataset https://www.kaggle.com/datasets/swaptr/layoffs-2022

-- Data Cleaning
# 1- Remove Duplicates (with CTE)
# 2- Standarized the data (Finding issues in data)
# 3- Null values or blank values handle
# 4- Remove Any columns

# to use the database
USE world_laysoff;

Select * From layoffs;

-- 1- Remove Duplicates (with CTE)
# Create a copy of table layoffs
CREATE TABLE layoffs_staging LIKE layoffs;

# Insert All data from layoffs table to layoffs_staging table
INSERT layoffs_staging SELECT * FROM layoffs;

Select * From layoffs_staging;

# This query to check the duplicate rows in table
 WITH duplicate_cte AS (
 Select *,
ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off, `date`, stage,
country, funds_raised_millions) AS row_num
From layoffs_staging
 )
 Select * From duplicate_cte Where row_num > 1;
 
 # Query to check if inside duplicate data
 Select * From layoffs_staging
 where company = 'Casper';
 
# Query to delete duplicate rows from cte. We need to create one more table
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

Select * From layoffs_staging2;

#Insert CTE data in one more table to delete duplicates
INSERT INTO layoffs_staging2
Select *,
ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off, `date`, stage,
country, funds_raised_millions) AS row_num
From layoffs_staging;

# delete duplicates from layoffs_staging2 table
Delete From layoffs_staging2  Where row_num > 1;

-- 2- Standarized the data (Finding issues in data)

#Trim function remove extra whitespaces from start and end to column company
Select company, TRIM(company) from layoffs_staging2;

# update company column to trimmed column without whitespaces from start and end
UPDATE layoffs_staging2
SET company = TRIM(company);

#Trim function remove extra whitespaces from start and end to column location then update column
Select industry, TRIM(industry) From layoffs_staging2;
UPDATE layoffs_staging2
SET industry = TRIM(industry);

#Trim function remove extra whitespaces from start and end to column location then update column
Select location, TRIM(location) From layoffs_staging2;
UPDATE layoffs_staging2
SET location = TRIM(location);

# Check industry column have synonym names Crypto, CryptoCurrency make all same name
Select DISTINCT industry From layoffs_staging2 ORDER BY 1;

Select * From layoffs_staging2 where industry Like 'Crypto%';

Update layoffs_staging2
Set industry = 'Crypto'
Where industry Like 'Crypto%';

Select Distinct country From layoffs_staging2 order by 1;

# Check data in country column her united states data need to update
Select * From layoffs_staging2 where country Like 'United States.%';

# TRAILING remove . in the end
Select country, TRIM(TRAILING "." FROM country) 
from layoffs_staging2 order by 1;

Update layoffs_staging2
set country = TRIM(TRAILING "." FROM country) 
where country Like 'United States.%';

# convert date column datatype from text to date and update in table
SELECT `date`,
str_to_date(`date`, '%m/%d/%Y')
From layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y');

#still the datatype of date is text in next step we gonna alter datatype
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- 3- Null values or blank values handle

# Work on industry column to check any null or empty values
SELECT *
From layoffs_staging2
Where industry IS NULL OR industry = '';

# first convert all values to null so join can work
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

# apply inner join to update same values as per the industry
SELECT t1.industry,t2.industry 
FROM layoffs_staging2 t1
	JOIN layoffs_staging2 t2
	ON t1.company = t2.company 
WHERE t1.industry IS NULL
OR t2.industry IS NOT NULL;

#update statement 
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company 
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT *
From layoffs_staging2
Where industry IS NULL OR industry = '';

SELECT *
From layoffs_staging2
Where company = 'Airbnb';

DELETE From layoffs_staging2
Where total_laid_off IS NULL OR percentage_laid_off IS NULL;

-- 4- Remove Any columns
# We don't need more row_num column
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
