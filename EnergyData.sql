SELECT TOP (1000) [country]
      ,[year]
      ,[population]
      ,[gdp]
      ,[primary_energy_consumption]
      ,[electricity_generation]
      ,[low_carbon_consumption]
      ,[fossil_fuel_consumption]
      ,[renewables_consumption]
      ,[greenhouse_gas_emissions]
      ,[coal_consumption]
      ,[oil_consumption]
      ,[gas_consumption]
      ,[solar_consumption]
      ,[wind_consumption]
      ,[hydro_consumption]
      ,[nuclear_consumption]
      ,[low_carbon_share_energy]
      ,[fossil_share_energy]
      ,[renewables_share_energy]
  FROM [07Desember2024].[dbo].[EnergyBussiness]


-- OBJECTIVE

-- Mencari tau ttg konsumsi energi (1), perubahan tren (2), dan kontribusi berbagai sumber energi (2)
-- Tujuannya adalah:
-- (1). Memahami pola konsumsi
-- (2). Peluang investasi serta dampak pada bisnis dan lingkungan


-- Data Cleaning --

-- CREATE STAGING TABLE

select *
into EnergyBussiness_staging3
from EnergyBussiness
where 1 = 0;

insert into EnergyBussiness_staging3
select * from EnergyBussiness

select *
from EnergyBussiness_staging3


-- 1. Remove Duplicates

SELECT *
FROM EnergyBussiness_staging3
WHERE ROW_NUMBER() OVER (
    PARTITION BY country, year, population, gdp, primary_energy_consumption, 
                 electricity_generation, low_carbon_consumption, fossil_fuel_consumption, 
                 renewables_consumption, greenhouse_gas_emissions, coal_consumption, oil_consumption,
				 gas_consumption, solar_consumption, wind_consumption, hydro_consumption, nuclear_consumption,
				 low_carbon_share_energy, fossil_share_energy, renewables_share_energy
    ORDER BY year DESC
) > 1;

WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY country, year, population, gdp, primary_energy_consumption, 
                 electricity_generation, low_carbon_consumption, fossil_fuel_consumption, 
                 renewables_consumption, greenhouse_gas_emissions, coal_consumption, oil_consumption,
				 gas_consumption, solar_consumption, wind_consumption, hydro_consumption, nuclear_consumption,
				 low_carbon_share_energy, fossil_share_energy, renewables_share_energy
               ORDER BY year DESC
           ) AS row_num
    FROM EnergyBussiness_staging3
)
SELECT *
FROM CTE
WHERE row_num > 1;


SELECT COUNT(*) AS TotalRows,
       COUNT(DISTINCT CONCAT(country, year, population, gdp, primary_energy_consumption, 
                 electricity_generation, low_carbon_consumption, fossil_fuel_consumption, 
                 renewables_consumption, greenhouse_gas_emissions, coal_consumption, oil_consumption,
				 gas_consumption, solar_consumption, wind_consumption, hydro_consumption, nuclear_consumption,
				 low_carbon_share_energy, fossil_share_energy, renewables_share_energy)) AS UniqueRows
FROM EnergyBussiness_staging3;



-- 2. Standardize Data

-- all the data is already standarized




-- 3. Look at Null Values

-- let them null because it makes it easier for calculations during the EDA phase



-- 4. Remove any columns and rows we need to

-- all the columns and rows there are all we need





-- Exploratory Data Analysis (EDA)

-- 1. Understand to a Data Distribution

select top 100 *
from EnergyBussiness_staging3

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'EnergyBussiness_staging3' AND COLUMN_NAME = 'gdp';



SELECT *
FROM EnergyBussiness_staging3
WHERE ISNUMERIC(population) = 0
OR ISNUMERIC(gdp) = 0;


UPDATE EnergyBussiness_staging3
SET gdp = REPLACE(gdp, '.', '');


-- Summary of Statistics

SELECT 
    MIN(CAST(population AS BIGINT)) AS Min_Population,
    MAX(CAST(population AS BIGINT)) AS Max_Population,
    AVG(CAST(population AS FLOAT)) AS Avg_Population,
    MIN(CAST(gdp AS FLOAT)) AS Min_GDP,
    MAX(CAST(gdp AS FLOAT)) AS Max_GDP,
    AVG(CAST(gdp AS FLOAT)) AS Avg_GDP
FROM EnergyBussiness_staging3;


UPDATE EnergyBussiness_staging3
SET primary_energy_consumption = REPLACE(primary_energy_consumption, '.', '');


-- Energy Consumption Distribution

SELECT
    MIN(CAST(primary_energy_consumption AS FLOAT)) AS Min_Energy,
    MAX(CAST(primary_energy_consumption AS FLOAT)) AS Max_Energy,
    AVG(CAST(primary_energy_consumption AS FLOAT)) AS Avg_Energy
FROM EnergyBussiness_staging3;



-- 2. Checking Annual Trends

UPDATE EnergyBussiness_staging3
SET primary_energy_consumption = REPLACE(primary_energy_consumption, '.', ''),
    greenhouse_gas_emissions = REPLACE(greenhouse_gas_emissions, '.', '');

ALTER TABLE EnergyBussiness_staging3
ALTER COLUMN primary_energy_consumption FLOAT;

ALTER TABLE EnergyBussiness_staging3
ALTER COLUMN greenhouse_gas_emissions FLOAT;


-- Total Energy Consumption

