Select*
From PortfolioProject..CovidDeaths
Order by 3,4

--Select*
--From PortfolioProject..CovidVaccinations
--Order by 3,4

--Select Data that we are going to be using

Select location, date, total_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2

--Looking at Total cases vs Total deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Location like '%states%'
Order by 1,2

--Looking at Total cases vs Population

Select location, date, convert(numeric,total_cases) as total_cases, convert(numeric,population) as population,(total_cases /  population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where Location like '%states%'
Order by 1,2

Select Location, population, max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, population
Order by PercentPopulationInfected desc

--Showing Countries with highest death count per population

Select location,  max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc

--Lets break it down by Continent

Select continent,  max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc

--Continent with Highest death per population
Select location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
Group by location
Order by TotalDeathCount desc

--GLOBAL NUMBERS

Select date, sum(new_cases) as total_cases,  sum(cast(total_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/ sum(new_cases)*100 as DeathPercentage

From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
order by 1,2

---Looking at Totasl Population vs Vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

---Partition using window function
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Using CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
Select* , convert(int, RollingPeopleVaccinated/Population)*100 as RollingPpleVacciPercent
From PopvsVac

---TEMP TABLE
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.date)
as RollingPeopleVaccinated

from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select* ,(RollingPeopleVaccinated/Population)*100 
From #PercentPopulationVaccinated

---DROP TABLE
Drop Table if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.date)
as RollingPeopleVaccinated

from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null

Select* ,(RollingPeopleVaccinated/Population)*100 
From #PercentPopulationVaccinated

--Creating View to store data for visualization

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select*
From PercentPopulationVaccinated