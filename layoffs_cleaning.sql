# Dataset https://www.kaggle.com/datasets/swaptr/layoffs-2022?resource=download
# Layoffs Dataset
# Tech layoffs from COVID 2019 to present





SELECT *
FROM world_layoffs.layoffs;

-- Data Cleaning
SET SQL_SAFE_UPDATES = 0; # Necessary to update or delete records


SELECT *
FROM world_layoffs.layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or blank values
-- 4. Remove Any Columns

-- Create a copy of the raw table called staging
CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *      
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM world_layoffs.layoffs;

-- Remove Duplicates
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;
 -- This code will go into a CTE--


-- CTE
WITH duplicate_cte AS 
(
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

SELECT *
FROM layoffs_staging
WHERE company = 'Oda'; # Similar data but not a duplicate

SELECT *
FROM layoffs_staging
WHERE company = 'Cazoo';  # Duplicate rows


## Creating a copy table with new column row_num to filter out duplicates where the value of row_num > 1
DROP TABLE IF EXISTS `layoffs_staging2`
 
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` text,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` text,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * 
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised) AS row_num
FROM layoffs_staging;

# View copy table 
SELECT * 
FROM layoffs_staging2;

# View the new copy table with condition that row_num > 1, these will be deleted.
SELECT * 
FROM layoffs_staging2
WHERE row_num >1 ;   

DELETE
FROM layoffs_staging2
WHERE row_num >1;  

SELECT * 
FROM layoffs_staging2;

-- Standardizing data
-- Using TRIM to remove unnecessary spaces--
-- company column edit
SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- industry column edits not necessary
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

-- location column edits not necessary
SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1;

-- country column UAE and United Arab Emirates are the same
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE country = 'UAE' OR country ='United Arab Emirates'

-- Update UAE into United Arab Emirates
UPDATE layoffs_staging2
SET country = 'United Arab Emirates'
WHERE country ='UAE';

-- Convert date column from text to date us STR_TO_DATE
SELECT `date`
FROM layoffs_staging2;

SELECT `date`,
STR_TO_DATE(`date`, "%Y-%m-%d")
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, "%Y-%m-%d");

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

## Additional Data type changes
-- total_laid _off and funds_raised_milions data types convert to INT
-- Convert total_laid _off column to INT
SELECT total_laid_off,
CAST(NULLIF(total_laid_off, '')AS UNSIGNED)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET total_laid_off = CAST(NULLIF(total_laid_off, '')AS UNSIGNED)

ALTER TABLE layoffs_staging2
MODIFY COLUMN total_laid_off INT;

SELECT *
FROM layoffs_staging2

-- Convert funds_raised_millions column to INT

SELECT funds_raised_millions,
CAST(NULLIF(funds_raised_millions, '') AS DECIMAL(10,0))
FROM layoffs_staging2;


UPDATE layoffs_staging2
SET funds_raised_millions = CAST(NULLIF(funds_raised_millions, '') AS DECIMAL(10,0))

SELECT funds_raised_millions,
CAST(NULLIF(funds_raised_millions, '') AS UNSIGNED INTEGER)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET funds_raised_millions = CAST(NULLIF(funds_raised_millions, '') AS UNSIGNED INTEGER)

ALTER TABLE layoffs_staging2
MODIFY COLUMN funds_raised_millions INT;



# Make percentage_laid_off column NULLABLE
SELECT percentage_laid_off
FROM layoffs_staging2;

SELECT percentage_laid_off,
CAST(NULLIF(percentage_laid_off, '') AS CHAR)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET percentage_laid_off = CAST(NULLIF(percentage_laid_off, '') AS CHAR)

## NULL and Blank values

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off IS NULL;


# Finding Blanks in industry column
SELECT DISTINCT industry
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE industry = '';

SELECT *
FROM layoffs_staging2
WHERE company= 'Appsmith';

# Appsmith is mostly related to Other for industry. Update industry.
SELECT *
FROM layoffs_staging2
WHERE industry = 'other';

UPDATE layoffs_staging2
SET industry = 'Other'
WHERE company = 'Appsmith';

SELECT *
FROM layoffs_staging2;



# Deleting unneccessary, untrustworthy data. 
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;



SELECT *
FROM layoffs_staging2;

# DROP row_num column from the table
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2;


