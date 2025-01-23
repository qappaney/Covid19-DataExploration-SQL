/*
Covid19 Data Exploration 
Skills used:
Joins, CTE, Temp Tables,, Bulk Insert, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types 
*/

Select *
From Covid19..CovidDeaths

-- Select Data that we are going to be starting with
Select Location, date, total_cases, new_cases, total_deaths, population
From Covid19..CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths in Egypt
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Covid19..CovidDeaths
Where location = 'Egypt'
and continent is not null 
order by 1,2


-- Total Cases vs Population in Egypt
Select Location, date, Population, total_cases,  (total_cases/population)*100 [Percent Population Infected]
From Covid19..CovidDeaths
Where location = 'Egypt'
order by 1,2


-- Countries with Highest Infection Rate compared to Population
-- Creating View to store data for later visualizations
drop view if exists Highest_Infection_Rate_Pop

create view Highest_Infection_Rate_Pop
as
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Covid19..CovidDeaths
Group by Location, Population



-- Countries with Highest Death Count per Population
-- Creating View to store data for later visualizations
drop view if exists Highest_Death_Count_Pop

create view Highest_Death_Count_Pop
as
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Covid19..CovidDeaths
Group by Location



-- Showing contintents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Covid19..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc


-- Creating View to store data for later visualizations
create view Max_Deaths_continent
as
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Covid19..CovidDeaths
Where continent is not null 
Group by continent
--order by TotalDeathCount desc

-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Covid19..CovidDeaths
--Where location = 'Egypt'
where continent is not null 
order by 1,2


-- Total Population vs Vaccinations(Joins)
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

From Covid19..CovidDeaths dea
Join Covid19..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Covid19..CovidDeaths dea
Join Covid19..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, round((RollingPeopleVaccinated/Population)*100,4)[Percentage]
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query
 

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

--Bulk Insert
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Covid19..CovidDeaths dea
Join Covid19..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date


Select *, (RollingPeopleVaccinated/Population)*100[Percentage]
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations
drop view if exists PercentPopulationVaccinated

Create View Percent_Population_Vaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid19..CovidDeaths dea
Join Covid19..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 



--All Views

select * 
from Highest_Infection_Rate_Pop

select *
from Highest_Death_Count_Pop

select * 
from Max_Deaths_continent

select * 
from Percent_Population_Vaccinated



