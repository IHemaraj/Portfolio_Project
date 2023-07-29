--With help of Alex The Analyst i've completed this project
--For Data Exploration first we need to take a look at dataset

SELECT *
FROM portfolioproject..CovidVaccinations
order by location, date

--select the data which we are going to use(location,date,total_cases,total_deaths,population)

SELECT location, date,total_cases,total_deaths, population
FROM portfolioproject..CovidDeaths
WHERE continent is not NULL
order by 1,2

--looking for the total_cases vs total_deaths in percentage

SELECT location, date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM portfolioproject..CovidDeaths
where location = 'India' and continent is not NULL
order by 1,2

--looking for the total_cases vs population
--shows the % of population get covid


SELECT location, date, population, total_cases, (total_cases/population)*100 as AffectedPercentage
FROM portfolioproject..CovidDeaths
where location = 'India' and continent is not NULL
order by 1,2

--looking for the countries with highest cases compared to population

SELECT location, population, MAX(total_cases) as HighestInfectedCases, max((total_cases/population))*100 as AffectedPercentage
FROM portfolioproject..CovidDeaths
--where location = 'India'
group by location, population
order by AffectedPercentage desc

--showing the countries with highest death count per population

SELECT location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
FROM portfolioproject..CovidDeaths
--where location = 'India'
WHERE continent is not NULL
group by location
order by TotalDeathCount desc

--let's check for continents

SELECT continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
FROM portfolioproject..CovidDeaths
--where location = 'India'
WHERE continent is not NULL
group by continent
order by TotalDeathCount desc

--global numbers for total deaths and total cases

SELECT   SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths,
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentageGlobally
--(total_cases/population)*100 as AffectedPercentage
FROM portfolioproject..CovidDeaths
--where location = 'India' 
where continent is not NULL
--GROUP BY date
order by 1,2

--now we are seeing vaccination table

SELECT *
FROM portfolioproject..CovidVaccinations

--JOin both tables with common column_names such as location, date

SELECT*
FROM portfolioproject..CovidDeaths AS dea
JOIN portfolioproject..COvidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY  2,3,4

--Now select the columns which we're going to execute

SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
FROM portfolioproject..CovidDeaths AS dea
JOIN portfolioproject..COvidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY  2,3,4

--now we need to find the increasing vaccination day by day we are adding new name rollingpeoplevaccination

SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location,dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM portfolioproject..CovidDeaths AS dea
JOIN portfolioproject..COvidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY  2,3

--use cte(common table expression)

With PopuVsVacc(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location,dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM portfolioproject..CovidDeaths AS dea
JOIN portfolioproject..COvidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY  1,2
)
SELECT*, (RollingPeopleVaccinated/population)*100
FROM PopuVsVacc

--creating temp table
DROP TABLE if exists #VaccinatedPopulationPercent
CREATE TABLE #VaccinatedPopulationPercent
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #VaccinatedPopulationPercent
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location,dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM portfolioproject..CovidDeaths AS dea
JOIN portfolioproject..COvidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY  2,3

SELECT*, (RollingPeopleVaccinated/population)*100 as GloballyVaccinatedPercentage
FROM #VaccinatedPopulationPercent

--creating view to store data fro later visualization

CREATE VIEW PopulationVaccinatedPercent as
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location,dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM portfolioproject..CovidDeaths AS dea
JOIN portfolioproject..COvidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY  2,3

SELECT*
FROM VaccinatedPopulationPercent

