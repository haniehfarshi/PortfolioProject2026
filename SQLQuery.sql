SELECT *
FROM PortfolioProject2026.dbo.CovidDeaths
where continent is not null
ORDER BY location, date;


--SELECT *
--FROM PortfolioProject2026.dbo.CovidVaccinations
--ORDER BY location, date;


--Select Data we are using
Select location,date, total_cases, new_cases, total_deaths,population
From PortfolioProject2026.dbo.CovidDeaths
where continent is not null
ORDER BY location, date;


--Looking at total Cases vs Total Deaths
Select location,date, total_cases, total_deaths, round((total_deaths/total_cases) *100,2) as Death_Percentage
From PortfolioProject2026.dbo.CovidDeaths
where location like '%states%' 
ORDER BY location, date;


--Looking at Total Cases vs Population
Select location,date, total_cases, population, round((total_cases/population) *100,2) as Total_Percentage
From PortfolioProject2026.dbo.CovidDeaths
where location like '%states%'
ORDER BY location, date;



-- Looking at Countries with Highest Infection Rate compared to Population
Select location,date, max(total_cases) as Highest_Infection_count , population, round(max(total_cases/population) *100,2) as Percent_population_Infected
From PortfolioProject2026.dbo.CovidDeaths
where continent is not null
Group by location, date,population
ORDER BY Percent_population_Infected desc;


--Showing Countries with Highest Death Counts Per Population
Select location, max(cast(total_deaths as int)) as Total_Death_count 
From PortfolioProject2026.dbo.CovidDeaths
where continent is not null
Group by location
ORDER BY Total_Death_count  desc;



-- Break down by Continent with Highest Death Counts
Select continent, max(cast(total_deaths as int)) as Total_Death_count 
From PortfolioProject2026.dbo.CovidDeaths
where continent is not null
Group by continent
ORDER BY Total_Death_count  desc;


--Global Numbers
Select date, sum(new_cases) as Total_Cases, sum(new_deaths) as Total_deaths,  round(sum(new_deaths)/sum(new_cases)*100,2) as Death_Percentage
From PortfolioProject2026.dbo.CovidDeaths
where continent is not null
Group by date
ORDER BY date;

--Overall
Select  sum(new_cases) as Total_Cases, sum(new_deaths) as Total_deaths,  round(sum(new_deaths)/sum(new_cases)*100,2) as Death_Percentage
From PortfolioProject2026.dbo.CovidDeaths
where continent is not null

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject2026..CovidDeaths dea
Join PortfolioProject2026..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
ORDER BY  dea.location, dea.date;




-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject2026..CovidDeaths dea
Join PortfolioProject2026..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
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

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject2026..CovidDeaths dea
Join PortfolioProject2026..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject2026..CovidDeaths dea
Join PortfolioProject2026..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
