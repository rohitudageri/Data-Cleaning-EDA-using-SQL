SELECT * FROM campusx.laptop;

-- Renaming
ALTER TABLE laptop RENAME COLUMN `Unnamed: 0` TO `index` ;

# 1) Creating Backup
CREATE TABLE laptop_backup LIKE laptop;

INSERT INTO laptop_backup
SELECT * FROM laptop;

# 2) Number of Rows
SELECT COUNT(*) FROM laptop;

# 3) Checking Memory
SELECT DATA_LENGTH/1024 FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'campusx'
AND TABLE_NAME = 'laptop';

# 4) DROPPING The Non-Important Columns

# 5) DROPPING the Null Values
SELECT * FROM laptop
WHERE company IS NULL AND Typename IS NULL AND Inches IS NULL AND screenresolution IS NULL 
AND `Cpu` IS NULL AND Ram IS NULL AND 
Memory IS NULL AND GPU IS NULL AND OPSys IS NULL AND Weight IS NULL AND price IS NULL;

SELECT COUNT(*) FROM laptop;

# 6) DROP Duplicates

# 7) Cleaning RAM (Changing Columns DataType)

-- Finding Unique values
SELECT DISTINCT(typename) FROM laptop;

-- Changing Datatype of inches column
ALTER TABLE laptop MODIFY COLUMN inches DECIMAL(10,2);

-- Ram Column 
UPDATE laptop l1
JOIN (SELECT `index`, REPLACE(Ram, 'GB', '') as new_Ram FROM laptop) l2
ON l1.`index` = l2.`index`
SET l1.Ram = l2.new_Ram;

ALTER TABLE laptop MODIFY COLUMN Ram INTEGER;

-- Weight Column
UPDATE laptop l1
JOIN (SELECT `index`, REPLACE(Weight, 'kg', '') as new_weight FROM laptop) l2
ON l1.`index` = l2.`index`
SET l1.Weight = l2.new_weight;

-- Opsys Column

SELECT DISTINCT(opsys) FROM laptop;
-- mac
-- windows
-- linux
-- no os
-- Android chrome(others)

UPDATE laptop
SET  opsys = 
CASE
	WHEN opsys LIKE '%mac%' THEN 'macos'
    WHEN opsys LIKE 'Windows%' THEN 'windows'
    WHEN opsys LIKE '%LINUX%'THEN 'linux'
    WHEN opsys = 'NO os' THEN 'N/A'
    ELSE 'Other'
END ;   

#GPU Column

SELECT DISTINCT(GPU) FROM laptop;

-- seperating gpu_name and gpu_brand from gpu column
ALTER TABLE laptop
ADD COLUMN gpu_name VARCHAR(255) AFTER GPU,
ADD COLUMN gpu_brand VARCHAR(255) AFTER gpu_name;

-- updating brand name
UPDATE laptop l1
JOIN (SELECT `index`, SUBSTRING_INDEX(GPU, ' ', 1) as gpu_brand_extracted FROM laptop) l2
ON l1.`index` = l2.`index`
SET l1.gpu_brand = l2.gpu_brand_extracted;

-- updating gpu_name
UPDATE laptop l1
JOIN (SELECT `index`, REPLACE(GPU,gpu_brand,' ' ) as gpu_name_extracted FROM laptop) l2
ON l1.`index` = l2.`index`
SET l1.gpu_name = l2.gpu_name_extracted;

-- Dropping the GPU column
ALTER TABLE laptop DROP COLUMN GPU ;

SELECT * FROM laptop;

# CPU column
-- checking distinct values
SELECT DISTINCT(CPU) FROM laptop;

-- creating new columns
ALTER TABLE laptop
ADD COLUMN cpu_name VARCHAR(255) AFTER CPU,
ADD COLUMN cpu_brand VARCHAR(255) AFTER cpu_name,
ADD COLUMN cpu_speed DECIMAL(10,2) AFTER cpu_brand;

-- Cpu_brand
UPDATE laptop l1
JOIN (SELECT `index`,substring_index(CPU,' ',1) as cpu_brand_extracted FROM laptop )l2
ON l1.`index` = l2.`index`
SET l1.cpu_brand = l2.cpu_brand_extracted;

-- cpu_speed
UPDATE laptop l1
JOIN(SELECT `index`,CAST(REPLACE(SUBSTRING_INDEX(CPU,' ',-1),'GHz','')AS DECIMAL(10,2))as cpu_speed_extracted FROM laptop) l2
ON l1.`index` = l2.`index`
SET l1.cpu_speed = l2.cpu_speed_extracted;

-- cpu name
UPDATE laptop l1
JOIN(SELECT `index`,REPLACE(REPLACE(Cpu,cpu_brand,''),
			SUBSTRING_INDEX(REPLACE(Cpu,cpu_brand,''),' ',-1),'') as cpu_name_extracted
FROM laptop ) l2
ON l1.`index` = l2.`index`
SET l1.cpu_name = l2.cpu_name_extracted;

UPDATE laptop
SET cpu_name =  SUBSTRING_INDEX(TRIM(cpu_name),' ',2);

ALTER TABLE laptop DROP COLUMN CPU;


# Screen Resolution column
-- We willl create 3 new columns 
-- resolution_height ,resolution_width , touchscreen

ALTER TABLE laptop
ADD COLUMN resolution_width  VARCHAR(255) AFTER ScreenResolution,
ADD COLUMN resolution_height VARCHAR(255) AFTER resolution_width ;

UPDATE laptop
SET resolution_width = SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',1) ,
resolution_height = SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',-1) ;

ALTER TABLE laptop
ADD COLUMN touchscreen INTEGER AFTER resolution_height;

UPDATE laptop
SET touchscreen = ScreenResolution LIKE '%Touch%';

ALTER TABLE laptop DROP COLUMN screenresolution;


# Memory Column
-- Memory_type,primary_storage,secondary_storage

ALTER TABLE laptop
ADD COLUMN memory_type VARCHAR(255) AFTER Memory,
ADD COLUMN primary_storage INTEGER AFTER memory_type,
ADD COLUMN secondary_storage INTEGER AFTER primary_storage;

-- memory_type
UPDATE laptop
SET memory_type =
CASE 
	WHEN memory LIKE '%SSD%' and memory LIKE '%HDD%' THEN 'Hybrid'
    WHEN memory LIKE '%HDD%' THEN 'HDD'
    WHEN memory LIKE '%SSD%' THEN 'SSD'
    WHEN memory LIKE '%Flash Storage%' THEN 'Flash Storage'
    WHEN memory LIKE '%Hybrid%' THEN 'Hybrid'
    WHEN memory LIKE '%Flash Storage%' and memory LIKE '%HDD%' THEN 'Hybrid'
    ELSE NULL
END ;

-- primary_storage & secondary_storage

UPDATE laptop
SET primary_storage = REGEXP_SUBSTR(SUBSTRING_INDEX(memory,' ',1),'[0-9]+'),
secondary_storage = CASE WHEN memory LIKE '%+%' THEN REGEXP_SUBSTR(SUBSTRING_INDEX(memory,'+',-1),'[0-9]+') ELSE 0 END ;

-- 

UPDATE laptop
SET primary_storage = CASE WHEN primary_storage <= 2 THEN primary_storage*1024 ELSE primary_storage END,
secondary_storage = CASE WHEN secondary_storage <= 2 THEN secondary_storage*1024 ELSE secondary_storage END;

ALTER TABLE laptop DROP COLUMN gpu_name;

SELECT * FROM laptop;
ALTER TABLE laptop DROP COLUMN Memory;