select * from PortfolioProject..CovidDeaths
order by 3,4

-- Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1, 2

-- Looking at Total Cases vs Total Deaths
select location, date, total_deaths, total_cases, (total_deaths/total_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location = 'Uzbekistan'
order by 1, 2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

select location, date, total_cases, Population, (total_cases/population) * 100 as PercentPoulationInfected
from PortfolioProject..CovidDeaths
--where location = 'Uzbekistan'
order by 1, 2

-- Looking at Countries with Highest Infection Rate compared to Poulation

select location, population, max(total_cases)as HighestInfectionCount, max((total_cases/population)) * 100 as PercentPoulationInfected
from PortfolioProject..CovidDeaths
group by location, population
--where location = 'Uzbekistan'
order by PercentPoulationInfected desc

-- Showing Countries with Highest Death Count per Population

select location, max(total_deaths)as HighestDeathsCount
from PortfolioProject..CovidDeaths
group by location
order by HighestDeathsCount desc

-- Showing continents with Highest Death Count by continent

select continent, max(total_deaths)as HighestDeathsCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by HighestDeathsCount desc

-- Sum of new cases and new deaths per date
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/nullif(sum(new_cases),0)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2


--Looking at Total Population vs Vaccinations
select dea.continent, dea.location ,dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/dea.population)*100
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

SET ANSI_WARNINGS OFF

with PopVSVac (Continent, Location, Date, Population,New_vaccinations, RollingPeopleVaccinated) as
(select dea.continent, dea.location ,dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/dea.population)*100
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null)

select *, (RollingPeopleVaccinated/Population)*100 from PopVSVac

--temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location ,dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/dea.population)*100
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date

select *, (RollingPeopleVaccinated/Population)*100 from #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
create view PercentPopulationVaccinated as
select dea.continent, dea.location ,dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/dea.population)*100
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated