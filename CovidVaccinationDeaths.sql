SELECT *
FROM CovidDeaths
WHERE continent is not NULL
order by 3,4

--Select Data that we are going  to USING
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths * 100.0 / total_cases)  as DeathPercentage
FROM CovidDeaths
WHERE location like '%states%'
order by 1,2


--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
SELECT location, date, population, total_cases, (total_cases * 100.0 / population) as PercentPopulationInfected
FROM CovidDeaths
WHERE location like '%states%'
order by 1,2


--Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases * 100.0 / population)) as PercentPopulationInfected
FROM CovidDeaths
WHERE continent is not NULL
Group by location, population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not NULL
Group by location
order by TotalDeathCount desc

--LET'S BREAK IT DOWN BY CONTINENTS

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is  NULL
Group by location
order by TotalDeathCount desc
--this is the correct way to show deaths in every continent

--Showing the continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not NULL
Group by continent
order by TotalDeathCount desc
--North America data doesn't include other countries that isn't USA


--Global numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100.0  as DeathPercentage 
FROM CovidDeaths
WHERE continent is not NULL
--GROUP by date
order by 1,2


--Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS INTEGER)) OVER (Partition by dea.location ORDER by dea.location,
dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
Join CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not NULL
ORDER by 2,3 


--USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated
)
AS
(
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,

        SUM(CAST(vac.new_vaccinations AS INTEGER))
            OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated

    FROM CovidDeaths dea

    JOIN CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date

    WHERE dea.continent IS NOT NULL
)

SELECT *, (RollingPeopleVaccinated * 100.0 / population)
FROM PopvsVac;


-- TEMP TABLE

DROP TABLE IF EXISTS PercentPopulationVaccinated;

CREATE TABLE PercentPopulationVaccinated
(
    continent TEXT,
    location TEXT,
    date TEXT,
    population NUMERIC,
    new_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

INSERT INTO PercentPopulationVaccinated

SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,

    SUM(CAST(vac.new_vaccinations AS INTEGER))
        OVER (
            PARTITION BY dea.location
            ORDER BY dea.date
        ) AS RollingPeopleVaccinated

FROM CovidDeaths dea

JOIN CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date

WHERE dea.continent IS NOT NULL;

SELECT *,
    (RollingPeopleVaccinated * 100.0 / population)
        AS PercentVaccinated
FROM PercentPopulationVaccinated


 --Create view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,  SUM(CAST(vac.new_vaccinations AS INTEGER))
        OVER (
            PARTITION BY dea.location
            ORDER BY dea.date
        ) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is NOT NULL;

SELECT * FROM PercentPopulationVaccinated