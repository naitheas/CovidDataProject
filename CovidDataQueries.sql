--Standardize Date Format for aggregation
ALTER TABLE CovidProject..CovidDeathsData
Add ConvertedDate Date;

UPDATE CovidProject..CovidDeathsData
SET ConvertedDate = CONVERT(DATE,date);

SELECT * FROM CovidProject..CovidDeathsData;

ALTER TABLE CovidProject..CovidVaccinationsData
Add ConvertedDate Date;

UPDATE CovidProject..CovidVaccinationsData
SET ConvertedDate = CONVERT(DATE,date);



--Query Total Cases VS Total Deaths to determine percentage of cases resulting in death
--Shows possible risk of death by contracting covid by percentage
SELECT SUM(total_cases) AS Total_Cases, SUM(total_deaths) AS Total_Deaths, SUM(total_deaths)/SUM(total_cases) * 100 
AS DeathPercentage
FROM CovidProject..CovidDeathsData
WHERE total_deaths is not null
AND continent is not null;


CREATE VIEW CasesVSDeathsPercentage AS
SELECT SUM(total_cases) AS Total_Cases, SUM(total_deaths) AS Total_Deaths, SUM(total_deaths)/SUM(total_cases) * 100 
AS DeathPercentage
FROM CovidProject..CovidDeathsData
WHERE total_deaths is not null
AND continent is not null;

--Query percentage of confirmed cases of covid by population
SELECT location, MAX(total_cases) AS confirmed_cases, population, MAX(total_cases/population) *100
AS ConfirmedPercentage, ConvertedDate
FROM CovidProject..CovidDeathsData
WHERE total_cases is not null
AND continent is not null
GROUP BY location, population, ConvertedDate;


CREATE VIEW ConfirmedCasesByPopulation AS
SELECT location, MAX(total_cases) AS confirmed_cases, population, MAX(total_cases/population) *100
AS ConfirmedPercentage, ConvertedDate
FROM CovidProject..CovidDeathsData
WHERE total_cases is not null
AND continent is not null
GROUP BY location, population, ConvertedDate;

--Query by locations with highest infection rate to population
SELECT location, population,MAX(total_cases) 
AS PeakInfectionCount, 
MAX(total_cases/population) *100
AS InfectionRate
FROM CovidProject..CovidDeathsData
WHERE total_cases is not null
AND continent is not null
GROUP BY location, population
ORDER BY InfectionRate DESC;

CREATE VIEW PopulationInfectionRate AS
SELECT location, population,MAX(total_cases) 
AS PeakInfectionCount, 
MAX(total_cases/population) *100
AS InfectionRate
FROM CovidProject..CovidDeathsData
WHERE total_cases is not null
AND continent is not null
GROUP BY location, population;


--Query by locations with highest death count per population
SELECT location, MAX(total_deaths)
AS TotalDeathCount
FROM CovidProject..CovidDeathsData
WHERE total_deaths is not null
AND continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC;

CREATE VIEW HighestDeathByLocation AS
SELECT location, MAX(total_deaths)
AS TotalDeathCount
FROM CovidProject..CovidDeathsData
WHERE total_deaths is not null
AND continent is not null
GROUP BY location;

--Query by continent with highest total death count per population
SELECT continent, MAX(total_deaths)
AS HighestDeathCount
FROM CovidProject..CovidDeathsData
WHERE continent is not null
GROUP BY continent
ORDER BY HighestDeathCount DESC;


CREATE VIEW HighestDeathCountByContinent AS
SELECT continent, MAX(total_deaths)
AS HighestDeathCount
FROM CovidProject..CovidDeathsData
WHERE continent is not null
GROUP BY continent;

--Query total deaths by continent
SELECT continent, SUM(total_deaths) AS TotalDeathCount
FROM CovidProject..CovidDeathsData
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;

CREATE VIEW TotalDeathCountByContinent AS
SELECT continent, SUM(total_deaths) AS TotalDeathCount
FROM CovidProject..CovidDeathsData
WHERE continent is not null
GROUP BY continent;



--Query total deaths by locations
SELECT location, SUM(total_deaths)
AS TotalDeaths
FROM CovidProject..CovidDeathsData
WHERE total_deaths is not null
AND continent is not null
GROUP BY location
ORDER BY 2 DESC;


CREATE VIEW TotalDeathsByLocation AS
SELECT location, SUM(total_deaths)
AS TotalDeaths
FROM CovidProject..CovidDeathsData
WHERE total_deaths is not null
AND continent is not null
GROUP BY location;

