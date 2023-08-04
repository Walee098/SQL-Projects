select * 
from CovidProjectPortfolio..CovidDeaths$
order by 3,4
--select * from CovidProjectPortfolio..CovidVacinated$ order by 3,4

-- Select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from CovidProjectPortfolio..CovidDeaths$ order by 1,2

-- Looking at Total Cases vs Total Deaths in Pakistan

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidProjectPortfolio..CovidDeaths$ 
where location like '%Pakistan%'
order by 1,2

-- Looking at Total cases vs Population
-- Shows what % of population got Covid

select location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
from CovidProjectPortfolio..CovidDeaths$ 
--where location like '%Pakistan%'
order by 1,2



-- Looking at countires with highest infection rate compared to Population

select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PupulationInfectedPercentage
from CovidProjectPortfolio..CovidDeaths$ 
--where location like '%Pakistan%'
Group by location, population
order by PupulationInfectedPercentage desc



-- Showing Countires with Highest Death Count per Population

select location, MAX(total_deaths) as TotalDeathCount
from CovidProjectPortfolio..CovidDeaths$ 
--where location like '%Pakistan%'
where continent is not null
Group by location
order by TotalDeathCount desc

-- Breaking down by CONTINENTS
select continent, MAX(total_deaths) as TotalDeathCount
from CovidProjectPortfolio..CovidDeaths$ 
--where location like '%Pakistan%'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Showing the continents with highest death count
select continent, MAX(total_deaths) as TotalDeathCount
from CovidProjectPortfolio..CovidDeaths$ 
--where location like '%Pakistan%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--- Global Numbers
SELECT date, 
       SUM(new_cases) AS total_cases, 
       SUM(new_deaths) AS total_deaths, 
       CASE 
          WHEN SUM(new_cases) = 0 THEN 0
          ELSE SUM(new_deaths) / SUM(new_cases) * 100 
       END AS DeathPercentage
FROM CovidProjectPortfolio..CovidDeaths$
-- WHERE location LIKE '%Pakistan%'
WHERE continent IS NOT NULL
GROUP BY date 
ORDER BY 1,2 

-- Checking vacinations in Pakistan
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from CovidProjectPortfolio..CovidDeaths$ dea
Join CovidProjectPortfolio..CovidVacinated$ vac
       on dea.location = vac.location
        and dea.date= vac.date
	where dea.continent is not null and dea.location LIKE '%Pakistan%' -- you can change your country 
order by 1,2,3


---- Total Population vs Rolling People Vacinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidProjectPortfolio..CovidDeaths$ dea
Join CovidProjectPortfolio..CovidVacinated$ vac
       on dea.location = vac.location
        and dea.date= vac.date
	where dea.continent is not null
order by 2,3

-- USING CTE

With PopvsVAC (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidProjectPortfolio..CovidDeaths$ dea
Join CovidProjectPortfolio..CovidVacinated$ vac
       on dea.location = vac.location
        and dea.date= vac.date
	where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPercent
from PopvsVAC

-- USING TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidProjectPortfolio..CovidDeaths$ dea
Join CovidProjectPortfolio..CovidVacinated$ vac
       on dea.location = vac.location
        and dea.date= vac.date
	--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPercent
from #PercentPopulationVaccinated

-- Creating a view

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidProjectPortfolio..CovidDeaths$ dea
Join CovidProjectPortfolio..CovidVacinated$ vac
       on dea.location = vac.location
        and dea.date= vac.date
	where dea.continent is not null
--order by 2,3  

select * from PercentPopulationVaccinated