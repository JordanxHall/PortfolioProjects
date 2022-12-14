select *
from PortfolioProject..CovidDeaths
order by 3,4

--Vax
--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

--Select the data we're going to be using

Select location, date, total_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--total cases vs total deaths
--shows the likelihood of dying if you contract Covid in [COUNTRY]
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location LIKE '%states%'
order by 1,2

--Looking at the total cases vs the population
--what percentage of the population contracted Covid
Select location, date, population, total_cases,(total_cases/population)*100 as CasesPercentofPop
from PortfolioProject..CovidDeaths
where location LIKE '%states%'
order by 1,2

--what countries have the highest infection rate per population
Select location, population, MAX(total_cases) as HighestCases,(MAX(total_cases/population))*100 as PercentofPopInfected
from PortfolioProject..CovidDeaths
--where location LIKE '%states%'
group by location, population
order by PercentofPopInfected DESC

--Showing countries with highest death count per population
Select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null --to weed out the groupings (Asia, EU, etc.)
group by location
order by TotalDeathCount DESC

--Looking at things by continent!
Select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null --to weed out the groupings (Asia, EU, etc.)
group by location
order by TotalDeathCount DESC


--showing the continent with the highest death count
Select location, continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null --to weed out the groupings (Asia, EU, etc.)
group by location, continent
order by TotalDeathCount DESC

--Global Numbers

Select date, SUM(new_cases) TotalCases, SUM(CAST(new_deaths as int)) TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 GlobalDeathPercentage
from PortfolioProject..CovidDeaths
--where location LIKE '%states%'
where continent is not null
group by date
order by 1,2

--Global total numbers
Select SUM(new_cases) TotalCases, SUM(CAST(new_deaths as int)) TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 GlobalDeathPercentage
from PortfolioProject..CovidDeaths
--where location LIKE '%states%'
where continent is not null
--group by date
order by 1,2


--total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.New_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingVaccinationCount
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	on vac.location = dea.location
	and vac.date = dea.date
Where dea.continent is not null
Order by 2,3

--Use CTE

with popsvsvac (continent, location, date, population, new_vaccinations, RollingVaccinationCount)
AS(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.New_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingVaccinationCount
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	on vac.location = dea.location
	and vac.date = dea.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingVaccinationCount/population)*100
From popsvsvac

--Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVaccinationCount numeric
)
INSERT INTO #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.New_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingVaccinationCount
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	on vac.location = dea.location
	and vac.date = dea.date
Where dea.continent is not null
--Order by 2,3

Select *, (RollingVaccinationCount/population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later visualizations


--Rolling Vaccination count view
CREATE VIEW PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.New_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingVaccinationCount
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	on vac.location = dea.location
	and vac.date = dea.date
Where dea.continent is not null
--Order by 2,3

CREATE VIEW GlobalDeathData as
Select date, SUM(new_cases) TotalCases, SUM(CAST(new_deaths as int)) TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 GlobalDeathPercentage
from PortfolioProject..CovidDeaths
--where location LIKE '%states%'
where continent is not null
group by date
--order by 1,2

CREATE VIEW GlobalTotalDeaths as
Select location, continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null --to weed out the groupings (Asia, EU, etc.)
group by location, continent
--order by TotalDeathCount DESC

CREATE VIEW InfectedPopulation as
Select location, population, MAX(total_cases) as HighestCases,(MAX(total_cases/population))*100 as PercentofPopInfected
from PortfolioProject..CovidDeaths
--where location LIKE '%states%'
group by location, population
--order by PercentofPopInfected DESC