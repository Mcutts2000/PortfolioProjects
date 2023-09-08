----SELECT *
----FROM PortfolioProject..CovidDeaths$
--where continent is not null
--order by 1,2


--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4


--select data that we are going to be using
 

 SELECT Location, date, total_cases, new_cases, total_deaths, population
 FROM PortfolioProject..CovidDeaths$
 Where continent is not null
 order by 1,2

 -- looking at Total Cases vs Total Deaths
 -- Shows the likelihood of dying if you contract covid in your country
 
 SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 FROM PortfolioProject..CovidDeaths$
  Where continent is not null
 order by 1,2

 --Looking at total cases vs population
 --Shows what percentage of population got covid over time

  SELECT Location, date, total_cases, population, (total_cases/population)*100 as CasePercentageOverTime
 FROM PortfolioProject..CovidDeaths$
 --Where location like '%States%'
 where continent is not null
 order by 1,2

 --What countires have the highest infection rate vs the population
 
 SELECT Location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as CasePercentageOverTime
 FROM PortfolioProject..CovidDeaths$
--Where location like '%A%'
where continent is not null
 GROUP BY Location, population
 order by CasePercentageOverTime desc


 -- Showing Countires with the highest death count per population

 
 SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
 FROM PortfolioProject..CovidDeaths$
--Where location like '%States%'
where continent is not null
 GROUP BY Location
 order by TotalDeathCount desc


 --Showing continents with the highest death count per population

 SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
 FROM PortfolioProject..CovidDeaths$
--Where location like '%States%'
where continent is not null
GROUP BY continent
 order by TotalDeathCount desc


 --Global Numbers

SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
 FROM PortfolioProject..CovidDeaths$
 Where continent is not null
 Group by date 
 order by 1,2


  
SELECT *
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date

 --Looking at Total Poluation vs Vaccinations

 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int, vac.new_vaccinations )) OVER (Partition by dea.location order by dea.location,
 dea.date) as RollingPeopleVaccinated,
 FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (Continnent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int, vac.new_vaccinations )) OVER (Partition by dea.location order by dea.location,
 dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated (Continent, Location, Date, Population, RollingPeopleVaccinated)
SELECT dea.continent, dea.location, dea.date, dea.population, 
       SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating view to store data for later visulizations

Create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, 
       SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--Order by 2,3