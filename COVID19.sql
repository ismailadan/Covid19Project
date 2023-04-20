/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

-- Exploring our data

select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

select *
From PortfolioProject..CovidVaccinations
where continent is not null
order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1, 2

-- Total Cases vs Total Deaths
-- Shows death rate in chosen country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentDeaths
From PortfolioProject..CovidDeaths
where location like '%kingdom%'
order by 1, 2 


-- Looking at the Total Cases vs Population
-- Showing what percentage of the population contracted Covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulation
From PortfolioProject..CovidDeaths
where location like '%kingdom%'
order by 1, 2 


-- Looking at countries with the highest infection rate compared to population

Select location, population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulation
From PortfolioProject..CovidDeaths
group by location, population, date
order by PercentPopulation desc


-- Showing Countries with the highest death count

Select location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


--Breaking it down by continent
-- Showing continents with highest death count
-- showing results only relevant to 'continents' as the dataset has stored all values in the 'location' column

Select location, SUM(new_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is null and location not in ('World', 'European Union', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
group by location

-- Global Numbers

-- Overall Global Cases, Deaths and Death rate
Select SUM(new_cases)  as GlobalCases , SUM(new_deaths) as GlobalDeaths, SUM(new_deaths)/ CASE WHEN SUM(new_cases) = 0 then null else SUM(new_cases) end *100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
order by 1, 2 


-- Global Cases, Deaths & Death rate by date

Select date, SUM(new_cases)  as GlobalCases , SUM(new_deaths) as GLobalDeaths, SUM(new_deaths)/ CASE WHEN SUM(new_cases) = 0 then null else SUM(new_cases) end *100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1, 2 


-- Looking total population vs vaccinations
-- Using both a join and window function to calculate cumulitve vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as CumulitiveVaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

-- Using CTE to enable further calculation of new columns

With PopvsVac (continent, location, date, population, new_vaccinations, CumulitiveVaccinations)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as CumulitiveVaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (CumulitiveVaccinations/population)*100 as PercentVaccinated
from PopvsVac


-- Temp Table to enable further one off analysis
-- Showing percentage of population vaccinated at any one time

drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population float,
new_vaccinations float,
CumulitiveVaccinations float
)

INSERT INTO #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as CumulitiveVaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

SELECT *, (CumulitiveVaccinations/population)*100 as PercentVaccinated
FROM #PercentPopulationVaccinated 


--Creating Views for later visualisation based on above queries
-- View 1 for later use

create view RateofInfectionByPopandDate as
Select location, population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulation
From PortfolioProject..CovidDeaths
group by location, population, date

-- View 2 for later use

create view HighestRateofInfectionByPop as 
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulation
From PortfolioProject..CovidDeaths
group by location, population

-- View 3 for later use

create view CountriesDeathCount as
Select location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
group by location

-- View 4 for later use

create view DeathCountContinent as
Select location, SUM(new_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is null and location not in ('World', 'European Union', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
group by location

-- View 5 for later use

create view TotalGlobalFigures as
Select SUM(new_cases)  as GlobalCases , SUM(new_deaths) as GlobalDeaths, SUM(new_deaths)/ CASE WHEN SUM(new_cases) = 0 then null else SUM(new_cases) end *100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null

-- View 6 for later use

create view GlobalFigures as
Select date, SUM(new_cases)  as GlobalCases , SUM(new_deaths) as GLobalDeaths, SUM(new_deaths)/ CASE WHEN SUM(new_cases) = 0 then null else SUM(new_cases) end *100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
group by date

-- View 7 for later use

create view PercentPopulationVaccinations as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as CumulitiveVaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null




