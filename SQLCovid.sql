--select *
--from Covid_Project..CovidDeaths$

--select *
--from Covid_Project..CovidVaccinations$
select location, date, total_cases, new_cases,population
from Covid_Project..CovidDeaths$
where continent is not null
order by 1,2

--Total Cases Vs Total Deaths
select location, date, total_cases, (total_deaths/total_cases) * 100 as DeathPercentage
from Covid_Project..CovidDeaths$
where location like '%states%'
order by 1,2

--Total Cases Vs Population
select location, date,population, total_cases, (total_cases/population) * 100 as PercentPopulationInfected
from Covid_Project..CovidDeaths$
--where location like '%states%'
order by 1,2

--Highest Infection Rate Compared to Population
select location, population, Max(total_cases) as HighestInfectionCount, Max((total_deaths/total_cases)) * 100 as PercentPopulationInfected
from Covid_Project..CovidDeaths$
--where location like '%states%'
group by location, population
order by PercentPopulationInfected desc

--Countries with Highest Death Count per Population
select location, Max(cast(Total_deaths as int)) as TotalDeathCount
from Covid_Project..CovidDeaths$
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

--Group by Continent with Highest Death Count
select location, Max(cast(Total_deaths as int)) as TotalDeathCount
from Covid_Project..CovidDeaths$
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

--Global Numbers
select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
from Covid_Project..CovidDeaths$
--where location like '%states%'
where continent is not null
group by date
order by 1,2


--Total Population vs Vaccinations

--USE CTE 

with PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as

(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations))
OVER (Partition BY dea.location ORDER by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
from Covid_Project..CovidDeaths$ dea
JOIN Covid_Project..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


--Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Contient nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations))
OVER (Partition BY dea.location ORDER by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
from Covid_Project..CovidDeaths$ dea
JOIN Covid_Project..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--Visulas for Later
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations))
OVER (Partition BY dea.location ORDER by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
from Covid_Project..CovidDeaths$ dea
JOIN Covid_Project..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated