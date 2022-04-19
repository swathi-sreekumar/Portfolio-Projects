-- Covid 19 data of India and her neighbours
SELECT * from coviddeaths
SELECT * from covidvaccinations
-- Total cases vs total deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage from coviddeaths
where location like 'India'
order by location

-- Total cases vs population
SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected from coviddeaths
where location like 'India'
order by location

-- Countries with Highest Infection Rate compared to population
SELECT location, population, max(total_cases) as HighestInfectionCount, (max(total_cases)/population)*100 as PercentPopulationInfected from coviddeaths
group by location
order by PercentPopulationInfected desc

-- Country with Highest Death Count per population
SELECT location, max(total_deaths) as TotalDeathCount, (max(total_deaths)/population)*100 as PercentPopulationDeceased from coviddeaths 
group by location
order by PercentPopulationDeceased desc

-- Overall Numbers
Select sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage from coviddeaths
order by TotalCases, TotalDeaths

-- Total Populations vs Vaccinations
-- Shows Percentage of Population that has received at least one Covid Vaccine
SELECT d.location, d.date, d.population, v.new_vaccinations, sum(v.new_vaccinations) over (partition by d.location order by d.location) as RollingPeopleVaccinated

from coviddeaths d INNER JOIN covidvaccinations v
                on d.location = v.location
				and d.date = v.date
order by d.location

-- Using CTE to perform Calculations on Partition By in previous query
With PopulationvsVaccinated (Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
SELECT d.location, d.date, d.population, v.new_vaccinations
, sum(v.new_vaccinations) over (partition by d.location order by d.location) as RollingPeopleVaccinated
from coviddeaths d INNER JOIN covidvaccinations v
                on d.location = v.location
                and d.date = v.date
)
SELECT *, (RollingPeopleVaccinated/Population)*100
from PopulationvsVaccinated                

-- Using Temp Table to perform Calculation on Partition By in previous query
Create table PercentPopulationVaccinated
(
Location varchar(255),
Date_ date,
Population int,
New_vaccinations int,
RollingPeopleVaccinated int
)
AS
SELECT d.location, d.date, d.population, v.new_vaccinations
, sum(v.new_vaccinations) over (partition by d.location order by d.location) as RollingPeopleVaccinated
from coviddeaths d INNER JOIN covidvaccinations v
                 on d.location = v.location
                 and d.date = v.date
order by d.location

SELECT *, (RollingPeopleVaccinated/Population)*100
from PercentPopulationVaccinated   

-- Creating View to store data for later visualization
CREATE VIEW PercentPopulationVaccinated as 
SELECT d.location, d.date, d.population, v.new_vaccinations
, sum(v.new_vaccinations) over (partition by d.location order by d.location) as RollingPeoplevaccinated
from coviddeaths d INNER JOIN covidvaccinations v
                on d.location = v.location
                and d.date = v.date
                