Select *
from PortfolioProject ..CovidDeaths
where continent is not null
order by 3,4

--Select *
--from PortfolioProject ..CovidDvaccinations
--order by 3,4
-- select the data that we are being using

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--looking at total cases vs total deaths 
-- shows liklihood of dying if you contract covid in your country 
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deaths_percentage
from PortfolioProject..CovidDeaths
where location like '%morocco%'
and continent is not null
order by 1,2

--looking at total cases vs population
--shows what percentage of population got Covid
select location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location like '%morocco%'
and continent is not null
order by 1,2

--looking at countries with highest infection rate compared to population 
select location,population,MAX(total_cases) as HighestInfectionCount,MAX(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%morocco%'
where continent is not null
Group by location,population
order by PercentPopulationInfected desc
-- showing countries with highest death count per population
select location,MAX(cast (total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%morocco%'
where continent is not null
Group by location
order by TotalDeathCount desc

--lets break things down by continent
select location,MAX(cast (total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%morocco%'
where continent is not null
Group by location
order by TotalDeathCount desc

--showing continents with the highest death count per population 
select continent,MAX(cast (total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%morocco%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS
select sum(new_cases) as totalcases,sum(cast(new_deaths as int))as totaldeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathsPercentage
from PortfolioProject..CovidDeaths
--where location like '%morocco%'
where continent is not null
--group by date 
order by 1,2


--looking at total Population vs Vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(new_vaccinations as int)) OVER ( Partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
,--sum(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidDvaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
order by 2,3
--USE CTE

with PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) OVER ( Partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
--sum(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidDvaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * ,(RollingPeopleVaccinated/population)*100
from PopvsVac

--temp table
Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar (255),
location nvarchar (255),
Date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) OVER ( Partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
--sum(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidDvaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select * ,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

-- creating view to store data for later visualisations
USE PortfolioProject;
GO
DROP VIEW IF EXISTS PercentPopulationVaccinated;
GO
create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) OVER ( Partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
--sum(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidDvaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select *
from PercentPopulationVaccinated