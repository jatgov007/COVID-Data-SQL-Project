
Use PortfolioProjects

Select  * from CovidDeaths
order by 3,4

Select top 10 * from CovidVaccinations

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths 

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%India%'
order by 1, 2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

select location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage
from CovidDeaths
order by 1,2

-- Looking at countries with Highest infection rate compared to population 

select location, population, max(total_cases) as HighestInfectionCount, (max(total_cases/population)) * 100 as HighestInfectedPercentage
from CovidDeaths
group by location, population
order by 4 desc 

-- Showing Countries with Highest Death Count per Population 

Select location,  Max(cast(total_deaths as int)) as HighestDeathCount
from CovidDeaths
where continent is not null
group by location
order by 2 desc

-- Looking at by Continent

Select continent,  Max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by 2 desc

-- Global Number 

select  sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, 
       sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage 
from CovidDeaths
where continent is not null
--group by date
order by 1


-- Looking at Total Population vs Vaccinations

Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(int, v.new_vaccinations)) over (partition by d.location order by d.location , d.date) as RollingPeopleVaccinated
from CovidDeaths d join CovidVaccinations v
	 on d.location = v.location and d.date = v.date
where d.continent is not null
order by 2,3

-- with CTE

With PopVsVac (Continent, Location, Date, Population, New_vaccination, RollingPeopleVaccinated)
as

(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(int, v.new_vaccinations)) over (partition by d.location order by d.location , d.date) as RollingPeopleVaccinated
from CovidDeaths d join CovidVaccinations v
	 on d.location = v.location and d.date = v.date
where d.continent is not null
--order by 2,3

)
select *, (RollingPeopleVaccinated/Population)*100  
from PopVsVac


-- with TEMP table 

drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime, 
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric

)
Insert into #PercentPopulationVaccinated

Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(int, v.new_vaccinations)) over (partition by d.location order by d.location , d.date) as RollingPeopleVaccinated
from CovidDeaths d join CovidVaccinations v
	 on d.location = v.location and d.date = v.date
where d.continent is not null

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated




--- Create View to store data for later visulization

Create view PercentagePopulationVaccinated as 

Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(int, v.new_vaccinations)) over (partition by d.location order by d.location , d.date) as RollingPeopleVaccinated
from CovidDeaths d join CovidVaccinations v
	 on d.location = v.location and d.date = v.date
where d.continent is not null


Select * from PercentagePopulationVaccinated