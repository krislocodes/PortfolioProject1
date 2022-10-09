select * 
from CovidDeaths
Where continent is not null
order by 3,4

--select * 
--from CovidVaccinations
--order by 3,4

-- Select Data that we will be using
select location, date, total_cases, new_cases, total_deaths, population 
from CovidDeaths
Where continent is not null
order by 1,2

-- Looking at total cases vs total deaths
-- Shows likelihood of dying when contracting Covid in your Country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where location like '%africa%'
order by 1,2

-- Loking at total cases vs population
-- Shows what percentage of population got Covid
select location, date, population, total_cases, (total_cases/population)*100 as PercentPopInfected
from PortfolioProject..CovidDeaths
--Where location like '%africa%'
order by 1,2

-- Looking at countries with highest infection rate compared to population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopInfected
from PortfolioProject..CovidDeaths
--Where location like '%africa%'
Group by Location, Population
order by PercentPopInfected desc

-- Showing the countries with the highest death count per population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%africa%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%africa%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Another version:
--select location, MAX(cast(total_deaths as int)) as TotalDeathCount
--from PortfolioProject..CovidDeaths
----Where location like '%africa%'
--Where continent is null
--Group by location
--order by TotalDeathCount desc

--- Showing the continents with the highest death count per population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%africa%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS
select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPercentage -- total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--Where location like '%africa%'
Where continent is not null
--Group by date
order by 1,2


-- Looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER 
(Partition by dea.location order by dea.location, dea.date) as RollingVaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER 
(Partition by dea.location order by dea.location, dea.date) as RollingVaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingVaccinations/Population)*100
From PopvsVac


-- TEMP TABLE

DROP table if exists #PercentPeopleVaccinated
Create table #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingVaccinations numeric,
)

Insert into #PercentPeopleVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER 
(Partition by dea.location order by dea.location, dea.date) as RollingVaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingVaccinations/Population)*100
From #PercentPeopleVaccinated



--Creating view to store data for later visualizations

Create View PercentPeopleVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER 
(Partition by dea.location order by dea.location, dea.date) as RollingVaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPeopleVaccinated

