select *
from [Portfolio-Project]..[covid deaths]
order by 3,4
 
select location, date, total_cases, new_cases,total_deaths, population_density
from [Portfolio-Project]..[covid deaths]
order by 1,2


--total cases vs total deaths

select location, date, total_cases,total_deaths, (cast(total_deaths as float)/ cast (total_cases as float))*100 as DeathPercentage
from [Portfolio-Project]..[covid deaths]
order by 1,2
   
-- total cases vs population

select location, date, total_cases,population_density, (cast(total_deaths as float)/ cast (population_density as float))*100 as DeathPercentage
from [Portfolio-Project]..[covid deaths]
where location like 'In%'
order by 1,2

--countries with highest infection rate compared to population

select location, population_density,MAX( total_cases) as HighestInfectionCount,max (cast(total_cases as int)/  (population_density ))*100 as PercentPopulationInfected
from [Portfolio-Project]..[covid deaths]
group by location, population_density
order by PercentPopulationInfected desc

--countries with highest death count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio-Project]..[covid deaths]
where continent is not null
group by location
order by TotalDeathCount desc

--continents with highest death count per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio-Project]..[covid deaths]
where continent is not null
group by continent
order by TotalDeathCount desc


--total population vs vaccinations
 --using CTE

 with popvsvac(continent, location,date, population_density,new_vaccinations, RollingPeopleVaccinated)
 as(
 select dea.continent, dea.location, dea.date, dea.population_density,
vac.new_vaccinations ,
SUM(convert(float , vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio-Project]..[covid deaths] as dea
join [Portfolio-Project]..[covid-vaccinatons] as vac
 on dea.location=vac.location
 and dea.date=vac.date 
 where dea.continent is not null
 )
 select *, (RollingPeopleVaccinated/population_density)*100
 from popvsvac

 --temp table
 drop table if exists #PercentPopulationVaccinated
 create table #PercentPopulationVaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population float,
 new_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )
 insert into #PercentPopulationVaccinated
 select dea.continent, dea.location, dea.date, dea.population_density,
vac.new_vaccinations ,
SUM(convert(float , vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio-Project]..[covid deaths] as dea
join [Portfolio-Project]..[covid-vaccinatons] as vac
 on dea.location=vac.location
 and dea.date=vac.date 

 select * , (RollingPeopleVaccinated/population)*100
 from #PercentPopulationVaccinated

 --creating view to store data for later visualisations

 create view PercentOfPopulationVaccinated as
 select dea.continent, dea.location, dea.date, dea.population_density,
vac.new_vaccinations ,
SUM(convert(float , vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio-Project]..[covid deaths] as dea
join [Portfolio-Project]..[covid-vaccinatons] as vac
 on dea.location=vac.location
 and dea.date=vac.date 
 where dea.continent is not null
 

 select *
 from PercentOfPopulationVaccinated