--Query rate of new deaths to new cases globally by continent
SELECT continent, SUM(new_cases) 
AS total_new_cases, 
SUM(new_deaths) 
AS total_new_deaths, 
SUM(new_deaths)/SUM(new_cases) * 100
AS DeathPercentage
FROM CovidProject..CovidDeathsData
WHERE new_cases > 0 AND new_deaths > 0
AND continent is not null
GROUP BY continent
ORDER BY 2,1;

CREATE VIEW GlobalNewDeathsByContinent AS
SELECT continent, SUM(new_cases) 
AS total_new_cases, 
SUM(new_deaths) 
AS total_new_deaths, 
SUM(new_deaths)/SUM(new_cases) * 100
AS DeathPercentage
FROM CovidProject..CovidDeathsData
WHERE new_cases > 0 AND new_deaths > 0
AND continent is not null
GROUP BY continent;;

--Query rate of new deaths to new cases global total
SELECT SUM(new_cases) 
AS total_cases, 
SUM(new_deaths) 
AS total_deaths, 
SUM(new_deaths)/SUM(new_cases) * 100
AS DeathPercentage
FROM CovidProject..CovidDeathsData
WHERE new_cases > 0 AND new_deaths > 0;

CREATE VIEW GlobalDeathPercentage AS
SELECT SUM(new_cases) 
AS total_cases, 
SUM(new_deaths) 
AS total_deaths, 
SUM(new_deaths)/SUM(new_cases) * 100
AS DeathPercentage
FROM CovidProject..CovidDeathsData
WHERE new_cases > 0 AND new_deaths > 0;


--Base Join table query
SELECT deaths.continent, deaths.location, deaths.ConvertedDate, deaths.population, vacc.new_vaccinations
FROM CovidProject..CovidDeathsData deaths
JOIN CovidProject..CovidVaccinationsData vacc
	ON deaths.location = vacc.location
	AND deaths.ConvertedDate = vacc.ConvertedDate
WHERE vacc.new_vaccinations is not null AND deaths.continent is not null
ORDER BY 1,2,3;

--Query global population versus new vaccinations administered daily
With GlobalPopulationVaccs (Date, Location, Population, Vaccination_Count)
AS
(SELECT deaths.ConvertedDate, deaths.location, deaths.population,MAX(vacc.total_vaccinations)
OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.ConvertedDate) AS Vaccination_Count
FROM CovidProject..CovidDeathsData deaths
JOIN CovidProject..CovidVaccinationsData vacc
	ON deaths.location = vacc.location
	AND deaths.ConvertedDate = vacc.ConvertedDate
)
SELECT *, (Vaccination_Count/Population)*100 
AS VaccinationPercentage
FROM GlobalPopulationVaccs
WHERE Vaccination_Count is not null;


CREATE VIEW GlobalPopulationVaccs AS
(SELECT deaths.ConvertedDate, deaths.location, deaths.population,MAX(vacc.total_vaccinations)
OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.ConvertedDate) AS Vaccination_Count
FROM CovidProject..CovidDeathsData deaths
JOIN CovidProject..CovidVaccinationsData vacc
	ON deaths.location = vacc.location
	AND deaths.ConvertedDate = vacc.ConvertedDate
)
SELECT *, (Vaccination_Count/Population)*100 
AS VaccinationPercentage
FROM GlobalPopulationVaccs
WHERE Vaccination_Count is not null;


--Temp table query to determine rolling count percentage of all vaccinations to population
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date date,
Population numeric,
New_vaccinations numeric,
RollingCountVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT deaths.continent, deaths.location, deaths.ConvertedDate, deaths.population, vacc.new_vaccinations, 
SUM(CAST(vacc.new_vaccinations AS BIGINT)) OVER (PARTITION BY deaths.Location ORDER BY deaths.location, deaths.ConvertedDate) 
AS RollingCountVaccinated
FROM CovidProject..CovidDeathsData deaths
JOIN CovidProject..CovidVaccinationsData vacc
	ON deaths.location = vacc.location
	AND deaths.ConvertedDate = vacc.ConvertedDate
WHERE deaths.continent is not null 

SELECT *, (RollingCountVaccinated/Population)*100
AS RollingVaccinationPercentage
FROM #PercentPopulationVaccinated

CREATE VIEW PercentagePopulationVaccinated AS
SELECT deaths.continent, deaths.location, deaths.ConvertedDate, deaths.population, vacc.new_vaccinations, 
SUM(CONVERT(BIGINT,vacc.new_vaccinations)) OVER (PARTITION BY deaths.Location ORDER BY deaths.location, deaths.ConvertedDate) 
AS RollingCountVaccinated
FROM CovidProject..CovidDeathsData deaths
Join CovidProject..CovidVaccinationsData vacc
	ON deaths.location = vacc.location
	and deaths.ConvertedDate = vacc.ConvertedDate
WHERE deaths.continent is not null 