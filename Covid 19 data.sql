use Protfolioproject;
select * from CovidDeaths 
where continent is not null
order by 3,4;
--Select * from CovidVaccinations order by 3,4;
--select data i am going to using.
select location,date, total_cases, new_cases, total_deaths, population
from CovidDeaths order by 1,2;


-- Looking at Total Cases Vs Total Deaths
-- Percentage of death if somebody get infected by corona
select location,date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercent
from CovidDeaths where location like '%Bang%' and continent is not null order by 1,2;

--Looking at Total Cases Vs Population
-- Shows what percentage of population got covid
select location,date, total_cases, population,(total_cases/population)*100 as CasesPercent
from CovidDeaths where location like '%Bang%' order by 1,2;

-- Looking at highest infection rate compared to population
select location,population, MAX(total_cases) aS HightestinfectionCount,MAX(total_cases/population)*100 as casepercent
from CovidDeaths group by location, population order by casepercent desc;

-- Looking for Countries highest death count
select location,MAX(cast(total_deaths as int)) as Totaldeathcount
from CovidDeaths where continent is not null group by location order by Totaldeathcount desc;

-- let see it with continent
select continent,MAX(cast(total_deaths as int)) as Totaldeathcount
from CovidDeaths where continent is not null group by continent order by Totaldeathcount desc;


--showing contintents with the highest death count per population
select continent,MAX(cast(total_deaths as int)) as Totaldeathcount
from CovidDeaths where continent is not null group by continent order by Totaldeathcount desc;


-- global numbers
select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths ,(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as deathpercent
from CovidDeaths
--Where locations like '%Bang%'
where continent is not null
--Group by date
order by 1,2;

-- looking for total population vs total vacinations
select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location
order by  dea.location, dea.date) as rollingpeoplevaccinated
from CovidDeaths as dea
join CovidVaccinations as vac
on dea.location = vac.location
and dea.date =  vac.date
where dea.continent is not null
order by 2,3;


--create ctf
with PopvsVac (continent, location, date, population, New_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location
order by  dea.location, dea.date) as rollingpeoplevaccinated
from CovidDeaths as dea
join CovidVaccinations as vac
on dea.location = vac.location
and dea.date =  vac.date
where dea.continent is not null
)
select *,(rollingpeoplevaccinated/population)*100
from PopvsVac;

--temp table
Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
rollingpeoplevaccinated numeric)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location
order by  dea.location, dea.date) as rollingpeoplevaccinated
from CovidDeaths as dea
join CovidVaccinations as vac
on dea.location = vac.location
and dea.date =  vac.date
--where dea.continent is not null

select *,(rollingpeoplevaccinated/population)*100
from #PercentPopulationVaccinated;

--creating view to store data for later visualizations
create view PercentPopulationVaccinated as
select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location
order by  dea.location, dea.date) as rollingpeoplevaccinated
from CovidDeaths as dea
join CovidVaccinations as vac
on dea.location = vac.location
and dea.date =  vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated;

-- we take there not as they are not inluded in the above quaries and want to stay consistant
-- European Union is part of europe 
select location, SUM(cast(new_deaths as int)) as TotalDeathCount
from CovidDeaths
Where continent is null
and location not in ('World','European Union','international')
Group by location
order by TotalDeathCount Desc;

--by country infected by population
select location,Population,MAX(total_cases) as HighestInfectionCount,Max(total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
group by location,Population
order by PercentPopulationInfected desc;

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc;