SELECT 
    year,
    SUM(primary_energy_consumption) AS Total_Energy_Consumption
FROM EnergyBussiness_staging3
GROUP BY year
ORDER BY year;


-- Greenhouse Gas Emissions

SELECT 
    year,
    SUM(greenhouse_gas_emissions) AS Total_Greenhouse_Gas_Emissions
FROM EnergyBussiness_staging3
GROUP BY year
ORDER BY year;



-- 3. Energy Share Analysis

-- we are going to analyzing the proportion of energy consumption from various sources such as fossil fuels and low-carbon energy

UPDATE EnergyBussiness_staging3
SET low_carbon_consumption = REPLACE(low_carbon_consumption, '.', ''),
    fossil_fuel_consumption = REPLACE(fossil_fuel_consumption, '.', '');

ALTER TABLE EnergyBussiness_staging3
ALTER COLUMN low_carbon_consumption FLOAT;

ALTER TABLE EnergyBussiness_staging3
ALTER COLUMN fossil_fuel_consumption FLOAT;


-- Low Carbon vs Fossil Energy Consumption

SELECT 
    year,
    SUM(low_carbon_consumption) AS Low_Carbon_Consumption,
	SUM(fossil_fuel_consumption) AS Fossil_Fuel_Consumption
FROM EnergyBussiness_staging3
GROUP BY year
ORDER BY year;



UPDATE EnergyBussiness_staging3
SET low_carbon_share_energy = REPLACE(low_carbon_share_energy, '.', ''),
    fossil_share_energy = REPLACE(fossil_share_energy, '.', ''),
	renewables_share_energy = REPLACE(renewables_share_energy, '.', '');

ALTER TABLE EnergyBussiness_staging3
ALTER COLUMN low_carbon_share_energy FLOAT;

ALTER TABLE EnergyBussiness_staging3
ALTER COLUMN fossil_share_energy FLOAT;

ALTER TABLE EnergyBussiness_staging3
ALTER COLUMN renewables_share_energy FLOAT;


-- Share of Energy from Various Sources

-- we are going to assessing the contribution of different energy sources (e.g., solar, wind, nuclear) to overall energy consumption

SELECT 
    country,
    AVG(low_carbon_share_energy) AS Avg_Low_Carbon_Share,
	AVG(fossil_share_energy) AS Avg_Fossil_Share,
	AVG (renewables_share_energy) AS Avg_Renewables_Share
FROM EnergyBussiness_staging3
GROUP BY country
ORDER BY Avg_Low_Carbon_Share DESC;



-- 4. Energy Consumption Mapping by Country

UPDATE EnergyBussiness_staging3
SET coal_consumption = REPLACE(coal_consumption, '.', ''),
    oil_consumption = REPLACE(oil_consumption, '.', ''),
	gas_consumption = REPLACE(gas_consumption, '.', ''),
	solar_consumption = REPLACE(solar_consumption, '.', ''),
	wind_consumption = REPLACE(wind_consumption, '.', ''),
	hydro_consumption = REPLACE(hydro_consumption, '.', ''),
	nuclear_consumption = REPLACE(nuclear_consumption, '.', '');

ALTER TABLE EnergyBussiness_staging3
ALTER COLUMN coal_consumption FLOAT;

ALTER TABLE EnergyBussiness_staging3
ALTER COLUMN oil_consumption FLOAT;

ALTER TABLE EnergyBussiness_staging3
ALTER COLUMN gas_consumption FLOAT;

ALTER TABLE EnergyBussiness_staging3
ALTER COLUMN solar_consumption FLOAT;

ALTER TABLE EnergyBussiness_staging3
ALTER COLUMN wind_consumption FLOAT;

ALTER TABLE EnergyBussiness_staging3
ALTER COLUMN hydro_consumption FLOAT;

ALTER TABLE EnergyBussiness_staging3
ALTER COLUMN nuclear_consumption FLOAT;


-- Consumption Based on Energy Source

SELECT 
    country,
    SUM(coal_consumption) AS Coal_Consumption,
    SUM(oil_consumption) AS Oil_Consumption,
    SUM(gas_consumption) AS Gas_Consumption,
    SUM(solar_consumption) AS Solar_Consumption,
    SUM(wind_consumption) AS Wind_Consumption,
    SUM(hydro_consumption) AS Hydro_Consumption,
    SUM(nuclear_consumption) AS Nuclear_Consumption
FROM EnergyBussiness_staging3
GROUP BY country
ORDER BY Coal_Consumption DESC;



-- 5. Finding Anomalies or Outliers

-- we are going to identifying data points that deviate significantly from expected patterns to investigate potential errors or unique cases



-- Unreasonable Energy Consumption

-- we highlighting instances of energy usage that seem unusually high or low compared to norms or benchmarks

SELECT *
FROM EnergyBussiness_staging3
WHERE primary_energy_consumption > (
    SELECT AVG(primary_energy_consumption) + 3 * STDEV(primary_energy_consumption)
    FROM EnergyBussiness_staging3
);

-- Low Energy Consumption

-- it focusing on cases with minimal energy consumption to study inefficiencies or limitations in energy access

SELECT *
FROM EnergyBussiness_staging3
WHERE primary_energy_consumption < (
    SELECT AVG(primary_energy_consumption) - 3 * STDEV(primary_energy_consumption)
    FROM EnergyBussiness_staging3
);


select top 1000 *
from EnergyBussiness_staging3
order by 2 desc, 5 desc




