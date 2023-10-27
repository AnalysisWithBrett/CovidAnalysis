Select * 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4


--Select * 
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4


-- Select data that we are going to be using --

Select Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


-- Looking at the Total cases vs Total deaths
--How many cases are there in the country and 
--how many deaths do they have for their entire cases
--shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases*100) as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location like '%kingdom%'
WHERE continent is not null
ORDER BY 1,2


-- Looking at Total cases vs Population
--Shows what percentage of population got covid

Select Location, date, Population, total_cases, (total_cases/Population*100) as CasePercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%kingdom%'
WHERE continent is not null
ORDER BY 1,2


-- Looking at countries with highest infection rate compared to population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/Population*100) as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%kingdom%'
--WHERE continent is not null
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc

--Showing countries with the highest death count per population
Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%kingdom%'
WHERE continent is not null
GROUP BY Location, Population
ORDER BY TotalDeathCount desc

--Let's break things down by continent

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%kingdom%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


Select location, Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%kingdom%'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc


--Showing continents with the highest death count per population
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%kingdom%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


--Global numbers
--Number of cases and deaths from each date

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%kingdom%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Total number of cases and deaths

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%kingdom%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


--looking at total populaton vs vaccinations
--USE CTE


With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Temp table 

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


SELECT *
From PercentPopulationVaccinated





-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
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

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc
