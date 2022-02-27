select * from CovidDeaths
order by 3,4

select * from CovidVaccination
order by 3,4

select location,date,total_cases,new_cases,total_deaths,population from CovidDeaths
order by 1,2

-- looking total deaths vs total cases in percentage
-- show likelihood of dying if you contract covid in your country

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage from CovidDeaths
where location like '%india%'
order by 1,2


--looking at total cases vs population
--shows what percentage of people get covid

select location,date,population,total_cases,(total_cases/population)*100 as gettingcovid from CovidDeaths
where location like '%india%'
order by 1,2 

--looking at countries with highest infection rate compared to population

select location,population, MAX(total_cases) as HighestInfectionCount , MAX((total_cases/population)*100) as
PercentPopulationInfected from CovidDeaths
--where location like '%india%'
group by location,population
order by PercentPopulationInfected desc

-- showing countries  with highest deathcount per populaiton

select location, MAX(cast(total_deaths as int)) as totaldeathcount from CovidDeaths
--where location like '%india%'
where continent	is not null
group by location
order by totaldeathcount desc

-- showing contintents with highest death count per population


select continent, MAX(cast(total_deaths as int)) as totaldeathcount from CovidDeaths
--where location like '%india%'
where continent	is not null
group by continent
order by totaldeathcount desc

-- Global numbers

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/
SUM(new_cases)*100 as Deathpercentage
from CovidDeaths
where continent is not null
order by 1,2

--looking total population vs vaccinations
-- use cte

with PopvsVac(continent, location,date,population,new_vaccinations,RollingPeopleVaccinated )
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as int))over(partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccination vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
 select *,(RollingPeopleVaccinated/population)*100 
 from PopvsVac

-- Temp table

drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
loaction nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric  
)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as int))over(partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccination vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

 select *,(RollingPeopleVaccinated/population)*100 
 from #PercentPopulationVaccinated

select * from #PercentPopulationVaccinated
 
 
 -- creating view for later data visualization

Create view PercentPopulationVaccinated as
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as int))over(partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccination vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated


