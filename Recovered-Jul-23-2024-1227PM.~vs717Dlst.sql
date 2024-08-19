select *
from Portfolioprojects..CovidDeaths$
order by 3,4

--select *
--from Portfolioprojects..CovidVaccinations$
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from Portfolioprojects..CovidDeaths$
order by 1,2

--Looking at Total cases vs Total death
--probabilities  of dying if you contract covid in your country

select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as Deathpercentage 
from Portfolioprojects..CovidDeaths$
where location like '%states%'
order by 1,2

--estimate at Total cases vs population

select location, date, population, total_cases,(total_cases/population)*100 as Deathpercentage 
from Portfolioprojects..CovidDeaths$
--where location like '%states%'
order by 1,2

--looking at countries with the highest infection rate compared to population


select location, population, Max(total_cases)as Highestinfectioncount, Max(total_cases/population)*100 as percentagepopulationinfected
from Portfolioprojects..CovidDeaths$
--where location like '%states%'
group by location, population
order by percentagepopulationinfected desc


--showcase countries with Highest Death count per population

select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
from Portfolioprojects..CovidDeaths$
--where location like '%Nigeria%'
where continent is not null
group by continent
order by TotalDeathCount desc

--Let's break things down by continent

select location, Max(cast(Total_deaths as int)) as TotalDeathCount
from Portfolioprojects..CovidDeaths$
--where location like '%Nigeria%'
where continent is null
group by location
order by TotalDeathCount desc

--GLOBAL NUMBERS

select SUM(new_cases)as total_cases, sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/Sum(new_cases)*100 as Deathpercentage 
from Portfolioprojects..CovidDeaths$
--where location like '%states%'
where continent is not null 
order by 1,2

--looking at Total Population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated 
from Portfolioprojects..CovidDeaths$ dea
join Portfolioprojects..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--CTE

with Popsvac (continent, location, date, population, new_vaccination, Rollingpeoplevaccinated)as 
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated 
from Portfolioprojects..CovidDeaths$ dea
join Portfolioprojects..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select * ,(Rollingpeoplevaccinated/population)*100
from Popsvac

--Temp Table

Drop table if exists #Percentpopulationvaccinated
create table #Percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
Rollingpeoplevaccinated numeric 
)
Insert into #Percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated 
from Portfolioprojects..CovidDeaths$ dea
join Portfolioprojects..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select * ,(Rollingpeoplevaccinated/population)*100
from #Percentpopulationvaccinated

--creating view to store data for later visualizations


Create View Percentpopulationvaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated 
from Portfolioprojects..CovidDeaths$ dea
join Portfolioprojects..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null


select *
from Percentpopulationvaccinated




