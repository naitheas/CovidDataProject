SELECT iso_code, location
FROM CovidProject..CovidDeathsData
ORDER BY 1,2;

--Query Total Cases VS Total Deaths to determine percentage of cases resulting in death
--Shows possible risk of death by contracting covid by percentage
SELECT iso_code, location, date, total_cases, total_deaths,ROUND(total_deaths/total_cases,4) *100 
AS DeathPercentage
FROM CovidProject..CovidDeathsData
WHERE total_deaths is not null
AND continent is not null
ORDER BY 1,2;

CREATE VIEW CasesVSDeathsPercentage AS
SELECT iso_code, location, date, total_cases, total_deaths,ROUND(total_deaths/total_cases,4) *100 
AS DeathPercentage
FROM CovidProject..CovidDeathsData
WHERE total_deaths is not null
AND continent is not null;

--Query percentage of confirmed cases of covid by population
SELECT location, date, total_cases, population, ROUND(total_cases/population,4)*100
AS ConfirmedPercentage
FROM CovidProject..CovidDeathsData
WHERE total_cases is not null
AND continent is not null
ORDER BY 1,2;

CREATE VIEW ConfirmedCasesByPopulation AS
SELECT location, date, total_cases, population, ROUND(total_cases/population,4)*100
AS ConfirmedPercentage
FROM CovidProject..CovidDeathsData
WHERE total_cases is not null
AND continent is not null;

--Query by locations with highest infection rate to population
SELECT location, population,MAX(total_cases) 
AS PeakInfectionCount, 
ROUND(MAX(total_cases/population),4)*100
AS InfectionRate
FROM CovidProject..CovidDeathsData
WHERE total_cases is not null
AND continent is not null
GROUP BY location, population
ORDER BY InfectionRate DESC;

CREATE VIEW PopulationInfectionRate AS
SELECT location, population,MAX(total_cases) 
AS PeakInfectionCount, 
ROUND(MAX(total_cases/population),4)*100
AS InfectionRate
FROM CovidProject..CovidDeathsData
WHERE total_cases is not null
AND continent is not null
GROUP BY location, population;


--Query by locations with highest death count
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

--Query by continent with highest death count per population
SELECT continent, MAX(total_deaths)
AS TotalDeathCount
FROM CovidProject..CovidDeathsData
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;

CREATE VIEW HighestDeathCounts AS
SELECT continent, MAX(total_deaths)
AS TotalDeathCount
FROM CovidProject..CovidDeathsData
WHERE continent is not null
GROUP BY continent;

--Query total deaths by locations
SELECT iso_code, location, SUM(total_deaths)
AS TotalDeaths
FROM CovidProject..CovidDeathsData
WHERE total_deaths is not null
AND continent is not null
GROUP BY iso_code,location
ORDER BY 3 DESC;

CREATE VIEW TotalDeathsByLocation AS
SELECT iso_code, location, SUM(total_deaths)
AS TotalDeaths
FROM CovidProject..CovidDeathsData
WHERE total_deaths is not null
AND continent is not null
GROUP BY iso_code,location;

--Query rate of new deaths to new cases globally by iso_codes
SELECT date, iso_code, SUM(new_cases) 
AS total_new_cases, 
SUM(new_deaths) 
AS total_new_deaths, 
ROUND(SUM(new_deaths)/SUM(new_cases),5) * 100
AS DeathPercentage
FROM CovidProject..CovidDeathsData
WHERE new_cases > 0 AND new_deaths > 0
GROUP BY date, iso_code
ORDER BY 1,2;

CREATE VIEW GlobalNewDeathsByISO AS
SELECT date, iso_code, SUM(new_cases) 
AS total_new_cases, 
SUM(new_deaths) 
AS total_new_deaths, 
ROUND(SUM(new_deaths)/SUM(new_cases),5) * 100
AS DeathPercentage
FROM CovidProject..CovidDeathsData
WHERE new_cases > 0 AND new_deaths > 0
GROUP BY date, iso_code;

--Query rate of new deaths to new cases global total
SELECT SUM(new_cases) 
AS total_new_cases, 
SUM(new_deaths) 
AS total_new_deaths, 
ROUND(SUM(new_deaths)/SUM(new_cases),5) * 100
AS DeathPercentage
FROM CovidProject..CovidDeathsData
WHERE new_cases > 0 AND new_deaths > 0;

CREATE VIEW GlobalNewDeaths AS
SELECT SUM(new_cases) 
AS total_new_cases, 
SUM(new_deaths) 
AS total_new_deaths, 
ROUND(SUM(new_deaths)/SUM(new_cases),5) * 100
AS DeathPercentage
FROM CovidProject..CovidDeathsData
WHERE new_cases > 0 AND new_deaths > 0;


--Base Join table query
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations
FROM CovidProject..CovidDeathsData deaths
JOIN CovidProject..CovidVaccinationsData vacc
	ON deaths.location = vacc.location
	AND deaths.iso_code = vacc.iso_code
	AND deaths.date = vacc.date
WHERE vacc.new_vaccinations is not null AND deaths.continent is not null
ORDER BY 1,2,3;

--Query global population versus new vaccinations administered daily
With GlobalPopulationNewVaccs (Date, Location, Population, New_Vaccinations, Vaccination_Count)
AS
(SELECT deaths.date, deaths.location, deaths.population,vacc.new_vaccinations,
SUM(CONVERT(BIGINT,vacc.new_vaccinations))
OVER (PARTITION BY deaths.location ORDER BY deaths.location,deaths.date) AS vaccination_count
FROM CovidProject..CovidDeathsData deaths
JOIN CovidProject..CovidVaccinationsData vacc
	ON deaths.location = vacc.location
	AND deaths.date = vacc.date
)
SELECT *, ROUND((Vaccination_Count/Population),4)*100 
AS VaccinationPercentage
FROM GlobalPopulationNewVaccs;

CREATE VIEW GlobalPopulationNewVaccs AS
SELECT deaths.date, deaths.location, deaths.population,vacc.new_vaccinations,
SUM(CONVERT(BIGINT,vacc.new_vaccinations))
OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS vaccination_count
FROM CovidProject..CovidDeathsData deaths
JOIN CovidProject..CovidVaccinationsData vacc
	ON deaths.location = vacc.location
	AND deaths.date = vacc.date


--Query global population vaccinated
With GlobalPopulationVaccs (Date, Location, Population, Total_Vaccinations, Vaccination_Count)
AS
(SELECT deaths.date, deaths.location, deaths.population,vacc.total_vaccinations,
SUM(CONVERT(BIGINT,vacc.total_vaccinations))
OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS vaccination_count
FROM CovidProject..CovidDeathsData deaths
JOIN CovidProject..CovidVaccinationsData vacc
	ON deaths.location = vacc.location
	AND deaths.date = vacc.date
)
SELECT *, ROUND((Vaccination_Count/Population),4)*100 
AS VaccinationPercentage
FROM GlobalPopulationVaccs;


CREATE VIEW GlobalPopulationVaccs AS
SELECT deaths.date, deaths.continent, deaths.location, deaths.population,vacc.total_vaccinations,
SUM(CONVERT(BIGINT,vacc.total_vaccinations))
OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS vaccination_count
FROM CovidProject..CovidDeathsData deaths
JOIN CovidProject..CovidVaccinationsData vacc
	ON deaths.location = vacc.location
	AND deaths.date = vacc.date
WHERE deaths.continent is not null
