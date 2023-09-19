/*

Queries used for Tableau Project

*/



-- 1. --Global Numbers

SELECT 
	SUM(new_cases) as TotalCases,
	SUM(cast(new_deaths as int)) as TotalDeaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
 FROM PortfolioProject..CovidDeaths$
 Where continent is not null
 --Group by date 
 order by 1,2


-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe


 SELECT Location, SUM(cast(new_deaths as int)) as TotalDeathCount
 FROM PortfolioProject..CovidDeaths$
--Where location like '%States%'
where continent is null
and location not in ('World', 'European Union', 'International') 
 GROUP BY Location
 order by TotalDeathCount desc


-- 3.
 SELECT Location, Population,  MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercenPopulationInfected
 FROM PortfolioProject..CovidDeaths$
--Where location like '%A%'
where continent is not null
 GROUP BY Location, population
 order by PercenPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercenPopulationInfected
 FROM PortfolioProject..CovidDeaths$
 Group by location, population, date
 order by PercenPopulationInfected desc













