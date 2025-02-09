select *
from PortfolioProject2..CovidDeathsUpdated
where continent is not null
order by 3,4

--select *
--from PortfolioProject2..CovidVaccinationsUpdated
--order by 3,4

-- Select Data that we are going to be using

update PortfolioProject2..CovidDeathsUpdated
set total_cases = NULL
where total_cases = 0

 -- shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject2..CovidDeathsUpdated
where location like '%australia%'
and continent is not null
order by 1,2

-- Looking at Total Cases Vs Population
-- Shows what percentage of Population got Covid

select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject2..CovidDeathsUpdated
where location like '%australia%'
and continent is not null
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Popution

select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentPopulationInfected
from PortfolioProject2..CovidDeathsUpdated
--where location like '%australia%'
where continent is not null
Group By location, population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population

select location, MAX(total_deaths) as TotalDeathsCount
from PortfolioProject2..CovidDeathsUpdated
--where location like '%australia%'
where continent is not null
Group By location
order by TotalDeathsCount desc


-- LET'S BREAKING THINGS DOWN BY CONTINENT
-- SHOWING CONTINENTS WITH THE HIGHEST DEATHS COUNT PER POPULATION
select continent, MAX(total_deaths) as TotalDeathsCount
from PortfolioProject2..CovidDeathsUpdated
--where location like '%australia%'
where continent is not null
Group By continent
order by TotalDeathsCount desc


-- GLOBAL NUMBERS

select sum(new_deaths) as total_deaths, sum(new_cases) as total_cases, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from PortfolioProject2..CovidDeathsUpdated
--where location like '%australia%'
where continent is not null
order by 1,2



-- Looking at Total Population Vs Vaccinations


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.date) as RollingPeopleVaccinated
from PortfolioProject2..CovidDeathsUpdated dea
join PortfolioProject2..CovidVaccinationsUpdated vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE

with PopvsVac(Continent, Locarion, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.date) as RollingPeopleVaccinated
from PortfolioProject2..CovidDeathsUpdated dea
join PortfolioProject2..CovidVaccinationsUpdated vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
from PopvsVac


--TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
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
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.date) as RollingPeopleVaccinated
from PortfolioProject2..CovidDeathsUpdated dea
join PortfolioProject2..CovidVaccinationsUpdated vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
from #PercentPopulationVaccinated


create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.date) as RollingPeopleVaccinated
from PortfolioProject2..CovidDeathsUpdated dea
join PortfolioProject2..CovidVaccinationsUpdated vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated
