/*
Covid 19 Data Exploration 
Skills used: 
    Joins, 
    CTE's, 
    Windows Functions, 
    Aggregate Functions, 
    Converting Data Types
*/

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT 
    location
    , calendardate AS "DATE"
    , ROUND(((total_deaths/total_cases) * 100),2) AS "FATALITY_RATE(%)"
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY location, calendardate;

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
-- Including option to specify a single country(location)
SELECT 
    location
    , calendardate AS "DATE"
    , ROUND(((total_cases/population) * 100),2) AS "INFECTION_RATE(%)"
FROM coviddeaths
WHERE continent IS NOT NULL
--AND location LIKE '%states%'
ORDER BY 1,2;

-- Countries with Highest Infection Rate compared to Population
SELECT
    location
    , TO_CHAR(population,'999G999G999G999') AS population
    , TO_CHAR(MAX(total_cases),'999G999G999G999') AS total_cases
    , ROUND(((MAX(total_cases)/population)*100),2) AS "HIGHEST_INFECTION_RATE(%)"
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY location;

-- Countries with Highest Death Count per Population
SELECT
    location
    , TO_CHAR(population,'999G999G999G999') AS population
    , TO_CHAR(MAX(total_deaths),'999G999G999G999') AS total_deaths
    , ROUND(((MAX(total_deaths)/population)*100),2) AS "HIGHEST_INFECTION_RATE(%)"
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY location;


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population
SELECT
    location
    , TO_CHAR(MAX(population),'999G999G999G999') AS population
    , TO_CHAR(MAX(total_deaths),'999G999G999G999') AS total_deaths
    , ROUND(((MAX(total_deaths)/MAX(population))*100),2) AS "CONTINENTAL_FATALITY_RATE(%)"
FROM coviddeaths
WHERE location IN (SELECT DISTINCT continent FROM coviddeaths)
AND continent IS NULL
GROUP BY location;


-- GLOBAL NUMBERS

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
SELECT
    MAX(cd.calendardate) AS "DATE"
    , cd.location
    , TO_CHAR(cd.population,'999G999G999G999') AS population
    , MAX(TO_NUMBER(cv.people_vaccinated_per_hundred)) AS "POP_VACCINATED_AT_LEAST_ONCE(%)"
FROM coviddeaths cd
JOIN covidvacinations cv
ON cd.location=cv.location
AND cd.calendardate=cv.calenderdate
WHERE cd.continent IS NOT NULL
--AND UPPER(cd.location)='TAIWAN'
GROUP BY cd.location, cd.population
ORDER BY cd.location;

-- Using CTE to determine the week of the most recent peak in number of new infections per country
WITH weekly_new_infections_by_country AS (
SELECT
    calendardate AS week_start_date
    , (calendardate + INTERVAL '6' DAY) AS week_end_date
    , location
    , TO_CHAR(population, '999G999G999G999') AS population
    , NVL(new_cases,0) AS new_cases
    , SUM(NVL(new_cases,0)) OVER (PARTITION BY location ORDER BY calendardate ROWS BETWEEN CURRENT ROW AND 6 FOLLOWING) AS weekly_new_infections
FROM coviddeaths
WHERE continent IS NOT NULL)
, highest_weekly_new_infections_by_country AS (
SELECT 
    week_start_date
    , week_end_date
    , location
    , population
    , TO_CHAR(weekly_new_infections, '999G999G999G999') AS weekly_new_infections
--    , DENSE_RANK() OVER (PARTITION BY location ORDER BY weekly_new_infections DESC) AS highest_weekly_new_infections    
    , DENSE_RANK() OVER (PARTITION BY location ORDER BY weekly_new_infections DESC, week_start_date DESC) AS highest_weekly_new_infections
FROM weekly_new_infections_by_country)
SELECT *
FROM highest_weekly_new_infections_by_country
WHERE highest_weekly_new_infections=1
ORDER BY location, highest_weekly_new_infections;

-- Using CTE to determine date of highest death-to-infection rate for each country
WITH death_to_infection_rate AS (
SELECT
    calendardate
    , location
    , NVL(total_cases,0) AS total_cases
    , NVL(new_deaths,0) AS new_deaths
    , ROUND(((NVL(new_deaths,0)/NVL(total_cases,1))*100), 2) AS death_to_infection_rate_pct
    , DENSE_RANK() OVER (PARTITION BY location ORDER BY (NVL(new_deaths,0)/NVL(total_cases,1))*100 DESC) AS highest_death_to_infection_rank
FROM coviddeaths)
SELECT 
    calendardate AS "DATE"
    , location
    , total_cases
    , new_deaths
    , death_to_infection_rate_pct
FROM death_to_infection_rate
WHERE highest_death_to_infection_rank=1
ORDER BY location
;
