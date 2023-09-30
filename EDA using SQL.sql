SELECT * FROM laptop;

# 1) Head,Tail , sample

SELECT * FROM laptop ORDER BY `index` LIMIT 5;
SELECT * FROM laptop ORDER BY `index` DESC LIMIT 5;
SELECT * FROM laptop ORDER BY rand() LIMIT 5;

#2) missing value

SELECT COUNT(Price) FROM laptop WHERE Price IS NULL;

#3) Creating a histogram

SELECT t.buckets,REPEAT('*',COUNT(*)/5) FROM (SELECT price, 
CASE 
	WHEN price BETWEEN 0 AND 25000 THEN '0-25K'
    WHEN price BETWEEN 25001 AND 50000 THEN '25K-50K'
    WHEN price BETWEEN 50001 AND 75000 THEN '50K-75K'
    WHEN price BETWEEN 75001 AND 100000 THEN '75K-100K'
	ELSE '>100K'
END AS 'buckets'
FROM laptop) t
GROUP BY t.buckets;


#4) Categorical column (univariate)
SELECT Company,COUNT(Company) FROM laptop
GROUP BY Company;


#5) Contengency Table
SELECT Company,
SUM(CASE WHEN Touchscreen = 1 THEN 1 ELSE 0 END) AS 'Touchscreen_yes',
SUM(CASE WHEN Touchscreen = 0 THEN 1 ELSE 0 END) AS 'Touchscreen_no'
FROM laptop
GROUP BY Company;


SELECT Company,
SUM(CASE WHEN cpu_brand = 'Intel' THEN 1 ELSE 0 END) AS 'Intel',
SUM(CASE WHEN cpu_brand ='Amd' THEN 1 ELSE 0 END) AS 'amd',
SUM(CASE WHEN cpu_brand ='samsung' THEN 1 ELSE 0 END) AS 'samsung'
FROM laptop
GROUP BY Company;

#6) Categorical Numerical Bivariavte Analysis

SELECT company ,MIN(Price),Max(Price),Avg(Price)
FROM laptop
GROUP BY company;

#7) missing values treatement
-- Replaing missing values with mean of price
-- Replacing missing values with price of corressponding company

#8) Feature Engineering

-- calucating ppi(pixel per inch) 

SELECT ROUND(SQRT(resolution_width*resolution_width + resolution_height*resolution_height)/Inches)
FROM laptop;

ALTER TABLE laptop ADD COLUMN ppi INTEGER;

UPDATE laptop
SET ppi = ROUND(SQRT(resolution_width*resolution_width + resolution_height*resolution_height)/Inches);

#9) One hot Encoding
SELECT cpu_brand,
CASE WHEN cpu_brand = 'Intel' THEN 1 ELSE 0 END as 'Intel',
CASE WHEN cpu_brand = 'AMD' THEN 1 ELSE 0 END as 'AMD',
CASE WHEN cpu_brand = 'Nvidia' THEN 1 ELSE 0 END as 'Nvidia'
FROM laptop