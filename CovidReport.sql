select *
from PortfolioProjects..CovidDeaths
order by 3,4

select location, total_cases, new_cases, date, total_deaths, population
from PortfolioProjects..CovidDeaths
order by location, date


--// total death vs total cases

select location, total_deaths,total_cases, date, population, ( TRY_CONVERT(float, total_deaths) /total_cases)*100 as DeathRatio
from PortfolioProjects..CovidDeaths
where location like '%india%'
order by DeathRatio desc


--// total cases vs population

select location, total_cases, date, population, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProjects..CovidDeaths
where location like '%india%'
order by 3

--countries with highest infecction rate compared to pupulation 

select location, population, max(cast(total_cases as int)) as MaxTotalCases, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProjects..CovidDeaths
group by location , population
order by PercentPopulationInfected desc;

--countries with highest deaths 

select location, max(cast(total_deaths as int)) as MaxDeathCount, max(cast(total_deaths as int))/population*100 as DeathRate
from PortfolioProjects..CovidDeaths
where continent  is not null
group by location , population
order by MaxDeathCount desc;


--ranking by continents 

select continent, max(cast(total_deaths as int)) as MaxDeathCount
from PortfolioProjects..CovidDeaths
where continent  is not null
group by continent
order by MaxDeathCount desc;


--showing continents with highest death count 

select continent, max(cast(total_deaths as int)) as MaxDeathCount
from PortfolioProjects..CovidDeaths
where continent  is not null
group by continent
order by MaxDeathCount desc;


--global numbers 
SELECT

    SUM(new_cases) AS SumCases,
    SUM(CAST(new_deaths AS INT)) AS SumDeaths,
    CASE
        WHEN SUM(new_cases) > 0 THEN
            (SUM(CAST(new_deaths AS FLOAT)) / SUM(new_cases)) * 100.0
        ELSE
            NULL
    END AS DeathPercentage
FROM
    PortfolioProjects..CovidDeaths
WHERE
    continent IS NOT NULL



with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location , dea.date)  as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccination vac
	on dea.location = vac.location 
	and dea.date = vac.date
	where dea.continent is not null
	
)
select *, (RollingPeopleVaccinated*100/population) as PovVsVacPercent
from PopvsVac
