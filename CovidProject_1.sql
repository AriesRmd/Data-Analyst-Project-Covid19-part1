Select * From CovidProject_1..CovidDeaths$
-- not null untuk menghilangkan location world dmna world adalah dunia tidak ada continent
where continent is not null
order by 1,2
-- Select columns
Select Location, date, total_cases, new_cases, total_deaths, population
From CovidProject_1..CovidDeaths$
order by 1,2

-- Looking at T_Cases vs T_Deaths

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From CovidProject_1..CovidDeaths$
where location like '%indonesia%'
order by 1,2

-- T_cases vs Population
-- Percentage of population got covid
Select Location, date, population, (total_cases/population)*100 as PopulationCovid_Percentage
From CovidProject_1..CovidDeaths$
--where location like '%indonesia%'
order by 1,2

-- Countries with Highest Infection Rate compare to Population
Select Location, population, MAX(total_cases) as Highest_Infection, MAX((total_cases/population))*100 as Population_Infect_Percentage
From CovidProject_1..CovidDeaths$
GROUP BY location,population
order by Population_Infect_Percentage desc


-- Showing Countries with highest deaths count per population
Select Location, MAX(cast(Total_deaths as int)) as Total_death_count
From CovidProject_1..CovidDeaths$
where continent is not null
GROUP BY location
order by Total_death_count desc

-- Total deaths by continent
Select location, MAX(cast(Total_deaths as int)) as Total_death_count
From CovidProject_1..CovidDeaths$
where continent is null
GROUP BY location
order by Total_death_count desc


-- Showing continent with highest death per population
Select continent, MAX(cast(Total_deaths as int)) as Total_death_count
From CovidProject_1..CovidDeaths$
where continent is null
GROUP BY continent
order by Total_death_count desc


-- GLOBAL NUMBERS
Select  date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percetage--total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From CovidProject_1..CovidDeaths$
--where location like '%indonesia%'
where continent is not null
group by date
order by 1,2

-- GLOBAL TOTAL NUMBERS until this day 23/09/2021
Select  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percetage--total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From CovidProject_1..CovidDeaths$
--where location like '%indonesia%'
where continent is not null
--group by date
order by 1,2


--Table Covid Vaccination
-- T.Population vs Get Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Vaccinated

From CovidProject_1..CovidDeaths$ dea
join CovidProject_1..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USING CTE
-- T.Population vs Get Vaccine

with popvsvac(continent, location, date, population, new_vaccinations, Vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Vaccinated

From CovidProject_1..CovidDeaths$ dea
join CovidProject_1..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (Vaccinated/population)*100 as Vaccinated_vs_Population
from popvsvac
--========================================================

--Temp Table
drop table if exists #PercentPopulationVaccinated --to editing table so we dont have to make a new one

create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Vaccinated numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Vaccinated

From CovidProject_1..CovidDeaths$ dea
join CovidProject_1..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (Vaccinated/population)*100 as Vaccinated_vs_Population
from #PercentPopulationVaccinated

--==========================================
-- Creating View to store data for visualization on tableau

create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Vaccinated

From CovidProject_1..CovidDeaths$ dea
join CovidProject_1..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated